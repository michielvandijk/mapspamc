# Process gaez
process_gaez <- function(file, var, lookup, ac, param) {

  # Prepare
  load_intermediate_data(c("cl_harm"), ac, param, local = TRUE, mess = FALSE)
  load_data(c("grid"), param, local = TRUE, mess = FALSE)

  crp_sys <- basename(file)
  crp_sys <- unlist(lapply(strsplit(crp_sys, "_"), function(x) paste(x[1], x[2], sep="_")))
  crp <- strsplit(crp_sys, split = "_")[[1]][1]
  sys <- strsplit(crp_sys, split = "_")[[1]][2]
  cat("\nProcessing: ", var, " ", crp_sys)

  # Get replacement crops
  load_data("gaez_replace", param, local = TRUE, mess = FALSE)

  rep_crops <- gaez_replace %>%
    tidyr::gather(number, rep_crop, -crop) %>%
    dplyr::mutate(number = as.integer(gsub("rc_", "", number))) %>%
    dplyr::filter(crop %in% crp)
  rep_crops <- rep_crops$rep_crop

  # Set initial values for repeat loop
  cp_cnt <- 0
  no_rc <- FALSE
  crp_sys_rep <- crp_sys
  target_rc <- crp

  # Loop till gaez data are all non zero
  repeat{
    r <- raster::raster(file)
    names(r) <- "value"

    # Combine with grid, select only relevant gridID and add crop_system
    df <- as.data.frame(raster::rasterToPoints(raster::stack(grid, r))) %>%
      dplyr::select(-x, -y) %>%
      dplyr::filter(gridID %in% cl_harm$gridID) %>%
      dplyr::mutate(crop_system = crp_sys)

    # Fix inconsistencies. Set any negative (some files have very small negative
    # values) and NA values to zero
    df <- df %>%
      dplyr::mutate(value = ifelse(is.na(value) | value < 0, 0, value))

    # Break out of loop if all values are non-zero
    if(!all(df$value == 0)) {
      break
      }

    # Break out of loop if all values are still zero but there is no replacement crop
    # anymore in the list.
    if(is.na(target_rc)) {
      no_rc <- TRUE
      break
    }

    # Update values for next repeat
    cp_cnt <- cp_cnt + 1
    target_rc <- rep_crops[cp_cnt]
    crp_sys_rep <- paste(target_rc, sys, sep = "_")
    file <- lookup$files_full[lookup$crop_system == crp_sys_rep]
  }

  # Create log
  log_file = file(file.path(param$spam_path,
    glue::glue("processed_data/intermediate_output/{ac}/{param$res}/log_{param$res}_{param$year}_{ac}_{param$iso3c}.log")))
  capture.output(file = log_file, append = TRUE, split = T,{
    if (no_rc) {
      cat("\nThere is no replacement crop for: ", crop_sys, "! All values are zero.")
    } else {
      if(crp_sys != crp_sys_rep) {
        cat("\nAll values for ", crp_sys, " are zero, replaced by: ", crp_sys_rep)
      }
    }
  })

  return(df)
}

