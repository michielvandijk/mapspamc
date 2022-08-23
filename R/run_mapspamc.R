#'@title Runs crop allocation algorithm at the set administrative unit level
#'
#'@description Run the selected model (min_entropy or max_score) and in
#'  GAMS. If `model_sel = 1`, the model is run for each individual
#'  administrative unit at level 1. If `model_sel = 0` the model is run only
#'  once for the total country. Selecting `out = TRUE` (default setting), the
#'  model log will be sent to the screen after the model run is finished. The
#'  log is as text file, which names starts with `model_log_` and is saved in
#'  the `processed_data/intermediate_output` folder.  Note that, depending on
#'  the size of the country and the selected resolution, the model might take a
#'  lot of time to run. If the model is very large, there is a risk your
#'  computer runs out of memory and an error message will be printed in the
#'  model log.
#'
#'@param param
#'@inheritParams create_mapspamc_folders
#'@param out logical; should the GAMS model log be send to the screen as output?
#'
#'@examples
#'\dontrun{
#'run_mapspamc(param, out = FALSE)
#'}
#'
#'@export
run_mapspamc <- function(param, out = TRUE) {
  stopifnot(inherits(param, "mapspamc_par"))
  stopifnot(is.logical(out))
  cat("\n => Running mapspamc")
  load_data("adm_list", param, local = TRUE, mess = FALSE)

  # Set adm_level
  if(param$solve_level == 0) {
    ac <- unique(adm_list$adm0_code)
  } else {
    ac <- unique(adm_list$adm1_code)
  }

  purrr::walk(ac, run_gams_adm_level, param, out = out)

}


