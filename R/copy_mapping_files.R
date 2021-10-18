# Function to copy mapping files
copy_mapping_files <- function(param) {
  mapping_files <- list.files(path = system.file("mappings", package = "mapspamc"), full.names = TRUE)

  purrr::walk(mapping_files, function(x) {
    if(!file.exists(file.path(param$spamc_path, paste0("mappings/", basename(x))))) {
      file.copy(x, file.path(param$spamc_path, paste0("mappings/", basename(x))))
    }
  })

}
