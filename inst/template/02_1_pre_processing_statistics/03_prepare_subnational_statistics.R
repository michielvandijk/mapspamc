#'========================================================================================
#' Project:  MAPSPAMC
#' Subject:  Script to process raw subnational statistics
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("inst/template/01_model_setup/01_model_setup.r"))


# LOAD DATA ------------------------------------------------------------------------------


# PREPARE STAT ---------------------------------------------------------------------------

# The user can prepare the data in Excel or use R. mapspamc offers a function to create a
# template for the data.

# To create the templates use the following commands
ha_stat <- create_statistics_template("ha", param)
fs_stat <- create_statistics_template("fs", param)
ci_stat <- create_statistics_template("ci", param)



# SAVE -----------------------------------------------------------------------------------
write_csv(ha_stat, file.path(param$raw_path,
                                glue("subnational_statistics/subnational_harvested_area_{param$year}_{param$iso3c}.csv")))
write_csv(ci_stat, file.path(param$raw_path,
                                glue("subnational_statistics/cropping_intensity_{param$year}_{param$iso3c}.csv")))
write_csv(sy_stat, file.path(param$raw_path,
                                glue("subnational_statistics/farming_system_shares_{param$year}_{param$iso3c}.csv")))


# NOTE -----------------------------------------------------------------------------------
# As you probably created a lot of objects in he R memory, we recommend to
# restart R at this moment and start fresh. This can be done easily in RStudio by
# pressing CTRL/CMD + SHIFT + F10.
