# Function to prepare bs and yg data per raster file
prepare_bs_yg <- function(var, param) {
  cat("\n=> Prepare", var)
  load_data("adm_list", param, local = TRUE, mess = FALSE)

  # Set adm_level
  if (param$solve_level == 0) {
    ac <- unique(adm_list$adm0_code)
  } else {
    ac <- unique(adm_list$adm1_code)
  }

  purrr::walk(ac, split_bs_py, var = var, param = param)
}
