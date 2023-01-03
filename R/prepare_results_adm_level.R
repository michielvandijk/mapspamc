# function to prepare output file, combining ADM results
prepare_results_adm_level <- function(ac, param) {
  cat("\n=> Extract results for", ac)
  load_data(c("grid", "adm_map_r"), param, local = TRUE, mess = F)

  model_folder <- create_model_folder(param)
  results_file <- file.path(
    param$model_path,
    glue::glue("processed_data/intermediate_output/{model_folder}/{ac}/spamc_{param$model}_{param$res}_{param$year}_{ac}_{param$iso3c}")
  )

  grid_df <- as.data.frame(grid, xy = TRUE)
  df <- gdxrrw::rgdx.param(results_file, "alloc_ha", names = c("gridID", "crop_system", "pa"), compress = T) %>%
    dplyr::mutate(
      gridID = as.numeric(as.character(gridID)),
      crop_system = as.character(crop_system)
    ) %>%
    tidyr::separate(crop_system, into = c("crop", "system"), sep = "_", remove = T) %>%
    dplyr::left_join(adm_map_r, by = "gridID") %>%
    dplyr::left_join(grid_df, by = "gridID")

  return(df)
}
