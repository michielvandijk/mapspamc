#' align_raster
#'
#' @param unaligned
#' @param reference
#' @param dstfile
#' @param cutline
#' @param crop_to_cutline
#' @param n_threads
#' @param r
#' @param overwrite
#'
#' @return
#' @export
#'
#' @examples
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
  if (is.character(n_threads)) {
    if (n_threads == "ALL_CPUS") {
      multi = TRUE
      wo = "NUM_THREADS=ALL_CPUS"
    }
  } else {
    if (n_threads == 1) {
      multi = FALSE
      wo = FALSE
    } else {
      multi = TRUE
      wo = paste("NUM_THREADS=", n_threads, sep = "")
    }
  }
  synced <- gdalUtilities::gdalwarp(srcfile = unaligned, dstfile = dstfile,
                                    te = te, te_srs = proj4_string, ts = ts,
                                    multi = multi, wo = wo, r = r,
                                    cutline = cutline, crop_to_cutline = crop_to_cutline,
                                    overwrite = overwrite)
  synced <- raster::raster(synced)
  return(synced)
}
