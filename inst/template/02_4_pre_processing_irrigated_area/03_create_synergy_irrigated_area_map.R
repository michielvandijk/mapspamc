#'========================================================================================================================================
#' Project:  MAPSPAMC
#' Subject:  Code to prepare synergy irrigated map
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================================================================


# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("scripts/01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
# Load data
load_data(c("adm_map", "grid", "gmia", "gia"), param)


# PREPARE --------------------------------------------------------------------------------
# Create grid area
grid_size <- area(grid)
grid_size <- grid_size * 100 # in ha
names(grid_size) <- "grid_size"

# Grid df
grid_df <- as.data.frame(rasterToPoints(grid))

# Create id_df, combining gia and gmia. Remove values < 0.01, most of which are
# probably caused by reprojecting the maps
ir_df <-   as.data.frame(rasterToPoints(stack(grid, grid_size, gmia, gia))) %>%
  filter(!is.na(gridID)) %>%
  dplyr::select(-x, -y) %>%
  mutate(gia = ifelse(gia < 0.01, 0, gia),
         gmia = ifelse(gmia < 0.01, 0, gmia))

# Create ranking by first taking the maximum of the irrigated area share,
# calculate irrigated area, and then rank. In this way we prefer the largest
# area, and hence prefer GIA over GMIA when the resolution is 30 arcsec (GIA is
# 1 or 0). At a resolution of 5 arcmin the GMIA and grid cells with a lot of GIA
# observations get a high rank, which is also desirable.

ir_df <- ir_df %>%
  dplyr::mutate(ir_max = pmax(gmia, gia, na.rm = T),
                ir_rank = cut(ir_max, labels = c(1:10), breaks = seq(0, 1, 0.1),
                              include.lowest = T),
                ir_rank = dense_rank(desc(ir_rank)),
                ir_max = ir_max * grid_size) %>%
  filter(!is.na(ir_rank), ir_max > 0) %>%
  dplyr::select(-gmia, -gia, -grid_size)


# CREATE IR MAX AND IR RANK MAPS ---------------------------------------------------------
# ir_max
ir_max_map <- ir_df %>%
  left_join(grid_df,.) %>%
  dplyr::select(x, y, ir_max)
ir_max_map <- rasterFromXYZ(ir_max_map)
crs(ir_max_map) <- crs(param$crs)
ir_max_map <- extend(ir_max_map, grid)
plot(ir_max_map)
plot(adm_map$geometry, add = T)


# ir_rank
ir_rank_map <- ir_df %>%
  left_join(grid_df,.) %>%
  dplyr::select(x, y, ir_rank)
ir_rank_map <- rasterFromXYZ(ir_rank_map)
crs(ir_rank_map) <- crs(param$crs)
ir_rank_map <- extend(ir_rank_map, grid)
plot(ir_rank_map)
plot(adm_map$geometry, add = T)


# SAVE -----------------------------------------------------------------------------------
temp_path <- file.path(param$spam_path, glue("processed_data/maps/irrigated_area/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

writeRaster(ir_max_map, file.path(temp_path,
                                  glue::glue("ia_max_{param$res}_{param$year}_{param$iso3c}.tif")),overwrite = T)

writeRaster(ir_rank_map, file.path(temp_path,
                                  glue::glue("ia_rank_{param$res}_{param$year}_{param$iso3c}.tif")),overwrite = T)

# CLEAN UP -------------------------------------------------------------------------------
rm(adm_map, gia, gmia, grid, grid_df, grid_size, ir_df, ir_max_map, ir_rank_map, temp_path)
