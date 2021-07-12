# Function to run mapspam in gams
run_gams_adm_level <- function(ac, param, out = TRUE){
  cat("\nRunning",  param$model, "model for", ac)
  model <- system.file("gams", glue::glue("{param$model}.gms"), package = "mapspamc", mustWork = TRUE)
  input <- file.path(param$spam_path,
      glue::glue("processed_data/intermediate_output/{ac}/{param$res}/input_{param$res}_{param$year}_{ac}_{param$iso3c}.gdx"))

  output <- file.path(param$spam_path,
      glue::glue("processed_data/intermediate_output/{ac}/{param$res}/spamc_{param$model}_{param$res}_{param$year}_{ac}_{param$iso3c}.gdx"))

  lst <- file.path(param$spam_path,
      glue::glue("processed_data/intermediate_output/{ac}/{param$res}/spamc_{param$model}_{param$res}_{param$year}_{ac}_{param$iso3c}.lst"))

  logf <- file.path(param$spam_path,
      glue::glue("processed_data/intermediate_output/{ac}/{param$res}/spamc_{param$model}_{param$res}_{param$year}_{ac}_{param$iso3c}.log"))

  # Using system2 now as this should be more portable and flexible. Still need to test it on Mac or Linux
  model <- gsub("/", "\\\\", model)
  input <- gsub("/", "\\\\", input)
  output <- gsub("/", "\\\\", output)
  lst <- gsub("/", "\\\\", lst)
  logf <- gsub("/", "\\\\", logf)

  cmd_output <- system2(file.path(param$gams_path, "gams.exe"), args = c(model,
                                glue::glue('--gdx_input="{input}"'),
                                glue::glue('--gdx_output="{output}"'),
                                glue::glue('lf="{logf}"'),
                                glue::glue('o="{lst}"'), "logoption 4"),
               stdout = TRUE, stderr = TRUE)

  # gams_system_call <- glue::glue("{param$gams_path}/gams.exe {model} --gdx_input={input} --gdx_output={output} lf={logf} o={lst} logOption 4")
  # gams_system_call <- gsub("/", "\\\\", gams_system_call) # change forward- into backslash
  # gams_system_call <- gsub("Program Files", "PROGRA~1", gams_system_call) # change forward- into backslash
  # cmd_output = system(gams_system_call, intern = TRUE)

  if (out) {
    message((paste(cmd_output, collapse = "\n")))
  }
  cat("\nFinished running",  param$model, "model for", ac, "\n")
}
