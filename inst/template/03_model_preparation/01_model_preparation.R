#'========================================================================================
#' Project:  mapspamc
#' Subject:  Script to prepare model input data
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# PREPARE PHYSICAL AREA ------------------------------------------------------------------
prepare_physical_area(param)


# CREATE SYNERGY CROPLAND INPUT ----------------------------------------------------------
prepare_cropland(param)


# PROCESS --------------------------------------------------------------------------------
prepare_irrigated_area(param)


# HARMONIZE INPUT DATA -------------------------------------------------------------------
harmonize_inputs(param)


# PREPARE SCORE --------------------------------------------------------------------------
prepare_priors_and_scores(param)


# COMBINE MODEL INPUTS -------------------------------------------------------------------
combine_inputs(param)

