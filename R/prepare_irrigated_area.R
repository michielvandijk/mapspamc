#' @title
#' Prepares synergy irrigated area extent
#'
#' @description
#' Combines all elements of the synergy irrigated area extent (maximum irrigated area and rank),
#' with information on the location of the subnational units and fixes potential inconsistencies
#' (e.g. irrigated area larger than grid cell size).
#'
#' @inheritParams create_folders
#'
#' @examples
#' \dontrun{
#' prepare_irrigated_area(param)
#' }
#'
#' @export

prepare_irrigated_area <- function(param) {
  stopifnot(inherits(param, "mapspamc_par"))
  cat("\n\n=> Prepare irrigated area")
  load_data(c("adm_map_r", "adm_list", "ia_max", "ia_rank", "grid"), param, local = TRUE, mess = FALSE)

  # Grid size
  grid_size <- calc_grid_size(grid)

  # Combine and remove cells where gridID is missing
  df <- as.data.frame(c(grid, ia_rank, ia_max, grid_size), xy = TRUE) %>%
    dplyr::filter(!is.na(gridID))

  # Fix inconsistencies
  # Set ia_max to grid_size if it is larger than grid_size
  df <- df %>%
    dplyr::mutate(ia_max = ifelse(grid_size < ia_max, grid_size, ia_max))


  # Remove gridID where ia_rank is NA
  df <- df %>%
    dplyr::filter(!is.na(ia_rank))

  # Set adm_level
  if (param$solve_level == 0) {
    adm_code_list <- unique(adm_list$adm0_code)
  } else {
    adm_code_list <- unique(adm_list$adm1_code)
  }

  # Save in line with solve level
  purrr::walk(adm_code_list, split_spatial, df, "ia", adm_map_r, param)
}
