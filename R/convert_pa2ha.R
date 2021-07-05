#'@export
convert_ha2pa <- function(df) {

  load_data(c("ci"), param, mess = F)

  ac_rn <- glue::glue("adm{param$solve_level}_code")
  an_rn <- glue::glue("adm{param$solve_level}_name")

  ci <- ci %>%
    tidyr::gather(crop, ci, -adm_name, -adm_code, -adm_level, -system) %>%
    dplyr::filter(adm_level == param$solve_level) %>%
    dplyr::rename({{ac_rn}} := adm_code,
                  {{an_rn}} := adm_name) %>%
    dplyr::select(-adm_level)

  results <- results %>%
    dplyr::left_join(ci) %>%
    dplyr::mutate(ha = pa*ci)
}


