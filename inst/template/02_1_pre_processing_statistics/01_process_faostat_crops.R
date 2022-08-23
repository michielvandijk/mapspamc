#'========================================================================================
#' Project:  mapspamc
#' Subject:  Script to process FAOSTAT crops data
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))

# LOAD DATA ------------------------------------------------------------------------------

# Crop production
prod <- read_csv(file.path(param$db_path, "faostat/Production_Crops_Livestock_E_All_Data_(Normalized).csv"))

# faostat2crop
load_data("faostat2crop", param)


# PROCESS --------------------------------------------------------------------------------
# faostat2crop
faostat2crop <- faostat2crop %>%
  dplyr::select(crop, faostat_crop_code) %>%
  na.omit()

# Extract harvested area data
area <- prod %>%
  filter(`Area Code` == countrycode(param$iso3c, "iso3c", "fao"), Element ==  "Area harvested", Unit == "ha") %>%
  dplyr::select(faostat_crop_code = `Item Code`, year = Year, unit = Unit, value = Value) %>%
  left_join(., faostat2crop) %>%
  filter(!is.na(value)) %>%
  na.omit() %>%# remove rows with na values for value
  group_by(crop, unit, year) %>%
  summarize(value = sum(value, na.rm = T),
            .groups = "drop") %>%
  ungroup() %>%
  mutate(source = "FAOSTAT",
         adm_level = 0,
         adm_code = param$iso3c,
         adm_name = param$country)
summary(area)
str(area)


# SAVE -----------------------------------------------------------------------------------
write_csv(area, file.path(param$model_path,
                          glue("processed_data/agricultural_statistics/faostat_crops_{param$year}_{param$iso3c}.csv")))

# CREATE FAOSTAT CROP LIST ---------------------------------------------------------------
faostat_crop_list <- area %>%
  dplyr::select(source, adm_code, adm_name, crop) %>%
  unique() %>%
  arrange(crop)

write_csv(faostat_crop_list, file.path(param$model_path,
                                       glue("processed_data/lists/faostat_crop_list_{param$year}_{param$iso3c}.csv")))

# CLEAN UP -------------------------------------------------------------------------------
rm(area, faostat_crop_list, faostat2crop, prod)

