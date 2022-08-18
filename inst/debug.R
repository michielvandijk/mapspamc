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

compare_adm2(pa_adm, pa_fs_adm, param$solve_level)

df1 <- pa_adm
df2 <- pa_fs_adm
level <- param$solve_level

compare_adm2 <- function(df1, df2, level, out = F){
  tot1 <- sum_adm_total(df1, level) %>%
    na.omit
  tot2 <- sum_adm_total(df2, level) %>%
    na.omit
  inter <- intersect(tot1$crop, tot2$crop)
  if(!isTRUE(all.equal(tot1$value[tot1$crop %in% inter],
                       tot2$value[tot2$crop %in% inter]))){
    stop(glue::glue("\ndf1 and df2 are not equal!",
                    call. = FALSE)
    )
  } else {
    cat("\ndf1 and df2 are equal")
  }

  out_df <- dplyr::bind_rows(
    sum_adm_total(df1, level) %>%
      mutate(source = "df1"),
    sum_adm_total(df2, level) %>%
      mutate(source = "df2")) %>%
    tidyr::spread(source, value) %>%
    mutate(difference = round(df1 - df2, 6)) %>%
    dplyr::select(-adm_level)
  if(out) return(out_df)
}


df <- df1

sum_adm_total <- function(df, level){
  unit <- names(df)[names(df) %in% c("ha", "pa")]
  names(df)[names(df) %in% c("ha", "pa")] <- "value"
  df <- df %>%
    dplyr::filter(adm_level == level) %>%
    dplyr::group_by(crop, adm_level) %>%
    dplyr::summarize(value = plus(value, na.rm = F)) %>%
    dplyr::arrange(crop)
  return(df)
}
