#'========================================================================================================================================
#' Project:  mapspamc
#' Subject:  Code to process GMIA
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map", "grid"), param)


# PROCESS --------------------------------------------------------------------------------
# GMIA presents the share of irrigated area with a resolution of 5 arcmin.

if(param$res == "5min") {
  temp_path <- file.path(param$model_path, glue("processed_data/maps/irrigated_area/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  # Warp and mask
  # use r = "near as we warp 5 arcmin to 5 arcmin.
  input <- file.path(param$db_path, glue("gmia/gmia.tif"))
  output <- align_raster(input, grid, adm_map, method = "near")
  names(output) <- "gmia"
  plot(output)

  # save
  writeRaster(output, file.path(param$model_path,
                                   glue("processed_data/maps/irrigated_area/{param$res}/gmia_{param$res}_{param$year}_{param$iso3c}.tif")),
  overwrite = T)
  }

if(param$res == "30sec") {

  temp_path <- file.path(param$model_path, glue("processed_data/maps/irrigated_area/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  # Warp and mask
  # use r = "bilinear as we warp 5 arcmin to 30 arcsec.
  input <- file.path(param$db_path, glue("gmia/gmia.tif"))
  output <- align_raster(input, grid, adm_map, method = "bilinear")
  names(output) <- "gmia"
  plot(output)

  # save
  writeRaster(output, file.path(param$model_path,
                                glue("processed_data/maps/irrigated_area/{param$res}/gmia_{param$res}_{param$year}_{param$iso3c}.tif"))
              ,
              overwrite = T)
}


# CLEAN UP ------------------------------------------------------------------------------
rm(grid, input, output, adm_map, temp_path)

