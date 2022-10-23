#'========================================================================================
#' Project:  mapspamc
#' Subject:  Code process SASAM global synergy cropland map
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map", "grid"), param)
temp_path <- file.path(param$model_path, glue("processed_data/maps/cropland/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)


# PROCESS MEAN ---------------------------------------------------------------------------
# Warp and mask
input <- file.path(param$db_path,  glue("sasam/cl_mean.tif"))
output <- align_raster(input, grid, adm_map, method = "bilinear")

# Maps are in shares of area. We multiply by grid size to create an area map.
r_area <- cellSize(grid, unit = "ha")
output <- output * r_area
plot(output)
writeRaster(output, file.path(temp_path,
                              glue("cl_mean_{param$res}_{param$year}_{param$iso3c}.tif")),
            overwrite = T)

# clean up
rm(input, output, r_area)


# PROCESS MAX ---------------------------------------------------------------------------
# Warp and mask
input <- file.path(param$db_path,  glue("sasam/cl_max.tif"))
output <- align_raster(input, grid, adm_map, method = "bilinear")

# Maps are in shares of area. We multiply by grid size to create an area map.
r_area <- cellSize(grid, unit = "ha")
output <- output * r_area
plot(output)
writeRaster(output, file.path(temp_path,
                              glue("cl_max_{param$res}_{param$year}_{param$iso3c}.tif")),
            overwrite = T)

# clean up
rm(input, output, r_area)


# PROCESS RANK ---------------------------------------------------------------------------
# Warp and mask
# Use r = "mode" to select the probability that occurs most often as probability is a categorical variable (1-32)
input <- file.path(param$db_path,  glue("sasam/cl_rank.tif"))
output <- align_raster(input, grid, adm_map, method = "mode")

# Maps are in shares of area. We multiply by grid size to create an area map.
plot(output)
writeRaster(output, file.path(temp_path,
                              glue("cl_rank_{param$res}_{param$year}_{param$iso3c}.tif")),
            overwrite = T)

# clean up
rm(input, output)


# CLEAN UP -------------------------------------------------------------------------------
rm(grid, adm_map, temp_path)




