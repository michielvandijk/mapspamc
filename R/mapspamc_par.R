#' @title
#' Sets `mapspamc` parameters
#'
#' @description
#' `mapspamc_par` sets all required parameters for spam to run, including core model
#' folders, country code, year, spatial resolution, availability of subnational
#' statistics, solve level, type of model and location of GAMS.
#'
#' @details
#' `mapspamc_par` creates an object of class `mapspamc_par`, which bundles all required
#' `mapspamc` parameters set by the user: model folder, location of the input database folder,
#' country alpha-3 code, country name, continent, year, spatial resolution, most detailed level at which
#' subnational statistics are available and administrative unit level at which the
#' model is solved, type of model. The coordinate reference system is automatically set to WGS84
#' (epsg:4326).
#'
#' If GAMS is properly installed, the GAMS executable is automatically found,
#' which is required to load the libraries to create gdx files. In case this
#' gives problems (e.g. because multiple versions of GAMS are installed, the
#' location of GAMS can be added manually.
#'
#' [countrycode::countrycode()] is used to determine the full country
#' name, three digit country code and continent on
#' the basis of the alpha-3 country code. This information is required to extract
#' country specific information from several datasets.
#'
#' @param model_path character string with the main model folder. Note that R uses
#'  forward slash or double backslash to separate folder names.
#' @param db_path character string with location of the mapspamc_db folder. This makes it
#'  possible to store the mapspamc_db on a server. If `db_path` is not specified the
#'  mapspamc_db folder is automatically created in the model folder.
#' @param iso3c character string with the three letter ISO 3166-1 alpha-3 country
#'  code, also referred to as iso3c. A list of country codes can be found in
#'  [Wikipedia](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3).
#' @param year numeric with the reference year of the model.
#' @param res character with the resolution of the model. Accepted inputs are "5min"
#'  (default) and "30sec".
#' @param adm_level integer with the level up to which subnational statistics are
#'  available. Accepted inputs are 0 (only national level data), 1 (national
#'  level and first level administrative unit - default) and 2 (national level,
#'  first and second level administrative unit).
#' @param solve_level integer that indicates the level at which the model is
#'  solved. Accepted inputs are 0 (model is run at national level - default) and
#'  1 (model is solved for each first level administrative unit separately).
#'  level and first level administrative unit - default)
#' @param model character that specifies the type of model that is run. Accepted
#'  inputs are "max_score" and "min_entropy". See package documentation for more
#'  information.
#' @param gams_path character that specifies the location of GAMS (i.e. the folder with
#' gamside.exe)
#'
#' @return mapspamc_par object
#'
#' @examples
#' \dontrun{
#' mapspamc_par(
#'   model_path = "C:/temp/mapspamc_mwi",
#'   iso3c = "MWI", year = 2010, res = "5min", adm_level = 1,
#'   solve_level = 0, model = "max_score", gams_path = "C:/GAMS"
#' )
#' }
#' @export
mapspamc_par <-
  function(model_path = NULL,
           db_path = NULL,
           iso3c = NULL,
           year = NULL,
           res = "5min",
           adm_level = 1,
           solve_level = 0,
           model = "max_score",
           gams_path = NULL) {
    if (is.null(db_path)) {
      message("db_path is not defined, set to mapspamc_db in the model folder")
      db_path <- file.path(model_path, "mapspamc_db")
    } else {
      db_path <- file.path(db_path, "mapspamc_db")
    }
    if (is.null(gams_path)) {
      gams_path <- ""
    }

    param <- list(
      iso3c = ifelse(!is.null(iso3c), toupper(iso3c), NA_character_),
      country = ifelse(!is.null(iso3c), countrycode::countrycode(iso3c, "iso3c", "country.name"), NA_character_),
      iso3n = ifelse(!is.null(iso3c), countrycode::countrycode(iso3c, "iso3c", "iso3n"), NA_character_),
      continent = ifelse(!is.null(iso3c), countrycode::countrycode(iso3c, "iso3c", "continent"), NA_character_),
      year = year,
      resolution = res,
      adm_level = adm_level,
      solve_level = solve_level,
      model = model,
      model_path = model_path,
      db_path = db_path,
      gams_path = gams_path,
      crs = "epsg:4326"
    )
    class(param) <- "mapspamc_par"
    validate_mapspamc_par(param)
    return(param)
  }
