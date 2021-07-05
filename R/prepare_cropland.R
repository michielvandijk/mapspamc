#'@title
#'Prepares the synergy cropland area for SPAM
#'
#'@param param
#'@inheritParams create_grid
#'
#'@examples
#'
#'@importFrom magrittr %>%
#'@export
prepare_cropland <- function(param){
  stopifnot(inherits(param, "spam_par"))
  cat("\n\n############### PREPARE CROPLAND ###############")
  load_data(c("adm_map_r", "adm_list","cl_med", "cl_max", "cl_rank", "grid"), param, local = TRUE, mess = FALSE)

  # Grid size
  grid_size <- calc_grid_size(grid)

  # Combine and remove few cells where gridID is missing, caused by masking grid with country borders using gdal.
  df <- as.data.frame(raster::rasterToPoints(raster::stack(grid, cl_med, cl_rank, cl_max, grid_size))) %>%
    dplyr::filter(!is.na(gridID))

  # Fix inconsistencies
  # Set cl_max to cl_med if cl > cl_max because of inconsistencies (when using SASAM)
  # Set if cl_max or cl_med are larger than grid_size set to grid_size
  df <- df %>%
    dplyr::mutate(cl_max = ifelse(cl_med > cl_max, cl_med, cl_max),
                  cl_med = ifelse(grid_size < cl_med, grid_size, cl_med),
                  cl_max = ifelse(grid_size < cl_max, grid_size, cl_max))


  # Remove gridID where cl_rank is NA
  df <- df %>%
    dplyr::filter(!is.na(cl_rank))

  # Set adm_level
  if(param$solve_level == 0) {
    adm_code_list <- unique(adm_list$adm0_code)
  } else {
    adm_code_list <- unique(adm_list$adm1_code)
  }

  # Save in line with solve level
  purrr::walk(adm_code_list, split_spatial, df, "cl", adm_map_r, param)
}

