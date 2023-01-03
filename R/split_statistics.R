# Function to combine ha, ps and ci and split into submodels if solve_level = 1 is selected
# Need to split first and then combine the data as in the ADM1 models, adm specific ps and ci data are used
#' @importFrom magrittr %>%
split_statistics <- function(ac, ha, ps, ci, param) {
  cat("\n=> Prepare physical area")
  load_data("adm_list", param, local = TRUE, mess = F)
  cat("\n=> Save pa and pa_ps statistics for", ac)

  ha_adm <- dplyr::bind_rows(
    ha[ha$adm_code == ac, ],
    ha[ha$adm_code %in% adm_list$adm1_code[adm_list$adm0_code == ac], ],
    ha[ha$adm_code %in% adm_list$adm2_code[adm_list$adm1_code == ac], ],
    ha[ha$adm_code %in% adm_list$adm2_code[adm_list$adm0_code == ac], ]
  ) %>%
    unique()

  # Select ps and ci for top level ADM only. We apply these to lower levels.
  ps_adm <- dplyr::bind_rows(
    ps[ps$adm_code == ac, ]
  ) %>%
    dplyr::select(-adm_code, -adm_name, -adm_level) %>%
    unique()

  ci_adm <- dplyr::bind_rows(
    ci[ci$adm_code == ac, ]
  ) %>%
    dplyr::select(-adm_code, -adm_name, -adm_level) %>%
    unique()

  # Calculate physical area using cropping intensity information.
  pa_adm <- ha_adm %>%
    dplyr::left_join(ci_adm, by = "crop") %>%
    dplyr::left_join(ps_adm, by = c("crop", "system")) %>%
    dplyr::mutate(pa = ha * ps / ci) %>%
    dplyr::group_by(adm_name, adm_code, crop, adm_level) %>%
    dplyr::summarize(
      pa = plus(pa, na.rm = T),
      .groups = "drop"
    ) %>%
    ungroup()

  # Calculate physical area broken down by production systems
  pa_ps_adm <- pa_adm %>%
    dplyr::filter(adm_code == ac) %>%
    dplyr::left_join(ps_adm, by = "crop") %>%
    dplyr::mutate(pa = pa * ps) %>%
    dplyr::select(-ps) %>%
    ungroup()

  # consistency check
  compare_adm2(pa_adm, pa_ps_adm, param$solve_level)

  pa_adm <- pa_adm %>%
    tidyr::spread(crop, pa) %>%
    dplyr::arrange(adm_code, adm_name, adm_level)

  pa_ps_adm <- pa_ps_adm %>%
    tidyr::spread(crop, pa) %>%
    dplyr::arrange(adm_code, adm_name, adm_level)

  model_folder <- create_model_folder(param)
  temp_path <- file.path(
    param$model_path,
    glue::glue("processed_data/intermediate_output/{model_folder}/{ac}")
  )
  dir.create(temp_path, recursive = T, showWarnings = F)

  readr::write_csv(pa_adm, file.path(
    temp_path,
    glue::glue("pa_{param$year}_{ac}_{param$iso3c}.csv")
  ))
  readr::write_csv(pa_ps_adm, file.path(
    temp_path,
    glue::glue("pa_ps_{param$year}_{ac}_{param$iso3c}.csv")
  ))
}
