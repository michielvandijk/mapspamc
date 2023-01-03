#' @title Creates template for subnational crop statistics
#'
#' @description
#' To support the preparation of the subnational statistics,
#' `create_statistics_template()` can create three types of data templates:
#' - ha for harvest area statistics
#' - ps for production system share
#' - ci for cropping intensity.
#'
#' @details
#' The function requires information on how the different administrative unit
#' levels are nested. This file needs to be created first by running
#' `create_adm_list()`.
#'
#' The dimensions of the templates are determined by the parameters set by means of
#' `mapspamc_par()`. The ha template dimension is determined by adm level parameter,
#' while the dimensions of the ps and cs templates (which are identical) are determined
#' by the solve level parameter.
#'
#' @param type Character vector that refers to the type of template that needs to
#'  be created. See details for allowed input.
#' @inheritParams create_folders
#'
#' @examples
#' \dontrun{
#' create_statistics_template(type = "ha", param)
#' }
#' @export
create_statistics_template <- function(type, param) {
  stopifnot(inherits(param, "mapspamc_par"))
  stopifnot(type %in% c("ha", "ps", "ci"))

  load_data(c("adm_list", "crop"), param, mess = FALSE, local = TRUE)

  adm_list_wide <- dplyr::bind_rows(
    adm_list %>%
      dplyr::select_at(vars(contains("adm0"))) %>%
      setNames(c("adm_name", "adm_code")) %>%
      dplyr::mutate(adm_level = 0) %>%
      unique(),
    adm_list %>%
      dplyr::select_at(vars(contains("adm1"))) %>%
      setNames(c("adm_name", "adm_code")) %>%
      dplyr::mutate(adm_level = 1) %>%
      unique(),
    adm_list %>%
      dplyr::select_at(vars(contains("adm2"))) %>%
      setNames(c("adm_name", "adm_code")) %>%
      dplyr::mutate(adm_level = 2) %>%
      unique()
  )

  if (type == "ha") {
    ha_template <- adm_list_wide %>%
      dplyr::filter(adm_level %in% c(0:param$adm_level))
    ha_template[, crop$crop] <- NA
    return(ha_template)
  } else if (type == "ps") {
    ps_template <- adm_list_wide %>%
      dplyr::filter(adm_level %in% c(0:param$solve_level))
    ps_template <- tidyr::expand_grid(ps_template, system = c("S", "L", "H", "I")) %>%
      dplyr::select(adm_name, adm_code, adm_level, system, everything())
    ps_template[, crop$crop] <- NA
    return(ps_template)
  } else if (type == "ci") {
    ci_template <- adm_list_wide %>%
      dplyr::filter(adm_level %in% c(0:param$solve_level))
    ci_template <- tidyr::expand_grid(ci_template, system = c("S", "L", "H", "I")) %>%
      dplyr::select(adm_name, adm_code, adm_level, system, everything())
    ci_template[, crop$crop] <- NA
    return(ci_template)
  }
}
