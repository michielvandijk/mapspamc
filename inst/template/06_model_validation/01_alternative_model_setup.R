#'========================================================================================
#' Project:  MAPSPAMC
#' Subject:  Setup model
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("inst/template/01_model_setup/01_model_setup.r"))

# NOTE -----------------------------------------------------------------------------------
# The scripts in the post-processing step are specific for the model resolution (i.e. 5min or
# 30sec). To run the alternative model with the same resolution, no new input data files have
# to be generated. In other words, all scripts that are part of step 2: pre-processing do
# not have to be run anymore!


# SETUP ALTERNATIVE MODEL ----------------------------------------------------------------
# Set mapspamc parameters for an alternative min entropy 5min model that only uses adm1_level statistics
# and constraints - min_entropy_5min_adm_level_1_solve_level_0 model)
alt_param <- mapspamc_par(
  model_path = model_path,
  #db_path = db_path,
  gams_path = gams_path,
  iso3c = "THA",
  year = 2020,
  res = "5min",
  adm_level = 1,
  solve_level = 0,
  model = "min_entropy")

# Set mapspamc parameters for an alternative max score 30sec model that only uses adm1_level statistics
# and constraints - max_score_30sec_adm_level_1_solve_level_0)
# alt_param <- mapspamc_par(
#   model_path = model_path,
#   db_path = db_path,
#   gams_path = gams_path,
#   iso3c = "THA",
#   year = 2020,
#   res = "5min",
#   adm_level = 1,
#   solve_level = 0,
#   model = "min_entropy")

# Show parameters
print(alt_param)

