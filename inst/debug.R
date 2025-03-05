#'========================================================================================
#' Project:  mapspamc
#' Subject:  Setup model
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SETUP R --------------------------------------------------------------------------------
# Install and load pacman package that automatically installs R packages if not available
if(!require(pacman)) install.packages("pacman")
library(pacman)

# Load required packages
p_load(mapspamc, countrycode, here, glue, terra, readxl, RColorBrewer, tidyverse, sf, ggpubr,
       viridis, tictoc)

# R options
options(scipen=999) # Suppress scientific notation
options(digits=4) # limit display to four digits


# SETUP MAPSPAMC -------------------------------------------------------------------------
# Set the folders where the scripts, model and database will be stored.
# Note that R uses forward slashes even in Windows!!

# Creates a model folder structure in c:/temp/ with the name 'mapspamc_mwi'.
# the user can replace mwi with the country code of the case-study country or
# choose a new name
model_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_iso3c/mapspamc_zaf"

# Creates a database folder with the name mapspamc_db in c:/temp
db_path <- "c:/temp"

# Sets the location of the version of GAMS that will be used to solve the model
gams_path <- "C:/MyPrograms/GAMS/40"
#gams_path <- "C:/GAMS/41"

# Set mapspamc parameters for the min_entropy_5min_adm_level_2_solve_level_0 model
param <- mapspamc_par(
  model_path = model_path,
  db_path = db_path,
  gams_path = gams_path,
  iso3c = "ZAF",
  year = 2020,
  res = "5min",
  adm_level = 2,
  solve_level = 0,
  model = "min_entropy")

# Create folder structure in the mapspamc_path
create_folders(param)



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

harmonize_inputs(param, cl_slackn = 1000, cl_slackp = 0.5)

load(param, "cl_harm")
