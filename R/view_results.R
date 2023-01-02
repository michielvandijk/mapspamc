#'@title
#'Compares crop distribution maps using a panel for each production system
#'
#'@description To quickly inspect the `mapspamc` results, `view_results()` shows crop
#'  distribution maps for a selected crop using a panel for each production system.
#'  This function works after `combine_results()` is run. There is no need to
#'  run `create_all_tif()`. The maps are visualized using
#'  [leafletjs](https://leafletjs.com/), which makes it possible to select a
#'  number of background tiles (e.g. OpenStreetMap).
#'
#'@param crp Character. Crop for which the maps are shows. `crp`  has to be
#'  one of the `mapspamc`  four letter crop codes.
#'@param var Character. The variable to be plotted. `var` has to be physical
#'  area (`"pa"`) or harvested area (`"ha"`).
#'@inheritParams create_folders
#'@param viewer Logical. Should the default web browers be used to show the
#'  maps? `FALSE` will show the maps in the RStudio viewer pane.
#'@param polygon Logical; should the country polygon be overlayed?
#'
#'@examples
#'\dontrun{
#'view_results(crop = "maiz", var = "ha", viewer = FALSE, polygon = FALSE)
#'}
#'
#'@export
view_results <- function(crp, var, param, viewer = TRUE, polygon = TRUE){
  stopifnot(inherits(param, "mapspamc_par"))
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
  grid_df <- as.data.frame(grid, xy = TRUE)

  df <- results %>%
    dplyr::filter(crop == crp, {var} != 0)
  sys <- unique(df$system)

  st <- lapply(sys, function(x) terra::rast(df[df$system == x, c("x", "y", var)], type = "xyz", crs = terra::crs(grid)))
  st <- lapply(seq(length(st)), function(i){
    mapview::mapView(st[[i]], layer.name = glue::glue("{var} {crp} {sys[i]}"),
                     map.types = c("OpenStreetMap", "Esri.WorldImagery", "OpenTopoMap", "CartoDB.Positron"))
  })

  if(polygon) {
    st <- lapply(seq(length(st)), function(i){st[[i]] + mapview::mapView(adm_map, alpha.region = 0)})
  }

  leafsync::sync(st)
}

