#' @title
#' Prepares grid cell priors and scores for all crops and production system combinations
#'
#' @description
#' Creates the priors and the scores for each grid cell. For convenience, the
#' function will always create data tables with priors and scores even though
#' only one might required.
#'
#' @details
#' Note that the function might take some time to run as it implements three
#' consecutive processes. First, the biophysical suitability and potential yield
#' maps for all production system and crop combinations are loaded and only grid
#' cells that overlap with the cropland extent from the previous step are
#' selected, after which all data is merged into one table and saved. This
#' process also checks if the maps do not only contain zero values and, where
#' needed, replaces the map by a substitute crop. This is important because it
#' occasionally happens that the biophysical suitability and potential yield
#' maps indicate zero suitability for a specific crop although the statistics
#' suggest the crop is produced in the country. Not correction for this, would
#' result in an ‘uninformed’ allocation of the crop, meaning it can be placed
#' anywhere as long as the the constraints are satisfied and the objective
#' function (minimization of cross-entropy or maximization of fitness score) is
#' optimized. In case all the substitute crops have zero values, a warning is
#' issued. The list of substitute crop is stored in the mappings/replace_gaez.sv
#' file and can be adjusted by the user. The second and third process create
#' data files with the priors and scores using the biophysical suitability and
#' potential yield, among others, as input data.
#'
#' @inheritParams create_grid
#'
#' @examples
#' \dontrun{
#' prepare_priors_and_scores(param)
#' }
#'
#'
#' @export
prepare_priors_and_scores2 <- function(param) {
  stopifnot(inherits(param, "mapspamc_par"))
  prepare_bs_yg("biophysical_suitability", param)
  prepare_bs_yg("potential_yield", param)
  load_data("adm_list", param, local = TRUE, mess = FALSE)

  # Set adm_level
  if (param$solve_level == 0) {
    ac <- unique(adm_list$adm0_code)
  } else {
    ac <- unique(adm_list$adm1_code)
  }

  cat("\n=> Prepare priors")
  load_data("adm_list", param, local = TRUE, mess = FALSE)
  purrr::walk(ac, split_priors2, param = param)

  cat("\n=> Prepare scores")
  load_data("adm_list", param, local = TRUE, mess = FALSE)
  purrr::walk(ac, split_scores, param = param)
}
