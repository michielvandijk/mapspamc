# Function to run mapspam in gams
run_gams_adm_level <- function(ac, param, out = TRUE){
  cat("\nSolving",  param$model, "model for", ac)
  gams_model <- system.file("gams", glue::glue("{param$model}.gms"), package = "mapspamc", mustWork = TRUE)

  model_folder <- create_model_folder(param)
  input <- file.path(param$mapspamc_path,
      glue::glue("processed_data/intermediate_output/{model_folder}/{ac}/input_{param$res}_{param$year}_{ac}_{param$iso3c}.gdx"))

  output <- file.path(param$mapspamc_path,
      glue::glue("processed_data/intermediate_output/{model_folder}/{ac}//spamc_{param$model}_{param$res}_{param$year}_{ac}_{param$iso3c}.gdx"))

  lst <- file.path(param$mapspamc_path,
      glue::glue("processed_data/intermediate_output/{model_folder}/{ac}//spamc_{param$model}_{param$res}_{param$year}_{ac}_{param$iso3c}.lst"))

  logf <- file.path(param$mapspamc_path,
      glue::glue("processed_data/intermediate_output/{model_folder}/{ac}/spamc_{param$model}_{param$res}_{param$year}_{ac}_{param$iso3c}.log"))

  # Using system2 now as this should be more portable and flexible. Still need to test it on Mac or Linux
  gams_model <- gsub("/", "\\\\", gams_model)
  input <- gsub("/", "\\\\", input)
  output <- gsub("/", "\\\\", output)
  lst <- gsub("/", "\\\\", lst)
  logf <- gsub("/", "\\\\", logf)

  cmd_output <- system2(file.path(param$gams_path, "gams.exe"), args = c(gams_model,
                                glue::glue('--gdx_input="{input}"'),
                                glue::glue('--gdx_output="{output}"'),
                                glue::glue('lf="{logf}"'),
                                glue::glue('o="{lst}"'), "logoption 4"),
               stdout = TRUE, stderr = TRUE)

  if (out) {
    message((paste(cmd_output, collapse = "\n")))
  }
  cat("\nFinished running",  param$model, "model for", ac, "\n")
}
