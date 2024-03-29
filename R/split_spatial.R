# Function split and save ir_df and cl_df in line with solve_level
split_spatial <- function(ac, df, var, adm_map_r, param) {
  cat("\n=> Save ", var, " for ", ac)
  adm_sel <- paste0("adm", param$solve_level, "_code")
  df <- dplyr::left_join(df, adm_map_r, by = c("gridID")) %>%
    na.omit()
  df <- df[df[[adm_sel]] == ac, ]

  model_folder <- create_model_folder(param)
  temp_path <- file.path(
    param$model_path,
    glue::glue("processed_data/intermediate_output/{model_folder}/{ac}")
  )
  dir.create(temp_path, recursive = T, showWarnings = F)
  saveRDS(df, file.path(
    temp_path,
    glue::glue("{var}_{param$res}_{param$year}_{ac}_{param$iso3c}.rds")
  ))
}
