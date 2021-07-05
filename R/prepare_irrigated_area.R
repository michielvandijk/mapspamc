#'Prepares the synergy irrigated area for SPAM
#'
#'@param param
#'@inheritParams create_grid
#'
#'@examples
#'
#'@export

prepare_irrigated_area <- function(param){
  stopifnot(inherits(param, "spam_par"))
  cat("\n\n############### PREPARE IRRIGATED AREA ###############")
  load_data(c("adm_map_r", "adm_list","ia_max", "ia_rank", "grid"), param, local = TRUE, mess = FALSE)

  # Grid size
  grid_size <- calc_grid_size(grid)

  # Combine and remove cells where gridID is missing
  df <- as.data.frame(raster::rasterToPoints(raster::stack(grid, ia_rank, ia_max, grid_size))) %>%
    dplyr::filter(!is.na(gridID))

  # Fix inconsistencies
  # Set ia_max to grid_size if it is larger than grid_size
  df <- df %>%
    dplyr::mutate(ia_max = ifelse(grid_size < ia_max, grid_size, ia_max))


  # Remove gridID where ia_rank is NA
  df <- df %>%
    dplyr::filter(!is.na(ia_rank))

  # Set adm_level
  if(param$solve_level == 0) {
    adm_code_list <- unique(adm_list$adm0_code)
  } else {
    adm_code_list <- unique(adm_list$adm1_code)
  }

  # Save in line with solve level
  purrr::walk(adm_code_list, split_spatial, df, "ia", adm_map_r, param)
}

