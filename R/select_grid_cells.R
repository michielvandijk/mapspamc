# Function to select grid cells by ranking and comparing them with the
# pa_adm_tot.
select_grid_cells <- function(df, adm_code, param, cl_slackp, cl_slackn) {

  # Select adm_levels for which grid cells need to be included. Note if adm2
  # data is complete for all crops and adms, there is no need to rank at adm0
  # and adm1 level. Similarly, if adm1 is complete there is no need to rank at
  # adm0 level. Ranking at higher level adms (e.g. ADM1)  when all data for the
  # higher level (e.g. ADM1) is complete results in different results as a the
  # ranking of cells grouped at the ADM2 level is different from that at ADM1
  # level. This function selects the highest level ADM if the total pa is the
  # same as the next level ADM.
  adm_level_include <-  purrr::map_df(0:param$adm_level, calculate_pa_tot, adm_code, param) %>%
    dplyr::group_by(adm_level) %>%
    dplyr::summarize(pa = sum(pa, na.rm = T)) %>%
    dplyr::mutate(rank  = dplyr::min_rank(pa)) %>%
    dplyr::group_by(rank) %>%
    dplyr::arrange(desc(adm_level), .by_group = TRUE) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup() %>%
    dplyr::select(adm_level)
  adm_level_include <- adm_level_include$adm_level


  # Rank and include grid cells at each adm level and select according to rule
  # as described above.
  cat("\nGrid cells of the following adm levels are included: ", fPaste(adm_level_include))
  grid_sel <- purrr::map_df(c(0:param$adm_level), rank_cl, df = df, adm_code = adm_code,
                            param = param, cl_slackp = cl_slackp, cl_slackn = cl_slackn) %>%
    dplyr::filter(adm_level %in% adm_level_include) %>%
    dplyr::select(gridID, adm_level) %>%
    dplyr::distinct()
  grid_sel <- grid_sel$gridID

  df_upd <- df %>%
    dplyr::filter(gridID %in% grid_sel)

  return(df_upd)
}

