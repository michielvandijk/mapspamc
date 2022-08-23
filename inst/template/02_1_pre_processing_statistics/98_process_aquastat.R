#'========================================================================================================================================
#' Project:  mapspamc
#' Subject:  Script to process aquastat irrigation data
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================================================================

############### SOURCE PARAMETERS ###############
source(here::here("01_model_setup/01_model_setup.r"))


############### LOAD DATA ###############
# Aquastat raw
aquastat_raw <- read_excel(file.path(param$db_path, glue("aquastat/aquastat_irrigation_{param$iso3c}.xlsx")), sheet = "data")

# Crop mapping
aquastat2crop <-  read_csv(file.path(param$model_path, "mappings/aquastat2crop.csv"))


############### PROCESS ###############
# Clean up database, note that AQUATAT uses UN, not FAO countrycodes
aquastat <- aquastat_raw %>%
  mutate(iso3c = countrycode(`Area Id`, "un", "iso3c")) %>%
  filter(iso3c == param$iso3c) %>%
  mutate(adm_code = param$iso3c,
         adm_name = param$country,
         adm_level = 0) %>%
  transmute(adm_name, adm_code, adm_level, variable = `Variable Name`, variable_code = `Variable Id`, year = Year, value = Value)

# Create irrigated area df
# Note that "Total harvested irrigated crop area (full control irrigation)" (4379) is only presented if all crops are included
ir_area <- aquastat %>%
  dplyr::filter(grepl("Harvested irrigated temporary crop area", variable)|
                grepl("Harvested irrigated permanent crop area", variable)|
                variable_code %in% c(4379, 4313)) %>%
  separate(variable, c("variable", "aquastat_crop"), sep = ":") %>%
  mutate(aquastat_crop = trimws(aquastat_crop),
         aquastat_crop = ifelse(is.na(aquastat_crop), "Total", aquastat_crop),
         aquastat_crop = ifelse(aquastat_crop == "total", "Total", aquastat_crop),
         value = value * 1000) # to ha

# Map to crops
ir_area <- ir_area %>%
  left_join(aquastat2crop) %>%
  group_by(adm_name, adm_code, adm_level, variable, year, crop) %>%
  summarize(value = sum(value, na.rm = T),
            aquastat_crop = paste(aquastat_crop, collapse = ", ")) %>%
  mutate(system = "I") %>%
  filter(crop != "REMOVE") # removes fodder


########## USER INPUT ##########
# AQUASTAT uses "Other fruits" as a category, which can either be mapped to
# tropical fruits (trof) or temperate fruits (temf) in mapspam.
# The standard is to map it to trof. If this is fine there is no need for any changes.
# If temf is more appropriate change trof to temf below.

# Check if the Other fruits category is present.
other_fruits <- ir_area %>%
  filter(crop %in% c("trof, temf"))
if(NROW(other_fruits) == 0) {
  message("There is no Other fruits category")
} else {
  message("There is an Other fruits category")
}

# If you want to change Other fruits to temf, change "trof" to "temf" in the statement below
ir_area <- ir_area %>%
 mutate(crop = if_else(aquastat_crop == "Other fruits", "trof", crop))


############### SAVE ###############
write_csv(ir_area, file.path(param$model_path,
  glue("processed_data/agricultural_statistics/aquastat_irrigated_crops_{param$year}_{param$iso3c}.csv")))


############### CLEAN UP ###############
rm(aquastat, aquastat_raw, aquastat_version, aquastat2crop, ir_area, other_fruits)


