#'========================================================================================
#' Project:  MAPSPAMC
#' Subject:  Script to run validation model
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("scripts/05_validation/01_alternative_model_setup.r"))


# PREPARE PHYSICAL AREA ------------------------------------------------------------------
prepare_physical_area(alt_param)


# CREATE SYNERGY CROPLAND INPUT ----------------------------------------------------------
prepare_cropland(alt_param)


# PROCESS --------------------------------------------------------------------------------
prepare_irrigated_area(alt_param)


# HARMONIZE INPUT DATA -------------------------------------------------------------------
harmonize_inputs(alt_param)


# PREPARE SCORE --------------------------------------------------------------------------
prepare_priors_and_scores(alt_param)


# COMBINE MODEL INPUTS -------------------------------------------------------------------
combine_inputs(alt_param)


# RUN MODEL -----------------------------------------------------------------------------
run_spamc(alt_param)


# COMBINE ADM1 RESULTS ------------------------------------------------------------------
combine_results(alt_param)



