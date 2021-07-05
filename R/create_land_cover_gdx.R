# Function to create land cover for GLOBIOM in gdx format
create_land_cover_gdx <- function(lc, param) {
  lc <- lc %>%
    dplyr::left_join(simu_info, by = "SimUID") %>%
    dplyr::select(
      SimUID,
      globiom_lc_code,
      LUId,
      ALLCOUNTRY,
      ALLCOLROW,
      AltiClass,
      SlpClass,
      SoilClass,
      AezClass,
      value
    )

  lc_gdx <-
    para_gdx(
      lc,
      c(
        "SimUID",
        "globiom_lc_code",
        "LUId",
        "ALLCOUNTRY",
        "ALLCOLROW",
        "AltiClass",
        "SlpClass",
        "SoilClass",
        "AezClass"
      ),
      "land_cover",
      "Updated land cover (000 ha)"
    )

  temp_path <- file.path(param$spam_path,
                         glue::glue("processed_data/results/{param$res}/{param$model}"))
  dir.create(temp_path, showWarnings = F, recursive = T)

  gdxrrw::wgdx(file.path(
    temp_path,
    glue::glue(
      "globiom_land_cover_{param$year}_{param$iso3c}"
    )
  ),
  lc_gdx)

  cat("\n############### Land cover gdx file saved ###############")
}
