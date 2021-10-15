# Function to identify artificial adms
identify_art_adms_per_level <- function(i, df_x_art, pa, base_xy) {

  cat("\nCreate artificial adms at adm level", i)
  # As numeric because otherwise R will put L in front of an integer, which will
  # be pasted along!
  i <- as.numeric(i)
  df_x <- filter_out_pa(i, pa)
  df_y <- filter_out_pa(i+1, pa)

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
  df_xy <- dplyr::left_join(base_xy, df_x, by = c("crop", "admX_code")) %>%
    dplyr::left_join(df_y, by = c("crop", "admY_code")) %>%
    dplyr::select(crop, admX_code, admY_code, pa_admY) %>%
    unique

  # Calculate pa for artificial adms
  art_id <- glue::glue("ART{i+1}")
  df_y_art <- df_xy %>%
    dplyr::left_join(df_x_art, by = c("crop", "admX_code")) %>%
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






