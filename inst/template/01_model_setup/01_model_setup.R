#'========================================================================================
#' Project:  MAPSPAMC
#' Subject:  Setup model
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# NOTE -----------------------------------------------------------------------------------
# This script below is sourced by all the other scripts in the data repository.
# In this way, you only have to set the MAPSPAMC parameters once.
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
# Set the folder where the model will be stored
# Note that R uses forward slashes even in Windows!!
mapspamc_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_iso3c/mapspamc_tha_test"
raw_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_iso3c/mapspamc_tha_test/raw_data"
gams_path <- "C:/MyPrograms/GAMS/win64/24.6"

# Set MAPSPAMC parameters for the min_entropy_5min_adm_level_2_solve_level_0 model
param <- mapspamc_par(mapspamc_path = mapspamc_path,
                  raw_path = raw_path,
                  gams_path = gams_path,
                         iso3c = "THA",
                         year = 2020,
                         res = "5min",
                         adm_level = 2,
                         solve_level = 0,
                         model = "min_entropy")

# # Set MAPSPAMC for the max_score_30sec_adm_level_2_solve_level_0 model model
# param <- mapspamc_par(mapspamc_path = mapspamc_path,
#                   raw_path = raw_path,
#                   gams_path = gams_path,
#                   iso3c = "THA",
#                   year = 2020,
#                   res = "30sec",
#                   adm_level = 2,
#                   solve_level = 0,
#                   model = "max_score")


# Show parameters
print(param)

# Create MAPSPAMC folder structure in the mapspamc_path
create_folders(param)


