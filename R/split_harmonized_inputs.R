# Harmonizes data in line with solve level
#
#' @importFrom magrittr %>%
#'
split_harmonized_inputs <- function(ac, param, cl_slackp, cl_slackn, ia_slackp, ia_slackn) {
  # https://stackoverflow.com/questions/7096989/how-to-save-all-console-output-to-file-in-r
  model_folder <- create_model_folder(param)
  log_file <- file(file.path(
    param$model_path,
    glue::glue("processed_data/intermediate_output/{model_folder}/{ac}/log_{param$res}_{param$year}_{ac}_{param$iso3c}.log")
  ))
  capture.output(file = log_file, append = FALSE, split = T, {
    cat("\n\n--------------------------------------------------------------------------------------------------------------")
    cat("\n", ac)
    cat("\n--------------------------------------------------------------------------------------------------------------")

    ############### STEP 1: LOAD DATA ###############
    # Load data
    load_intermediate_data(c("cl"), ac, param, local = T, mess = F)

    ############### STEP 2: SET CL TO MEDIAN CROPLAND ###############
    # Create df of cl map,  set cl to median cropland
    # Remove few cells where gridID is missing, caused by masking grid with country borders using gdal.
    cl_df <- cl %>%
      dplyr::mutate(cl = cl_mean)

    # Remove gridID where cl_rank is NA
    cl_df <- cl_df %>%
      dplyr::filter(!is.na(cl_rank))

    ############### STEP 3: HARMONIZE CL   ###############
    cl_df <- harmonize_cl(df = cl_df, ac, param)


    ############### STEP 4: HARMONIZE IA ###############
    cl_df <- harmonize_ia(cl_df, ac, param, ia_slackp = ia_slackp, ia_slackn = ia_slackn) %>%
      dplyr::mutate(
        ia = ifelse(is.na(ia), 0, ia),
        ia_max = ifelse(is.na(ia_max), 0, ia_max)
      )

    ############### STEP 5: PREPARE FINAL CL MAP BY RANKING CELLS PER ADM ###############
    cl_df <- select_grid_cells(cl_df, ac, param, cl_slackp = cl_slackp, cl_slackn = cl_slackn)


    ############### STEP 6: PREPARE FILES ###############
    # Irrigation
    ia_harm_df <- cl_df %>%
      dplyr::select(gridID, ia) %>%
      na.omit()

    # Cropland: rename adm_code to param$adm_level
    adm_level_sel <- glue::glue("adm{param$adm_level}_code")
    cl_harm_df <- cl_df[c("gridID", adm_level_sel, "cl")]
    names(cl_harm_df)[names(cl_harm_df) == adm_level_sel] <- "adm_code"
    cl_harm_df$adm_level <- param$adm_level


    ############### STEP 6: CREATE MAPS ###############
    # cl map
    cl_harm_r <- gridID2raster(cl_harm_df, "cl", param)

    # ia map
    ia_harm_r <- gridID2raster(ia_harm_df, "ia", param)


    ############### STEP 7: SAVE ###############
    temp_path <- file.path(
      param$model_path,
      glue::glue("processed_data/intermediate_output/{model_folder}/{ac}")
    )
    dir.create(temp_path, recursive = T, showWarnings = F)

    saveRDS(cl_harm_df, file.path(
      temp_path,
      glue::glue("cl_harm_{param$res}_{param$year}_{ac}_{param$iso3c}.rds")
    ))
    terra::writeRaster(cl_harm_r, file.path(
      temp_path,
      glue::glue("cl_harm_r_{param$res}_{param$year}_{ac}_{param$iso3c}.tif")
    ), overwrite = T)

    # ia_harm
    saveRDS(ia_harm_df, file.path(
      temp_path,
      glue::glue("ia_harm_{param$res}_{param$year}_{ac}_{param$iso3c}.rds")
    ))
    terra::writeRaster(ia_harm_r, file.path(
      temp_path,
      glue::glue("ia_harm_r_{param$res}_{param$year}_{ac}_{param$iso3c}.tif")
    ), overwrite = T)
  })
}
