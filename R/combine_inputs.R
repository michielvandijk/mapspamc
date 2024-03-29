#' @title Combines all inputs into one GAMS gdx file
#'
#' @description Combines all inputs, including the harmonized cropland, irrigated
#'  area and statistics, and the scores/priors into one GAMS gdx file that can be
#'  used by `mapspamc` as input. If solve_level = 1, a gdx file for each
#'  administrative level 1 unit is created.'
#'
#' @details The gdx file contains a number of sets and parameter tables that
#'  define the model. Sets describe the dimensions of the model, while
#'  parameters contain the data along these dimensions. As part of the process
#'  to combine all the inputs and if relevant, artificial administrative units
#'  are created that represent the combination of all administrative units per
#'  crop for which subnational statistics are missing. These units are added to
#'  the list of administrative units from the subnational statistics. The names
#'  of these units, stored in the `adm_area` parameter table, start with the
#'  name of the lower level administrative unit which nests the units with
#'  missing data, followed by `ART` and the level for which data is missing and
#'  ending with the crop for which data is not available.
#'
#' @inheritParams create_folders
#'
#' @examples
#' \dontrun{
#' combine_inputs(param)
#' }
#' @export
combine_inputs <- function(param) {
  stopifnot(inherits(param, "mapspamc_par"))

  # Test if gdxrrw and gams are installed.
  setup_gams(param)

  cat("\n=> Combine inputs")
  load_data("adm_list", param, local = TRUE, mess = FALSE)

  # Set adm_level
  if (param$solve_level == 0) {
    ac <- unique(adm_list$adm0_code)
  } else {
    ac <- unique(adm_list$adm1_code)
  }

  purrr::walk(ac, combine_inputs_adm_level, param)
}
