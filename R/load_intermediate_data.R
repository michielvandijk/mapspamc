# FUnction to load intermediate output in line with solve level for further processing
load_intermediate_data <- function(fl, adm_code, param, local = TRUE, mess = TRUE){
  fl <- match.arg(fl, c("cl", "ia", "ir", "pa", "pa_fs",
                        "cl_harm", "ia_harm", "bs", "py",
                        "rps", "priors", "scores"),
                  several.ok = TRUE)
  load_list <- list()

  if("cl" %in% fl) {
    file <- file.path(param$spam_path,
      glue::glue("processed_data/intermediate_output/{adm_code}/{param$res}/cl_{param$res}_{param$year}_{adm_code}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["cl"]] <- readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("ia" %in% fl) {
    file <- file.path(param$spam_path,
      glue::glue("processed_data/intermediate_output/{adm_code}/{param$res}/ia_{param$res}_{param$year}_{adm_code}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["ia"]] <- readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("pa" %in% fl) {
    file <- file.path(param$spam_path,
      glue::glue("processed_data/intermediate_output/{adm_code}/{param$res}/pa_{param$year}_{adm_code}_{param$iso3c}.csv"))
    if(file.exists(file)) {
      load_list[["pa"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("pa_fs" %in% fl) {
    file <- file.path(param$spam_path,
      glue::glue("processed_data/intermediate_output/{adm_code}/{param$res}/pa_fs_{param$year}_{adm_code}_{param$iso3c}.csv"))
    if(file.exists(file)) {
      load_list[["pa_fs"]] <- suppressMessages(readr::read_csv(file))
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("bs" %in% fl) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/intermediate_output/{adm_code}/{param$res}/bs_{param$res}_{param$year}_{adm_code}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["bs"]] <- readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("py" %in% fl) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/intermediate_output/{adm_code}/{param$res}/py_{param$res}_{param$year}_{adm_code}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["py"]] <- readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("cl_harm" %in% fl) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/intermediate_output/{adm_code}/{param$res}/cl_harm_{param$res}_{param$year}_{adm_code}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["cl_harm"]] <- readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("ia_harm" %in% fl) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/intermediate_output/{adm_code}/{param$res}/ia_harm_{param$res}_{param$year}_{adm_code}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["ia_harm"]] <- readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("rps" %in% fl) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/intermediate_output/{adm_code}/{param$res}/rps_{param$res}_{param$year}_{adm_code}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["rps"]] <- readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if("scores" %in% fl) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/intermediate_output/{adm_code}/{param$res}/scores_{param$res}_{param$year}_{adm_code}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["scores"]] <- readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }


  if("priors" %in% fl) {
    file <- file.path(param$spam_path,
                      glue::glue("processed_data/intermediate_output/{adm_code}/{param$res}/priors_{param$res}_{param$year}_{adm_code}_{param$iso3c}.rds"))
    if(file.exists(file)) {
      load_list[["priors"]] <- readRDS(file)
    } else {
      stop(paste(basename(file), "does not exist"),
           call. = FALSE)
    }
  }

  if(mess) {
    cat("\n", fPaste(fl), "loaded")
  }

  if(local) {
    invisible(list2env(load_list, envir = parent.frame()))
  } else {
    invisible(list2env(load_list, envir = .GlobalEnv))
  }
}
