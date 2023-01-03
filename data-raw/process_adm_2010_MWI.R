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
if (!require(pacman)) install.packages("pacman")
library(pacman)

# Load key packages
p_load(here, tidyverse, readxl, stringr, scales, glue)

# Load additional packages
p_load(countrycode, sf, usethis)


# Set database version
db_version <- "v0.0.1"

# Set path
if (Sys.info()["user"] == "dijk158") {
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
adm_raw <- st_read(file.path(db_path, glue("raw_data/adm/{iso3c_sel}/gg_SPAM_2/g2008_2.shp")))


# ========================================================================================
# PROCESS --------------------------------------------------------------------------------
# ========================================================================================

adm_map_raw <- adm_raw %>%
  filter(ADM0_NAME == country_sel)
plot(adm$geometry)

# ========================================================================================
# SAVE -----------------------------------------------------------------------------------
# ========================================================================================

use_data(adm_map_raw)
