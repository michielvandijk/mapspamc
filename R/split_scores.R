# Process_bs_py
split_scores <- function(ac, param){

  cat("\nPrepare scores for", ac)

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

  scores_base <- expand.grid(gridID = unique(cl_harm$gridID),
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


    ############### CREATE SCORE ###############
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


  ############### SCORE FOR EACH SYSTEM ###############
  ## SUBSISTENCE
  # We use the rural population share as score but exclude areas where suitability is zero
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

  rps <-scores_base %>%
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
    dplyr::select(gridID, crop_system, rur_pop_share)

  ### LOW INPUT
  # We use suitability for only for L
  # Then we normalize over all crops so that an overal ranking is created.
  # This means that crops with higher suitability will get a higher score than crops with a lower suitability.
  # The argument is that if there would be competition between crops, the crop with the highest suitability
  # Will be allocated first

  # crop_l
  crop_l <- unique(pa_fs$crop[pa_fs$system == "L"])

  # Score table.  We use suitability only for L
  score_l <- scores_base %>%
    dplyr::filter(system == "L") %>%
    dplyr::left_join(adm_map_r, by = "gridID") %>%
    dplyr::left_join(bs, by = c("gridID", "crop_system")) %>%
    dplyr::mutate(
      bs = ifelse(is.na(bs), 0, bs),
      score = 100*(bs-min(bs, na.rm = T))/(max(bs, na.rm = T)-min(bs, na.rm = T)),
      score = ifelse(is.na(score),0, score)) %>%
    dplyr::select(gridID, crop_system, score)

  ## HIGH INPUT
  # We use revenue and accessibility
  # Then we normalize rev and acessibility over all crops so that an overal ranking is created.
  # Next we use equal weight geometric average as the final ranking.
  # This means that crops with higher revenue and accessibility will get a higher score than crops with a lower rankings.
  # The argument is that if there would be competition between crops, the crop with the highest score
  # Will be allocated first
  # We rerank the combined rev and accessibility score again to it has the same scale as l and i scores.

  # crop_h
  crop_h <- unique(pa_fs$crop[pa_fs$system == "H"])

  # Score table.  We use geometric average of rev and accessibility
  score_h <- scores_base %>%
    dplyr::filter(system == "H") %>%
    dplyr::left_join(adm_map_r, by = "gridID") %>%
    dplyr::left_join(rev, by = c("gridID", "crop_system")) %>%
    dplyr::left_join(acc, by = "gridID") %>%
    dplyr::mutate(
      rev = ifelse(is.na(rev), 0, rev),
      acc_norm = ifelse(is.na(acc_norm), 0, acc_norm),
      rev_norm = 100*(rev-min(rev, na.rm = T))/(max(rev, na.rm = T)-min(rev, na.rm = T)),
      score = (rev_norm*acc_norm)^0.5,
      score = 100*(score-min(score, na.rm = T))/(max(score, na.rm = T)-min(score, na.rm = T)),
      score = ifelse(is.na(score), 0, score)) %>%
    dplyr::select(gridID, crop_system, score)


  ## IRRIGATION
  # We use the same score as for H
  # We select only ir gridID
  # crop_i
  crop_i <- unique(pa_fs$crop[pa_fs$system == "I"])

  # Score table.  We use geometric average of suitability and accessibility
  score_i <- scores_base %>%
    dplyr::filter(system == "I") %>%
    dplyr::left_join(ia_harm, by = "gridID") %>%
    dplyr::filter(!is.na(ia)) %>%
    dplyr::left_join(rev, by = c("gridID", "crop_system")) %>%
    dplyr::left_join(acc,  by = "gridID") %>%
    dplyr::mutate(
      rev = ifelse(is.na(rev), 0, rev),
      acc_norm = ifelse(is.na(acc_norm), 0, acc_norm),
      rev_norm = 100*(rev-min(rev, na.rm = T))/(max(rev, na.rm = T)-min(rev, na.rm = T)),
      score = (rev_norm*acc_norm)^0.5,
      score = 100*(score-min(score, na.rm = T))/(max(score, na.rm = T)-min(score, na.rm = T)),
      score = ifelse(is.na(score), 0, score)) %>%
    dplyr::select(gridID, crop_system, score)


  ############### COMBINE ###############
  # score
  score_df <- dplyr::bind_rows(score_l, score_h, score_i) %>%
    dplyr::left_join(scores_base,., by = c("gridID", "crop_system")) %>%
    dplyr::mutate(score = tidyr::replace_na(score, 0)) %>%
    tidyr::separate(crop_system, into = c("crop", "system"), sep = "_", remove = F)
  summary(score_df)


  ############### SAVE ###############
  # save
  model_folder <- create_model_folder(param)
  saveRDS(rps, file.path(param$spam_path,
    glue::glue("processed_data/intermediate_output/{model_folder}/{ac}/rps_{param$res}_{param$year}_{ac}_{param$iso3c}.rds")))
  saveRDS(score_df, file.path(param$spam_path,
    glue::glue("processed_data/intermediate_output/{model_folder}/{ac}/scores_{param$res}_{param$year}_{ac}_{param$iso3c}.rds")))
}

