#'Rasterizes the map with the location of the subnational administrative units
#'
#'For several internal operations, SPAMc needs a rasterized version of the map
#'with locations of the subnational administrative units. This function creates
#'this map and saves it into the `/processed_data/maps/adm/` folder.
#'
#'@param
#'@inheritParams create_spam_folders
#'
#'@return RasterLayer
#'
#'@examples
#'\dontrun{
#'rasterize_adm_map(param)
#'}
#'@importFrom magrittr %>%
#'@export
#'
rasterize_adm_map <- function(param) {

  cat("\n############# Rasterize Adm map ###############")
  load_data(c("adm_map", "grid"), param, mess = FALSE, local = TRUE)
  adm_map_r <- raster::rasterize(adm_map, grid)
  names(adm_map_r) <- "ID"
  raster::plot(adm_map_r)

  # Get adm info
  if(param$adm_level == 0){
    adm_df <- raster::levels(adm_map_r)[[1]] %>%
      dplyr::transmute(ID, adm0_name, adm0_code)
  } else if(param$adm_level == 1){
    adm_df <- raster::levels(adm_map_r)[[1]] %>%
      dplyr::transmute(ID, adm0_name, adm0_code, adm1_name, adm1_code)
  } else if(param$adm_level == 2){
    adm_df <- raster::levels(adm_map_r)[[1]] %>%
      dplyr::transmute(ID, adm0_name, adm0_code, adm1_name, adm1_code, adm2_name, adm2_code)
  }

  # stack
  adm_map_r <- raster::stack(grid, adm_map_r)

  # Create data.frame, remove cells outside border and add adm names
  adm_map_r <- as.data.frame(raster::rasterToPoints(adm_map_r)) %>%
    dplyr::left_join(adm_df, by = "ID") %>%
    na.omit %>%
    dplyr::select(-ID, -x, -y)


  temp_path <- file.path(param$spam_path, glue::glue("processed_data/maps/adm/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)
  saveRDS(adm_map_r, file.path(temp_path,
                               glue::glue("adm_map_r_{param$res}_{param$year}_{param$iso3c}.rds")))

}
