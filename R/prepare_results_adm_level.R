# function to prepare output file, combining ADM results
prepare_results_adm_level <- function(ac, param) {

  cat("\nExtract results for", ac)
  load_data(c("grid", "adm_map_r"), param, mess = F)

  results_file <- file.path(param$spam_path,
    glue::glue("processed_data/intermediate_output/{ac}/{param$res}/spamc_{param$model}_{param$res}_{param$year}_{ac}_{param$iso3c}"))

  grid_df <- as.data.frame(raster::rasterToPoints(grid)) %>%
    setNames(c("x", "y", "gridID"))
  df <- gdxrrw::rgdx.param(results_file, "palloc", names = c("gridID", "crop_system", "pa"),  compress = T) %>%
    dplyr::mutate(gridID = as.numeric(as.character(gridID)),
           crop_system = as.character(crop_system)) %>%
    tidyr::separate(crop_system, into = c("crop", "system"), sep = "_", remove = T) %>%
    dplyr::left_join(adm_map_r, by = "gridID") %>%
    dplyr::left_join(grid_df, by = "gridID")

  return(df)
}
