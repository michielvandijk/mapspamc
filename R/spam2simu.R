# function to aggregate mapspam output to simu
spam2simu <- function(var, param) {
  cat("\n##### Aggregate SPAM crop distribution maps to simu #####")
  load_data("crop2globiom", param, mess = F, local = T)
  files <- list.files(file.path(param$spam_path,
    glue::glue("processed_data/results/{param$res}/{param$model}/maps/{var}")), full.names = T, pattern = glob2rx("*.tif"))

  # function to aggregate mapspam raster output to simu
  raster2simu <- function(file, param) {

    load_data("simu_r", param, mess = F, local = T)
    map <- raster::raster(file)
    cat("\n", names(map))
    simu_map <- as.data.frame(raster::zonal(map, simu_r, fun = 'sum', na.rm = T)) %>%
      setNames(c("SimUID","value"))
    crp <- strsplit(names(map), "_")[[1]][2]
    sys <- strsplit(names(map), "_")[[1]][3]
    simu_map <- simu_map %>%
      dplyr::mutate(crop = crp,
             system = sys,
             resolution = param$res,
             year = param$year,
             iso3c = param$iso3c)
    return(simu_map)
  }

  df <- purrr::map_dfr(files, raster2simu, param) %>%
    dplyr::mutate(variable = var)

  # Aggregate to globiom crops
  # Divide by 1000 to get 1000 ha as in globiom
  df <- df %>%
    dplyr::left_join(crop2globiom, by = "crop") %>%
    dplyr::group_by(SimUID, year, iso3c, system, globiom_crop) %>%
    dplyr::summarize(value = sum(value, na.rm = T)/1000) %>%
    dplyr::ungroup()

  return(df)
}




