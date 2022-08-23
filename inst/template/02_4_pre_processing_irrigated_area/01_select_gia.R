#'========================================================================================
#' Project:  mapspamc
#' Subject:  Code to process GIA
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map", "grid"), param)


# PROCESS --------------------------------------------------------------------------------

if(param$res == "30sec") {
  temp_path <- file.path(param$model_path, glue("processed_data/maps/irrigated_area/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  input <- file.path(param$db_path, glue("gia/gia.tif"))
  output <- align_raster(input, grid, adm_map, method = "near")
  names(output) <- "gia"
  plot(output)

  writeRaster(output, file.path(param$model_path,
    glue("processed_data/maps/irrigated_area/{param$res}/gia_{param$res}_{param$year}_{param$iso3c}.tif")),
    overwrite = T)
}

if(param$res == "5min"){
  # Gia assumes full 30sec (the resolution of the map) are irrigated and uses a categorical
  # variable (1) to indicate irrigated areas (see README.txt).
  # In order to use the map at lower resolutions (e.g. 5 arcmin) we need to use method = "average" to
  # calculate the share of irrigated area.

  temp_path <- file.path(param$model_path, glue("processed_data/maps/irrigated_area/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  input <- file.path(param$db_path, glue("gia/gia.tif"))
  output <- align_raster(input, grid, adm_map, method = "average")
  names(output) <- "gia"
  plot(output)

  writeRaster(output, file.path(param$model_path,
                                glue("processed_data/maps/irrigated_area/{param$res}/gia_{param$res}_{param$year}_{param$iso3c}.tif")),
              overwrite = T)
}


# CLEAN UP ------------------------------------------------------------------------------
rm(input, output, grid, adm_map, temp_path)
