# Function to validate spam_par class
validate_spam_par <- function(param) {
  stopifnot(inherits(param, "spam_par"))
  if (is.null(param$spam_path))
    stop("spam_path is not defined",
         call. = FALSE)
  if (is.na(param$iso3c)) {
    stop("iso3c not defined",
         call. = FALSE)
  } else {
    if(!grepl("^[A-Z]{3}$", param$iso3c)) {
      stop("iso3c is not a three letter character",
           call. = FALSE)
    }
  }
  if (is.null(param$year)) {
    stop("year is not defined",
         call. = FALSE)
  } else {
    if(!is.numeric(param$year)) {
      stop("year is not a value",
           call. = FALSE)
    } else {
      if(param$year < 1000 | param$year > 2300) {
        message("year seems to have an unrealistic value")
      }
    }
  }
  if (!param$res %in% c("5min", "30sec"))
    stop("5min and 30sec are allowed values for res",
         call. = FALSE)
  if (!param$adm_level %in% c(0, 1, 2))
    stop("0, 1, 2, are allowed values for adm_level",
         call. = FALSE)
  if (!param$solve_level %in% c(0, 1))
    stop("0, 1 are allowed values for solve_level",
         call. = FALSE)
  if (!param$model %in% c("max_score", "min_entropy"))
    stop("max_score and min_entropy are allowed values for model",
         call. = FALSE)
}

