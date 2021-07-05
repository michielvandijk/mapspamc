#'create file with information on how administrative units are nested
#'
#'To organize and process the subnational statistics, a data.frame is needed
#'that lists all administrative units at all available levels and how they are
#'nested. The data.frame should have columns with the name and code for each
#'level of administrative unit data using the following format: admX_name and
#'admX_code, where X corresponds with the administrative unit level for which
#'data is available.
#'
#'All the required information should be contained in the atribute table of the
#'polygon file with the location of the administrative units. This function
#'strips the attribute table from the polygon file and saves it as
#'`adm_list.csv` in the `processed_data/lists/` folder. The package
#'documentation provides information on how to create the polygon file.
#'
#'@param x	object of class sf with the location of the administrative units
#'  including an attribute table with information on how they are nested
#'@inheritParams create_spam_folders
#'
#'@examples
#'\dontrun{
#'create_adm_list(adm_map, param)
#'}
#'
#'@export

#'
create_adm_list <- function(x, param) {
  stopifnot(inherits(param, "spam_par"))
  # Create adm_list
  adm_list <- x %>%
    sf::st_drop_geometry()

  readr::write_csv(adm_list,
    file.path(param$spam_path, glue::glue("processed_data/lists/adm_list_{param$year}_{param$iso3c}.csv")))
}
