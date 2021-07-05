#'@export
print.spam_par <- function(x, ...) {
    cat("iso3c: ", x$iso3c, "\n")
    cat("year: ", x$year, "\n")
    cat("resolution: ", x$res, "\n")
    cat("adm level: ", x$adm_level, "\n")
    cat("solve level: ", x$solve_level, "\n")
    cat("model: ", x$model, "\n")
    cat("spam path: ", x$spam_path, "\n")
    cat("raw data path: ", x$raw_path, "\n")
    cat("country name: ", x$country, "\n")
    cat("iso3n: ", x$iso3n, "\n")
    cat("fao code: ", x$fao_code, "\n")
    cat("continent: ", x$continent, "\n")
    cat("crs: ", x$crs, "\n")
    cat("gams_path:", x$gams_path, "\n")
}

