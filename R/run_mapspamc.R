#' @title Runs crop allocation algorithm at the set administrative unit level
#'
#' @description Run the selected model (`min_entropy` or `max_score`) in GAMS
#'  with a pre-selected solver (see details). If `model_sel = 1`, the model is
#'  run for each individual administrative unit at level 1. If `model_sel = 0`
#'  the model is run only once for the total country. Selecting `out = TRUE`
#'  (default setting), the GAMS model log will be sent to the screen after the
#'  model run has finished. The log is a text file, which names starts with
#'  `model_log_` and is saved in the `processed_data/intermediate_output`
#'  folder.  Note that, depending on the size of the country and the selected
#'  resolution, the model might take a long time to run. If the model is very
#'  large, the computer might run out of memory and an error message will be
#'  printed in the log file.
#'
#' @details Depending on the license, GAMS is installed with several solvers. For
#'  each type of problem a default solver is pre-selected. If `solver =
#'  "default"`, the GAMS default options for linear (`max_score`) and non-linear
#'  (`min_entropy`) problems are used to solve the models. To find out which
#'  solvers are available and which are the default, open the GAMS IDE: file ->
#'  options -> solvers.  The user has the option to select one of the other
#'  linear- and non-linear solvers supported by GAMS: ANTIGONE, BARON, CPC,
#'  CPLEX, CONOPT4, CONOPT, GUROBI, IPOPT, IPOPTH, KNITRO, LGO, LINDO,
#'  LOCALSOLVER, MINOS, MOSEK, MSNLP, OSICPLEX, OSIGUROBI, OSIMOSEK, OSIXPRESS,
#'  PATHNLP, SCIP, SNOPT, SOPLEX, XA, XPRESS.
#'
#'  For the `max_score` model, which is a linear problem, it is recommended to
#'  use [CPLEX](https://www.gams.com/latest/docs/S_CPLEX.html). For  non-linear
#'  problems, such as the `min_entropy` model, is not possible to predict at
#'  forehand, which solver performs best. It is recommended to start with using
#'  the [IPOPT](https://www.gams.com/latest/docs/S_IPOPT.html), which has shown
#'  good performance in solving cross-entropy models. An alternative option is
#'  [CONOPT4](https://www.gams.com/latest/docs/S_CONOPT4.html), which, however,
#'  is often much slower, and in some cases is not able to solve the model.
#'
#'  The GAMS code (gms files) to solve the `max_score` and `min_entropy` models
#'  is stored in the `gams` folder in the `mapspamc` R library folder.
#'  Interested users might want to take a look and, if necessary, modify the
#'  code and run it directly in GAMS, separately from the `mapspamc` package.
#'
#' @inheritParams create_folders
#' @param solver Name of the GAMS solver. If set to `"default"`, the GAMS default
#'  solvers are selected, see details for more information.
#' @param out logical; should the GAMS model log be send to the screen as output?
#'
#' @examples
#' \dontrun{
#' run_mapspamc(param, solver = "IPOPT", out = FALSE)
#' }
#'
#' @export
run_mapspamc <- function(param, solver = "default", out = TRUE) {
  stopifnot(inherits(param, "mapspamc_par"))
  stopifnot(is.logical(out))
  load_data("adm_list", param, local = TRUE, mess = FALSE)

  # Set adm_level
  if (param$solve_level == 0) {
    ac <- unique(adm_list$adm0_code)
  } else {
    ac <- unique(adm_list$adm1_code)
  }

  purrr::walk(ac, run_gams_adm_level, param, solver = solver, out = out)
}
