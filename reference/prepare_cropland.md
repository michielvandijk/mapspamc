# Prepares synergy cropland extent

Combines all elements of the synergy cropland extent (median and maximum
cropland per grid cell and rank), with information on the location of
the subnational units and fixes potential inconsistencies (e.g. cropland
area larger than grid cell size).

## Usage

``` r
prepare_cropland(param)
```

## Arguments

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

## Examples

``` r
if (FALSE) { # \dontrun{
prepare_cropland(param)
} # }
```
