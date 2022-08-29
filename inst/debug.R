#'========================================================================================
#' Project:  mapspamc
#' Subject:  Setup model
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# NOTE -----------------------------------------------------------------------------------
# This script below is sourced by all the other scripts in the data repository.
# In this way, you only have to set the mapspamc parameters once.
# It also ensures that the necessary packages (see below) are loaded.

# SETUP R --------------------------------------------------------------------------------
# Install and load pacman package that automatically installs R packages if not available
if(!require(pacman)) install.packages("pacman")
library(pacman)

# Load required packages
p_load(mapspamc, countrycode, here, glue, terra, readxl, tidyverse, sf, ggpubr, viridis)

# R options
options(scipen=999) # Suppress scientific notation
options(digits=4) # limit display to four digits


# SETUP MAPSPAMC -------------------------------------------------------------------------
# Creates a model folder structure in c:/temp/ with the name 'mapspamc_mwi'.
# the user can replace mwi with the country code of the case-study country or
# choose a new name
model_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_iso3c/mapspamc_mwi"
#model_path <- "c:/temp/mapspamc_mwi"

# Creates a database folder with the name mapspamc_db in c:/temp
db_path <- "c:/temp"

# Sets the location of the version of GAMS that will be used to solve the model
gams_path <- "C:/MyPrograms/GAMS/win64/24.6"
gams_path <- "C:/MyPrograms/GAMS/win64/24.1"

gams <- gdxrrw::igdx(param$gams_path, returnStr=FALSE)
gams
gams == TRUE
gams <- gdxrrw::igdx()
isTRUE(gams)

# Set mapspamc parameters for the min_entropy_5min_adm_level_2_solve_level_0 model
param <- mapspamc_par(
  model_path = model_path,
  db_path = db_path,
  gams_path = gams_path,
  iso3c = "MWI",
  year = 2010,
  res = "5min",
  adm_level = 2,
  solve_level = 0,
  model = "min_entropy")


