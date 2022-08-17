#'========================================================================================
#' Project:  MAPSPAMC
#' Subject:  Script to prepare model input data
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("scripts/01_model_setup/01_model_setup.r"))


# PREPARE PHYSICAL AREA ------------------------------------------------------------------
prepare_physical_area(param)


# CREATE SYNERGY CROPLAND INPUT ----------------------------------------------------------
prepare_cropland(param)

pre
# PROCESS --------------------------------------------------------------------------------
prepare_irrigated_area(param)


# HARMONIZE INPUT DATA -------------------------------------------------------------------
harmonize_inputs(param)


# PREPARE SCORE --------------------------------------------------------------------------
prepare_priors_and_scores(param)


# COMBINE MODEL INPUTS -------------------------------------------------------------------
combine_inputs(param)


# RUN MODEL -----------------------------------------------------------------------------
run_spamc(param)


# COMBINE ADM1 RESULTS ------------------------------------------------------------------
combine_results(param)


