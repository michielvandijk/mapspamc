# Helper functions that are run inside other functions.
# These functions are for internal use only and are not documented nor exported

# Function to create a data.frame with subtotals per crop at set adm level.
sum_adm_total <- function(df, level) {
  unit <- names(df)[names(df) %in% c("ha", "pa")]
  names(df)[names(df) %in% c("ha", "pa")] <- "value"
  df <- df %>%
    dplyr::filter(adm_level == level) %>%
    dplyr::group_by(crop, adm_level) %>%
    dplyr::summarize(value = plus(value, na.rm = F)) %>%
    dplyr::arrange(crop)
  return(df)
}

# Function to compare subtotals per crop at different adm levels.
compare_adm <- function(df, level_1, level_2, out = F) {
  tot1 <- sum_adm_total(df, level_1) %>%
    na.omit()
  tot2 <- sum_adm_total(df, level_2) %>%
    na.omit()
  inter <- intersect(tot1$crop, tot2$crop)

  if (!isTRUE(all.equal(
    tot1$value[tot1$crop %in% inter],
    tot2$value[tot2$crop %in% inter]
  ))) {
    message(
      glue::glue("\nadm{level_1} and adm{level_2} are not equal!. Did you run reaggregate_statistics()?")
    )
  } else {
    cat(glue::glue("\nadm{level_1} and adm{level_2} are equal"))
  }

  out_df <- dplyr::bind_rows(
    sum_adm_total(df, level_1),
    sum_adm_total(df, level_2)
  ) %>%
    tidyr::spread(adm_level, value) %>%
    setNames(c("crop", "level_1", "level_2")) %>%
    mutate(difference = round(level_1 - level_2, 6)) %>%
    setNames(c("crop", paste0("adm", level_1), paste0("adm", level_2), "difference"))
  if (out) {
    return(out_df)
  }
}

# Function to compare adm totals for two different data.frames, i.e. pa and pa_ps
compare_adm2 <- function(df1, df2, level, out = F) {
  tot1 <- sum_adm_total(df1, level) %>%
    na.omit()
  tot2 <- sum_adm_total(df2, level) %>%
    na.omit()
  inter <- intersect(tot1$crop, tot2$crop)
  if (!isTRUE(all.equal(
    tot1$value[tot1$crop %in% inter],
    tot2$value[tot2$crop %in% inter]
  ))) {
    stop(glue::glue("\ndf1 and df2 are not equal!",
      call. = FALSE
    ))
  } else {
    cat("\ndf1 and df2 are equal")
  }

  out_df <- dplyr::bind_rows(
    sum_adm_total(df1, level) %>%
      mutate(source = "df1"),
    sum_adm_total(df2, level) %>%
      mutate(source = "df2")
  ) %>%
    tidyr::spread(source, value) %>%
    mutate(difference = round(df1 - df2, 6)) %>%
    dplyr::select(-adm_level)
  if (out) {
    return(out_df)
  }
}

# Function to paste a vector but replace last one by and
fPaste <- function(vec) sub(",\\s+([^,]+)$", " and \\1", toString(vec))

# Function to create grid area
calc_grid_size <- function(grid) {
  grid_size <- terra::cellSize(grid, unit = "ha")
  names(grid_size) <- "grid_size"
  return(grid_size)
}

# Function to calculate total at given adm level
calculate_pa_tot <- function(adm_lvl, adm_code, param) {
  load_intermediate_data(c("pa"), adm_code, param, local = T, mess = F)

  df <- pa %>%
    tidyr::gather(crop, pa, -adm_code, -adm_name, -adm_level) %>%
    dplyr::filter(adm_level == adm_lvl) %>%
    dplyr::group_by(adm_code, adm_name, adm_level) %>%
    dplyr::summarise(pa = sum(pa, na.rm = T)) %>%
    dplyr::ungroup()
  return(df)
}

# Function to create a map from gridID dataframe
gridID2raster <- function(df, var, param) {
  load_data("grid", param, local = TRUE, mess = FALSE)
  grid_df <- as.data.frame(grid, xy = TRUE)
  r <- dplyr::left_join(df, grid_df, by = "gridID")
  r <- rast(r[c("x", "y", var)], crs = param$crs)
  return(r)
}

# Function to calculate totals per adm level
filter_out_pa <- function(i, pa) {
  df <- pa %>%
    dplyr::filter(adm_level == i) %>%
    dplyr::rename(
      "adm{{i}}_code" := .data$adm_code,
      "pa_adm{{i}}" := .data$pa
    ) %>%
    dplyr::select(-adm_name)

  return(df)
}


# Function to create folders
create_model_folder <- function(param) {
  model_folder <- glue::glue("{param$model}_{param$resolution}_adm_level_{param$adm_level}_solve_level_{param$solve_level}")
  return(model_folder)
}

# Creates tif file from df
create_tif <- function(crp, sy, var, df) {
  load_data("grid", param, mess = FALSE, local = TRUE)
  grid_df <- as.data.frame(grid, xy = TRUE)
  df <- df %>%
    dplyr::select(-x, -y) %>%
    dplyr::filter(crop == crp, system == sy) %>%
    dplyr::left_join(grid_df, ., by = "gridID") %>%
    dplyr::select(x, y, {{ var }})
  name <- paste(crp, sy, sep = "_")
  r <- terra::rast(df, crs = param$crs)
  r <- extend(r, grid)
  names(r) <- name
  terra::plot(r, main = name)
  cat("\n=> Tif file created for", var, name)
  return(r)
}

# Sum of vector elements but now NA + NA = NA not 0 as in sum
#
# `plus` Returns the sum of all values provided as arguments but ensures `NA` +
# `NA` = `NA`.
#
# This function is the same as `sum`() but if `na.rm` is `FALSE` and all input
# values are `NA`, it will return `NA` instead of 0.
#
# plus(1:10)
# plus(c(NA, NA))
# plus(c(NA, NA), na.rm = T)
plus <- function(x, na.rm = F) {
  if (all(is.na(x))) {
    c(x[0], NA)
  } else {
    if (na.rm == T) {
      sum(x, na.rm = TRUE)
    } else {
      sum(x, na.rm)
    }
  }
}
