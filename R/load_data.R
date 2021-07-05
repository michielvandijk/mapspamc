#'@title
#'Load model input data for further processing
#'
#'@description
#'`load_data()` can be used to quickly load input data (e.g. subnational
#'statistics, maps and mappings). This can be useful to quickly inspect the
#'statistics or visualize a map. Data can only be loaded after the
#'`create_spam_folders()` has been run and data has been created by running
#'pre-processing steps. See details for allowed input.
#'
#'@details
#'The following inputs are allowed:
#'
#'- adm_list:
#'- adm_map:
#'- adm_map_r:
#'- cl_med:
#'- cl_max:
#'- cl_rank:
#'- ia_max:
#'- ia_rank:
#'- gaez2crop:
#'- gaez_replace:
#'- grid:
#'- gia:
#'- gmia:
#'- pop:
#'- acc:
#'- urb:
#'- simu:
#'- simu_r:
#'- ha:
#'- fs:
#'- ci:
#'- price:
#'- dm2fm:
#'- crop2globiom:
#'- faostat2crop:
#'- results:
#'
#'@param data character vector that refers to the data that is loaded. See
#'  details for allowed input.
#'@param
#'@inheritParams create_grid
#'@param local logical; should the data be loaded into the global (`TRUE`) or
#'  local environment (`FALSE). Loading data into the local environment is only
#'  relevant when the function is used in internal package functions.
#'@param mess logical; should a message be printed to the screen that indicates
#'  which dataset is loaded?
#'
#'@export
load_data <- function(data, param, local = FALSE, mess = TRUE){
  stopifnot(inherits(param, "spam_par"))
  stopifnot(all(data %in% c("adm_list", "adm_map", "adm_map_r",
                        "cl_med", "cl_max", "cl_rank",
                        "ia_max", "ia_rank",
                        "grid", "gia", "gmia",
                        "pop", "acc", "urb",
                        "simu_r", "simu",
                        "ha", "fs", "ci",
                        "price",
                        "dm2fm", "crop2globiom", "faostat2crop", "crop", "gaez2crop",
                        "gaez_replace",
                        "results", "results_tp1")))

  load_list <- list()

  if("grid" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/grid/{param$res}/grid_{param$res}_{param$year}_{param$iso3c}.tif"))
    if(file.exists(file)) {
      load_list[["grid"]] <- raster::raster(file)
      names(load_list[["grid"]]) <- "gridID"
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("gia" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/irrigated_area/{param$res}/gia_{param$res}_{param$year}_{param$iso3c}.tif"))
    if(file.exists(file)) {
      load_list[["gia"]] <- raster::raster(file)
      names(load_list[["gia"]]) <- "gia"
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("gmia" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/irrigated_area/{param$res}/gmia_{param$res}_{param$year}_{param$iso3c}.tif"))
    if(file.exists(file)) {
      load_list[["gmia"]] <- raster::raster(file)
      names(load_list[["gmia"]]) <- "gmia"
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("pop" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/population/{param$res}/pop_{param$res}_{param$year}_{param$iso3c}.tif"))
    if(file.exists(file)) {
      load_list[["pop"]] <- raster::raster(file)
      names(load_list[["pop"]]) <- "pop"
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("acc" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/accessibility/{param$res}/acc_{param$res}_{param$year}_{param$iso3c}.tif"))
    if(file.exists(file)) {
      load_list[["acc"]] <- raster::raster(file)
      names(load_list[["acc"]]) <- "acc"
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }


  if("urb" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/population/{param$res}/urb_{param$year}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["urb"]] <- readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("price" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/agricultural_statistics/crop_prices_{param$year}_{param$iso3c}.csv"))
    if(file.exists(file)) {
      load_list[["price"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("faostat2crop" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("mappings/faostat2crop.csv"))
    if(file.exists(file)) {
      load_list[["faostat2crop"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("crop" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("mappings/crop.csv"))
    if(file.exists(file)) {
      load_list[["crop"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("dm2fm" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("mappings/dm2fm.csv"))
    if(file.exists(file)) {
      load_list[["dm2fm"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("crop2globiom" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("mappings/crop2globiom.csv"))
    if(file.exists(file)) {
      load_list[["crop2globiom"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("gaez2crop" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("mappings/gaez2crop.csv"))
    if(file.exists(file)) {
      load_list[["gaez2crop"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("gaez_replace" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("mappings/gaez_replace.csv"))
    if(file.exists(file)) {
      load_list[["gaez_replace"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("adm_map" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/adm/{param$res}/adm_map_{param$year}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["adm_map"]] <- readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("adm_map_r" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/adm/{param$res}/adm_map_r_{param$res}_{param$year}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["adm_map_r"]] <- readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("adm_list" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/lists/adm_list_{param$year}_{param$iso3c}.csv"))
    if(file.exists(file)) {
      load_list[["adm_list"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("results" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/results/{param$res}/{param$model}/results_{param$res}_{param$year}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["results"]] <-readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("results_tp1" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/mapspam_tp1/{param$res}/results_{param$res}_{year_tp1}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["results_tp1"]] <-readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("ha" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/agricultural_statistics/ha_adm_{param$year}_{param$iso3c}.csv"))
    if(file.exists(file)) {
      load_list[["ha"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("fs" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/agricultural_statistics/fs_adm_{param$year}_{param$iso3c}.csv"))
    if(file.exists(file)) {
      load_list[["fs"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("ci" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/agricultural_statistics/ci_adm_{param$year}_{param$iso3c}.csv"))
    if(file.exists(file)) {
      load_list[["ci"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("cl_med" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/cropland/{param$res}/cl_med_{param$res}_{param$year}_{param$iso3c}.tif"))
    if(file.exists(file)) {
      load_list[["cl_med"]] <- raster::raster(file)
      names(load_list[["cl_med"]]) <- "cl_med"
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }


  if("cl_max" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/cropland/{param$res}/cl_max_{param$res}_{param$year}_{param$iso3c}.tif"))
    if(file.exists(file)) {
      load_list[["cl_max"]] <- raster::raster(file)
      names(load_list[["cl_max"]]) <- "cl_max"
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("cl_rank" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/cropland/{param$res}/cl_rank_{param$res}_{param$year}_{param$iso3c}.tif"))
    if(file.exists(file)) {
      load_list[["cl_rank"]] <- raster::raster(file)
      names(load_list[["cl_rank"]]) <- "cl_rank"
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("ia_max" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/irrigated_area/{param$res}/ia_max_{param$res}_{param$year}_{param$iso3c}.tif"))
    if(file.exists(file)) {
      load_list[["ia_max"]] <- raster::raster(file)
      names(load_list[["ia_max"]]) <- "ia_max"
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("ia_rank" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/irrigated_area/{param$res}/ia_rank_{param$res}_{param$year}_{param$iso3c}.tif"))
    if(file.exists(file)) {
      load_list[["ia_rank"]] <- raster::raster(file)
      names(load_list[["ia_rank"]]) <- "ia_rank"
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("simu_r" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/simu/{param$res}/simu_r_{param$res}_{param$year}_{param$iso3c}.tif"))
    if(file.exists(file)) {
      load_list[["simu_r"]] <- raster::raster(file)
      names(load_list[["simu_r"]]) <- "simu_r"
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("simu" %in% data) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/maps/simu/{param$res}/simu_{param$res}_{param$year}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["simu"]] <- readRDS(file)
      } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if(mess) {
    cat("\n", fPaste(data), "loaded")
  }
  if(local == TRUE) {
    invisible(list2env(load_list, envir = parent.frame()))
  } else {
    invisible(list2env(load_list, envir = .GlobalEnv))
  }
}
