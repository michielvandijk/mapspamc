#'@title
#'Creates `mapspamc` folder structure
#'
#'@description
#'`create_folders` creates the folder structure that is needed store raw
#'data, processed data and parameters for `mapspamc`.
#'
#'@details
#'`create_folders` creates two folders in the `model_path`, set by the user:
#'mappings and processed_data (including subfolders). It copies a number of cvs files
#'into the mappings folder, which contain several data tables that are needed to run
#'the model and, if needed can be adjusted by the user. If set by the user a mapspamc_db
#'folder (including subfolders) is created in  `db_path`. Otherwise the folder is
#'created in the model folder.
#'
#'@param param Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
#'  including core model folders, alpha-3 country code, year, spatial
#'  resolution, most detailed level at which subnational statistics are
#'  available, administrative unit level at which the model is solved and type of
#'  model.
#'
#'@examples
#'\dontrun{
#'create_folders(param)
#'}
#'
#'@export
create_folders <- function(param = NULL) {
    stopifnot(inherits(param, "mapspamc_par"))
    if(!dir.exists(param$db_path))
        dir.create(param$db_path, showWarnings = TRUE, recursive = TRUE)
    db_folders <- c("adm", "aquastat", "copernicus", "esacci", "esri",
                    "faostat", "gaez", "gia", "glad", "gmia", "grump", "sasam",
                    "subnational_statistics", "synergy_cropland_table",
                    "travel_time", "worldpop")
    purrr::walk(db_folders, function(x) {
      if(!dir.exists(file.path(param$db_path, paste0("", x)))) {
        dir.create(file.path(param$db_path, paste0("", x)),
                   showWarnings = TRUE,
                   recursive = TRUE)
      }
    })

    if(!dir.exists(file.path(param$model_path, "processed_data")))
        dir.create(file.path(param$model_path, paste0("processed_data")),
                   showWarnings = TRUE, recursive = TRUE)
    proc_folders <- c("lists",
                      "intermediate_output",
                      "agricultural_statistics",
                      "maps/adm",
                      "maps/grid",
                      "maps/biophysical_suitability",
                      "maps/potential_yield",
                      "maps/accessibility",
                      "maps/population",
                      "maps/irrigated_area",
                      "maps/cropland",
                      "results")
    purrr::walk(proc_folders, function(x) {
        if(!dir.exists(file.path(param$model_path, paste0("processed_data/", x)))) {
            dir.create(file.path(param$model_path, paste0("processed_data/", x)),
                       showWarnings = TRUE,
                       recursive = TRUE)
        }
    })

    if(!dir.exists(file.path(param$model_path, "mappings")))
        dir.create(file.path(param$model_path, "mappings"), showWarnings = TRUE, recursive = TRUE)

    copy_mapping_files <- function(param) {
      mapping_files <- list.files(system.file("mappings", package = "mapspamc"), full.names = TRUE)

      purrr::walk(mapping_files, function(x) {
        if(!file.exists(file.path(param$model_path, paste0("mappings/", basename(x))))) {
          file.copy(x, file.path(param$model_path, paste0("mappings/", basename(x))))
        }
      })
    }
    copy_mapping_files(param)

    cat("\n=> mapspamc folder structure created in", param$model_path,
        "\n=> mapspamc raw_path created in", param$db_path)
}
