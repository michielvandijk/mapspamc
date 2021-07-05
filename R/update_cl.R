# Function to update cl if cl_tot < adm
update_cl <- function(df, problem_adm, adm_lvl) {

  rn <- paste0("adm", adm_lvl, "_code")
  if(NROW(problem_adm) > 0) {
    cat("\ncl is updated to cl_max for the following adms")
    cl_max_rp <- problem_adm$adm_code[problem_adm$short_max > 0 & problem_adm$short_gs > 0]
    solved_adm <- problem_adm %>%
      dplyr::filter(adm_code %in% cl_max_rp) %>%
      dplyr::transmute(adm_code, adm_name, adm_level, cl_tot_old = cl_tot,
                       cl_tot_upd = cl_tot_max, pa)

    print(knitr::kable(solved_adm,
                       digits = 0,
                       format.args = list(big.mark   = ",")))

    df_upd <- df %>%
      dplyr::mutate(cl = ifelse(.data[[rn]] %in% problem_adm$adm_code, cl_max, cl))
    return(df_upd)
  } else {
    return(df)
  }
}
