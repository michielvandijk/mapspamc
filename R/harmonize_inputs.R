#'@title
#'Harmonizes crop statistics, cropland and irrigated area extent
#'
#'@description
#' Function that compares and harmonizes the subnational physical area with gridded information on the
#' location and extend of cropland and irrigated area.
#'
#' @param param
#' @inheritParams create_grid
#' @param cl_slackp percentage of total cropland that will be added when comparing
#' physical area statistics to cropland extent.
#' @param cl_slackn times the area of the largest grid cell will be added when comparing
#' physical area statistics to cropland extent.
#' @param ia_slackp percentage of total irrigated area that will be added when comparing
#' irrigated area statistics to irrigated area extent.
#' @param ia_slackn times the area of the largest grid cell will be added when comparing
#' physical area statistics to irrigated area extent.
#'
#' @examples
#' harmonize_inputs(param, cl_slackp = 0.05, cl_slackn = 5, ia_slackp = 0.05, ia_slackn = 5)
#'
#' @importFrom magrittr %>%
#' @export
harmonize_inputs <- function(param, cl_slackp = 0.05, cl_slackn = 5, ia_slackp = 0.05, ia_slackn = 5){

  stopifnot(inherits(param, "mapspamc_par"))

  load_data(c("adm_list"), param, local = TRUE, mess = F)
  if(param$solve_level == 0) {
    ac <- unique(adm_list$adm0_code)
  } else {
    ac <- unique(adm_list$adm1_code)
  }
  purrr::walk(ac, split_harmonized_inputs, param, cl_slackp = cl_slackp, cl_slackn = cl_slackn,
              ia_slackp = ia_slackp, ia_slackn = ia_slackn)
}
