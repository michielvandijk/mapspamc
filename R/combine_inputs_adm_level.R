# Function to combine all model input per adm_level
combine_inputs_adm_level <- function(ac, param) {
  cat("\nPrepare model input for", ac)
  # Load data
  load_intermediate_data(c("pa_ps", "cl_harm", "ia_harm", "bs", "py", "rps", "priors", "scores"),
    ac, param,
    local = TRUE, mess = FALSE
  )
  load_data(c("adm_list"), param, local = TRUE, mess = FALSE)


  ############### PREPARATIONS ###############
  # Put statistics in long format and filter out crops where pa = 0
  pa_ps <- pa_ps %>%
    tidyr::pivot_longer(-c(adm_code, adm_name, adm_level, system), names_to = "crop", values_to = "pa") %>%
    dplyr::filter(pa != 0)


  ############### CREATE ARTIFICIAL ADMS   ###############
  adm_art_raw <- prepare_artificial_adms(ac, param)

  # Finalize adm_art by selecting adm_level and removing duplicates
  pa_rn <- glue::glue("imp_adm{param$adm_level}")
  ac_rn <- glue::glue("adm{param$adm_level}_code")
  ac_art_rn <- glue::glue("adm{param$adm_level}_code_art")

  # It is possible that the sum of lower adms is not exactly equal to the total
  # of the higher level adm because of internal precision to deal with fractions.
  # As a result artificial adms are created that are very small (e.g. 1e-10).
  # These are set to zero

  adm_art_raw <- adm_art_raw %>%
    dplyr::rename(pa = {{ pa_rn }}) %>%
    dplyr::mutate(pa = ifelse(dplyr::near(pa, 0), 0, pa))
  # Put statistics in long format and filter out crops where pa = 0
  # These crops create artificial adms, which created conflicts.
  # Removed this again because when all crops are zero in an area, total
  # area is removed, which leads to conflicts.
  # %>%
  #   dplyr::filter(pa != 0)

  adm_art <- adm_art_raw %>%
    dplyr::select(-{{ ac_rn }}) %>%
    unique() %>%
    dplyr::rename(adm_code = {{ ac_art_rn }})

  # artificial adm mapping
  adm_art_map <- adm_art_raw %>%
    dplyr::rename(
      adm_code_art = {{ ac_art_rn }},
      adm_code = {{ ac_rn }}
    ) %>%
    dplyr::select(adm_code_art, adm_code) %>%
    unique()


  ############### CREATE GAMS PARAMETERS ###############
  # adm_area(k,s): Land use per lowest level adm, including artificial adms (k) and crop (s).
  adm_area <- adm_art %>%
    dplyr::select(adm_code, crop, pa)
  adm_area_gdx <- para_gdx(adm_area, c("adm_code", "crop"), "adm_area", "Crop area per adm")

  # lc(i): Crop cover for each gridcell (i)
  cl_m <- cl_harm %>%
    dplyr::select(gridID, cl)

  cl_gdx <- para_gdx(cl_m, c("gridID"), "cl", "Cropland per grid cell")


  # crop_area(j): Total area per crop system (j)
  crop_area <- pa_ps %>%
    dplyr::filter(adm_code == ac) %>%
    dplyr::mutate(crop_system = paste(crop, system, sep = "_")) %>%
    dplyr::ungroup() %>%
    dplyr::select(crop_system, pa)

  crop_area_gdx <- para_gdx(crop_area, c("crop_system"), "crop_area", "Total area per crop")


  # ir_area(i): Irrigated area per grid cell (i)
  ir_area <- ia_harm %>%
    dplyr::filter(gridID %in% unique(cl_harm$gridID)) %>%
    dplyr::select(gridID, ia)

  if (nrow(ir_area) == 0) {
    ir_area_gdx <- numeric(0)
  } else {
    ir_area_gdx <- para_gdx(ir_area, c("gridID"), "ir_area", "Irrigated area per grid cell")
  }

  # ir_crop(j): Total irrigated area per crop system (j)
  ir_crop <- pa_ps %>%
    dplyr::filter(adm_code == ac) %>%
    dplyr::filter(system == "I") %>%
    dplyr::mutate(crop_system = paste(crop, system, sep = "_")) %>%
    dplyr::ungroup() %>%
    dplyr::select(crop_system, pa)

  if (nrow(ir_crop) == 0) {
    ir_crop_gdx <- numeric(0)
  } else {
    ir_crop_gdx <- para_gdx(ir_crop, c("crop_system"), "ir_crop", "Total irrigated area per crop")
  }

  # prior(i,j): prior per grid cell and crop_system
  priors <- priors %>%
    dplyr::select(gridID, crop_system, prior)

  priors_gdx <- para_gdx(priors, c("gridID", "crop_system"), "priors", "prior per grid cell and crop_system")

  # score(i,j): Score per grid cell and crop_system
  scores <- scores %>%
    dplyr::select(gridID, crop_system, score)

  scores_gdx <- para_gdx(scores, c("gridID", "crop_system"), "scores", "score per grid cell and crop_system")

  # rur_pop_s(i,j): Rural population share per grid cell
  if (nrow(rps) == 0) {
    rps_gdx <- numeric(0)
  } else {
    rps_gdx <- para_gdx(rps, c("gridID", "crop_system"), "rur_pop_share", "Rural population shares")
  }


  ### CREATE GAMS SETS
  # Grid cells (i)
  grid_s <- cl_harm %>%
    dplyr::select(gridID) %>%
    unique()

  grid_s_gdx <- set_gdx(grid_s, c("gridID"), "i", "Grid cells")


  # Crops system combinations (j)
  crop_system_s <- pa_ps %>%
    dplyr::mutate(crop_system = paste(crop, system, sep = "_")) %>%
    dplyr::filter(adm_code == ac) %>%
    dplyr::ungroup() %>%
    dplyr::select(crop_system) %>%
    unique()

  crop_system_s_gdx <- set_gdx(crop_system_s, c("crop_system"), "j", "Crop systems")


  # Crop (s)
  crop_s <- adm_art %>%
    dplyr::select(crop) %>%
    unique()

  crop_s_gdx <- set_gdx(crop_s, c("crop"), "s", "Crops")

  # Subsistence system
  s_system_s <- pa_ps %>%
    dplyr::mutate(crop_system = paste(crop, system, sep = "_")) %>%
    dplyr::filter(adm_code == ac, system == "S") %>%
    dplyr::ungroup() %>%
    dplyr::select(crop_system) %>%
    unique()

  if (nrow(s_system_s) == 0) {
    s_system_s_gdx <- numeric(0)
  } else {
    s_system_s_gdx <- set_gdx(s_system_s, c("crop_system"), "j_s", "Subsistence system combinations")
  }

  # Adms with statistics (k)
  adm_s <- adm_area %>%
    dplyr::select(adm_code) %>%
    unique()

  adm_s_gdx <- set_gdx(adm_s, c("adm_code"), "k", "Administrative regions")


  # Crops with corresponding crop system combinations (s,j)
  crop_crop_system_s <- pa_ps %>%
    dplyr::mutate(crop_system = paste(crop, system, sep = "_")) %>%
    dplyr::filter(adm_code == ac) %>%
    dplyr::ungroup() %>%
    dplyr::select(crop, crop_system) %>%
    unique()

  crop_crop_system_s_gdx <- set_gdx(crop_crop_system_s, c("crop", "crop_system"), "n", "Crops with corresponding system combinations")

  # Administrative regions with corresponding grid cells (k,i)
  adm_grid_s <- cl_harm %>%
    dplyr::left_join(adm_art_map, by = "adm_code") %>%
    dplyr::select(adm_code = adm_code_art, gridID) %>%
    unique()

  adm_grid_s_gdx <- set_gdx(adm_grid_s, c("adm_code", "gridID"), "l", "adm with corresponding grid cells")


  # Administrative regions with corresponding crops (k,s)
  adm_crop_s <- adm_area %>%
    dplyr::select(adm_code, crop) %>%
    unique()

  adm_crop_s_gdx <- set_gdx(adm_crop_s, c("adm_code", "crop"), "m", "adm with corresponding crops")


  ############### CREATE GAMS SCALARS ###############
  # scalef: number of grid cells to scale optimization so numbers do not get too small
  scalef <- nrow(grid_s)
  scalef_gdx <- scalar_gdx(scalef, "scalef", "Scaling factor")


  ############### REMOVE ALL EMPTY GDX COMPONENTS AS THEY ARE NOT ALLOWED ###############
  gdx_input <- list(
    cl_gdx, adm_area_gdx, ir_crop_gdx, ir_area_gdx, crop_area_gdx,
    s_system_s_gdx,
    scores_gdx, priors_gdx, grid_s_gdx, crop_system_s_gdx, adm_s_gdx, crop_crop_system_s_gdx,
    adm_grid_s_gdx, adm_crop_s_gdx, crop_s_gdx,
    rps_gdx,
    scalef_gdx
  )

  gdx_input <- gdx_input[lapply(gdx_input, length) > 0]

  ############### SAVE ###############
  model_folder <- create_model_folder(param)
  temp_path <- file.path(
    param$model_path,
    glue::glue("processed_data/intermediate_output/{model_folder}/{ac}")
  )
  dir.create(temp_path, recursive = T, showWarnings = F)

  # Prepare GDX
  gdxrrw::wgdx(
    file.path(temp_path, glue::glue("input_{param$res}_{param$year}_{ac}_{param$iso3c}.gdx")),
    gdx_input
  )
  cat("\n=> GDX model input file saved for ", ac)
}
