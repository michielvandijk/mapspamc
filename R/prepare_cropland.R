#'@title
#'Prepares synergy cropland extent
#'
#'@description
#'Combines all elements of the synergy cropland extent (median and maximum cropland per grid cell and rank),
#'with information on the location of the subnational units and fixes potential inconsistencies
#'(e.g. cropland area larger than grid cell size).
#'
#'@param param
#'@inheritParams create_grid
#'
#'@examples
#'
#'@importFrom magrittr %>%
#'@export
prepare_cropland <- function(param){
  stopifnot(inherits(param, "mapspamc_par"))
  cat("\n\n=> Prepare cropland")
  load_data(c("adm_map_r", "adm_list","cl_mean", "cl_max", "cl_rank", "grid"), param, local = TRUE, mess = FALSE)

  # Grid size
  grid_size <- calc_grid_size(grid)

  # Combine and remove few cells where gridID is missing, caused by masking grid with country borders using gdal.
  df <- as.data.frame(c(grid, cl_mean, cl_rank, cl_max, grid_size),xy = TRUE) %>%
    dplyr::filter(!is.na(gridID))

  # Fix inconsistencies
  # Set cl_max to cl_mean if cl > cl_max because of inconsistencies (when using SASAM)
  # Set if cl_max or cl_mean are larger than grid_size set to grid_size
  df <- df %>%
    dplyr::mutate(cl_max = ifelse(cl_mean > cl_max, cl_mean, cl_max),
                  cl_mean = ifelse(grid_size < cl_mean, grid_size, cl_mean),
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

