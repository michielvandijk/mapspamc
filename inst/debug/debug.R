library(mapspamc)
# Set the folder where the model will be stored
# Note that R uses forward slashes even in Windows!!
spamc_path <- "C:/Users/dijk158/Dropbox/crop_map_ZAMBEZI/spam5min/2000/MOZ/adm1"
gams_path <- "C:/MyPrograms/gams/25.1"


# Set SPAMc parameters
param <- spam_par(spam_path = spamc_path,
                  raw_path = "C:/Users/dijk158/Dropbox/crop_map_global",
                  iso3c = "MOZ",
                  year = 2000,
                  res = "5min",
                  adm_level = 1,
                  solve_level = 0,
                  model = "min_entropy",
                  gams_path = gams_path)

# Show parameters
print(param)

library(gdxrrw)
igdx("C:/MyPrograms/gams/25.1")


ac <- "MOZ"
combine_inputs(param)

gdxrrw::wgdx(file.path(temp_path, glue::glue("input_{param$res}_{param$year}_{ac}_{param$iso3c}.gdx")),
             cl_gdx,
             adm_area_gdx,
             ir_crop_gdx,
             ir_area_gdx,
             crop_area_gdx,
             s_system_s_gdx,
             scores_gdx,
             priors_gdx,
              grid_s_gdx, crop_system_s_gdx,
              adm_s_gdx,
              crop_crop_system_s_gdx,
            #  adm_grid_s_gdx,
              adm_crop_s_gdx, crop_s_gdx,
              rps_gdx,
             scalef_gdx)
