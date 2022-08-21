#'@title Aggregates gridded results of alternative model to the administrative unit level of the target model
#'
#'@description `aggregate_to_adm` aggregates gridded results of an alternative model specified by `alt_param`
#' to the administrative unit level determined by `adm_level` of the target model specified by `param`.
#' The model described by `alt_param` must be identical to the target model apart from the `adm_level`
#' parameter, which is set to a less-detailed level. A comparison of the output of `aggregate_to_adm` with
#' subnational information at the most detailed level available is a validation of the alternative model and,
#' indirectly, also of the target model.
#'
#'@param param
#'@inheritParams create_mapspamc_folders
#'
#'@param alt_param Object of type spamc_par that bundles all `mapspamc` parameters, including core model folders,
#'alpha-3 country code, year, spatial resolution, most detailed level at which subnational statistics are
#'available, administrative unit level at which the model is solved and type of model.
#'
#'@return data.frame with `mapspamc` results aggregated to the administrative unit level specified in
#'`alt_param`.
#'
#'@examples
#'\dontrun{
#'}
#'@export
aggregate_to_adm <- function(param, alt_param){
    stopifnot(inherits(param, "mapspamc_par"))
    stopifnot(inherits(alt_param, "mapspamc_par"))

    load_data("results", alt_param)
    load_data("adm_map", param)
    load_data("grid", param)

    aggregate_crop_adm <- function(cr){
        grid_df <- as.data.frame(grid, xy = TRUE)

        df <-  dplyr::filter(results, crop %in% cr) %>%
            dplyr::group_by(gridID, crop) %>%
            dplyr::summarize(value = sum(pa, na.rm = T), .groups = "drop") %>%
            na.omit() %>%
            dplyr::left_join(grid_df)

        crop_map_r <- terra::rast(df %>% dplyr::select(x, y, value), crs = param$crs)

        message(glue("{cr}"))

        ac_rn <- glue::glue("adm{param$adm_level}_code")
        an_rn <- glue::glue("adm{param$adm_level}_name")
        adm_map <- adm_map %>%
            dplyr::rename(adm_code := {{ac_rn}},
                          adm_name := {{an_rn}})

        df <- data.frame(
            adm_code = adm_map$adm_code,
            adm_name = adm_map$adm_name,
            crop = cr,
            value = exactextractr::exact_extract(crop_map_r, adm_map, fun = "sum")
        )
        return(df)
    }
    df_ag <- map_df(unique(results$crop),  aggregate_crop_adm)
    model_folder <- create_model_folder(alt_param)
    temp_path <- file.path(param$mapspamc_path,
                           glue::glue("processed_data/results/{model_folder}"))
    dir.create(temp_path, showWarnings = F, recursive = T)
    saveRDS(df_ag, file.path(temp_path, glue::glue("results_aggregated to_adm{param$adm_level}_{param$year}_{param$iso3c}.rds")))
    return(df_ag)
}
