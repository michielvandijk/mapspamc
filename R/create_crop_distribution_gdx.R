# Function to create crop distribution for GLOBIOM in gdx format
#'@export
create_crop_distribution_gdx <- function(crop, param) {
  crop_upd <- crop %>%
    dplyr::filter(globiom_crop != "rest") %>%
    dplyr::select(SimUID, system, globiom_crop, value) %>%
    dplyr::mutate(system = dplyr::recode(
      system,
      "S" = "SS",
      "L" = "LI",
      "H" = "HI",
      "I" = "IR"
    )) %>%
    dplyr::left_join(simu_info, by = "SimUID") %>%
    dplyr::select(
      SimUID,
      system,
      globiom_crop,
      LUId,
      ALLCOUNTRY,
      ALLCOLROW,
      AltiClass,
      SlpClass,
      SoilClass,
      AezClass,
      value
    )

  crop_upd_gdx <- para_gdx(
    crop_upd,
    c(
      "SimUID",
      "system",
      "globiom_crop",
      "LUId",
      "ALLCOUNTRY",
      "ALLCOLROW",
      "AltiClass",
      "SlpClass",
      "SoilClass",
      "AezClass"
    ),
    "crop_area",
    "Crop area (000 ha)"
  )

  temp_path <- file.path(param$spam_path,
                         glue::glue("processed_data/results/{param$res}/{param$model}"))
  dir.create(temp_path, showWarnings = F, recursive = T)

  gdxrrw::wgdx(file.path(
    temp_path,
    glue::glue(
      "globiom_crop_area_{param$year}_{param$iso3c}"
    )
  ),
  crop_upd_gdx)
  cat("\n############### Crop distribution gdx file saved ###############")

}
