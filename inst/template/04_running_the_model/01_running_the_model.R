#'========================================================================================
#' Project:  mapspamc
#' Subject:  Script to run the model
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# RUN MODEL -----------------------------------------------------------------------------
# Select solver for each model and use tictoc to show processing time.
tic()
if(param$model == "min_entropy"){
  run_mapspamc(param, solver = "IPOPT")
} else {
  run_mapspamc(param, solver = "CPLEX")
}
toc()


# COMBINE ADM1 RESULTS ------------------------------------------------------------------
combine_results(param)


# INSPECT RESULTS ------------------------------------------------------------------------
view_results("rice", var = "ha", param)
view_results("maiz", var = "ha", param)
