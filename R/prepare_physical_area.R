#'@title
#'Calculates physical crop area at the subnational level
#'
#'@description
#'To estimate the physical crop area for each farming system harvest area (ha)
#'statistics are combined with information on farmings system shares (fs) and
#'cropping intensity (ci). Depending on how the model is solved, the physical
#'area statistics are saved at the administrative unit level 0 (country) level
#'(model solve level 0) or at the level 1 administrative unit level (model solve
#'level 1).
#'
#'@details
#'`prepare_physical_area` combines ha, fs and ci statistics and saves two files in csv
#'format: (1) physical area (pa) and (2) physical area broken down by farming
#'systems (pa_fs). Results are saved in the subfolders that are located in the
#'the `processed_data/intermediate` folder.
#'
#'@param param
#'@inheritParams create_grid
#'
#'@examples
#'
#'@export
prepare_physical_area <- function(param){
    stopifnot(inherits(param, "mapspamc_par"))
    cat("\n=> Prepare physical area")
    load_data(c("adm_list", "ha", "fs", "ci"), param, local = TRUE, mess = FALSE)

    # Set adm_level
    if(param$solve_level == 0) {
        ac <- unique(adm_list$adm0_code)
    } else {
        ac <- unique(adm_list$adm1_code)
    }

    # wide to long format
    ha <- ha %>%
        tidyr::pivot_longer(-c(adm_name, adm_code, adm_level), names_to = "crop", values_to = "ha")

    # Set -999 and empty string values
    ha <- ha %>%
        dplyr::mutate(ha = ifelse(ha == -999, NA_real_, ha))

    # filter out crops which values are all zero or NA
    crop_na_0 <- ha %>%
        dplyr::group_by(crop) %>%
        dplyr::filter(all(ha %in% c(0, NA))) %>%
        dplyr::select(crop) %>%
        unique

    ha <- ha %>%
        dplyr::filter(!crop %in% crop_na_0$crop)

    # Remove lower level adm data if it would somehow not be used
    ha <- ha %>%
        dplyr::filter(adm_level <= param$adm_level)

    # wide to long format
    fs <- fs %>%
      tidyr::pivot_longer(-c(adm_name, adm_code, adm_level, system), names_to = "crop", values_to = "fs")

    # Set -999 and empty string values
    fs <- fs %>%
        dplyr::mutate(fs = ifelse(fs == -999, NA_real_, fs))

    # Select relevant crops using ha
    fs <- fs %>%
        dplyr::filter(crop %in% unique(ha$crop))

    # wide to long format
    ci <- ci %>%
      tidyr::pivot_longer(-c(adm_name, adm_code, adm_level, system), names_to = "crop", values_to = "ci")

    # Set -999 and empty string values
    ci <- ci %>%
        dplyr::mutate(ci = ifelse(ci == -999, NA_real_, ci))

    # Select relevant crops using ha
    ci <- ci %>%
        dplyr::filter(crop %in% unique(ha$crop))

    # Save
    purrr::walk(ac, split_statistics, ha, fs, ci, param)
}

