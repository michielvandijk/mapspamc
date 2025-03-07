#' Calculates the balance between cropland and physical crop area
#'
#'@description
#' `calculate_cropland_coverage()` calculates the balance between total
#' cropland, derived from the synergy cropland mask, and total physical area as
#' provided by the crop statistics.
#'
#'
#' @inheritParams create_grid
#'
#' @export
calc_cropland_coverage <- function(param){
  stopifnot(inherits(param, "mapspamc_par"))
  load_data(c("adm_list"), param, local = TRUE, mess = F)
  if (param$solve_level == 0) {
    ac <- unique(adm_list$adm0_code)
  } else {
    ac <- unique(adm_list$adm1_code)
  }
  pa_cl <- purrr::map_dfr(ac, split_calc_cropland_coverage, param)
  pa_cl_tot <- dplyr::bind_rows(
    pa_cl,
    pa_cl |>
      dplyr::summarize(
        pa = sum(pa, na.rm = TRUE),
        cl_mean = sum(cl_mean, na.rm = TRUE),
        cl_max = sum(cl_max, na.rm = TRUE)
      ) |>
      dplyr::mutate(
        adm_code = param$iso3c,
        adm_name = param$country,
        adm_level = 0
      )
  ) |>
    dplyr::mutate(cl_mean_pa = cl_mean/pa,
           cl_max_pa = cl_max/pa)
  return(pa_cl_tot)
}
