# functions to compare cl_med with pa and replace where needed.
check_cl <- function(df, adm_lvl, adm_code, param){

  cat("\nadm level: ", adm_lvl)

  pa_adm_tot <- purrr::map_df(0:param$adm_level, calculate_pa_tot, adm_code, param)
  rn <- paste0("adm", adm_lvl, "_code")

  cl_check <- df %>%
    dplyr::rename(adm_code = {{rn}}) %>%
    dplyr::group_by(adm_code) %>%
    dplyr::summarize(cl_tot = sum(cl, na.rm = T),
                     cl_tot_max = sum(cl_max, na.rm = T),
                     grid_tot = sum(grid_size, na.rm = T)) %>%
    dplyr::left_join(pa_adm_tot %>%
                       dplyr::filter(adm_level == adm_lvl), by = "adm_code") %>%
    dplyr::mutate(short = cl_tot-pa,
                  short_max = cl_tot_max-pa,
                  short_gs = grid_tot-pa) %>%
    dplyr::select(adm_code, adm_name, adm_level, cl_tot, cl_tot_max, grid_tot, pa, short, short_max,
                  short_gs) %>%
    dplyr::arrange(adm_code, adm_name) %>%
    dplyr::ungroup()

  problem_adm <- dplyr::filter(cl_check, short < 0)
  if(NROW(problem_adm) == 0) {
    cat("\nNo adjustments needed for cropland")
  } else {
    cl_max_rp <- problem_adm$adm_code[problem_adm$short_max > 0 & problem_adm$short_gs > 0]
    cl_not_rp1 <- problem_adm$adm_code[problem_adm$short_max < 0 & problem_adm$short_gs > 0]
    cl_not_rp2 <- problem_adm$adm_code[problem_adm$short_max < 0 & problem_adm$short_gs < 0]

    if(length(cl_max_rp) > 0) {
      cat("\nFor the following ADMs, cl is set to cl_max to solve inconsistencies.")
      print(knitr::kable(problem_adm %>%
                           dplyr::filter(adm_code %in% cl_max_rp),
                         digits = 0,
                         format.args = list(big.mark   = ",")))
    }

    if(length(cl_not_rp1) > 0) {
      cat("\nFor the following ADMs, cl is larger than cl_max.",
          "\nThis will result in slack if the statistics are not revised.")
      print(knitr::kable(problem_adm %>%
                           dplyr::filter(adm_code %in% cl_not_rp1),
                         digits = 0,
                         format.args = list(big.mark   = ",")))
    }

    if(length(cl_not_rp2) > 0) {
      cat("\nFor the following ADMs, cl is larger than cl_max and even the grid size.",
          "\nThis will result in slack if the statistics are not revised.")
      print(knitr::kable(problem_adm %>%
                           dplyr::filter(adm_code %in% cl_not_rp2),
                         digits = 0,
                         format.args = list(big.mark   = ",")))
    }
  }
  return(problem_adm)
}
