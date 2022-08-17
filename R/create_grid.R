#'@title
#'Create `mapspamc` country grid
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
#'@inheritParams create_mapspamc_folders
#'
#'@examples
#'\dontrun{
#'create_grid(param)
#'}
#'
#'@export
create_grid <- function(param = NULL){

  load_data("adm_map", param, mess = FALSE, local = TRUE)
  stopifnot(inherits(param, "mapspamc_par"))
  if(param$res == "5min") {
    grid_fact <- 12
    cat("\n=> Resolution is", param$res)
  } else if (param$res == "30sec"){
    grid_fact <- 120
    cat("\n=> Resolution is", param$res)
  }

  # Create grid masked to country using +init=epsg:4326 and then reproject to
  # user set crs
  grid <- terra::rast() # 1 degree raster
  grid <- terra::disagg(grid, fact = grid_fact)
  adm_map <- adm_map %>%
    sf::st_transform(crs = "epsg:4326")
  grid <- terra::crop(grid, adm_map)
  terra::values(grid) <- 1:terra::ncell(grid) # Add ID numbers
  grid <- terra::mask(grid, terra::vect(adm_map))
  grid <- terra::trim(grid)
  names(grid) <- "gridID"

  temp_path <- file.path(param$mapspamc_path, glue::glue("processed_data/maps/grid/{param$res}"))
  dir.create(temp_path, showWarnings = F, recursive = T)
  terra::writeRaster(grid, file.path(temp_path, glue::glue("grid_{param$res}_{param$year}_{param$iso3c}.tif")),
              overwrite = T)
}
