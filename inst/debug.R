library(mapspamc)

# SETUP MAPSPAMC -------------------------------------------------------------------------
# Set the folder where the model will be stored
mapspamc_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_iso3c/mapspamc_tha_test"
raw_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_iso3c/mapspamc_tha_test/raw_data"
gams_path <- "C:/MyPrograms/GAMS/win64/24.6"

# Set MAPSPAMC parameters for the min_entropy_5min_adm_level_2_solve_level_0 model
param <- mapspamc_par(mapspamc_path = mapspamc_path,
                      raw_path = raw_path,
                      gams_path = gams_path,
                      iso3c = "THA",
                      year = 2020,
                      res = "5min",
                      adm_level = 2,
                      solve_level = 0,
                      model = "min_entropy")

ac <- "TH00"

ia_slackp = 0.05


# Function to calculate total at given adm level
calculate_pa_tot <- function(adm_lvl, ac, param) {
  load_intermediate_data(c("pa"), ac, param, local = T,mess = F)

  df <- pa %>%
    tidyr::gather(crop, pa, -adm_code, -adm_name, -adm_level) %>%
    dplyr::filter(adm_level == adm_lvl) %>%
    dplyr::group_by(adm_code, adm_name, adm_level) %>%
    dplyr::summarise(pa = sum(pa, na.rm = T)) %>%
    dplyr::ungroup()
  return(df)
}
