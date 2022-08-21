#'@title
#'Prepares grid cell priors and scores for all crops and farming system combinations
#'
#'@export
prepare_priors_and_scores <- function(param) {
  stopifnot(inherits(param, "mapspamc_par"))
  prepare_bs_yg("biophysical_suitability", param)
  prepare_bs_yg("potential_yield", param)

  # Set adm_level
  if(param$solve_level == 0) {
    ac <- unique(adm_list$adm0_code)
  } else {
    ac <- unique(adm_list$adm1_code)
  }

  cat("\n=> Prepare priors")
  load_data("adm_list", param, local = TRUE, mess = FALSE)
  purrr::walk(ac, split_priors, param = param)

  cat("\n=> Prepare scores")
  load_data("adm_list", param, local = TRUE, mess = FALSE)
  purrr::walk(ac, split_scores, param = param)
}


