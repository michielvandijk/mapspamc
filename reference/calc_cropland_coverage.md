# Calculates the balance between cropland and physical crop area

`calculate_cropland_coverage()` calculates the balance between total
cropland, derived from the synergy cropland mask, and total physical
area as provided by the crop statistics.

## Usage

``` r
calc_cropland_coverage(param)
```

## Arguments

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.
