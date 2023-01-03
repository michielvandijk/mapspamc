# Function that iterates over adm level starting with the most detailed and
# update cl so it is in line with pa.
harmonize_cl <- function(df, ac, param) {
  if (param$solve_level == 0) {
    for (i in param$adm_level:0) {
      problem_adm <- check_cl(df = df, adm_lvl = i, ac, param)
      df <- update_cl(df, problem_adm = problem_adm, adm_lvl = i)
    }
  }
  if (param$solve_level == 1) {
    for (i in param$adm_level:1) {
      problem_adm <- check_cl(df = df, adm_lvl = i, ac, param)
      df <- update_cl(df, problem_adm = problem_adm, adm_lvl = i)
    }
  }
  return(df)
}

# Function to update cl if cl_tot < adm
update_cl <- function(df, problem_adm, adm_lvl) {
  rn <- paste0("adm", adm_lvl, "_code")
  if (NROW(problem_adm) > 0) {
    df_upd <- df %>%
      dplyr::mutate(cl = ifelse(.data[[rn]] %in% problem_adm$adm_code, cl_max, cl))
    return(df_upd)
  } else {
    return(df)
  }
}

# functions to compare cl_mean with pa and replace where needed.
check_cl <- function(df, adm_lvl, ac, param) {
  cat("\nadm level: ", adm_lvl)

  pa_adm_tot <- purrr::map_df(0:param$adm_level, calculate_pa_tot, ac, param)
  rn <- paste0("adm", adm_lvl, "_code")

  cl_check <- df %>%
    dplyr::rename(adm_code = {{ rn }}) %>%
    dplyr::group_by(adm_code) %>%
    dplyr::summarize(
      cropland = sum(cl, na.rm = T),
      max_cropland = sum(cl_max, na.rm = T),
      grid_area = sum(grid_size, na.rm = T)
    ) %>%
    dplyr::left_join(pa_adm_tot %>%
      dplyr::filter(adm_level == adm_lvl), by = "adm_code") %>%
    dplyr::mutate(
      cl_short = cropland - pa,
      max_cl_short = max_cropland - pa,
      ga_short = grid_area - pa
    ) %>%
    dplyr::select(
      adm_code, adm_name, adm_level, cropland, max_cropland, grid_area, pa, cl_short, max_cl_short,
      ga_short
    ) %>%
    dplyr::arrange(adm_code, adm_name) %>%
    dplyr::ungroup()

  problem_adm <- dplyr::filter(cl_check, cl_short < 0)
  if (NROW(problem_adm) == 0) {
    cat("\nNo adjustments needed for cropland")
  } else {
    cl_max_rp <- problem_adm$adm_code[problem_adm$max_cl_short > 0 & problem_adm$ga_short > 0]
    cl_not_rp1 <- problem_adm$adm_code[problem_adm$max_cl_short < 0 & problem_adm$ga_short > 0]
    cl_not_rp2 <- problem_adm$adm_code[problem_adm$max_cl_short < 0 & problem_adm$ga_short < 0]

    if (length(cl_max_rp) > 0) {
      cat("\nFor the following ADMs, cropland is set to max cropland to address inconsistencies.")
      print(knitr::kable(
        problem_adm %>%
          dplyr::filter(adm_code %in% c(cl_max_rp, cl_not_rp1, cl_not_rp2)),
        digits = 0,
        format.args = list(big.mark = ",")
      ))
    }

    if (length(cl_not_rp1) > 0) {
      cat(
        "\nFor these ADMs inconsistencies remain as total crop area is larger than the maximum available cropland.",
        "\nThis will result in slack."
      )
      print(knitr::kable(
        problem_adm %>%
          dplyr::filter(adm_code %in% cl_not_rp1),
        digits = 0,
        format.args = list(big.mark = ",")
      ))
    }

    if (length(cl_not_rp2) > 0) {
      cat(
        "\nFor these ADMs inconsistencies remain as total crop area is larger than the grid area.",
        "\nThis will result in slack."
      )
      print(knitr::kable(
        problem_adm %>%
          dplyr::filter(adm_code %in% cl_not_rp2),
        digits = 0,
        format.args = list(big.mark = ",")
      ))
    }
  }
  return(problem_adm)
}
