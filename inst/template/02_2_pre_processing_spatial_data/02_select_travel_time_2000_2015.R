#'========================================================================================
#' Project:  MAPSPAMC
#' Subject:  Code to process travel time maps
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("inst/template/01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map", "grid"), param)


# PROCESS --------------------------------------------------------------------------------
temp_path <- file.path(param$mapspamc_path, glue("processed_data/maps/accessibility/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

# There are two products, one for around 2000 and one for around 2015, we select on the basis of reference year
if (param$year <= 2007){
  input <- file.path(param$raw_path, "travel_time_2000/acc_50.tif")
  } else {
  input <- file.path(param$raw_path, "travel_time_2015/2015_accessibility_to_cities_v1.0.tif")
}

# Warp and mask
output <- align_raster(input, grid, adm_map)
plot(output)
writeRaster(output, file.path(param$mapspamc_path,
                              glue("processed_data/maps/accessibility/{param$res}/acc_{param$res}_{param$year}_{param$iso3c}.tif")),
            overwrite = TRUE)

# CLEAN UP -------------------------------------------------------------------------------
rm(input, output, grid, adm_file, temp_path)
