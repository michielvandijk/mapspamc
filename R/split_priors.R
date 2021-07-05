# Process_bs_py
split_priors <- function(ac, param){

  cat("\nPrepare priors for", ac)

  # Load data
  load_intermediate_data(c("pa", "pa_fs", "cl_harm", "ia_harm", "bs", "py"), ac, param, local = TRUE, mess = FALSE)
  load_data(c("adm_list", "adm_map", "adm_map_r", "grid", "pop", "acc", "urb", "price", "dm2fm"), param, local = TRUE, mess = FALSE)

  ############### PREPARATIONS ###############
  # Put statistics in long format
  pa <- pa %>%
    tidyr::gather(crop, pa, -adm_code, -adm_name, -adm_level)

  pa_fs <- pa_fs %>%
    dplyr::filter(adm_code == ac) %>%
    tidyr::gather(crop, pa, -adm_code, -adm_name, -adm_level, -system) %>%
    dplyr::filter(!is.na(pa) & pa != 0) %>%
    dplyr::mutate(crop_system = paste(crop, system , sep = "_"))

  priors_base <- expand.grid(gridID = unique(cl_harm$gridID),
                             crop_system = unique(pa_fs$crop_system), stringsAsFactors = F) %>%
    tidyr::separate(crop_system, into = c("crop", "system"), sep = "_", remove = F)

  # create gridID list
  grid_df <- as.data.frame(raster::rasterToPoints(grid))

  ## Rural population
  # Note that we normalize over adms to distribute the crops more evenly over adms.
  # If we would normalize over the whole country, crops for which we do not have adm information,
  # might be pushed to a very limited area.
  pop_rural <- raster::mask(pop, urb, inverse = T) # Remove urban areas
  pop_rural <- as.data.frame(raster::rasterToPoints(raster::stack(grid, pop_rural))) %>%
    dplyr::select(gridID, pop) %>%
    dplyr::mutate(pop = ifelse(is.na(pop), 0, pop)) %>% # We assume zero population in case data is missing
    dplyr::left_join(adm_map_r, by = "gridID") %>%
    dplyr::rename(adm_code = glue::glue("adm{param$adm_level}_code")) %>%
    dplyr::group_by(adm_code) %>%
    dplyr::mutate(
      pop_norm = 100*(pop-min(pop, na.rm = T))/(max(pop, na.rm = T)-min(pop, na.rm = T)),
      pop_norm = ifelse(is.nan(pop_norm) | is.na(pop_norm), 0, pop_norm)) %>%
    dplyr::ungroup() %>%
    dplyr::select(gridID, pop_norm) %>%
    dplyr::filter(gridID %in% unique(cl_harm$gridID))


  ## Accessibility
  # NOTE that we normalize so that max = 0 and min = 1 as higher tt gives lower suitability
  # NOTE that we normalize over the whole country as some cash crops are allocated at national level.
  # We expected these crops to be located a most accessible areas from a national (not adm) perspective
  # Hence we do not normalize using adm_sel as a basis.
  acc <- as.data.frame(raster::rasterToPoints(raster::stack(grid, acc))) %>%
    dplyr::select(gridID, acc) %>%
    dplyr::left_join(adm_map_r, by = "gridID") %>%
    dplyr::rename(adm_code = glue::glue("adm{param$adm_level}_code")) %>%
    dplyr::mutate(
      acc_norm = 100*(max(acc, na.rm = T)-acc)/(max(acc, na.rm = T)-min(acc, na.rm = T))) %>%
    dplyr::mutate(acc_norm = ifelse(is.nan(acc_norm) | is.na(acc_norm), 0, acc_norm)) %>%
    dplyr::select(gridID, acc_norm)  %>%
    dplyr::filter(gridID %in% unique(cl_harm$gridID))


  ############### CREATE PRIOR ###############
  # We calculate potential revenue by:
  # (1) Converting potential yield in dm to fm
  # (2) Multiplying potential yield with national crop prices

  # Convert to fm
  rev <- py %>%
    tidyr::separate(crop_system, into = c("crop", "system"), sep = "_", remove = F) %>%
    dplyr::left_join(dm2fm, by = "crop") %>%
    dplyr::mutate(py = py/t_factor) %>%
    dplyr::left_join(price, by = "crop") %>%
    dplyr::mutate(rev = py*price) %>%
    dplyr::select(gridID, crop_system, rev)


  ############### PRIOR FOR EACH SYSTEM ###############
  ## SUBSISTENCE
  # We use the rural population share as prior but exclude areas where suitability is zero
  # We also remove adm where crops are not allocated by definition because stat indicates zero ha.

  # crop_s
  crop_s <- unique(pa_fs$crop[pa_fs$system == "S"])

  # select adm without crop_s
  adm_code_crop_s <- dplyr::bind_rows(
    pa[pa$adm_code == ac,],
    pa[pa$adm_code %in% adm_list$adm1_code[adm_list$adm0_code == ac],],
    pa[pa$adm_code %in% adm_list$adm2_code[adm_list$adm1_code == ac],],
    pa[pa$adm_code %in% adm_list$adm2_code[adm_list$adm0_code == ac],]) %>%
    unique() %>%
    dplyr::filter(crop %in% crop_s, pa == 0) %>%
    dplyr::select(crop, adm_code, adm_name, adm_level) %>%
    dplyr::mutate(adm_code_crop = paste(adm_code, crop, sep = "_"))

  prior_s <-priors_base %>%
    dplyr::filter(system == "S") %>%
    dplyr::left_join(adm_map_r, by = "gridID") %>%
    dplyr::select(-dplyr::ends_with("_name")) %>%
    tidyr::gather(adm_code_level, adm_code, -gridID, -crop, -system, -crop_system) %>%
    dplyr::mutate(adm_code_crop = paste(adm_code, crop, sep = "_")) %>%
    dplyr::filter(!adm_code_crop %in% adm_code_crop_s$adm_code_crop) %>%
    dplyr::select(gridID, crop, system, crop_system) %>%
    dplyr::distinct() %>%
    dplyr::left_join(pop_rural, by = "gridID") %>%
    dplyr::left_join(bs, by = c("gridID", "crop_system")) %>%
    dplyr::group_by(crop) %>%
    dplyr::mutate(
      pop_norm = ifelse(bs == 0, 0, pop_norm),
      pop_norm = ifelse(is.na(pop_norm), 0, pop_norm),
      rur_pop_share = pop_norm/sum(pop_norm, na.rm = T),
      rur_pop_share = ifelse(is.na(rur_pop_share), 0, rur_pop_share),
      crop_system = paste(crop, system, sep = "_")) %>%
    dplyr::ungroup() %>%
    dplyr::select(gridID, crop_system, rur_pop_share) %>%
    dplyr::left_join(pa_fs, by = "crop_system") %>%
    dplyr::mutate(prior = rur_pop_share*pa) %>%
    dplyr::select(gridID, crop_system, prior)

  ### LOW INPUT
  # We use suitability for only for L
  # Then we normalize over all crops so that an overal ranking is created.
  # This means that crops with higher suitability will get a higher prior than crops with a lower suitability.
  # The argument is that if there would be competition between crops, the crop with the highest suitability
  # Will be allocated first

  # crop_l
  crop_l <- unique(pa_fs$crop[pa_fs$system == "L"])

  # prior table.  We use suitability only for L
  prior_l <- priors_base %>%
    dplyr::filter(system == "L") %>%
    dplyr::left_join(bs, by = c("gridID", "crop_system")) %>%
    dplyr::mutate(bs = ifelse(is.na(bs), 0, bs),
                  prior = 100*(bs-min(bs, na.rm = T))/(max(bs, na.rm = T)-min(bs, na.rm = T)),
                  prior = ifelse(is.na(prior), 0, prior)) %>%
    dplyr::select(gridID, crop_system, prior)


  ## HIGH INPUT
  # We use revenue and accessibility
  # Then we normalize rev and acessibility over all crops so that an overal ranking is created.
  # Next we use equal weight geometric average as the final ranking.
  # This means that crops with higher revenue and accessibility will get a higher prior than crops with a lower rankings.
  # The argument is that if there would be competition between crops, the crop with the highest prior
  # Will be allocated first
  # We rerank the combined rev and accessibility prior again to it has the same scale as l and i priors.

  # crop_h
  crop_h <- unique(pa_fs$crop[pa_fs$system == "H"])

  # prior table.  We use geometric average of rev and accessibility
  prior_h <- priors_base %>%
    dplyr::filter(system == "H") %>%
    dplyr::left_join(rev, by = c("gridID", "crop_system")) %>%
    dplyr::left_join(acc, by = "gridID") %>%
    dplyr::mutate(
           rev = ifelse(is.na(rev), 0, rev),
           acc_norm = ifelse(is.na(acc_norm), 0, acc_norm),
           rev_norm = 100*(rev-min(rev, na.rm = T))/(max(rev, na.rm = T)-min(rev, na.rm = T)),
           prior = (rev_norm*acc_norm)^0.5,
           prior = 100*(prior-min(prior, na.rm = T))/(max(prior, na.rm = T)-min(prior, na.rm = T)),
           prior = ifelse(is.na(prior), 0, prior)) %>%
    dplyr::select(gridID, crop_system, prior)

  ## IRRIGATION
  # We use the same prior as for H
  # We select only ir gridID
  # crop_i
  crop_i <- unique(pa_fs$crop[pa_fs$system == "I"])

  # prior table.  We use geometric average of suitability and accessibility
  prior_i <- priors_base %>%
    dplyr::filter(system == "I") %>%
    dplyr::left_join(ia_harm, by = "gridID") %>%
    dplyr::filter(!is.na(ia)) %>%
    dplyr::left_join(rev, by = c("gridID", "crop_system")) %>%
    dplyr::left_join(acc,  by = "gridID") %>%
    dplyr::mutate(
      rev = ifelse(is.na(rev), 0, rev),
      acc_norm = ifelse(is.na(acc_norm), 0, acc_norm),
      rev_norm = 100*(rev-min(rev, na.rm = T))/(max(rev, na.rm = T)-min(rev, na.rm = T)),
      prior = (rev_norm*acc_norm)^0.5,
      prior = 100*(prior-min(prior, na.rm = T))/(max(prior, na.rm = T)-min(prior, na.rm = T)),
      prior = ifelse(is.na(prior), 0, prior)) %>%
    dplyr::select(gridID, crop_system, prior)


  ### CALCULATE PRIORS USING RELATIVE SHARES OF RESIDUAL AREA AFTER S
  # Residual grid area
  resid_area <- prior_s %>%
    dplyr::group_by(gridID) %>%
    dplyr::summarize(prior_s = sum(prior, na.rm = T)) %>%
    dplyr::ungroup() %>%
    dplyr::left_join(cl_harm,., by = "gridID") %>%
    dplyr::mutate(
      prior_s = ifelse(is.na(prior_s), 0, prior_s),
      resid = ifelse(cl-prior_s < 0, 0, cl-prior_s),
      resid = ifelse(is.na(resid), 0, resid)) %>%
    dplyr::select(gridID, resid)

  # Distribute residual area over I, L, H systems using score as weight.
  prior_i_l_h <- dplyr::bind_rows(prior_i, prior_l, prior_h) %>%
    tidyr::spread(crop_system, prior, fill = 0) %>% # add 0 as fill
    tidyr::gather(crop_system, prior, -gridID) %>%
    dplyr::group_by(gridID) %>%
    dplyr::mutate(prior_share = prior/sum(prior, na.rm = T),
                  prior_share = ifelse(is.na(prior_share), 0, prior_share)) %>%
    dplyr::ungroup() %>%
    dplyr::left_join(resid_area, by = "gridID") %>%
    dplyr::mutate(prior = resid * prior_share) %>%
    dplyr::select(gridID, crop_system, prior) %>%
    dplyr::filter(prior > 0)


  ############### COMBINE ###############
  # combine with prior_s and remove areas that are smaller than 0.0001 (= 1m2)
  prior_df <- dplyr::bind_rows(prior_s, prior_i_l_h) %>%
    tidyr::separate(crop_system, into = c("crop", "system"), sep = "_", remove = F) %>%
    dplyr::filter(prior > 0.0001)

  # Use number of lc grid cells as scaling factor
  scalelp <- nrow(cl_harm)

  # Scale priors
  prior_df <- prior_df %>%
    dplyr::group_by(crop, system) %>%
    dplyr::mutate(prior = prior/sum(prior, na.rm = T)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(prior = prior * scalelp,
           crop_system = paste(crop, system, sep = "_"))


  ############### SAVE ###############
  # save
  saveRDS(prior_df, file.path(param$spam_path,
    glue::glue("processed_data/intermediate_output/{ac}/{param$res}/priors_{param$res}_{param$year}_{ac}_{param$iso3c}.rds")))
}

