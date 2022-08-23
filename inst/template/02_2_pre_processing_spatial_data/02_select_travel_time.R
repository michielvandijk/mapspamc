#'========================================================================================
#' Project:  mapspamc
#' Subject:  Code to process travel time maps
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map", "grid"), param)


# PROCESS --------------------------------------------------------------------------------
temp_path <- file.path(param$model_path, glue("processed_data/maps/accessibility/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

# Warp and mask
input <- file.path(param$db_path, "travel_time/2015_accessibility_to_cities_v1.0.tif")
output <- align_raster(input, grid, adm_map)
plot(output)
writeRaster(output, file.path(param$model_path,
                              glue("processed_data/maps/accessibility/{param$res}/acc_{param$res}_{param$year}_{param$iso3c}.tif")),
            overwrite = TRUE)

# CLEAN UP -------------------------------------------------------------------------------
rm(input, output, grid, adm_map, temp_path)
