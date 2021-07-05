# Function to combine all model input per adm_level
combine_model_input <- function(ac, param){

  #TODO adm_code is referred as ac => not consistent
  cat("\nPrepare model input for", ac)

  # Load data
  load_intermediate_data(c("pa", "pa_fs", "cl_harm", "ia_harm", "bs", "py", "rps", "score"),
                         ac, param, local = TRUE, mess = FALSE)
  load_data(c("adm_list"), param, local = TRUE, mess = FALSE)


  ############### PREPARATIONS ###############
  # Put statistics in long format and filter out crops where pa = 0
  # These crops create artificial adms, which created conflicts
  pa <- pa %>%
    tidyr::gather(crop, pa, -adm_code, -adm_name, -adm_level) %>%
    dplyr::filter(pa != 0)

  pa_fs <- pa_fs %>%
    tidyr::gather(crop, pa, -adm_code, -adm_name, -adm_level, -system) %>%
    dplyr::filter(pa != 0)


  ############### CREATE ARTIFICIAL ADMS   ###############
  adm_art_raw <- prepare_artificial_adms(ac, param)

  # Finallize adm_art by selecting adm_level and removing duplicates
  imp_rn <- glue::glue("imp_adm{param$adm_level}")
  ac_rn <- glue::glue("adm{param$adm_level}_code")
  ac_art_rn <- glue::glue("adm{param$adm_level}_code_art")
  adm_art <- adm_art_raw %>%
    dplyr::select(-{{ac_rn}}) %>%
    unique %>%
    dplyr::rename(pa = {{pa_rn}},
                  adm_code = {{ac_art_rn}})

  # Remove artifical adms that are approximately zero, which are caused if data
  # is not rebalanced.
  adm_art <- adm_art %>%
    dplyr::filter(!abs(pa) < 1e-6)

  # artificial adm mapping
  adm_art_map <- adm_art_raw %>%
    dplyr::rename(adm_code_art = {{adm_rn}},
                  adm_code = {{ac_rn}}) %>%
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
  crop_area <- pa_fs %>%
    dplyr::filter(adm_code == ac) %>%
    dplyr::mutate(crop_system = paste(crop, system, sep = "_")) %>%
    dplyr::ungroup() %>%
    dplyr::select(crop_system, pa)

  crop_area_gdx <- para_gdx(crop_area, c("crop_system"), "crop_area", "Total area per crop")


  # ir_area(i): Irrigated area per grid cell (i)
  ir_area <- ia_harm %>%
    dplyr::filter(gridID %in% unique(cl_harm$gridID)) %>%
    dplyr::select(gridID, ia)

  ir_area_gdx <- para_gdx(ir_area, c("gridID"), "ir_area", "Irrigated area per grid cell")


  # ir_crop(j): Total irrigated area per crop system (j)
  ir_crop <- pa_fs %>%
    dplyr::filter(adm_code == ac) %>%
    dplyr::filter(system == "I") %>%
    dplyr::mutate(crop_system = paste(crop, system, sep = "_")) %>%
    dplyr::ungroup() %>%
    dplyr::select(crop_system, pa)

  ir_crop_gdx <- para_gdx(ir_crop, c("crop_system"), "ir_crop", "Total irrigated area per crop")


  # score(i,j): Score per grid cell and crop_system
  score <- score %>%
    dplyr::select(gridID, crop_system, score)

  score_gdx <- para_gdx(score, c("gridID", "crop_system"), "score", "score per grid cell and crop_system")

  # # prior(i,j): prior per grid cell and crop_system
  # prior <- prior_raw %>%
  #   dplyr::select(gridID, crop_system, prior_scaled)
  #
  # prior_gdx <- para_gdx(prior, c("gridID", "crop_system"), "prior", "scaled prior per grid cell and crop_system")


  # rur_pop_s(i,j): Rural population share per grid cell
  rps_gdx <- para_gdx(rps, c("gridID", "crop_system"), "rur_pop_share", "Rural population shares")


  ### CREATE GAMS SETS
  # Grid cells (i)
  grid_s <- cl_harm %>%
    dplyr::select(gridID) %>%
    unique()

  grid_s_gdx <- set_gdx(grid_s, c("gridID"), "i", "Grid cells")


  # Crops system combinations (j)
  crop_system_s <- pa_fs %>%
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
  s_system_s <- pa_fs %>%
    dplyr::mutate(crop_system = paste(crop, system, sep = "_")) %>%
    dplyr::filter(adm_code == ac, system == "S") %>%
    dplyr::ungroup() %>%
    dplyr::select(crop_system) %>%
    unique()

  s_system_s_gdx <- set_gdx(s_system_s, c("crop_system"), "j_s", "Subsistence system combinations")

  # Adms with statistics (k)
  adm_s <- adm_area %>%
    dplyr::select(adm_code) %>%
    unique()

  adm_s_gdx <- set_gdx(adm_s, c("adm_code"), "k", "Administrative regions")


  # Crops with corresponding crop system combinations (s,j)
  crop_crop_system_s <- pa_fs %>%
    dplyr::mutate(crop_system = paste(crop, system, sep = "_")) %>%
    dplyr::filter(adm_code == ac) %>%
    dplyr::ungroup() %>%
    dplyr::select(crop, crop_system) %>%
    unique()

  crop_crop_system_s_gdx <- set_gdx(crop_crop_system_s, c("crop","crop_system"), "n", "Crops with corresponding system combinations")

  # Administrative regions with corresponding grid cells (k,i)
  adm_grid_s <- cl_harm %>%
    dplyr::left_join(adm_art_map, by = "adm_code") %>%
    dplyr::select(adm_code = adm_code_art, gridID) %>%
    unique()

  adm_grid_s_gdx <- set_gdx(adm_grid_s, c("adm_code","gridID"), "l", "adm with corresponding grid cells")


  # Administrative regions with corresponding crops
  adm_crop_s <- adm_area %>%
    dplyr::select(adm_code, crop) %>%
    unique()

  adm_crop_s_gdx <- set_gdx(adm_crop_s, c("adm_code", "crop"), "m", "adm with corresponding crops")


  ############### CREATE GAMS SCALARS ###############
  # scalef: number of grid cells to scale optimization so numbers do not get too small
  scalef <- nrow(grid_s)
  scalef_gdx <- scalar_gdx(scalef, "scalef", "Scaling factor")


  ############### SAVE ###############
  temp_path <- file.path(param$spam_path,
                         glue::glue("processed_data/intermediate_output/{ac}"))
  dir.create(temp_path, recursive = T, showWarnings = F)

  # Function to test if gdxrrw is installed.
  test_gdxrrw <- function(a, b) {
    if (!requireNamespace("gdxrrw", quietly = TRUE)) {
      stop("Package gdxrrw needed for this function to work. Please install it (see vignette on installation for more information).",
           call. = FALSE)
    }
  }
  # GDX
  gdxrrw::wgdx(file.path(temp_path, glue::glue("input_{param$res}_{param$year}_{ac}_{param$iso3c}.gdx")),
       cl_gdx,
       adm_area_gdx,
       ir_crop_gdx,
       ir_area_gdx,
       crop_area_gdx,
       s_system_s_gdx,
       score_gdx,
       grid_s_gdx, crop_system_s_gdx,
       adm_s_gdx,
       crop_crop_system_s_gdx,
       adm_grid_s_gdx,
       adm_crop_s_gdx, crop_s_gdx,
       rps_gdx,
       scalef_gdx)
}

