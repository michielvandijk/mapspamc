#'========================================================================================================================================
#' Project:  mapspamc
#' Subject:  Code to select ESRI cropland map
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map", "grid"), param)


# PROCESS --------------------------------------------------------------------------------
temp_path <- file.path(param$model_path, glue("processed_data/maps/cropland/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

# Warp and mask
input <- file.path(param$db_path, glue("esri/esri_2020.tif"))
output <- align_raster(input, grid, adm_map, method = "bilinear")
names(output) <- "esri"
plot(output)
writeRaster(output, file.path(temp_path, glue("croland_esri_{param$res}_{param$year}_{param$iso3c}.tif")),
            overwrite = TRUE)


# CLEAN UP -------------------------------------------------------------------------------
rm(input, output, grid, adm_map, temp_path)
