#' Sum of vector elements but now NA + NA = NA not 0 as in sum
#'
#'`plus` Returns the sum of all values provided as arguments but ensures `NA` +
#'`NA` = `NA`.
#'
#'This function is the same as `sum`() but if `na.rm` is `FALSE` and all input
#'values are `NA`, it will return `NA` instead of 0.
#'
#'@param x numeric vector.
#'@param na.rm logical. Should missing values be removed?
#'
#'@return The sum of `x`
#'
#'@examples
#'plus(1:10)
#'plus(c(NA, NA))
#'plus(c(NA, NA), na.rm = T)
#'@export
plus <- function(x, na.rm = F){
    if(all(is.na(x))){
        c(x[0],NA)
    } else {
        if(na.rm == T){
            sum(x, na.rm = TRUE)
        } else {
            sum(x, na.rm)
        }
    }
}

