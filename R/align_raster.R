#'@title
#'align raster using a reference grid and polygon
#'
#'@description
#'`align_raster()` is used to clip raster data from global maps and align them with
#'the country grid that is created by `create_grid()`. Aligning implies that the resulting
#'map will have the same dimensions, resolution, extent and projection, and therefore
#'can be stacked and combined with other spatial data.
#'
#' @details
#'The selected method depends on the resolution. In case input maps have a lower or similar
#'resolution than the model resolution, method = "bilinear" is recommended. In case input maps
#'have a higher resolution, method = "sum" or method = "average" is recommended, depending on the
#'type of data that is processed.
#'
#'Note that input maps are resampled to the target resolution before they are clipped to the polygon.
#'In this way the edges of the resulting raster will be more detailed than clipping a low-resolution
#'map.
#'
#' @param r SpatRaster or location of SpatRaster to be processed
#' @param ref_grid SpatRaster or locationof SpatRaster with the geometry that r should be resampled to
#' @param clip SpatVector or sf object that will be used to clip r
#' @param method character. Method used for estimating the new cell values. See `terra::resample()`
#' for options.
#'
#'@examples
#'\dontrun{
#'align_raster(gaez_file, grid, adm_map, method = "bilinear")
#'}
#'@rawNamespace import(terra, except = arrow)
#'@export
align_raster <- function(r, ref_grid, clip, method = "bilinear"){
  r <- rast(r)
  clip <- vect(adm_map)
  ref_grid <- rast(grid)
  r <- crop(r, clip, snap = "out")
  r <- resample(r, ref_grid, method = method)
  r <- mask(r, clip)
  return(r)
}
