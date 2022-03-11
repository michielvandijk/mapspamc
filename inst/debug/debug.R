library(mapspamc)

# SETUP MAPSPAMC -------------------------------------------------------------------------
# Set the folder where the model will be stored
# Note that R uses forward slashes even in Windows!!
spamc_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_iso3c/mapspamc_egy"
raw_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_db"
gams_path <- "C:/MyPrograms/GAMS/win64/24.6"

# Set SPAMc parameters for the min_entropy_5min_adm_level_2_solve_level_0 model
param <- spamc_par(spamc_path = spamc_path,
                   raw_path = raw_path,
                   gams_path = gams_path,
                   iso3c = "EGY",
                   year = 2018,
                   res = "30sec",
                   adm_level = 2,
                   solve_level = 0,
                   model = "min_entropy")

# Show parameters
print(param)

library(gdxrrw)
library(tidyverse)
igdx(gams_path)
library(glue)



# Set files
reference <- file.path(param$spamc_path,
                  glue("processed_data/maps/grid/{param$res}/grid_{param$res}_{param$year}_{param$iso3c}.tif"))
cutline <- file.path(param$spamc_path,
                  glue("processed_data/maps/adm/{param$res}/adm_map_{param$year}_{param$iso3c}.shp"))
unaligned <- file.path(param$raw_path,
                   glue("esacci/esacci_cropland_density.tif"))
dstfile <- file.path(param$spamc_path,
                    glue("processed_data/maps/cropland/{param$res}/esacci_{param$year}_{param$iso3c}.tif"))

library(sf)
raster::raster(reference)
sf::st_read(cutline)
raster::raster(unaligned)

a <- align_raster(unaligned = unaligned, reference = reference, dstfile = dstfile,
                  cutline = cutline, crop_to_cutline = FALSE,
                  r = "bilinear", overwrite = TRUE)

raster::plot(a)
# Warp and mask
dstfilea <- file.path(param$spamc_path,
                     glue("processed_data/maps/cropland/{param$res}/esacci_{param$year}_{param$iso3c}a.tif"))

a <- align_raster(unaligned = unaligned, reference = reference, dstfile = dstfilea,
                           cutline = cutline, crop_to_cutline = FALSE,
                           r = "bilinear", overwrite = TRUE)


dstfileb <- file.path(param$spamc_path,
                      glue("processed_data/maps/cropland/{param$res}/esacci_{param$year}_{param$iso3c}b.tif"))

b <- align_raster(unaligned = unaligned, reference = reference, dstfile = dstfileb,
                  cutline = cutline, crop_to_cutline = TRUE,
                  r = "bilinear", overwrite = TRUE)

dstfilec <- file.path(param$spamc_path,
                      glue("processed_data/maps/cropland/{param$res}/esacci_{param$year}_{param$iso3c}c.tif"))
c <- align_raster(unaligned = unaligned, reference = reference, dstfile = dstfilec,
                  cutline = cutline, crop_to_cutline = FALSE,
                  r = "near", overwrite = TRUE)

a
b
c
all.equal(b,c)
hist(b)
hist(c)
library(mapview)
mapview(a) + mapview(c)
plot(c)
# Align_rasters_clip
# As a consequence of updating to the latest gdal (3.1), allign_rasters in gdalUtils does no
# longer work. The problem seems to be related with the gdalinfo function that no longer returns
# crs. Below I added a quick fix, which uses crs from the raster package to get the
# required information.
align_raster <- function (unaligned, reference, dstfile, cutline, crop_to_cutline = FALSE,
                          r = "bilinear", overwrite = TRUE,
                          n_threads = "ALL_CPUS")
{
  proj4_string <- as.character(raster::crs(raster::raster(reference)))
  bbox <- raster::extent(raster::raster(reference))
  te <- c(bbox[1], bbox[3], bbox[2], bbox[4])
  ts <- c(dim(raster::raster(reference))[2], dim(raster::raster(reference))[1])
  if (missing(dstfile))
    dstfile <- tempfile()
  if (is.character(nThreads)) {
    if (nThreads == "ALL_CPUS") {
      multi = TRUE
      wo = "NUM_THREADS=ALL_CPUS"
    }
  } else {
    if (nThreads == 1) {
      multi = FALSE
      wo = FALSE
    } else {
      multi = TRUE
      wo = paste("NUM_THREADS=", nThreads, sep = "")
    }
  }
  synced <- gdalUtilities::gdalwarp(srcfile = unaligned, dstfile = dstfile,
                                    te = te, te_srs = proj4_string, ts = ts,
                                    multi = multi, wo = wo, r = r,
                                    cutline = cutline, crop_to_cutline = crop_to_cutline,
                                    overwrite = overwrite)
  synced <- raster(synced)
  return(synced)
}
