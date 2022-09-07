#'========================================================================================
#' Project:  mapspamc
#' Subject:  Code to process urban extent maps
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------
load_data(c("adm_map"), param)

# urban extent, select country
grump_raw <- read_sf(file.path(param$db_path, "grump/global_urban_extent_polygons_v1.01.shp"))


# PROCESS --------------------------------------------------------------------------------
grump <- grump_raw %>%
  filter(ISO3 == param$iso3c)
plot(adm_map$geometry)
plot(grump$geometry, col = "red", add = T)


# SAVE -----------------------------------------------------------------------------------
temp_path <- file.path(param$model_path, glue("processed_data/maps/population/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)
saveRDS(grump, file.path(temp_path, glue("urb_{param$year}_{param$iso3c}.rds")))


# CLEAN UP -------------------------------------------------------------------------------
rm(adm_map, grump, grump_raw, temp_path)


