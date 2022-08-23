#'========================================================================================
#' Project:  mapspamc
#' Subject:  Script to process raw subnational statistics
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("01_model_setup/01_model_setup.r"))

# In this script the raw subnational statistics are processed. In order to prevent errors
# when running the model, it is essential to put the statistics in the right
# format and make sure they are consistent (e.g. total area at national level is equal to
# that of subnational area).

# The user can prepare the data in Excel or use R. mapspamc offers a function to create a
# template for the data. It also providers several support functions to check for consistency
# and modify where needed. See the package documentation for more information.


# LOAD DATA ------------------------------------------------------------------------------


# PREPARE STAT ---------------------------------------------------------------------------

# To create the templates use the following commands
ha_stat <- create_statistics_template("ha", param)
fs_stat <- create_statistics_template("fs", param)
ci_stat <- create_statistics_template("ci", param)


# SAVE -----------------------------------------------------------------------------------
write_csv(ha_stat, file.path(param$db_path,
                                glue("subnational_statistics/subnational_harvested_area_template_{param$year}_{param$iso3c}.csv")))
write_csv(ci_stat, file.path(param$db_path,
                                glue("subnational_statistics/cropping_intensity_template_{param$year}_{param$iso3c}.csv")))
write_csv(fs_stat, file.path(param$db_path,
                                glue("subnational_statistics/farming_system_shares_template_{param$year}_{param$iso3c}.csv")))


# NOTE -----------------------------------------------------------------------------------
# As you probably created a lot of objects in he R memory, we recommend to
# restart R at this moment and start fresh. This can be done easily in RStudio by
# pressing CTRL/CMD + SHIFT + F10.
