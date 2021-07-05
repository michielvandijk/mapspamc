#'Prepares the physical area subnational statistics so they can be used as input
#'for SPAM.
#'
#'To estimate the physical crop area for each farming system harvest area (ha)
#'statistics are combined with information on farmings sytem shares (fs) and
#'cropping intensity (ci). Depending on how the model is solved, the physical
#'area statistics are saved at the administrative unit level 0 (country) level
#'(model solve level 0) or at the level 1 administrative unit level (model solve
#'level 1).
#'
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
    stopifnot(inherits(param, "spam_par"))
    cat("\n\n############### PREPARE PHYSICAL AREA ###############")
    load_data(c("adm_list", "ha", "fs", "ci"), param, local = TRUE, mess = FALSE)

    # Set adm_level
    if(param$solve_level == 0) {
        adm_code_list <- unique(adm_list$adm0_code)
    } else {
        adm_code_list <- unique(adm_list$adm1_code)
    }

    # wide to long format
    ha <- ha %>%
        gather(crop, ha, -adm_name, -adm_code, -adm_level)

    # Set -999 and empty string values
    ha <- ha %>%
        mutate(ha = if_else(ha == -999, NA_real_, ha))

    # filter out crops which values are all zero or NA
    crop_na_0 <- ha %>%
        group_by(crop) %>%
        filter(all(ha %in% c(0, NA))) %>%
        dplyr::select(crop) %>%
        unique

    ha <- ha %>%
        filter(!crop %in% crop_na_0$crop)

    # Remove lower level adm data if it would somehow not be used
    ha <- ha %>%
        filter(adm_level <= param$adm_level)

    # wide to long format
    fs <- fs %>%
        gather(crop, fs, -adm_name, -adm_code, -adm_level, -system)

    # Set -999 and empty string values
    fs <- fs %>%
        mutate(fs = if_else(fs == -999, NA_real_, fs))

    # Select relevent crops using ha
    fs <- fs %>%
        filter(crop %in% unique(ha$crop))

    # wide to long format
    ci <- ci %>%
        gather(crop, ci, -adm_name, -adm_code, -adm_level, -system)

    # Set -999 and empty string values
    ci <- ci %>%
        mutate(ci = if_else(ci == -999, NA_real_, ci))

    # Select relevent crops using ha
    ci <- ci %>%
        filter(crop %in% unique(ha$crop))

    # Save
    purrr::walk(adm_code_list, split_statistics, ha, fs, ci, param)
}

