#'Harmonizes the subnational statistics, the cropland extent and the irrigated area
#'
# Function to harmonize pa cl and ir according to solve_sel
#'
#' @param param
#' @param cl_slackp
#' @param cl_slackn
#' @param ia_slackp
#
#' @inheritParams create_grid
#'
#' @examples
#'
#' @importFrom magrittr %>%
#' @export
harmonize_inputs <- function(param, cl_slackp = 0.05, cl_slackn = 5, ia_slackp = 0.05){

  load_data(c("adm_list"), param, local = TRUE, mess = F)
  if(param$solve_level == 0) {
    ac <- unique(adm_list$adm0_code)
  } else {
    ac <- unique(adm_list$adm1_code)
  }
  purrr::walk(ac, split_harmonized_inputs, param, cl_slackp = cl_slackp, cl_slackn = cl_slackn, ia_slackp = ia_slackp)
}
