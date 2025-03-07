#' Calculates cropland coverage in line with solve level
#'
split_calc_cropland_coverage <- function(ac, param){
  load_intermediate_data(c("cl"), ac, param, local = T, mess = F)
  cl_adm_tot <- cl |>
    dplyr::summarize(
      cl_mean = sum(cl_mean, na.rm = TRUE),
      cl_max = sum(cl_max, na.rm = TRUE))

  adm_tot <- calculate_pa_tot(param$solve_level, ac, param) |>
    bind_cols(cl_adm_tot)
  return(adm_tot)
  }
