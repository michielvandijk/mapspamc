# Function to run mapspam in gams
run_gams_adm_level <- function(ac, solver = solver, param, out = TRUE){
  cat("\nSolving",  param$model, "model for", ac, "with the", solver, "solver")
  gams_model <- system.file("gams", glue::glue("{param$model}.gms"), package = "mapspamc", mustWork = TRUE)

  model_folder <- create_model_folder(param)
  input <- file.path(param$model_path,
      glue::glue("processed_data/intermediate_output/{model_folder}/{ac}/input_{param$res}_{param$year}_{ac}_{param$iso3c}.gdx"))

  output <- file.path(param$model_path,
      glue::glue("processed_data/intermediate_output/{model_folder}/{ac}//spamc_{param$model}_{param$res}_{param$year}_{ac}_{param$iso3c}.gdx"))

  lst <- file.path(param$model_path,
      glue::glue("processed_data/intermediate_output/{model_folder}/{ac}//spamc_{param$model}_{param$res}_{param$year}_{ac}_{param$iso3c}.lst"))

  logf <- file.path(param$model_path,
      glue::glue("processed_data/intermediate_output/{model_folder}/{ac}/spamc_{param$model}_{param$res}_{param$year}_{ac}_{param$iso3c}.log"))

  # Using system2 now as this should be more portable and flexible. Still need to test it on Mac or Linux
  gams_model <- gsub("/", "\\\\", gams_model)
  input <- gsub("/", "\\\\", input)
  output <- gsub("/", "\\\\", output)
  lst <- gsub("/", "\\\\", lst)
  logf <- gsub("/", "\\\\", logf)
  gams_solvers <- c("ANTIGONE", "BARON", "CPC", "CPLEX", "CONOPT4", "CONOPT", "GUROBI", "IPOPT", "IPOPTH",
                    "KNITRO", "LGO", "LINDO", "LOCALSOLVER", "MINOS", "MOSEK", "MSNLP", "OSICPLEX",
                    "OSIGUROBI", "OSIMOSEK", "OSIXPRESS", "PATHNLP", "SCIP","SNOPT", "SOPLEX", "XA", "XPRESS")

  if(solver == "default"){
      solver_sel <- NULL
      } else {
        solver <- toupper(solver)
        if(solver %in% gams_solvers){
          solver_sel <- toupper(solver)
          } else {
            stop(paste0("Unknown GAMS solver was selected. Options are ", paste(gams_solvers, collapse = ", ")))
          }
        }

  if(is.null(solver_sel)){
    cmd_output <- system2(file.path(param$gams_path, "gams.exe"),
                          args = c(gams_model,
                                   glue::glue('--gdx_input="{input}"'),
                                   glue::glue('--gdx_output="{output}"'),
                                   glue::glue('lf="{logf}"'),
                                   glue::glue('o="{lst}"'),
                                    "logoption 4"),
                          stdout = TRUE, stderr = TRUE)
  } else {
    cmd_output <- system2(file.path(param$gams_path, "gams.exe"),
                          args = c(gams_model,
                                   glue::glue('--gdx_input="{input}"'),
                                   glue::glue('--gdx_output="{output}"'),
                                   glue::glue('lf="{logf}"'),
                                   glue::glue('o="{lst}"'),
                                   glue::glue('solver="{solver_sel}"'),
                                   "logoption 4"),
                          stdout = TRUE, stderr = TRUE)
    }

  if (out) {
    message((paste(cmd_output, collapse = "\n")))
  }
  cat("\nFinished running",  param$model, "model for", ac, "\n")
}
