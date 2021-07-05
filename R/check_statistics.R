#'Checks the consistency of the subnational statistics
#'
#'Subnational statistics must be of class `subnat`
#'
#'@param df data.frame with subnational statistics at various levels in the long format
#'@param param
#'@inheritParams create_spam_folders
#'@param out logical; should the checking report be returned as output?
#'
#'@return data.frame `df` when out is set to `TRUE`
#'
#'@examples
#'
#'@export
check_statistics <- function(df, param, out = FALSE){
    stopifnot(inherits(param, "spam_par"))
    stopifnot(is.logical(out))

    if(param$adm_level == 2) {
        report <- list(
            compare_adm(df, 1, 2, out = out),
            compare_adm(df, 0, 2, out = out),
            compare_adm(df, 0, 1, out = out)
            )
    }
    if(param$adm_level == 1) {
        report <- compare_adm(df, 0, 1, out = out)
    }
    if(param$adm_level == 0) {

    }
    if(out & param$adm_level %in% c(1,2)) {
        return(report)
    } else {
        cat("\nadm_level = 1, no report can be produced")
    }
}

