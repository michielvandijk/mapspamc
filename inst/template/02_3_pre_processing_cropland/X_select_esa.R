#'========================================================================================================================================
#' Project:  mapspamc
#' Subject:  Code to select ESA land cover map per country
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================================================================

############### SOURCE PARAMETERS ###############
source(here::here("scripts/01_model_setup/01_model_setup.r"))


############### PROCESS ###############
temp_path <- file.path(param$spam_path, glue("processed_data/maps/cropland/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)


# Set files
mask <- file.path(param$spam_path,
                  glue("processed_data/maps/adm/{param$res}/adm_map_{param$year}_{param$iso3c}.shp"))
input <- file.path(param$raw_path,
                    glue("esacci/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2010-v2.0.7.tif"))
output <- file.path(param$spam_path,
                    glue("processed_data/maps/cropland/{param$res}/esa_raw_{param$year}_{param$iso3c}.tif"))

# Warp and mask
output_map <- gdalwarp(srcfile = input, dstfile = output,
                       cutline = mask, crop_to_cutline = T, srcnodata = "0",
                       r = "near", overwrite = T)

plot(raster(output_map))


############### CLEAN UP ###############
rm(input, mask, output, output_map, temp_path)
