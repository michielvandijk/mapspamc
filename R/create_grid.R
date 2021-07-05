#'@title
#'Create spam country grid
#'
#'@description
#'Creates the spatial grid that is used by SPAM to allocate physical area shares
#'for each crop and system. The border of the country is used as mask to
#'determine the grid and each grid is given a gridID number.
#'
#'@details
#'For technical reasons, gridID values are set before the raster is masked with
#'the country border, which means they are unique but non consecutive. Note that
#'grids at a resolution of 30 arcsec can become very large and might make some
#'time to create. The file is saved in `/processed_data/maps/grid/`
#'
#'@param param
#'@inheritParams create_spam_folders
#'
#'@examples
#'\dontrun{
#'create_grid(param)
#'}
#'
#'@export
create_grid <- function(param = NULL){

  load_data("adm_map", param, mess = FALSE, local = TRUE)
  stopifnot(inherits(param, "spam_par"))
  if(param$res == "5min") {
    grid_fact <- 12
    cat("\nResolution is", param$res)
  } else if (param$res == "30sec"){
    grid_fact <- 120
    cat("Resolution is", param$res)
  }

  # Create grid masked to country using +init=epsg:4326 and then reproject to
  # user set crs
  grid <- raster::raster() # 1 degree raster
  grid <- raster::disaggregate(grid, fact = grid_fact)
  adm_map <- adm_map %>%
    sf::st_transform(crs = "+init=epsg:4326")
  grid <- raster::crop(grid, adm_map)
  values(grid) <- 1:ncell(grid) # Add ID numbers
  grid <- raster::mask(grid, adm_map)
  grid <- trim(grid)
  names(grid) <- "gridID"

  temp_path <- file.path(param$spam_path, glue::glue("processed_data/maps/grid/{param$res}"))
  dir.create(temp_path, showWarnings = F, recursive = T)
  writeRaster(grid, file.path(temp_path, glue::glue("grid_{param$res}_{param$year}_{param$iso3c}.tif")),
              overwrite = T)
}
