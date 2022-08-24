#'========================================================================================
#' Project:  mapspamc
#' Subject:  Setup model
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))

# NOTE -----------------------------------------------------------------------------------
# The scripts in the post-processing step are specific for the model resolution (i.e. 5min or
# 30sec). To run the alternative model with the same resolution, no new input data files have
# to be generated. In other words, all scripts that are part of step 2: pre-processing do
# not have to be run anymore!


# SETUP ALTERNATIVE MODEL ----------------------------------------------------------------
# Set mapspamc parameters for an alternative model that only uses adm1_level statistics
alt_param <- mapspamc_par(
  model_path = model_path,
  db_path = db_path,
  gams_path = gams_path,
  iso3c = param$iso3c,
  year = param$year,
  res = param$resolution,
  adm_level = 1,
  solve_level = param$solve_level,
  model = param$model)

# Show parameters
print(alt_param)
