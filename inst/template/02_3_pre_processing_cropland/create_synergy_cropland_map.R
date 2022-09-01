#'========================================================================================================================================
#' Project:  mapspamc
#' Subject:  Code to create synergy cropland map
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map", "grid"), param)

# cropland from different sources
esri <- rast(file.path(param$model_path,
                       glue("processed_data/maps/cropland/{param$res}/cropland_esri_{param$res}_{param$year}_{param$iso3c}.tif")))
glad <- rast(file.path(param$model_path,
                       glue("processed_data/maps/cropland/{param$res}/cropland_glad_{param$res}_{param$year}_{param$iso3c}.tif")))
esacci <- rast(file.path(param$model_path,
                         glue("processed_data/maps/cropland/{param$res}/cropland_esacci_{param$res}_{param$year}_{param$iso3c}.tif")))
copernicus <- rast(file.path(param$model_path,
                             glue("processed_data/maps/cropland/{param$res}/cropland_copernicus_{param$res}_{param$year}_{param$iso3c}.tif")))

# Rank table
st_raw <- read_excel(file.path(param$db_path,
                               glue("synergy_cropland_rank_table/synergy_cropland_rank_table_{param$year}.xlsx")),
                     sheet = "table")


# PROCESS --------------------------------------------------------------------------------
# Combine rasters
cl_df <- c(esacci, esri, glad, copernicus)
cl_df <- as.data.frame(cl_df, xy=TRUE)

# Add grid_id, put in long format, calculate area and remove zeros
cl_df <- cl_df %>%
  mutate(grid_id = rownames(.)) %>%
  pivot_longer(-c(grid_id, x, y), names_to = "source", values_to = "area") %>%
  filter(area != 0)
summary(cl_df)

# Create combined codes in rank table
st <- st_raw %>%
  pivot_longer(-c(agreement, rank), names_to = "source", values_to = "code_digit") %>%
  mutate(code = ifelse(code_digit == 1, source, 0)) %>%
  group_by(agreement, rank) %>%
  summarize(code = paste0(code, collapse = "-"),
            .groups = "drop")
n_distinct(st$code)
table(st$code)


# CREATE SYNERGY MAP ---------------------------------------------------------------------
# Code combinations.
# Note that the order of the maps in factor should match with the order in the scoring table
# Also note that we use older dplyr command spread and gather as they tend to preserve the factor order,
# which is not the case for pivot_wider and pivot_longer.
cl_code <- cl_df %>%
  mutate(code = source,
         source = factor(source, levels = c("esri", "glad", "copernicus", "esacci"))) %>%
  dplyr::select(-area) %>%
  spread(source, code, fill = "0") %>%
  gather(source, code, -c(grid_id, x, y)) %>%
  group_by(grid_id, x, y) %>%
  summarize(code = paste0(code, collapse = "-"),
            .groups = "drop") %>%
  left_join(st)
summary(cl_code)
table(cl_code$rank)

# Calculate mean and max area per grid cell and combine
cl_area <-  cl_df %>%
  group_by(grid_id) %>%
  summarize(mean = mean(area, na.rm = T),
            max = max(area, na.rm = T),
            .groups = "drop")
summary(cl_area)

# combine
cl_syn_df <- left_join(cl_code, cl_area) %>%
  filter(!is.na(mean))
summary(cl_syn_df)


# CREATE RASTER FILES --------------------------------------------------------------------
# Calculate grid size to estimate cropland in ha
r_area <- cellSize(grid, unit = "ha")

# synergy cropland
cl <- rast(cl_syn_df[c("x","y", "mean")], type = "xyz", crs = "EPSG:4326")
cl <- extend(cl, grid)
cl <- cl*r_area
names(cl) <- "cl_mean"
plot(cl)

# synergy cropland max
cl_max <- rast(cl_syn_df[c("x","y", "max")], type = "xyz", crs = "EPSG:4326")
cl_max <- extend(cl_max, grid)
cl_max <- cl_max*r_area
names(cl) <- "cl_max"
plot(cl_max)

# synergy cropland rank
cl_rank <- rast(cl_syn_df[c("x","y", "rank")], type = "xyz", crs = "EPSG:4326")
cl_rank <- extend(cl_rank, grid)
names(cl_rank) <- "cl_rank"
plot(cl_rank)


# SAVE -----------------------------------------------------------------------------------
writeRaster(cl, file.path(param$model_path,
                          glue("processed_data/maps/cropland/{param$res}/cl_mean_{param$res}_{param$year}_{param$iso3c}.tif")),
            overwrite = TRUE)

writeRaster(cl_max, file.path(param$model_path,
                              glue("processed_data/maps/cropland/{param$res}/cl_max_{param$res}_{param$year}_{param$iso3c}.tif")),
            overwrite = TRUE)

writeRaster(cl_rank, file.path(param$model_path,
                               glue("processed_data/maps/cropland/{param$res}/cl_rank_{param$res}_{param$year}_{param$iso3c}.tif")),
            overwrite = TRUE)

# CLEAN UP -------------------------------------------------------------------------------
rm(adm_map, cl, cl_area, cl_code, cl_df, cl_max, cl_rank, cl_syn_df,
   copernicus, esacci, esri, glad, grid, r_area, st, st_raw)

