#'Create `mapspamc` folder structure
#'
#'`create_mapspamc_folders` creates the folder structure that is needed store raw
#'data, processed data and parameters for `mapspamc`.
#'
#'`create_mapspamc_folders` creates two folders in the `mapspamc_path`, set by the user:
#'mappings and processed_data, and creates a `raw_data` folder in the location
#'as set in `mapspamc_par`. In addition, it copies a number of cvs files into the
#'mappings folder, which contain several data tables that are needed to run the
#'model and, if needed can be adjusted by the user.
#'
#'@param param Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
#'  including core model folders, alpha-3 country code, year, spatial
#'  resolution, most detailed level at which subnational statistics are
#'  available, administrative unit level at which the model is solved and type of
#'  model.
#'
#'@examples
#'\dontrun{
#'create_mapspamc_folders(param)
#'}
#'
#'@export
create_mapspamc_folders <- function(param = NULL) {
    stopifnot(inherits(param, "mapspamc_par"))
    if(!dir.exists(param$raw_path))
        dir.create(param$raw_path, showWarnings = TRUE, recursive = TRUE)
    raw_folders <-
        c(
            "adm",
            "aquastat",
            "faostat",
            "gaez",
            "gia",
            "gmia",
            "grump",
            "sasam",
            "subnational_statistics",
            "travel_time_2000",
            "travel_time_2015",
            "worldpop"
        )

    purrr::walk(raw_folders, function(x) {
        if(!dir.exists(file.path(param$raw_path, x))) {
            dir.create(file.path(param$raw_path, x),
                       showWarnings = TRUE,
                       recursive = TRUE)
            }
    })

    if(!dir.exists(file.path(param$mapspamc_path, "processed_data")))
        dir.create(file.path(param$mapspamc_path, paste0("processed_data")),
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
        if(!dir.exists(file.path(param$mapspamc_path, paste0("processed_data/", x)))) {
            dir.create(file.path(param$mapspamc_path, paste0("processed_data/", x)),
                       showWarnings = TRUE,
                       recursive = TRUE)
        }
    })

    if(!dir.exists(file.path(param$mapspamc_path, "mappings")))
        dir.create(file.path(param$mapspamc_path, "mappings"), showWarnings = TRUE, recursive = TRUE)

    copy_mapping_files(param)

    cat("\n=> mapspamc folder structure created in", param$mapspamc_path,
        "\n=> mapspamc raw_path created in", param$raw_path)
}
