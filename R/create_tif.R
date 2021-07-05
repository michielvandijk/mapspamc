#'@export
create_tif <- function(crp, sy, var, df){

  load_data("grid", param, mess = FALSE, local = TRUE)
  grid_df <- as.data.frame(raster::rasterToPoints(grid))
  df <- df %>%
    dplyr::select(-x, -y) %>%
    dplyr::filter(crop == crp, system == sy) %>%
    dplyr::left_join(grid_df,., by = "gridID") %>%
    dplyr::select(x, y, {{var}})
  name <- paste(crp, sy, sep = "_")
  r <- raster::rasterFromXYZ(df, crs = param$crs)
  r <- extend(r, grid)
  names(r) <- name
  raster::plot(r, main = name)
  cat("\nTif file created for", var, name)
  return(r)
}

