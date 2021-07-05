#'@title Show crop distributions maps using a stack for each farming system
#'
#'@description To quickly inspect the SPAMc results, `view_stack` shows crop
#'  distribution maps for a selected crop stacking the maps for each farming
#'  system. The maps are visualized using [leafletjs](https://leafletjs.com/),
#'  which makes it possible to select a number of background tiles (e.g.
#'  OpenStreetMap).
#'
#'@param crp Character. Crop for which the maps are shows. `crp`  has to be
#'  one of the SPAMc four letter crop codes.
#'@param var Character. The variable to be plotted. `var` has to be physical
#'  area (`"pa"`) or harvested area (`"ha"`).
#'@param param
#'@inheritParams create_spam_folders
#'@param viewer Logical. Should the default web browers be used to show the
#'  maps? `FALSE` will show the maps in the RStudio viewer pane.
#'@param polygon Logical; should the country polygon be overlayed?
#'
#'@examples \dontrun{ view_stack(crop = "maiz", var = "ha", viewer = FALSE,
#'  polygon = FALSE) }
#'
#'@export
view_stack <- function(crp, var, param, viewer = TRUE, polygon = TRUE){
  stopifnot(inherits(param, "spam_par"))
  stopifnot(is.logical(viewer))
  stopifnot(is.logical(polygon))
  stopifnot(var %in% c("pa", "ha"))

  if(viewer) {
    options(viewer = NULL)
  } else {
    options(viewer=function (url, height = NULL)
    {
      if (!is.character(url) || (length(url) != 1))
        stop("url must be a single element character vector.",
             call. = FALSE)
      if (identical(height, "maximize"))
        height <- -1
      if (!is.null(height) && (!is.numeric(height) || (length(height) !=
                                                       1)))
        stop("height must be a single element numeric vector or 'maximize'.",
             call. = FALSE)
      invisible(.Call("rs_viewer", url, height))
    })
  }


  load_data(c("grid", "results", "adm_map"), param, mess = FALSE, local = TRUE)
  ext <- raster::extent(grid)
  grid_df <- as.data.frame(raster::rasterToPoints(grid))

  df <- results %>%
    dplyr::filter(crop == crp, {var} != 0)
  sys <- unique(df$system)
  st <- lapply(sys, function(x) raster::rasterFromXYZ(df[df$system == x, c("x", "y", var)], crs = crs(grid)))
  st <- lapply(st, function(x) raster::extend(x, ext)) # Harmonize exent for stacking
  if(length(sys) >1){
    st <- raster::stack(st)
  }else{
    st <- st[[1]]
  }
  names(st) <- paste(crop, sys, var, sep = "_")
  st[st==0] <- NA

  if(polygon) {
    mapview::mapview(adm_map, alpha.region = 0) + mapview::mapview(st, use.layer.names = T)
  } else {
    mapview::mapview(st, use.layer.names = T)
  }
}

