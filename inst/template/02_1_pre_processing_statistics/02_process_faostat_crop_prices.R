#'========================================================================================
#' Project:  mapspamc
#' Subject:  Script to process FAOSTAT price data
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------

# Crop production
prod_raw <- read_csv(file.path(param$db_path, "faostat/Production_Crops_Livestock_E_All_Data_(Normalized).csv"))

# price data
price_raw <- read_csv(file.path(param$db_path, "faostat/Prices_E_All_Data_(Normalized).csv"))

# faostat2crop
load_data("faostat2crop", param)
faostat2crop <- faostat2crop %>%
  dplyr::select(crop, faostat_crop_code) %>%
  na.omit()


# PROCESS --------------------------------------------------------------------------------
# Clean up FAOSTAT
price <- price_raw %>%
  setNames(tolower(names(.))) %>%
  filter(element == "Producer Price (USD/tonne)") %>%
  mutate(iso3c = countrycode(`area code`, "fao", "iso3c")) %>%
  filter(!is.na(iso3c)) %>%
  dplyr::select(iso3c, faostat_crop_code = `item code`, year, price = value)

area <- prod_raw %>%
  setNames(tolower(names(.))) %>%
  filter(element == "Area harvested") %>%
  mutate(iso3c = countrycode(`area code`, "fao", "iso3c")) %>%
  filter(!is.na(iso3c)) %>%
  dplyr::select(iso3c, item, faostat_crop_code = `item code`, year, area = value)

# Combine and calculate weighted average price for crop
# We take weighted average over five years to reduce fluctuations
# We take average for continents because otherwise there are many missing data (e.g. coffee in Southern Africa)
price_iso3c <- full_join(price, area) %>%
  na.omit() %>%
  left_join(faostat2crop) %>%
  filter(!is.na(crop)) %>%
  group_by(iso3c, crop, year) %>%
  summarize(price = sum(price*area)/sum(area, na.rm = T),
            .groups = "drop") %>%
  ungroup() %>%
  filter(year %in% c(param$year-1, param$year, param$year+1)) %>%
  mutate(continent = countrycode(iso3c, "iso3c", "continent"),
         region = countrycode(iso3c, "iso3c", "region")) %>%
  group_by(crop, continent) %>%
  summarize(price = mean(price, na.rm = T),
            .groups = "drop") %>%
  ungroup()

# Filter out continent prices
price_iso3c <- price_iso3c %>%
  filter(continent == countrycode(param$iso3c, "iso3c", "continent")) %>%
  dplyr::select(-continent)

# Check missing
crop_list <- faostat2crop %>%
  dplyr::select(crop) %>%
  unique()

miss_crop <- full_join(crop_list, price_iso3c) %>%
  complete(crop) %>%
  filter(is.na(price))


# SAVE -----------------------------------------------------------------------------------
write_csv(price_iso3c, file.path(param$model_path,
                                 glue("processed_data/agricultural_statistics/crop_prices_{param$year}_{param$iso3c}.csv")))


# CLEAN UP -------------------------------------------------------------------------------
rm(area, crop_list, faostat2crop, miss_crop, price, price_iso3c, price_raw,
   prod_raw)
