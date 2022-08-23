#'========================================================================================
#' Project:  mapspamc
#' Subject:  Code to process population maps
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map", "grid"), param)


# PROCESS --------------------------------------------------------------------------------
# WorldPop presents population density per grid cell (in this case 30 arcsec, the resolution of the map).
# In order to use the map at higher resolutions (e.g. 5 arcmin) we need to resample using
# the average option and multiply by 100, the number of 30sec grid cells in 5 arcmin.
# Note that WorldPop presents annual maps so make sure you download WorldPop map for the year set in param!

input <- file.path(param$db_path, glue("worldpop/ppp_{param$year}_1km_Aggregated.tif"))

if(param$res == "30sec") {
  temp_path <- file.path(param$model_path, glue("processed_data/maps/population/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  # Warp and mask
  output <- align_raster(input, grid, adm_map, method = "bilinear")
  plot(output)
}

if(param$res == "5min") {
  temp_path <- file.path(param$model_path, glue("processed_data/maps/population/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  # Warp and mask
  output <- align_raster(input, grid, adm_map, method = "average")

  # Multiple average population with 100
  output <- output*100
  plot(output)
}

# SAVE -----------------------------------------------------------------------------------
writeRaster(output, file.path(temp_path, glue("pop_{param$res}_{param$year}_{param$iso3c}.tif")),
            overwrite = T)

# CLEAN UP -------------------------------------------------------------------------------
rm(grid, adm_map, output, temp_path)

