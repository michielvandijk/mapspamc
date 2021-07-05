#'@export
prepare_model_input <- function(param) {
  load_data("adm_list", param, local = TRUE, mess = FALSE)

  # Set adm_level
  if(param$solve_level == 0) {
    adm_code_list <- unique(adm_list$adm0_code)
  } else {
    adm_code_list <- unique(adm_list$adm1_code)
  }

  purrr::walk(adm_code_list, combine_model_input, param = param)
}


