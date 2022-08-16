#'========================================================================================
#' Project:  MAPSPAMC
#' Subject:  Code to process population maps
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("scripts/01_model_setup/01_model_setup.r"))


# PROCESS --------------------------------------------------------------------------------
# WorldPop presents population density per #grid cell (in this case 30 arcsec,
# the resolution of the map).
# In order to use the map at higher resolutions (e.g. 5 arcmin) we need to resample using
# the average option and multiple by 100, the number of 30sec grid cells in 5 arcmin.

# NOTE: the WorldPop input file is conditional on the year. So make sure you
# download the map for the year set in param!

grid <- file.path(param$spam_path,
                  glue("processed_data/maps/grid/{param$res}/grid_{param$res}_{param$year}_{param$iso3c}.tif"))
mask <- file.path(param$spam_path,
                  glue("processed_data/maps/adm/{param$res}/adm_map_{param$year}_{param$iso3c}.shp"))
input <- file.path(param$raw_path, glue("worldpop/ppp_{param$year}_1km_Aggregated.tif"))
output <- file.path(param$spam_path,
                    glue("processed_data/maps/population/{param$res}/pop_{param$res}_{param$year}_{param$iso3c}.tif"))

if(param$res == "30sec") {

  temp_path <- file.path(param$spam_path, glue("processed_data/maps/population/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  # Warp and mask
  output_map <- align_rasters_fix(unaligned = input, reference = grid, dstfile = output,
                   cutline = mask, crop_to_cutline = F,
                   r = "bilinear", overwrite = T)
  plot(output_map)
}

if(param$res == "5min") {

  temp_path <- file.path(param$spam_path, glue("processed_data/maps/population/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  # Warp and mask
  worldpop_temp <- align_rasters_fix(unaligned = input, reference = grid, dstfile = output,
                              cutline = mask, crop_to_cutline = F,
                              r = "average", overwrite = T)

  # Multiple average population with 100
  worldpop_temp <- worldpop_temp*100
  plot(worldpop_temp)

  # Overwrite
  writeRaster(worldpop_temp, file.path(param$spam_path,
    glue("processed_data/maps/population/{param$res}/pop_{param$res}_{param$year}_{param$iso3c}.tif")),
    overwrite = T)
}


# CLEAN UP -------------------------------------------------------------------------------
rm(grid, input, mask, output, temp_path, worldpop_temp)

