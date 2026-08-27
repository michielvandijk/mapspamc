# Prepares synergy irrigated area extent

Combines all elements of the synergy irrigated area extent (maximum
irrigated area and rank), with information on the location of the
subnational units and fixes potential inconsistencies (e.g. irrigated
area larger than grid cell size).

## Usage

``` r
prepare_irrigated_area(param)
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
prepare_irrigated_area(param)
} # }
```
