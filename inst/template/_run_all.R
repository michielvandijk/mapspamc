#'========================================================================================
#' Project:  mapspamc
#' Subject:  Script to run all scripts from model setup to validation
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================


# NOTE -----------------------------------------------------------------------------------
# This script runs all the mapspamc steps: (1) model setup, (2) pre-processing,
# (3) model_preparation, (4) running_the_model, (5) post_processing and (6) model_validation.

# It might be convenient to quickly rerun the model after statistics or other input data has
# been adjusted. Note however that modifications of the statistics easily result in errors that prevent running
# downstream model steps. Hence, we always recommend to run all steps separately to fix issues that might occur and only then
# use this script to fully rerun the model.
#
# Also depending on the model and target year the steps in 02_3_pre_processing_cropland need to be adjusted.
# For 2010, select_sasam.r can be run to prepare the synergy cropland map. For all other years separate
# cropland products need to be processed and combined into one synergy cropland map


# MODEL SETUP
source(here::here("01_model_setup/01_model_setup.r"))
source(here::here("01_model_setup/02_prepare_adm_map_and_grid.r"))


# PRE-PROCESSING -------------------------------------------------------------------------
# Always carefully check if 03_prepare_subnational_statistics and 04_check_and_calibrate_statistics
# are correctly run. We recommend to not source these files but run them manually so outcomes can
# be closely inspected.
source(here::here("02_1_pre_processing_statistics/01_process_faostat_crops.r"))
source(here::here("02_1_pre_processing_statistics/02_process_faostat_crop_prices.r"))
source(here::here("02_1_pre_processing_statistics/03_prepare_subnational_statistics.r"))
source(here::here("02_1_pre_processing_statistics/04_check_and_calibrate_statistics.r"))

source(here::here("02_2_pre_processing_spatial_data/01_select_gaez.r"))
source(here::here("02_2_pre_processing_spatial_data/02_select_travel_time.r"))
source(here::here("02_2_pre_processing_spatial_data/03_select_urban_extent.r"))
source(here::here("02_2_pre_processing_spatial_data/04_select_worldpop.r"))

# Steps below need to be selected manually.
#source(here::here("02_3_pre_processing_cropland/select_copernicus.r"))
#source(here::here("02_3_pre_processing_cropland/select_esacci.r"))
#source(here::here("02_3_pre_processing_cropland/select_esri.r"))
#source(here::here("02_3_pre_processing_cropland/select_glad.r"))
source(here::here("02_3_pre_processing_cropland/select_sasam.r"))
#source(here::here("02_3_pre_processing_cropland/create_synergy_cropland_map.r"))

source(here::here("02_4_pre_processing_irrigated_area/01_select_gia.r"))
source(here::here("02_4_pre_processing_irrigated_area/02_select_gmia.r"))
source(here::here("02_4_pre_processing_irrigated_area/03_create_synergy_irrigated_area_map.r"))


# MODEL PREPARATION ----------------------------------------------------------------------
source(here::here("03_model_preparation/01_model_preparation.r"))


# RUNNING THE MODEL ----------------------------------------------------------------------
source(here::here("04_running_the_model/01_running_the_model.r"))


# POST-PROCESSING ------------------------------------------------------------------------
source(here::here("05_post_processing/01_create_maps.r"))


# MODEL VALIDATION -----------------------------------------------------------------------
source(here::here("06_model_validation/01_alternative_model_setup.r"))
source(here::here("06_model_validation/02_prepare_and_run_alternative_model.r"))
source(here::here("06_model_validation/03_model_validation.r"))
