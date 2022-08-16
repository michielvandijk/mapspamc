#'========================================================================================
#' Project:  MAPSPAMC
#' Subject:  Code to select GAEZ input maps
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# Align_rasters_clip
# As a consequence of updating to the latest gdal (3.1), allign_rasters in gdalUtils does no
# longer work. The problem seems to be related with the gdalinfo function that no longer returns
# crs. Below I added a quick fix, which uses crs from the raster package to get the
# required information.
align_rasters_fix <- function (unaligned, reference, dstfile, cutline, crop_to_cutline,
                               nThreads = 1, ...)
{
  reference_info <- suppressWarnings(
    gdalUtils::gdalinfo(reference, raw_output = FALSE, proj4 = TRUE,
             verbose = FALSE)
  )
  proj4_string <- reference_info$proj4
  if(identical(proj4_string, character(0))) {
    proj4_string <- as.character(raster::crs(raster::raster(reference)))
  }
  bbox <- reference_info$bbox
  te <- c(reference_info$bbox[1, 1], reference_info$bbox[2,
                                                         1], reference_info$bbox[1, 2], reference_info$bbox[2,
                                                                                                            2])
  ts <- c(reference_info$columns, reference_info$rows)
  if (missing(dstfile))
    dstfile <- tempfile()
  if (is.character(nThreads)) {
    if (nThreads == "ALL_CPUS") {
      multi = TRUE
      wo = "NUM_THREADS=ALL_CPUS"
    }
  }
  else {
    if (nThreads == 1) {
      multi = FALSE
      wo = FALSE
    }
    else {
      multi = TRUE
      wo = paste("NUM_THREADS=", nThreads, sep = "")
    }
  }
  synced <- gdalUtilities::gdalwarp(srcfile = unaligned, dstfile = dstfile,
                       te = te, te_srs = proj4_string, ts = ts,
                       cutline = cutline, crop_to_cutline = crop_to_cutline,
                       multi = multi, wo = wo)
  synced <- raster(synced)
  return(synced)
}

# Function to loop over gaez files, warp and mask
clip_gaez <- function(id, var, folder){
  cat("\n", id)
  temp_path <- file.path(param$spam_path, glue("processed_data/maps/{folder}/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)
  input <- lookup$files_full[lookup$id == id]
  output <- file.path(temp_path,
                      glue("{id}_{var}_{param$res}_{param$year}_{param$iso3c}.tif"))
  output_map <- align_rasters_fix(unaligned = input, reference = grid, dstfile = output,
                                  cutline = mask, crop_to_cutline = F,
                                  r = "bilinear", verbose = F, overwrite = T)
  plot(output_map, main = id)
  # added otherwise a fatal error occurs, most likely because a file is accessed twice
  Sys.sleep(2)
}


# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("scripts/01_model_setup/01_model_setup.r"))

# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map", "grid", "gaez2crop"), param)

# As some gaez maps are not available (see Convert_GAEZ_too_Suit_v4.docx, we need a specific mapping).
gaez2crop <- gaez2crop %>%
  mutate(id = paste(crop, system, sep = "_"))


# CREATE 5 ARCMIN MAPS FROM RAW GAEZ FOR CROPSUIT ----------------------------------------
# Create file lookup table
lookup <- bind_rows(
  data.frame(files_full = list.files(file.path(param$raw_path, "gaez/cropsuitabilityindexvalue"), pattern = ".tif$", full.names = T),
                             files = list.files(file.path(param$raw_path, "gaez/cropsuitabilityindexvalue"), pattern = ".tif$")) %>%
    separate(files, into = c("suit_variable", "gaez_crop", "gaez_system", "input"), sep = "_", remove = F) %>%
    separate(input, into = c("gaez_input", "ext"), sep = "\\.") %>%
    dplyr::select(-ext),
  data.frame(files_full = list.files(file.path(param$raw_path, "gaez/cropsuitabilityindexforcurrentcultivatedland"), pattern = ".tif$", full.names = T),
                                    files = list.files(file.path(param$raw_path, "gaez/cropsuitabilityindexforcurrentcultivatedland"), pattern = ".tif$")) %>%
    separate(files, into = c("suit_variable", "gaez_crop", "gaez_system", "input"), sep = "_", remove = F) %>%
    separate(input, into = c("gaez_input", "ext"), sep = "\\.") %>%
    dplyr::select(-ext)) %>%
  left_join(gaez2crop,., by = c("gaez_crop", "gaez_input", "gaez_system", "suit_variable"))


# WARP AND MASK --------------------------------------------------------------------------
# Set files
grid <- file.path(param$spam_path,
                  glue("processed_data/maps/grid/{param$res}/grid_{param$res}_{param$year}_{param$iso3c}.tif"))
mask <- file.path(param$spam_path,
                  glue("processed_data/maps/adm/{param$res}/adm_map_{param$year}_{param$iso3c}.shp"))

# warp and mask
walk(lookup$id, clip_gaez, "bs", "biophysical_suitability")


# CLEAN UP -------------------------------------------------------------------------------
rm(lookup)


# CREATE 5 ARCMIN MAPS FROM RAW GAEZ FOR PRODUCTION CAPACITY -----------------------------
# Create file lookup table
lookup <- bind_rows(
  data.frame(files_full = list.files(file.path(param$raw_path, "gaez/totalproductioncapacity"), pattern = ".tif$", full.names = T),
                             files = list.files(file.path(param$raw_path, "gaez/totalproductioncapacity"), pattern = ".tif$")) %>%
    separate(files, into = c("prod_variable", "gaez_crop", "gaez_system", "input"), sep = "_", remove = F) %>%
    separate(input, into = c("gaez_input", "ext"), sep = "\\.") %>%
    dplyr::select(-ext),
  data.frame(files_full = list.files(file.path(param$raw_path, "gaez/potentialproductioncapacityforcurrentcultivatedland"), pattern = ".tif$", full.names = T),
                                    files = list.files(file.path(param$raw_path, "gaez/potentialproductioncapacityforcurrentcultivatedland"), pattern = ".tif$")) %>%
    separate(files, into = c("prod_variable", "gaez_crop", "gaez_system", "input"), sep = "_", remove = F) %>%
    separate(input, into = c("gaez_input", "ext"), sep = "\\.") %>%
    dplyr::select(-ext)) %>%
  left_join(gaez2crop,., by = c("gaez_crop", "gaez_input", "gaez_system", "prod_variable"))

# warp and mask
walk(lookup$id, clip_gaez, "py", "potential_yield")


# CLEAN UP -------------------------------------------------------------------------------
rm(adm_map, gaez2crop, grid, mask)
rm(clip_gaez, lookup)

