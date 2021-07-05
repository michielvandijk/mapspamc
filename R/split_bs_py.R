# Process_bs_py
split_bs_py <- function(var, ac, param){

  temp_path <- file.path(param$spam_path,
                         glue::glue("processed_data/intermediate_output/{ac}/{param$res}"))
  dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

  if(var == "biophysical_suitability") {
    f <- file.path(temp_path, glue::glue("bs_{param$res}_{param$year}_{ac}_{param$iso3c}.rds"))
  }

  if(var == "potential_yield") {
    f <- file.path(temp_path, glue::glue("py_{param$res}_{param$year}_{ac}_{param$iso3c}.rds"))
  }

  if(file.exists(f)) {
    cat("\n", basename(f), "already exists. Not created again.")
  } else {
    cat(paste0("\n", ac))
    load_intermediate_data(c("cl_harm", "pa_fs"), ac, param, local = TRUE, mess = FALSE)
    load_data(c("grid"), param, local = TRUE, mess = FALSE)

    # Select relevant crop_system combinations to process
    pa_fs <- pa_fs %>%
      tidyr::gather(crop, pa, -adm_code, -adm_name, -adm_level, -system)

    cs_list <- pa_fs %>%
      dplyr::group_by(crop, system) %>%
      dplyr::filter(!all(pa %in% c(0, NA))) %>%
      dplyr::mutate(crop_system = paste(crop, system , sep = "_")) %>%
      dplyr::ungroup() %>%
      dplyr::select(crop_system) %>%
      unique

    # Process bs_py
    lookup <- dplyr::bind_rows(
      data.frame(files_full = list.files(file.path(param$spam_path,
                                                   glue::glue("processed_data/maps/{var}/{param$res}")), full.names = TRUE, pattern = glob2rx("*.tif")),
                 files = list.files(file.path(param$spam_path,
                                              glue::glue("processed_data/maps/{var}/{param$res}")), full.names = FALSE, pattern = glob2rx("*.tif")),
                 stringsAsFactors = FALSE)
    ) %>%
      tidyr::separate(files, into = c("crop", "system", "variable", "res", "year", "iso3c"), sep = "_", remove = F) %>%
      tidyr::separate(iso3c, into = c("iso3c", "ext"), sep = "\\.") %>%
      dplyr::select(-ext) %>%
      dplyr::mutate(crop_system = paste(crop, system, sep = "_"))

    cs_sel <- lookup$files_full[lookup$crop_system %in% cs_list$crop_system]

    # Process maps one-by-one
    df <- purrr::map_df(cs_sel, process_gaez, var = var, lookup = lookup, ac = ac, param = param)

    #save
    if(var == "biophysical_suitability") {
      df <- dplyr::rename(df, bs = value)
      saveRDS(df, file.path(temp_path, glue::glue("bs_{param$res}_{param$year}_{ac}_{param$iso3c}.rds")))

    } else {
      if(var == "potential_yield") {
        df <- dplyr::rename(df, py = value)
        saveRDS(df, file.path(temp_path, glue::glue("py_{param$res}_{param$year}_{ac}_{param$iso3c}.rds")))
      }
    }
  }
}


