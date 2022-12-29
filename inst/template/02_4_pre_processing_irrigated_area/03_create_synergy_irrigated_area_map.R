#'========================================================================================================================================
#' Project:  mapspamc
#' Subject:  Code to prepare synergy irrigated map
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map", "grid", "gmia", "gia"), param)


# PREPARE --------------------------------------------------------------------------------
# Create grid area
grid_size <- cellSize(grid, unit = "ha")
names(grid_size) <- "grid_size"

# Grid df
grid_df <- as.data.frame(grid, xy = TRUE)

# Create id_df, combining gia and gmia. Remove values < 0.01, most of which are
# probably caused by reprojecting the maps
ir_df <-   as.data.frame(c(grid, grid_size, gmia, gia), xy = TRUE) %>%
  filter(!is.na(gridID)) %>%
  dplyr::select(-x, -y) %>%
  mutate(gia = ifelse(gia < 0.01, 0, gia),
         gmia = ifelse(gmia < 0.01, 0, gmia))

# Create ranking by (1) take the maximum of the GMIA and GIA irrigated area share,
# (2) add a rank from 1 (highest share) to 10 (lowest share) using equal intervals of 0.1 irrigated area share,
# (3) rank the cells from 1 to 10 and (4) calculate the irrigated area in ha.
# By ranking on irrigated area share, GIA (share is 1) is always preferred over GMIA when a resolution of 30 arc seconds
# is selected. At a resolution of 5 arc minutes GMIA and GIA grid cells with a large share of irrigated area receive
# a high rank, which is also desirable.

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
ir_max_map <- rast(ir_max_map[c("x","y", "ir_max")], type = "xyz", crs = "EPSG:4326")
ir_max_map <- extend(ir_max_map, grid)
plot(ir_max_map)
plot(adm_map$geometry, add = T)

# ir_rank
ir_rank_map <- ir_df %>%
  left_join(grid_df,.) %>%
  dplyr::select(x, y, ir_rank)
ir_rank_map <- rast(ir_rank_map[c("x","y", "ir_rank")], type = "xyz", crs = "EPSG:4326")
ir_rank_map <- extend(ir_rank_map, grid)
plot(ir_rank_map)
plot(adm_map$geometry, add = T)


# SAVE -----------------------------------------------------------------------------------
temp_path <- file.path(param$model_path, glue("processed_data/maps/irrigated_area/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

writeRaster(ir_max_map, file.path(temp_path,
                                  glue::glue("ia_max_{param$res}_{param$year}_{param$iso3c}.tif")),overwrite = T)

writeRaster(ir_rank_map, file.path(temp_path,
                                  glue::glue("ia_rank_{param$res}_{param$year}_{param$iso3c}.tif")),overwrite = T)

# CLEAN UP -------------------------------------------------------------------------------
rm(adm_map, gia, gmia, grid, grid_df, grid_size, ir_df, ir_max_map, ir_rank_map, temp_path)
