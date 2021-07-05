#'@title
#'Prepares the synergy cropland area for SPAM including tp1
#'
#'@param param
#'@inheritParams create_grid
#'
#'@examples
#'
#'@importFrom magrittr %>%
#'@export
prepare_cropland_tp1 <- function(param){
  stopifnot(inherits(param, "spam_par"))
  cat("\n\n############### PREPARE CROPLAND ###############")
  load_data(c("adm_map_r", "adm_list","cl_med", "cl_max", "cl_rank", "grid", "results_tp1"), param, local = TRUE, mess = FALSE)

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

  # To harmonize with tp1 data we use the following rules:
  # lc > lc_tp1, we assume lc = lc_tp1
  # lc <= lc_tp1 <= lc_max, we assume lc = lc_tp1
  # lc_tp1 > lc_max, we assume lc = lc_max but still crop allocation needs to be rescaled accordingly
  # is.na(lc_tp1), we assume lc

  # Calculate total lc per gridID for spam tp1 and remove zero values
  cl_tp1 <-results_tp1 %>%
    dplyr::group_by(gridID) %>%
    dplyr::summarize(cl_tp1 = sum(pa, na.rm = T), .groups = "drop") %>%
    dplyr::filter(cl_tp1 != 0)

  # Add spam lc_tp1
  df <- df %>%
    dplyr::left_join(cl_tp1) %>%
    dplyr::mutate(
      cl_med = dplyr::case_when(
        cl_max < cl_tp1 ~ cl_max,
        cl_med <= cl_tp1 & cl_tp1 <= cl_max ~ cl_tp1,
        cl_med > cl_tp1 ~ cl_tp1,
        is.na(cl_tp1) ~ cl_med
      )
    ) %>%
    dplyr::select(-cl_tp1)

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

