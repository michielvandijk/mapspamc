library(mapspamc)

spamc_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_iso3c/mapspamc_mwi"
raw_path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/data/mapspamc_db"
#gams_path <- "C:/MyPrograms/GAMS/35"
gams_path <- "C:/MyPrograms/GAMS/win64/24.6"

# Set SPAMc parameters
param <- spam_par(spam_path = spamc_path,
                  raw_path = raw_path,
                  gams_path = gams_path,
                  iso3c = "MWI",
                  year = 2010,
                  res = "5min",
                  adm_level = 2,
                  solve_level = 0,
                  model = "min_entropy")

# Show parameters
print(param)

library(gdxrrw)
igdx(gams_path)

create_grid(param)

ac <- "ZMB"
var <- "biophysical_suitability"
var <- "potential_yield"
file <- cs_sel[1]

