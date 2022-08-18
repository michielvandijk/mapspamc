#'========================================================================================================================================
#' Project:  MAPSPAMC
#' Subject:  Code to select ESACCI cropland map
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("inst/template/01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map", "grid"), param)


# PROCESS --------------------------------------------------------------------------------

temp_path <- file.path(param$mapspamc_path, glue("processed_data/maps/cropland/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

# Warp and mask
input <- file.path(param$raw_path, glue("esacci/esacci_2020.tif"))
output <- align_raster(input, grid, adm_map, method = "bilinear")
names(output) <- "esacci"
plot(output)
writeRaster(output, file.path(temp_path, glue("cropmask_esacci_{param$res}_{param$year}_{param$iso3c}.tif")),
            overwrite = TRUE)


# CLEAN UP -------------------------------------------------------------------------------
rm(input, output, grid, adm_map, temp_path)
