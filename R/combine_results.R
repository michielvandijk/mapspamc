#'@title Combines SPAMc GAMS output into a single rds file
#'
#'@description Combines the GAMs results that are saved in one (`solve_level =
#'  0`)  or multiple (`solve_level = 1`) gdx files into a single rds file, that can be
#'  easily loaded into R. The file is saved in the `processed_data/results` folder.
#'
#'@param param
#'@inheritParams create_spam_folders
#'@param cut numeric. Sets allocation smaller than a certain value to 0. The default is 0.0001 (1 m2).
#'@param out logical; should the results be returned as output?
#'@examples
#'\dontrun{
#'combine_results(param)
#'}#'
#'@export
combine_results <- function(param, cut = 0.0001, out = FALSE) {
   stopifnot(inherits(param, "spam_par"))
   stopifnot(is.logical(out))

   # Test if gdxrrw and gams are installed.
   setup_gams(param)

   cat("\n\n############### COMBINE RESULTS ###############")
   load_data(c("adm_list", "ci"), param, local = TRUE, mess = FALSE)

  # Set adm_level
  if(param$solve_level == 0) {
    adm_code_list <- unique(adm_list$adm0_code)
  } else {
    adm_code_list <- unique(adm_list$adm1_code)
  }

 df <- purrr::map_df(adm_code_list, prepare_results_adm_level, param) %>%
   dplyr::mutate(year = param$year,
          resolution = param$res,
          model = param$model,
          solve_level = param$solve_level)

 ac_rn <- glue::glue("adm{param$solve_level}_code")
 an_rn <- glue::glue("adm{param$solve_level}_name")

 ci <- ci %>%
   tidyr::gather(crop, ci, -adm_name, -adm_code, -adm_level, -system) %>%
   dplyr::filter(adm_level == param$solve_level) %>%
   dplyr::rename({{ac_rn}} := adm_code,
                 {{an_rn}} := adm_name) %>%
   dplyr::select(-adm_level)

 # Add suppressMessages to suppress joining by message followin left_join.
 # by = cannot be used as join depends on param$adm_level so cannot be set in advance
 df <- suppressMessages(df %>%
   dplyr::left_join(ci) %>%
   dplyr::mutate(ha = pa*ci) %>%
   dplyr::select(gridID, crop, system, ha, pa, everything(), pa, ha))

 temp_path <- file.path(param$spam_path,
                        glue::glue("processed_data/results/{param$res}/{param$model}"))
 dir.create(temp_path, showWarnings = F, recursive = T)

 # Remove pa values smaller than cut. Both pa and ha are removed for consistency
 df <- df %>%
    dplyr::filter(ha > cut)

 saveRDS(df, file.path(temp_path, glue::glue("results_{param$res}_{param$year}_{param$iso3c}.rds")))

 if(out) {
    return(df)
    }
}




