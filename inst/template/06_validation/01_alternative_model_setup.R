#'========================================================================================
#' Project:  MAPSPAMC
#' Subject:  Setup model
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("scripts/01_model_setup/01_model_setup.r"))

# NOTE -----------------------------------------------------------------------------------
# The scripts in the post-processing step are specific for the model resolution (i.e. 5min or
# 30sec). To run the alternative model with the same resolution, these steps do not have to be
# repeated.


# SETUP ALTERNATIVE MODEL ----------------------------------------------------------------
# In the case for Malawi we run an adm_level = 1 model
alt_param <- spamc_par(spamc_path = spamc_path,
                      raw_path = raw_path,
                      gams_path = gams_path,
                      iso3c = "MWI",
                      year = 2010,
                      res = "5min",
                      adm_level = 1,
                      solve_level = 0,
                      model = "min_entropy")

# To validate the max_score_30sec_adm_level_2_solve_level_0 model that is also described
# in Van Dijk et al. (2022) select the correct parameters in 01_model_setup.R and use these settings:
# alt_param <- spamc_par(spamc_path = spamc_path,
#                   raw_path = raw_path,
#                   gams_path = gams_path,
#                   iso3c = "MWI",
#                   year = 2010,
#                   res = "30sec",
#                   adm_level = 1,
#                   solve_level = 0,
#                   model = "max_score")

# Show parameters
print(alt_param)

