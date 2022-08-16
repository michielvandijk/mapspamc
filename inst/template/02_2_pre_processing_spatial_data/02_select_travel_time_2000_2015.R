#'========================================================================================
#'#' Project:  MAPSPAMC
#' Subject:  Code to process travel time maps
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("scripts/01_model_setup/01_model_setup.r"))


# PROCESS --------------------------------------------------------------------------------
temp_path <- file.path(param$spam_path, glue("processed_data/maps/accessibility/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

# Set files
grid <- file.path(param$spam_path,
                  glue("processed_data/maps/grid/{param$res}/grid_{param$res}_{param$year}_{param$iso3c}.tif"))
mask <- file.path(param$spam_path,
                  glue("processed_data/maps/adm/{param$res}/adm_map_{param$year}_{param$iso3c}.shp"))
output <- file.path(param$spam_path,
                    glue("processed_data/maps/accessibility/{param$res}/acc_{param$res}_{param$year}_{param$iso3c}.tif"))

# There are two products, one for around 2000 and one for around 2015, we select on the basis of reference year
if (param$year <= 2007){
  input <- file.path(param$raw_path, "travel_time_2000/acc_50.tif")
  } else {
  input <- file.path(param$raw_path, "travel_time_2015/2015_accessibility_to_cities_v1.0.tif")
}

# Warp and mask
output_map <- align_rasters_fix(unaligned = input, reference = grid, dstfile = output,
                            cutline = mask, crop_to_cutline = F, srcnodata = "-9999",
                            r = "bilinear", overwrite = T)
plot(output_map)


# CLEAN UP -------------------------------------------------------------------------------
rm(input, mask, output, grid, output_map, temp_path)
