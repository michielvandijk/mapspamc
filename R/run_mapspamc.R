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
#'@details
#'The default solvers for `run_mapspamc` are CONOPT4 for the cross-entropy model and
#'CPLEX for the max_score model. CONOPT4 was developed to solve large
#'non-linear problems, including cross-entropy, whereas CPLEX was designed to solve large linear problems,
#'such as the max_score model. For more information see the CONOPT4 documentation
#'[here](https://www.gams.com/latest/docs/S_CONOPT4.html) and the CPLEX documentation
#'[here](https://www.gams.com/latest/docs/S_CPLEX.html).
#'
#'It depends on the GAMS license of the user if these solvers are available. For the cross-entropy model,
#'the user can select several alternative solvers: IPOPT, IPOPTH and CONOPT by setting the solver argument.
#'Note, however, that in comparison with CONOPT4, these three solvers should inferior performance and were
#'often not able to solve the model. Also note that selecting a solver for which the user does not have a
#'license will result in a GAMS error, causing problems in further steps to create the crop distribution maps.
#'
#'@inheritParams create_folders
#'@param solver Name of the solver that is used by GAMS. If left blank, the default solvers are selected,
#'see Details for more information.
#'@param out logical; should the GAMS model log be send to the screen as output?
#'
#'@examples
#'\dontrun{
#'run_mapspamc(param, solver = "CONOPT4", out = FALSE)
#'}
#'
#'@export
run_mapspamc <- function(param, solver = NULL, out = TRUE) {
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

  purrr::walk(ac, run_gams_adm_level, param, solver, out = out)

}



