# Function to create artificial adms

if(adm_sel == 0){

  # Create all adm combinations at adm_sel
  adm_base <- adm_list_long %>%
    filter(adm_level == adm_sel)

  base <- expand.grid(adm0_code = unique(adm_base$adm_code), crop = unique(pa$crop), stringsAsFactors = F) %>%
    mutate(adm_level = adm_sel) %>%
    left_join(adm_code_list)

  adm0_pa <- pa %>%
    filter(adm_level == 0) %>%
    rename(adm0_code = adm_code, pa_adm0 = pa) %>%
    dplyr::select(-adm_name, -adm_level)

  adm0_1_2 <- left_join(base, adm0_pa) %>%
    dplyr::select(crop, adm0_code, pa_adm0) %>%
    unique

  # Prepare artificial adm. With only adm0 level data there are none.
  adm_art <- adm0_1_2 %>%
    dplyr::select(adm_code = adm0_code, crop = crop, pa = pa_adm0)

  adm_art_map <- data.frame(adm_code = unique(adm0_1_2$adm0_code), fips_art = unique(adm0_1_2$adm0_code))

}


### ARTIFICIAL ADM FOR adm_sel = 1

if(adm_sel == 1){

  ### PREPARE DATA
  # Create all adm combinations at adm_sel
  adm_base <- adm_list_long %>%
    filter(adm_level == adm_sel)

  base <- expand.grid(adm1_code = unique(adm_base$adm_code), crop = unique(pa$crop), stringsAsFactors = F) %>%
    mutate(adm_level = adm_sel) %>%
    left_join(adm_code_list)

  adm0_pa <- pa %>%
    filter(adm_level == 0) %>%
    rename(adm0_code = adm_code, pa_adm0 = pa) %>%
    dplyr::select(-adm_name, -adm_level)

  adm1_pa <- pa %>%
    filter(adm_level == 1) %>%
    rename(adm1_code = adm_code, pa_adm1 = pa) %>%
    dplyr::select(-adm_name, -adm_level)

  ### ADM0_1 ARTIFICIAL UNITS
  # Combine adm 0_1 data
  adm0_1 <- left_join(base, adm1_pa) %>%
    left_join(adm0_pa) %>%
    dplyr::select(crop, adm0_code, adm1_code, pa_adm0, pa_adm1) %>%
    unique

  # Prepare artificial adm combining adm0 and adm1
  adm1_art <- adm0_1 %>%
    group_by(adm0_code, crop) %>%
    mutate(adm1_av = sum(pa_adm1, na.rm = T),
           imp_adm1 = ifelse(is.na(pa_adm1), unique(pa_adm0) - adm1_av, pa_adm1)) %>%
    ungroup() %>%
    mutate(adm1_code_art = ifelse(is.na(pa_adm1), paste(adm0_code, "ART1", crop, sep = "_"), adm1_code)) %>%
    dplyr::select(adm1_code_art, adm1_code, crop, imp_adm1) %>%
    unique

  adm_art <- adm1_art %>%
    dplyr::select(crop, imp_adm1, adm1_code_art) %>%
    unique %>%
    rename(adm_code = adm1_code_art, pa = imp_adm1)

  # artificial adm mapping
  adm_art_map <- adm1_art %>%
    dplyr::select(adm_code_art = adm1_code_art, adm_code = adm1_code) %>%
    unique
}

### ARTIFICIAL ADM FOR adm_sel = 2 and solve_sel = 0
adm_depth <- 2
if(adm_sel == 2 & solve_sel == 0){

  rn <- paste0("adm", adm_depth, "_code")

  # only select adm_code
  adm_code_list <- adm_list %>%
    dplyr::select(adm0_code, adm1_code, adm2_code)

  # create adm long list
  adm_list_long <- pa %>%
    tidyr::gather(crop, pa, -adm_code, -adm_name, -adm_level) %>%
    dplyr::select(adm_code, adm_name, adm_level) %>%
    unique()

  ### PREPARE DATA
  # Create dataframe with all adm crop combinations at lowest level = adm_lvl
  # associated lower level adms

  rn <- glue::glue("adm{param$adm_level}_code")
  adm_list_at_lowest_level <- unique(pa$adm_code[pa$adm_level == param$adm_level])
  base <- expand.grid(adm_code = adm_list_at_lowest_level, crop = unique(pa$crop), stringsAsFactors = F) %>%
    dplyr::rename({{rn}} := adm_code) %>%
    dplyr::mutate(adm_level = param$adm_level) %>%
    dplyr::left_join(adm_code_list)


s <- param$solve_level
e <- param$adm_level


create_pa_tot <- function(i, pa) {

  df <- pa %>%
    dplyr::filter(adm_level == i) %>%
    dplyr::rename("adm{{i}}_code" := .data$adm_code,
                  "pa_adm{{i}}" :=  .data$pa) %>%
    dplyr::select(-adm_name, -adm_level)
  return(df)
}


adm0_pa <- create_pa_tot(0, pa)
adm1_pa <- create_pa_tot(1, pa)
adm2_pa <- create_pa_tot(2, pa)



adm0_art <- adm0_pa %>%
  dplyr::mutate(adm0_code_art = adm0_code)



  ### ADM0_1 ARTIFICIAL UNITS
  # Combine adm 0_1 data
  adm0_1 <- dplyr::left_join(base, adm1_pa) %>%
    dplyr::left_join(adm0_pa) %>%
    dplyr::select(crop, adm0_code, adm1_code, pa_adm1) %>%
    unique

  # Prepare artificial adm combining adm0 and adm1
  adm1_art <- adm0_1 %>%
    dplyr::left_join(adm0_art) %>%
    dplyr::group_by(adm0_code_art, crop) %>%
    dplyr::mutate(adm1_av = sum(pa_adm1, na.rm = T),
           imp_adm1 = ifelse(is.na(pa_adm1), unique(pa_adm0) - adm1_av, pa_adm1)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(adm1_code_art = ifelse(is.na(pa_adm1), paste(adm0_code_art, "ART1", crop, sep = "_"), adm1_code)) %>%
    dplyr::select(adm1_code_art, adm1_code, crop, imp_adm1) %>%
    unique


  ### ADM1_2 ARTIFICIAL UNITS
  # We take the new adm1 list including artificial adms as basis

  # Combine adm 1_2 data
  adm1_2 <- dplyr::left_join(base, adm2_pa) %>%
    dplyr::left_join(adm1_pa) %>%
    dplyr::select(crop, adm1_code, adm2_code, pa_adm2) %>%
    unique

  # Prepare artificial adm combining adm0 and adm1
  adm2_art <- adm1_2 %>%
    dplyr::left_join(adm1_art) %>%
    dplyr::group_by(adm1_code_art, crop) %>%
    dplyr::mutate(adm2_av = sum(pa_adm2, na.rm = T),
           imp_adm2 = ifelse(is.na(pa_adm2), unique(imp_adm1) - adm2_av, pa_adm2)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(adm2_code_art = ifelse(is.na(pa_adm2), paste(adm1_code_art, "ART2", crop, sep = "_"), adm2_code)) %>%
    unique()

  adm_art <- adm2_art %>%
    dplyr::select(crop, imp_adm2, adm2_code_art) %>%
    unique %>%
    dplyr::rename(adm_code = adm2_code_art, pa = imp_adm2)

  # artificial adm mapping
  adm_art_map <- adm2_art %>%
    dplyr::select(adm_code_art = adm2_code_art, adm_code = adm2_code) %>%
    unique
}

### ARTIFICIAL ADM FOR adm_sel = 2 and adm_solve = 1
adm_sel <- 2
solve_sel <- 1

if(adm_sel == 2 & solve_sel == 1){



  # only select adm_code
  adm_code_list <- adm_list %>%
    dplyr::select(adm0_code, adm1_code, adm2_code)


  # create adm long list
  adm_list_long <- pa %>%
    tidyr::gather(crop, pa, -adm_code, -adm_name, -adm_level) %>%
    dplyr::select(adm_code, adm_name, adm_level) %>%
    unique()

  ### PREPARE DATA
  # Create dataframe with all adm crop combinations at lowest level with
  # associated lower level adms
  adm_list_at_lowest_level <- unique(pa$adm_code[pa$adm_level == param$adm_level])
  base <- expand.grid(adm2_code = adm_list_at_lowest_level, crop = unique(pa$crop), stringsAsFactors = F) %>%
    dplyr::mutate(adm_level = param$adm_level) %>%
    dplyr::left_join(adm_code_list)


  adm1_pa <- pa %>%
    dplyr::filter(adm_level == 1) %>%
    dplyr::rename(adm1_code = adm_code, pa_adm1 = pa) %>%
    dplyr::select(-adm_name, -adm_level)

  adm2_pa <- pa %>%
    dplyr::filter(adm_level == 2) %>%
    dplyr::rename(adm2_code = adm_code, pa_adm2 = pa) %>%
    dplyr::select(-adm_name, -adm_level)


  ### ADM1_2 ARTIFICIAL UNITS
  # We take the new adm1 list including artificial adms as basis

  # Combine adm 1_2 data
  adm1_2 <- dplyr::left_join(base, adm2_pa) %>%
    dplyr::left_join(adm1_pa) %>%
    dplyr::select(crop, adm1_code, adm2_code, pa_adm1, pa_adm2) %>%
    unique

  # Prepare artificial adm combining adm0 and adm1
  adm2_art <- adm1_2 %>%
    dplyr::group_by(adm1_code, crop) %>%
    dplyr::mutate(adm2_av = sum(pa_adm2, na.rm = T),
           imp_adm2 = ifelse(is.na(pa_adm2), unique(pa_adm1) - adm2_av, pa_adm2)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(adm2_code_art = ifelse(is.na(pa_adm2), paste(adm1_code, "ART2", crop, sep = "_"), adm2_code)) %>%
    unique()

  adm_art <- adm2_art %>%
    dplyr::select(crop, imp_adm2, adm2_code_art) %>%
    unique %>%
    dplyr::rename(adm_code = adm2_code_art, pa = imp_adm2)

  # artificial adm mapping
  adm_art_map <- adm2_art %>%
    dplyr::select(adm_code_art = adm2_code_art, adm_code = adm2_code) %>%
    unique
}
