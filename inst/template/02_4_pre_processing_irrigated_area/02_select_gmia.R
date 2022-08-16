#'========================================================================================================================================
#' Project:  MAPSPAMC
#' Subject:  Code to process GMIA
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("scripts/01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map"), param)

# Raw gmia file
gmia_raw <- raster(file.path(param$raw_path,"gmia/gmia_v5_aei_ha.asc"))


# PROCESS --------------------------------------------------------------------------------
# The crs of the gmia (WGS 84) is missing and the file is not in tif. We add and save the map
crs(gmia_raw) <- "+proj=longlat +datum=WGS84 +no_defs"
if(!file.exists(file.path(param$raw_path, "gmia/gmia_v5_aei_ha_crs.tif"))){
  writeRaster(gmia_raw, file.path(param$raw_path, "gmia/gmia_v5_aei_ha_crs.tif"),
              overwrite = T)
}

# GMIA presents the area in ha of area equiped for irrigation at 5 arcmin resolution.
# Hence, we cannot simply warp to higher resolutions (e.g. 30 arcmin).
# We calculate the share of irrigated area first and then warp.
# In case the resolution is 5 arcmin, we only clip the map to the country borders

if(param$res == "5min") {
  # Set files
  grid <- file.path(param$spam_path,
                    glue("processed_data/maps/grid/{param$res}/grid_{param$res}_{param$year}_{param$iso3c}.tif"))
  mask <- file.path(param$spam_path,
                    glue("processed_data/maps/adm/{param$res}/adm_map_{param$year}_{param$iso3c}.shp"))
  input <- file.path(param$raw_path,
                     glue("gmia/gmia_v5_aei_ha_crs.tif"))
  output <- file.path(param$spam_path,
                      glue("processed_data/maps/irrigated_area/{param$res}/gmia_temp_{param$res}_{param$year}_{param$iso3c}.tif"))

  temp_path <- file.path(param$spam_path, glue("processed_data/maps/irrigated_area/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  # Warp and mask
  # use r = "near as we warp 5 arcmin to 5 arcmin. Using r = "bilinear" might result in different grid cell values
  output_map <- align_rasters_fix(unaligned = input, reference = grid, dstfile = output,
                              cutline = mask, crop_to_cutline = F,
                              r = "near", overwrite = T)
  plot(output_map)


  # Calculate share of irrigated area
  output_map <- output_map/(area(output_map)*100)
  plot(output_map)

  # save
  writeRaster(output_map, file.path(param$spam_path,
                                   glue("processed_data/maps/irrigated_area/{param$res}/gmia_{param$res}_{param$year}_{param$iso3c}.tif"))
              ,
  overwrite = T)
  }

if(param$res == "30sec") {

  temp_path <- file.path(param$spam_path, glue("processed_data/maps/irrigated_area/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  # Crop, making sure it also includes grid cells, which center is outside the polygon
  # by adding snap = "out")
  gmia_temp <- crop(gmia_raw, adm_map, snap = "out")

  # Set 0 values to NA
  gmia_temp <- reclassify(gmia_temp, cbind(0, NA))

  # Calculate share of irrigated area
  gmia_temp <- gmia_temp/(area(gmia_temp)*100)
  plot(gmia_temp)

  # Save
  writeRaster(gmia_temp, file.path(param$spam_path,
    glue("processed_data/maps/irrigated_area/{param$res}/gmia_temp_{param$year}_{param$iso3c}.tif")),
    overwrite = T)

  # Set files
  grid <- file.path(param$spam_path,
    glue("processed_data/maps/grid/{param$res}/grid_{param$res}_{param$year}_{param$iso3c}.tif"))
  mask <- file.path(param$spam_path,
    glue("processed_data/maps/adm/{param$res}/adm_map_{param$year}_{param$iso3c}.shp"))
  input <- file.path(param$spam_path,
    glue("processed_data/maps/irrigated_area/{param$res}/gmia_temp_{param$year}_{param$iso3c}.tif"))
  output <- file.path(param$spam_path,
    glue("processed_data/maps/irrigated_area/{param$res}/gmia_{param$res}_{param$year}_{param$iso3c}.tif"))

  # Warp and mask
  output_map <- align_rasters_fix(unaligned = input, reference = grid, dstfile = output,
                              cutline = mask, crop_to_cutline = F,
                              r = "bilinear", overwrite = T)
  plot(output_map)
}


# CLEAN UP ------------------------------------------------------------------------------
rm(adm_map, gmia_raw, output_map)
rm(grid, input, mask, output, temp_path)

