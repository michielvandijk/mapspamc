#'========================================================================================
#' Project:  mapspamc
#' Subject:  Code to align GAEZ input maps
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map", "grid"), param)


# CLIP GAEZ ------------------------------------------------------------------------------
# Function to clip gaez
clip_gaez <- function(file_name, folder, method = "bilinear"){
  id <- gsub(".tif$", "", basename(file_name))
  cat("\n", id)
  temp_path <- file.path(param$model_path, glue("processed_data/maps/{folder}/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)
  output <- align_raster(file_name, grid, adm_map, method = method)
  writeRaster(output, file.path(temp_path,
                      glue("{id}_{param$res}_{param$year}_{param$iso3c}.tif")), overwrite = TRUE)
}

# Clip potential yield files
gaez_files_py <- list.files(file.path(param$db_path, glue("gaez/potential_yield")),
                            pattern = glob2rx("*.tif"),
                            full.names = TRUE)
walk(gaez_files_py, clip_gaez, "potential_yield", method = "bilinear")


# Clip biophysical suitability files
gaez_files_bs <- list.files(file.path(param$db_path, glue("gaez/biophysical_suitability")),
                            pattern = glob2rx("*.tif"),
                            full.names = TRUE)
walk(gaez_files_bs, clip_gaez, "biophysical_suitability", method = "bilinear")


# CLEAN UP ------------------------------------------------------------------------------
rm(clip_gaez, gaez_files_py, gaez_files_bs, adm_map, grid)
