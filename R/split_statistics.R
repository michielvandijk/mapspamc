# Function to combine ha, fs and ci and split
# Need to split first and then combine as in split version, adm specific fs and ci are used
#'@importFrom magrittr %>%
split_statistics <- function(ac, ha, fs, ci, param){
  load_data("adm_list", param, local = TRUE, mess = F)
  cat("\nSave pa and pa_fs statistics for", ac)

  ha_adm <- dplyr::bind_rows(
    ha[ha$adm_code == ac,],
    ha[ha$adm_code %in% adm_list$adm1_code[adm_list$adm0_code == ac],],
    ha[ha$adm_code %in% adm_list$adm2_code[adm_list$adm1_code == ac],],
    ha[ha$adm_code %in% adm_list$adm2_code[adm_list$adm0_code == ac],]) %>%
    unique()

  # Select fs and ci for top level ADM only. We apply these to lower levels.
  fs_adm <- dplyr::bind_rows(
    fs[fs$adm_code == ac,]) %>%
    dplyr::select(-adm_code, -adm_name, -adm_level) %>%
    unique()

  ci_adm <- dplyr::bind_rows(
    ci[ci$adm_code == ac,]) %>%
    dplyr::select(-adm_code, -adm_name, -adm_level) %>%
    unique()

  # Calculate physical area using cropping intensity information.
  pa_adm <- ha_adm %>%
    dplyr::left_join(ci_adm, by = "crop")  %>%
    dplyr::left_join(fs_adm, by = c("crop", "system")) %>%
    dplyr::mutate(pa = ha*fs/ci) %>%
    dplyr::group_by(adm_name, adm_code, crop, adm_level) %>%
    dplyr::summarize(pa = plus(pa, na.rm = T)) %>%
    ungroup()

  # Calculate physical area broken down by farming systems
  pa_fs_adm <- pa_adm %>%
    dplyr::filter(adm_code == ac) %>%
    dplyr::left_join(fs_adm, by = "crop") %>%
    dplyr::mutate(pa = pa*fs) %>%
    dplyr::select(-fs) %>%
    ungroup()

  # consistency check
  compare_adm2(pa_adm, pa_fs_adm, param$solve_level)

  pa_adm <- pa_adm %>%
    tidyr::spread(crop, pa) %>%
    dplyr::arrange(adm_code, adm_name, adm_level)

  pa_fs_adm <- pa_fs_adm %>%
    tidyr::spread(crop, pa) %>%
    dplyr::arrange(adm_code, adm_name, adm_level)

  temp_path <- file.path(param$spam_path,
                         glue::glue("processed_data/intermediate_output/{ac}/{param$res}"))
  dir.create(temp_path, recursive = T, showWarnings = F)
  readr::write_csv(pa_adm, file.path(temp_path,
                              glue::glue("pa_{param$year}_{ac}_{param$iso3c}.csv")))
  readr::write_csv(pa_fs_adm, file.path(temp_path,
                                 glue::glue("pa_fs_{param$year}_{ac}_{param$iso3c}.csv")))
}
