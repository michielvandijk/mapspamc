#'========================================================================================
#' Project:  mapspamc
#' Subject:  Script to run the model
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("inst/template/01_model_setup/01_model_setup.r"))


# RUN MODEL -----------------------------------------------------------------------------
run_mapspamc(param)


# COMBINE ADM1 RESULTS ------------------------------------------------------------------
combine_results(param)


