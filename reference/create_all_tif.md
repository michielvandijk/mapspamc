# Creates tif files for all crop distribution maps produced by the model

The function creates tif files with maps for all crop and system
combinations for which area information was allocated by the model. Maps
are both created for harvested (ha) and physical (pa) area. Files are
saved in the `/processed_data/results/{model}/maps` folder.

## Usage

``` r
create_all_tif(param)
```

## Arguments

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.
