#'@export
print.mapspamc_par <- function(x, ...) {
    cat("country name: ", x$country, "\n")
    cat("iso3n: ", x$iso3n, "\n")
    cat("iso3c: ", x$iso3c, "\n")
    cat("continent: ", x$continent, "\n")
    cat("year: ", x$year, "\n")
    cat("model: ", x$model, "\n")
    cat("resolution: ", x$res, "\n")
    cat("adm level: ", x$adm_level, "\n")
    cat("solve level: ", x$solve_level, "\n")
    cat("model path: ", x$model_path, "\n")
    cat("mapspamc_db path: ", x$db_path, "\n")
    cat("gams path:", x$gams_path, "\n")
    cat("model folder: ", create_model_folder(x), "\n")
    cat("crs: ", x$crs, "\n")
}

