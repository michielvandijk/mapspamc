#'========================================================================================================================================
#' Project:  mapspamc
#' Subject:  Script to calculate irrigated system shares
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================================================================


############### SOURCE PARAMETERS ###############
source(here::here("01_model_setup/01_model_setup.r"))


############### LOAD DATA ###############
# Adm statistics
load_data(c("ha"), param)

# Faostat
faostat_raw <- read_csv(file.path(param$model_path,
                          glue("processed_data/agricultural_statistics/faostat_crops_{param$year}_{param$iso3c}.csv")))

# Faostat
aquastat_raw <- read_csv(file.path(param$model_path,
                          glue("processed_data/agricultural_statistics/aquastat_irrigated_crops_{param$year}_{param$iso3c}.csv")))


########## PROCESS ##########
# Prepare stat
ha <- ha %>%
  gather(crop, value_ha, -adm_name, -adm_code, -adm_level) %>%
  mutate(value_ha = as.numeric(value_ha),
         value_ha = if_else(value_ha == -999, NA_real_, value_ha),
         adm_code = as.character(adm_code))

aquastat <- aquastat_raw %>%
  filter(crop != "total",
         variable %in% c("Harvested irrigated permanent crop area", "Harvested irrigated temporary crop area")) %>%
  dplyr::select(adm_code, adm_name, adm_level, crop, ir_area = value, year)

faostat <- faostat_raw %>%
  dplyr::select(adm_name, adm_code, adm_level, crop, year, value)

# Combine
ir_share <- left_join(faostat, aquastat) %>%
  na.omit %>%
  mutate(ir_share = ir_area/value*100)

# plot
ggplot(data = ir_share, aes(x = as.factor(year), y = ir_share, fill = crop)) +
  geom_col() +
  facet_wrap(~crop, scales = "free")

# save
write_csv(ir_share, file.path(param$model_path,
                              glue("processed_data/agricultural_statistics/share_of_irrigated_crops_{param$year}_{param$iso3c}.csv")))
