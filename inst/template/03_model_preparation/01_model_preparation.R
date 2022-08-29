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


# PREPARE CROPLAND -----------------------------------------------------------------------
prepare_cropland(param)


# PREPARE IRRIGATED AREA -----------------------------------------------------------------
prepare_irrigated_area(param)


# HARMONIZE INPUT DATA -------------------------------------------------------------------
harmonize_inputs(param)


# PREPARE SCORE --------------------------------------------------------------------------
prepare_priors_and_scores(param)


# COMBINE MODEL INPUTS -------------------------------------------------------------------
combine_inputs(param)

