#'========================================================================================
#' Project:  MAPSPAMC
#' Subject:  Code to process GIA
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("scripts/01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
# Raw gia file
gia_raw <- raster(file.path(param$raw_path, "gia/global_irrigated_areas.tif"))


# PROCESS --------------------------------------------------------------------------------
# The crs of the gia (WGS 84) is missing for some reason. We add and save the map
crs(gia_raw) <- "+proj=longlat +datum=WGS84 +no_defs"
if(!file.exists(file.path(param$raw_path, "gia/global_irrigated_areas_crs.tif"))){
  writeRaster(gia_raw, file.path(param$raw_path, "gia/global_irrigated_areas_crs.tif"), overwrite = T)
}

# Gia assumes full 30sec (the resolution of the map) are irrigated and uses a categorical
# variable (1-4) to indicate irrigated areas (see README.txt).
# In order to use the map at higher resolutions (e.g. 5 arcmin) we need to reclassify these into
# 1 (100%) and use gdalwarp with "average" to calculate the share of irrigated area at larger grid cells.
# If res is 30sec, we can clip the raw map and reclassify c(1:4) values to 1.

# Set files
grid <- file.path(param$spam_path,
                  glue("processed_data/maps/grid/{param$res}/grid_{param$res}_{param$year}_{param$iso3c}.tif"))
mask <- file.path(param$spam_path,
                  glue("processed_data/maps/adm/{param$res}/adm_map_{param$year}_{param$iso3c}.shp"))
input <- file.path(param$raw_path, "gia/global_irrigated_areas_crs.tif")
output <- file.path(param$spam_path,
                    glue("processed_data/maps/irrigated_area/{param$res}/gia_temp_{param$year}_{param$iso3c}.tif"))

temp_path <- file.path(param$spam_path, glue("processed_data/maps/irrigated_area/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

# Clip to adm
# Warp and mask
# Use r = "near" for categorical values.
# Use crop to cutline to crop.
# TODO probably does not work at 30sec!!
gia_temp <- align_rasters_fix(unaligned = input, reference = grid, dstfile = output,
                          cutline = mask, crop_to_cutline = F,
                          r = "near", overwrite = T)

# Reclassify
gia_temp <- reclassify(gia_temp, cbind(1, 4, 1))
names(gia_temp) <- "gia"
plot(gia_temp)

if(param$res == "30sec") {
  temp_path <- file.path(param$spam_path, glue("processed_data/maps/irrigated_area/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  writeRaster(gia_temp,
    file.path(param$spam_path,
    glue("processed_data/maps/irrigated_area/{param$res}/gia_{param$res}_{param$year}_{param$iso3c}.tif")),
    overwrite = T)
}

if(param$res == "5min"){
  temp_path <- file.path(param$spam_path, glue("processed_data/maps/irrigated_area/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  # Save temporary file with 1 for irrigated area
  writeRaster(gia_temp, file.path(param$spam_path,
                                  glue("processed_data/maps/irrigated_area/{param$res}/gia_temp_{param$year}_{param$iso3c}.tif")), overwrite = T)

  # Set files
  grid <- file.path(param$spam_path,
    glue("processed_data/maps/grid/{param$res}/grid_{param$res}_{param$year}_{param$iso3c}.tif"))
  mask <- file.path(param$spam_path,
    glue("processed_data/maps/adm/{param$res}/adm_map_{param$year}_{param$iso3c}.shp"))
  input <- file.path(param$spam_path,
    glue("processed_data/maps/irrigated_area/{param$res}/gia_temp_{param$year}_{param$iso3c}.tif"))
  output <- file.path(param$spam_path,
    glue("processed_data/maps/irrigated_area/{param$res}/gia_{param$res}_{param$year}_{param$iso3c}.tif"))

  # Warp and mask
  # Use average to calculate share of irrigated area
  gia_temp <- align_rasters_fix(unaligned = input, reference = grid, dstfile = output,
                cutline = mask, crop_to_cutline = F,
                r = "average", overwrite = T)
  plot(gia_temp)
}


# CLEAN UP ------------------------------------------------------------------------------
rm(gia_raw, gia_temp, input, grid, mask, output, temp_path)
