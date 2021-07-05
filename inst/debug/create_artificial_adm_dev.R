# Function to create artificial adms
create_artificial_adms <- function(i, df_x_art, pa, base_xy) {

  df_x <- calculate_pa_tot(i, pa)
  df_y <- calculate_pa_tot(i+1, pa)

  # Rename
  names(df_x) <- gsub("[0-9]", "X", names(df_x))
  names(df_y) <- gsub("[0-9]", "Y", names(df_y))
  names(df_x_art) <- gsub("[0-9]", "X", names(df_x_art))
  adm_level_x <- unique(df_x$adm_level)
  adm_level_y <- unique(df_y$adm_level)
  names(base_xy) <- gsub(adm_level_x, "X", names(base_xy))
  names(base_xy) <- gsub(adm_level_y, "Y", names(base_xy))

  # Drop adm_level for joining
  df_x <- dplyr::select(df_x, -adm_level)
  df_y <- dplyr::select(df_y, -adm_level)

  # Combine df_x and df_y
  df_xy <- dplyr::left_join(base_xy, df_x) %>%
    dplyr::left_join(df_y) %>%
    dplyr::select(crop, admX_code, admY_code, pa_admY) %>%
    unique

  # Calculate pa for artificial adms
  art_id <- glue::glue("ART{i+1}")
  df_y_art <- df_xy %>%
    dplyr::left_join(df_x_art) %>%
    dplyr::group_by(admX_code_art, crop) %>%
    dplyr::mutate(admY_av = sum(pa_admY, na.rm = T),
                  imp_admY = ifelse(is.na(pa_admY), unique(imp_admX) - admY_av, pa_admY)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(admY_code_art = ifelse(is.na(pa_admY), paste(admX_code_art, art_id, crop, sep = "_"), admY_code)) %>%
    dplyr::select(admY_code_art, admY_code, crop, imp_admY) %>%
    unique

  # Correct names
  names(df_y_art) <- gsub("Y", i+1, names(df_y_art))

  return(df_y_art)
}

# Functio to calculate totals per adm level
calculate_pa_tot <- function(i, pa) {

    df <- pa %>%
    dplyr::filter(adm_level == i) %>%
    dplyr::rename("adm{{i}}_code" := .data$adm_code,
                  "pa_adm{{i}}" :=  .data$pa) %>%
    dplyr::select(-adm_name)

    return(df)
}



## For loop
step <- param$adm_level - param$solve_level
init <- min(pa$adm_level)
vec <- c(init:(step-1))

# set adm_art at lowest level
adm_art <- create_pa_tot(init, pa) %>%
  dplyr::mutate("adm{{init}}_code_art" := adm0_code) %>%
  dplyr::rename("imp_adm{{init}}" := pa_adm0) %>%
  dplyr::select(-adm_level)

for(i in vec) {
  print(i)
  adm_art <- create_art_adm(i, adm_art)
}

# Final adm_art
adm_art_final <- adm_art_upd2 %>%
  dplyr::select(-adm2_code) %>%
  unique



