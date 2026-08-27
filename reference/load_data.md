# Load model input data for further processing

`load_data()` can be used to quickly load input data (e.g. subnational
statistics, maps and mappings). This can be useful to quickly inspect
the statistics or visualize a map. Data can only be loaded after data
has been created by running the pre-processing steps. See details for
allowed input.

## Usage

``` r
load_data(data, param, local = FALSE, mess = TRUE)
```

## Arguments

- data:

  character vector that refers to the data that is loaded. See details
  for allowed input.

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

- local:

  logical; should the data be loaded into the global (`TRUE`) or local
  environment (\`FALSE). Loading data into the local environment is only
  relevant when the function is used in internal package functions.

- mess:

  logical; should a message be printed to the screen that indicates
  which dataset is loaded?

## Details

The following inputs are allowed:

- adm_list:

- adm_map:

- adm_map_r:

- cl_mean:

- cl_max:

- cl_rank:

- ia_max:

- ia_rank:

- gaez2crop:

- gaez_replace:

- grid:

- gia:

- gmia:

- pop:

- acc:

- urb:

- simu:

- simu_r:

- ha:

- ps:

- ci:

- price:

- dm2fm:

- crop2globiom:

- faostat2crop:

- results:

## Examples

``` r
load_data(c("ha", "adm_map"), param)
#> Error: object 'param' not found
```
