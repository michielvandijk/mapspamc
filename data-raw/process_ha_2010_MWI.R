# ========================================================================================
# Project:  mapspamc
# Subject:  Script clip Malawi adm maps from global SPAM map
# Author:   Michiel van Dijk
# Contact:  michiel.vandijk@wur.nl
# ========================================================================================

# ========================================================================================
# SETUP ----------------------------------------------------------------------------------
# ========================================================================================

# Load pacman for p_load
if(!require(pacman)) install.packages("pacman")
library(pacman)

# Load key packages
p_load(here, tidyverse, readxl, stringr, scales, glue)

# Load additional packages
p_load(countrycode, sf)

# Set database version
db_version <- "v0.0.1"

# Set path
if(Sys.info()["user"] == "dijk158") {
  proj_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_db"
  db_path <- file.path(proj_path, glue("{db_version}"))
}

# R options
options(scipen = 999)
options(digits = 4)


# ========================================================================================
# LOAD DATA ------------------------------------------------------------------------------
# ========================================================================================

iso3c_sel <- "MWI"
country_sel <- countrycode(iso3c_sel, "iso3c", "country.name")
year_sel <- 2010
ha_df_raw <- read_csv(file.path(db_path,
                                glue("processed_data/subnational_statistics/{iso3c_sel}/subnational_harvested_area_{year_sel}_{iso3c_sel}.csv")))

# ========================================================================================
# PROCESS HA STATISTICS ------------------------------------------------------------------
# ========================================================================================

# wide to long format
ha_df <- ha_df_raw %>%
  pivot_longer(-c(adm_name, adm_code, adm_level), names_to = "crop", values_to = "ha")

# Convert -999 and empty string values to NA
ha_df <- ha_df %>%
  mutate(ha = if_else(ha == -999, NA_real_, ha),
         ha = as.numeric(ha)) # this will transform empty string values "" into NA and throw a warning

# filter out crops which values are all zero or NA
crop_na_0 <- ha_df %>%
  group_by(crop) %>%
  filter(all(ha %in% c(0, NA))) %>%
  dplyr::select(crop) %>%
  unique

ha_df <- ha_df %>%
  filter(!crop %in% crop_na_0$crop)

# Round values
ha_df <- ha_df %>%
  mutate(ha = round(ha, 0))

# ========================================================================================
# SAVE -----------------------------------------------------------------------------------
# ========================================================================================

usethis::use_data(ha_df)
