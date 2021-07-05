
############### SETUP R ###############
# Install and load pacman package that automatically installs R packages if not available
if("pacman" %in% rownames(installed.packages()) == FALSE) install.packages("pacman")
library(pacman)

# Load key packages
p_load("mapspamc", "tidyverse", "readxl", "stringr", "here", "scales", "glue", "gdalUtils", "sf", "raster")

# Set root folder, which is defined by RStudio project
root <- here()

# R options
options(scipen=999) # Supress scientific notation
options(digits=4) # limit display to four digits


############### SETUP SPAMc ###############
# Set the folder where the model will be stored
# Note that R uses forward slashes even in Windows!!
spamc_path <- "C:/Users/dijk158/Dropbox/mapspamc_mwi"

# Create SPAMc folder structure in the spamc_path
create_spam_folders(spamc_path)

# Set SPAMc parameters
param <- spam_par(spam_path = spamc_path,
                iso3c = "MWI",
                year = 2010,
                res = "5min",
                adm_level = 2,
                solve_level = 0,
                model = "max_score")

# Show parameters
print(param)

