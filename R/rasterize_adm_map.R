#'@title
#'Rasterizes the map with the location of the subnational administrative units
#'
#'@description
#'For several internal operations, `mapspamc` needs a rasterized version of the map
#'with locations of the subnational administrative units. This function creates
#'this map and saves it into the `/processed_data/maps/adm/` folder.
#'
#'@inheritParams create_folders
#'
#'@return RasterLayer
#'
#'@examples
#'\dontrun{
#'rasterize_adm_map(param)
#'}
#'
#'@rawNamespace import(terra, except = arrow)
#'@importFrom magrittr %>%
#'@export
#'
rasterize_adm_map <- function(param) {

  load_data(c("adm_map", "grid", "adm_list"), param, mess = FALSE, local = TRUE)
  cat("\n=> Rasterize administrative unit map")
  field <- glue::glue("adm{param$adm_level}_code")
  adm_map_r <- terra::rasterize(terra::vect(adm_map), grid, field = field)

  # stack
  adm_map_r <- c(grid, adm_map_r)

  # Create data.frame, remove cells outside border and add adm names
  adm_map_r <- data.frame(adm_map_r) %>%
    dplyr::left_join(adm_list, by = field) %>%
    na.omit

  temp_path <- file.path(param$model_path, glue::glue("processed_data/maps/adm/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)
  saveRDS(adm_map_r, file.path(temp_path,
                               glue::glue("adm_map_r_{param$res}_{param$year}_{param$iso3c}.rds")))

}
