#'========================================================================================
#' Project:  MAPSPAMC
#' Subject:  Code to process urban extent maps
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("scripts/01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
# Adm location
adm_map <- readRDS(file.path(param$spam_path,
                         glue("processed_data/maps/adm/{param$res}/adm_map_{param$year}_{param$iso3c}.rds")))

# urban extent, select country
grump_raw <- read_sf(file.path(param$raw_path, "grump/global_urban_extent_polygons_v1.01.shp"))


# PROCESS --------------------------------------------------------------------------------
grump <- grump_raw %>%
  filter(ISO3 == param$iso3c)
plot(adm_map$geometry)
plot(grump$geometry, col = "red", add = T)


# SAVE -----------------------------------------------------------------------------------
temp_path <- file.path(param$spam_path, glue("processed_data/maps/population/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

saveRDS(grump, file.path(param$spam_path, glue("processed_data/maps/population/{param$res}/urb_{param$year}_{param$iso3c}.rds")))


# CLEAN UP -------------------------------------------------------------------------------
rm(adm_map, grump, grump_raw, temp_path)


