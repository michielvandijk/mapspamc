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
#model_path <- "D:/GLOBIOM_UCSB/mapspamc_2000"
model_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_iso3c/mapspamc_usa"

# Creates a database folder with the name mapspamc_db in c:/temp
db_path <- "C:/temp"

# Sets the location of the version of GAMS that will be used to solve the model
#gams_path <- "C:/GAMS/win64/27.3"
gams_path <- "C:/MyPrograms/GAMS/40"

# Set mapspamc parameters for the min_entropy_5min_adm_level_2_solve_level_0 model
param <- mapspamc_par(
  model_path = model_path,
  db_path = db_path,
  gams_path = gams_path,
  iso3c = "USA",
  year = 2000,
  res = "5min",
  adm_level = 2,
  solve_level = 1,
  model = "min_entropy")

# Set mapspamc parameters for the max_score_30sec_adm_level_2_solve_level_0 model
# param <- mapspamc_par(
#   model_path = model_path,
#   db_path = db_path,
#   gams_path = gams_path,
#   iso3c = "MWI",
#   year = 2010,
#   res = "30sec",
#   adm_level = 2,
#   solve_level = 0,
#   model = "max_score")


# Show parameters
print(param)

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

# HARMONIZE INPUT DATA -------------------------------------------------------------------
harmonize_inputs(alt_param)
ac
ac <- "USCT"
cl_slackp = 0.05
cl_slackn = 5
ia_slackp = 0.05
ia_slackn = 5

split_harmonized_inputs("USCT", alt_param, cl_slackp, cl_slackn, ia_slackp, ia_slackn)

split_harmonized_inputs <- function(ac, alt_param, cl_slackp, cl_slackn, ia_slackp, ia_slackn) {
  # https://stackoverflow.com/questions/7096989/how-to-save-all-console-output-to-file-in-r
  model_folder <- create_model_folder(alt_param)
  log_file <- file(file.path(
    alt_param$model_path,
    glue::glue("processed_data/intermediate_output/{model_folder}/{ac}/log_{alt_param$res}_{alt_param$year}_{ac}_{alt_param$iso3c}.log")
  ))
  capture.output(file = log_file, append = FALSE, split = T, {
    cat("\n\n--------------------------------------------------------------------------------------------------------------")
    cat("\n", ac)
    cat("\n--------------------------------------------------------------------------------------------------------------")

    ############### STEP 1: LOAD DATA ###############
    # Load data
    load_intermediate_data(c("cl"), ac, alt_param, local = T, mess = F)

    ############### STEP 2: SET CL TO MEDIAN CROPLAND ###############
    # Create df of cl map,  set cl to median cropland
    # Remove few cells where gridID is missing, caused by masking grid with country borders using gdal.
    cl_df <- cl %>%
      dplyr::mutate(cl = cl_mean)

    # Remove gridID where cl_rank is NA
    cl_df <- cl_df %>%
      dplyr::filter(!is.na(cl_rank))

    ############### STEP 3: HARMONIZE CL   ###############
    cl_df <- harmonize_cl(df = cl_df, ac, alt_param)


    ############### STEP 4: HARMONIZE IA ###############
    cl_df <- harmonize_ia(cl_df, ac, alt_param, ia_slackp = ia_slackp, ia_slackn = ia_slackn) %>%
      dplyr::mutate(
        ia = ifelse(is.na(ia), 0, ia),
        ia_max = ifelse(is.na(ia_max), 0, ia_max)
      )

    ############### STEP 5: PREPARE FINAL CL MAP BY RANKING CELLS PER ADM ###############
    cl_df <- select_grid_cells(cl_df, ac, alt_param, cl_slackp = cl_slackp, cl_slackn = cl_slackn)


    ############### STEP 6: PREPARE FILES ###############
    # Irrigation
    ia_harm_df <- cl_df %>%
      dplyr::select(gridID, ia) %>%
      na.omit()

    # Cropland: rename adm_code to alt_param$adm_level
    adm_level_sel <- glue::glue("adm{alt_param$adm_level}_code")
    cl_harm_df <- cl_df[c("gridID", adm_level_sel, "cl")]
    names(cl_harm_df)[names(cl_harm_df) == adm_level_sel] <- "adm_code"
    cl_harm_df$adm_level <- alt_param$adm_level


    ############### STEP 6: CREATE MAPS ###############
    # cl map
    cl_harm_r <- gridID2raster(cl_harm_df, "cl", alt_param)

    # ia map
    ia_harm_r <- gridID2raster(ia_harm_df, "ia", alt_param)


    ############### STEP 7: SAVE ###############
    temp_path <- file.path(
      alt_param$model_path,
      glue::glue("processed_data/intermediate_output/{model_folder}/{ac}")
    )
    dir.create(temp_path, recursive = T, showWarnings = F)

    saveRDS(cl_harm_df, file.path(
      temp_path,
      glue::glue("cl_harm_{alt_param$res}_{alt_param$year}_{ac}_{alt_param$iso3c}.rds")
    ))
    terra::writeRaster(cl_harm_r, file.path(
      temp_path,
      glue::glue("cl_harm_r_{alt_param$res}_{alt_param$year}_{ac}_{alt_param$iso3c}.tif")
    ), overwrite = T)

    # ia_harm
    saveRDS(ia_harm_df, file.path(
      temp_path,
      glue::glue("ia_harm_{alt_param$res}_{alt_param$year}_{ac}_{alt_param$iso3c}.rds")
    ))
    terra::writeRaster(ia_harm_r, file.path(
      temp_path,
      glue::glue("ia_harm_r_{alt_param$res}_{alt_param$year}_{ac}_{alt_param$iso3c}.tif")
    ), overwrite = T)
  })
}
