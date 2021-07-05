# Functions to prepare gdx file for GAMS

# Function to create val for parameter prep file
val_gdx <- function(val, variables){

  # Create factors of variables
  val[,variables] <- lapply(val[,variables, drop = F] , factor) # Drop added otherwise val becomes a vector

  # Convert factor variables to numeric
  for(i in which(sapply(val, class) == "factor")) val[[i]] = as.numeric(val[[i]])
  val <- as.matrix(val)
  val <- unname(val)
  return(val)
}


# Function to create uels for parameter prep file
uels_gdx <- function(uels, variables){
  uels <- uels[names(uels) %in% variables]
  uels <- lapply(uels, factor)
  uels <- lapply(uels,levels)
  return(uels)
}

# Function prepare parameter gdx file
para_gdx <- function(df, variables, name, ts = NULL, type = "parameter",  form = "sparse"){

  # Prepare input
  val <- val_gdx(df, variables)
  uels <- uels_gdx(df, variables)
  dim <- length(uels)
  ts <- ifelse(is.null(ts), name, ts)

  # Create parameter list
  para <- list()
  para[["val"]] <- val    # Array containing the symbol data
  para[["name"]] <- name  # Symbol name (data item)
  para[["dim"]] <- dim    # Dimension of symbol = levels
  para[["ts"]] <- ts      # Explanatory text for the symbol
  para[["uels"]] <- uels  # Unique Element Labels (UELS) (levels)
  para[["type"]] <- type  # Type of the symbol
  para[["form"]] <- form  # Representation, sparse or full
  return(para)
}


# Function prepare sets gdx file
set_gdx <- function(df, variables, name = NULL, ts = NULL, type = "set"){

  # Prepare input
  uels <- uels_gdx(df, variables)

  if(length(variables) > 1) {
    val <- val_gdx(df, variables)
    form <- "sparse"
  } else {
    val <- array(rep(1, length(uels[[1]])))
    form <- "full"
  }

  dim <- length(uels)
  name <- ifelse(is.null(name), variables, name)
  ts <- ifelse(is.null(ts), variables, ts)

  # Create set list
  set <- list()
  set[["val"]] <- val
  set[["name"]] <- name
  set[["ts"]] <- ts
  set[["type"]] <- type
  set[["dim"]] <- dim
  set[["form"]] <- form
  set[["uels"]] <- uels
  return(set)
}

# Function to prepare scalar gdx file
scalar_gdx <- function(val, name = NULL, ts = NULL, type = "parameter", form = "full"){

  # Create scalar list
  scalar <- list()
  scalar[["val"]] <- val
  scalar[["name"]] <- name
  scalar[["ts"]] <- ts
  scalar[["type"]] <- type
  scalar[["form"]] <- form
  return(scalar)
}
