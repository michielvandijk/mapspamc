# Function to determine area of simu that is covered by specific land cover class
#'@export
calc_lc_area <- function(mapping, lc_map, param) {
  cat("\n############### Calculate land cover class area per simu ###############")
  mp <- mapping %>%
    dplyr::group_by(globiom_lc_code) %>%
    dplyr::summarize(lc_code = list(unique(lc_code)))

  load_data("simu", param, mess = F, local = T)
  simu <- simu %>%
    dplyr::group_by(SimUID) %>%
    dplyr::summarize(simu_area = sum(simu_area, na.rm = T)/1000) %>% # to 1000 ha, which is used by GLOBIOM
    dplyr::mutate(geometry = sf::st_cast(geometry, "MULTIPOLYGON")) %>% # Cast to MP for exactextract
    dplyr::ungroup()

  simu_area_df <- simu %>%
    sf::st_drop_geometry(.) %>%
    dplyr::select(SimUID, value = simu_area) %>%
    dplyr::mutate(globiom_lc_code = "SimUarea")

  calc_share <- function(i, r, mp, simu) {

    globiom_lc_code <- mp$globiom_lc_code[i]
    cat("\nProcessing", globiom_lc_code)
    lc_code <- mp$lc_code[i][[1]]

    # Total lc resolution cells of lc_code class covered
    simu[,c("n_lc")] <- exactextractr::exact_extract(r, simu, function(values, coverage_fraction)
      sum(coverage_fraction[values %in% lc_code]))

    # Total number of cells at lc resolution in polygon
    simu[,c("n_all")] <- exactextractr::exact_extract(r, simu, function(values, coverage_fraction)
      sum(coverage_fraction))

    # Note that total coverage does not add up to one as border SimUID polygons are not
    # always fully covered by underlying lc map.
    df <- simu %>%
      sf::st_drop_geometry(.) %>%
      dplyr::mutate(globiom_lc_code = globiom_lc_code,
                    area = n_lc/n_all*simu_area) %>%
      dplyr::select(SimUID, globiom_lc_code, value = area)


    return(df)
  }

  df <- dplyr::bind_rows(
    purrr::map_df(1:nrow(mp), calc_share, r = lc_map, mp = mp, simu = simu),
    simu_area_df)
  return(df)
}
