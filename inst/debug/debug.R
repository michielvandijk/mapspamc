library(mapspamc)

# SETUP MAPSPAMC -------------------------------------------------------------------------
# Set the folder where the model will be stored
# Note that R uses forward slashes even in Windows!!
spamc_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_iso3c/mapspamc_egy"
raw_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_db"
gams_path <- "C:/MyPrograms/GAMS/win64/24.6"

# Set SPAMc parameters for the min_entropy_5min_adm_level_2_solve_level_0 model
param <- spamc_par(spamc_path = spamc_path,
                   raw_path = raw_path,
                   gams_path = gams_path,
                   iso3c = "EGY",
                   year = 2018,
                   res = "5min",
                   adm_level = 2,
                   solve_level = 0,
                   model = "min_entropy")

# Show parameters
print(param)

library(gdxrrw)
library(tidyverse)
igdx(gams_path)
library(glue)


# PREPARE SCORE --------------------------------------------------------------------------
prepare_priors_and_scores(param)


# COMBINE MODEL INPUTS -------------------------------------------------------------------
combine_inputs(param)


