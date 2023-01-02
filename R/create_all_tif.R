#'@title
#'Creates tif files for all crop distribution maps produced by the model
#'
#'@description
#'The function creates tif files with maps for all crop and system combinations for which area information
#'was allocated by the model. Maps are both created for harvested (ha) and physical (pa) area. Files are
#'saved in the `/processed_data/results/{model}/maps` folder.
#'
#'@inheritParams create_grid
#'
#'@export
create_all_tif <- function(param) {
  stopifnot(inherits(param, "mapspamc_par"))
  cat("\n=> Create .tif files for all crop and production system combinations")
  load_data("results", param, mess = F)

  # by crop and system
  crop_system_list <- results %>%
    dplyr::select(crop, system) %>%
    unique

  model_folder <- create_model_folder(param)
  save_tif <- function(crp, sy, var, df) {
    r <- create_tif(crp, sy, var, df)
    temp_path <- file.path(param$model_path,
                           glue::glue("processed_data/results/{model_folder}/maps/{var}/"))
    dir.create(temp_path, showWarnings = F, recursive = T)
    terra::writeRaster(r,
      file.path(temp_path, glue::glue("{var}_{crp}_{sy}_{param$res}_{param$year}_{param$iso3c}.tif")),
      overwrite = T)
    }
  purrr::walk2(crop_system_list$crop, crop_system_list$system, save_tif, var = "ha", df = results)
  purrr::walk2(crop_system_list$crop, crop_system_list$system, save_tif, var = "pa", df = results)
}



