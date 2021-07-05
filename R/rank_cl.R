# FUnction to rank grid cells at each main and nested adm level comparing with
# pa_adm_tot.
rank_cl <- function(df, adm_lvl, adm_code, param, cl_slackp, cl_slackn) {

  # Rank cropland cells till sum is at least equal to the statistics.  We add
  # the minimum of 5 grid_sell area or slack percentage to ensure this.
  pa_adm_tot <- purrr::map_df(0:param$adm_level, calculate_pa_tot, adm_code, param)
  rn <- paste0("adm", adm_lvl, "_code")

  # Rank adm to match lu
  adm_rank <- df %>%
    dplyr::rename(adm_code = {{rn}}) %>%
    dplyr::group_by(adm_code) %>%
    dplyr::arrange(adm_code, cl_rank, desc(cl), .by_group = TRUE) %>%
    dplyr::mutate(adm_cum = cumsum(cl)) %>%
    dplyr::left_join(pa_adm_tot %>%
                       dplyr::filter(adm_level == adm_lvl, !is.na(pa), pa != 0) %>%
                       dplyr::select(adm_code, adm_level, adm_name, pa), by = "adm_code") %>%
    dplyr::mutate(slack = min(pa * cl_slackp, min(cl_slackn*max(df$grid_size)))) %>%
    dplyr::filter(adm_cum <= pa + slack) %>%
    dplyr::ungroup() %>%
    dplyr::select(gridID, adm_level, adm_code, adm_name)
  return(adm_rank)
}
