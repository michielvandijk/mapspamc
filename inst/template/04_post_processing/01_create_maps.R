#'========================================================================================
#' Project:  MAPSPAMC
#' Subject:  Create crop distribution maps
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("scripts/01_model_setup/01_model_setup.r"))


# INSPECT RESULTS ------------------------------------------------------------------------
view_panel("rice", var = "ha", param)
view_panel("maiz", var = "ha", param)


# CREATE TIF -----------------------------------------------------------------------------
create_all_tif(param)

