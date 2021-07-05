#'@title
#' Prepares priors and scores for all farming systems, crops and grid cells
#'
#'@export
prepare_priors_and_scores <- function(param) {
  stopifnot(inherits(param, "spam_par"))
  prepare_bs_yg("biophysical_suitability", param)
  prepare_bs_yg("potential_yield", param)

  cat("\n\n############### PREPARE PRIORS ###############")
  load_data("adm_list", param, local = TRUE, mess = FALSE)

  # Set adm_level
  if(param$solve_level == 0) {
    adm_code_list <- unique(adm_list$adm0_code)
  } else {
    adm_code_list <- unique(adm_list$adm1_code)
  }

  purrr::walk(adm_code_list, split_priors, param = param)

  cat("\n\n############### PREPARE SCORES ###############")
  load_data("adm_list", param, local = TRUE, mess = FALSE)

  # Set adm_level
  if(param$solve_level == 0) {
    adm_code_list <- unique(adm_list$adm0_code)
  } else {
    adm_code_list <- unique(adm_list$adm1_code)
  }

  purrr::walk(adm_code_list, split_scores, param = param)
}


