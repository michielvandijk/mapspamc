# Function to prepare artificial adms
prepare_artificial_adms <- function(ac, param) {

  cat("\nPrepare artificial administrative units for", ac)
  load_intermediate_data(c("pa"), ac, param, local = TRUE, mess = FALSE)
  load_data(c("adm_list"), param, local = TRUE, mess = FALSE)

  # Put statistics in long format and filter out crops where pa = 0
  # These crops create artificial adms, which created conflicts
  pa <- pa %>%
    tidyr::gather(crop, pa, -adm_code, -adm_name, -adm_level)

  adm_list_at_highest_level <- unique(pa$adm_code[pa$adm_level == param$adm_level])
  ac_rn <- glue::glue("adm{param$adm_level}_code")
  base <- expand.grid(adm_code = adm_list_at_highest_level, crop = unique(pa$crop), stringsAsFactors = F) %>%
    dplyr::rename({{ac_rn}} := adm_code) %>%
    dplyr::mutate(adm_level = param$adm_level) %>%
    dplyr::left_join(adm_list, by = {{ac_rn}})

  ## Prepare loop
  step <- param$adm_level - param$solve_level
  init <- param$solve_level

  # set adm_art at lowest level
  ac_solve_rn <- glue::glue("adm{param$solve_level}_code")
  pa_solve_rn <- glue::glue("pa_adm{param$solve_level}")
  adm_art <- filter_out_pa({{param$solve_level}}, pa) %>%
    dplyr::mutate("adm{{init}}_code_art" := .data[[{{ac_solve_rn}}]]) %>%
    dplyr::rename("imp_adm{{init}}" := {{pa_solve_rn}}) %>%
    dplyr::select(-adm_level)

  # Only create artificial adms if step is larger than zero
  # Otherwise adm are the same as adm_art at the lowest level
  if(step > 0) {
    for(i in seq(init, param$adm_level, 1)[c(1:step)]) {
      adm_art <- identify_art_adms_per_level(i, adm_art, pa, base)
    }
  }

  return(adm_art)
}
