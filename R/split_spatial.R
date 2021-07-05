# Function split and save ir_df and cl_df in line with solve_level
split_spatial <- function(ac, df, var, adm_map_r, param){
  cat("\nSave ", var, " for ", ac)
  adm_sel <- paste0("adm", param$solve_level, "_code")
  df <- dplyr::left_join(df, adm_map_r, by = c("gridID")) %>%
    na.omit()
  df <- df[df[[adm_sel]] == ac,]

  temp_path <- file.path(param$spam_path,
                         glue::glue("processed_data/intermediate_output/{ac}/{param$res}"))
  dir.create(temp_path, recursive = T, showWarnings = F)
  saveRDS(df, file.path(temp_path,
                        glue::glue("{var}_{param$res}_{param$year}_{ac}_{param$iso3c}.rds")))
}
