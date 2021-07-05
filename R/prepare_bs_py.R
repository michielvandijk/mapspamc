# Function to prepare bs and yg data per raster file
prepare_bs_yg <- function(var, param) {
  cat("\n\n############### PREPARE", toupper(var), "###############")
  load_data("adm_list", param, local = TRUE, mess = FALSE)

  # Set adm_level
  if(param$solve_level == 0) {
    adm_code_list <- unique(adm_list$adm0_code)
  } else {
    adm_code_list <- unique(adm_list$adm1_code)
  }

  purrr::walk(adm_code_list, split_bs_py, var = var, param = param)
}


