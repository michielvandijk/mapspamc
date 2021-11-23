#'@title
#'Sets spam parameters
#'
#'@description
#'`spamc_par` sets all required parameters for spam to run, including core model
#'folders, country code, year, spatial resolution, availability of subnational
#'statistics, solve level, type of model and location of GAMS.
#'
#'@details
#'`spamc_par` creates an object of class `spamc_par`, which bundles all required
#'spam parameters set by the user: SPAM folder, raw data folder, country alpha-3
#'code and name, year, spatial resolution, most detailed level at which
#'subnational statistics are available, administrative unit level at which the
#'model is solved, type of model, three digit country code and
#'continent. The coordinate reference system is automatically set to WGS84
#'(epsg:4326).
#'
#'If GAMS is properly installed, the GAMS executable is automatically found,
#'which is required to load the libraries to create gdx files. In case this
#'gives problems the location of GAMS can be added manually.
#'
#'\code{\link[countrycode]{countrycode}} is used to determine the full country
#'name, three digit country code and continent on
#'the basis of the alpha-3 country code. This information is required to extract
#'country specific information from several datasets.
#'
#'@param spamc_path character string with the main SPAM folder. Note that R uses
#'  forward slash or double backslash to separate folder names.
#'@param raw_path character string with the raw data folder. This makes it
#'  possible to store the raw data on a server. If `raw_path` is not specified
#'  it is automatically set to the default raw data folder in the main model
#'  folder.
#'@param iso3c character string with the three letter ISO 3166-1 alpha-3 country
#'  code, also referred to as iso3c. A list of country codes can be found in
#'  [Wikipedia](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3).
#'@param year numeric with the reference year for SPAM.
#'@param res character with the resolution of SPAM. Accepted inputs are "5min"
#'  (default) and "30sec".
#'@param adm_level integer with the level up to which subnational statistics are
#'  available. Accepted inputs are 0 (only national level data), 1 (national
#'  level and first level administrative unit - default) and 2 (national level,
#'  first and second level administrative unit).
#'@param solve_level integer that indicates the level at which the model is
#'  solved. Accepted inputs are 0 (model is run at national level - default) and
#'  1 (model is solved for each first level administrative unit separately).
#'  level and first level administrative unit - default)
#'@param model character that specifies the type of model that is run. Accepted
#'  inputs are "max_score" and "min_entropy". See package documentation for more
#'  information.
#'
#'@return spamc_par object
#'
#'@examples
#'\dontrun{
#'spamc_par(spamc_path = "C:/Users/dijk158/Dropbox/mapspamc_mwi",
#'iso3c = "MWI", year = 2010, res = "5min", adm_level = 1,
#'solve_level = 0, model = "max_score", gams_path = "C:/GAMS")
#'}
#'@export
spamc_par <-
    function(spamc_path = NULL,
             raw_path = NULL,
             iso3c = NULL,
             year = NULL,
             res = "5min",
             adm_level = 1,
             solve_level = 0,
             model = "max_score",
             gams_path = NULL) {

        if (is.null(raw_path)) {
            message("raw_path is not defined, set to raw_data in main folder")
            raw_path <- file.path(spamc_path, "raw_data")
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
            spamc_path = spamc_path,
            raw_path = raw_path,
            gams_path = gams_path,
            crs = "+init=epsg:4326")
        class(param) <- "spamc_par"
        validate_spamc_par(param)
        return(param)
    }

