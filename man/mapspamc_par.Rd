% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mapspamc_par.R
\name{mapspamc_par}
\alias{mapspamc_par}
\title{Sets \code{mapspamc} parameters}
\usage{
mapspamc_par(
  model_path = NULL,
  db_path = NULL,
  iso3c = NULL,
  year = NULL,
  res = "5min",
  adm_level = 1,
  solve_level = 0,
  model = "max_score",
  gams_path = NULL
)
}
\arguments{
\item{model_path}{character string with the main model folder. Note that R uses
forward slash or double backslash to separate folder names.}

\item{db_path}{character string with location of the mapspamc_db folder. This makes it
possible to store the mapspamc_db on a server. If \code{db_path} is not specified the
mapspamc_db folder is automatically created in the model folder.}

\item{iso3c}{character string with the three letter ISO 3166-1 alpha-3 country
code, also referred to as iso3c. A list of country codes can be found in
\href{https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3}{Wikipedia}.}

\item{year}{numeric with the reference year of the model.}

\item{res}{character with the resolution of the model. Accepted inputs are "5min"
(default) and "30sec".}

\item{adm_level}{integer with the level up to which subnational statistics are
available. Accepted inputs are 0 (only national level data), 1 (national
level and first level administrative unit - default) and 2 (national level,
first and second level administrative unit).}

\item{solve_level}{integer that indicates the level at which the model is
solved. Accepted inputs are 0 (model is run at national level - default) and
1 (model is solved for each first level administrative unit separately).
level and first level administrative unit - default)}

\item{model}{character that specifies the type of model that is run. Accepted
inputs are "max_score" and "min_entropy". See package documentation for more
information.}

\item{gams_path}{character that specifies the location of GAMS (i.e. the folder with
gamside.exe)}
}
\value{
mapspamc_par object
}
\description{
\code{mapspamc_par} sets all required parameters for spam to run, including core model
folders, country code, year, spatial resolution, availability of subnational
statistics, solve level, type of model and location of GAMS.
}
\details{
\code{mapspamc_par} creates an object of class \code{mapspamc_par}, which bundles all required
\code{mapspamc} parameters set by the user: model folder, location of the input database folder,
country alpha-3 code, country name, continent, year, spatial resolution, most detailed level at which
subnational statistics are available and administrative unit level at which the
model is solved, type of model. The coordinate reference system is automatically set to WGS84
(epsg:4326).

If GAMS is properly installed, the GAMS executable is automatically found,
which is required to load the libraries to create gdx files. In case this
gives problems (e.g. because multiple versions of GAMS are installed, the
location of GAMS can be added manually.

\code{\link[countrycode:countrycode]{countrycode::countrycode()}} is used to determine the full country
name, three digit country code and continent on
the basis of the alpha-3 country code. This information is required to extract
country specific information from several datasets.
}
\examples{
\dontrun{
mapspamc_par(
  model_path = "C:/temp/mapspamc_mwi",
  iso3c = "MWI", year = 2010, res = "5min", adm_level = 1,
  solve_level = 0, model = "max_score", gams_path = "C:/GAMS"
)
}
}
