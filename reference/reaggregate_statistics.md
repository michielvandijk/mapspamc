# Reaggregates subnational statistics from the bottom up so they are consistent

Reaggregates subnational statistics from the bottom up so they are
consistent

## Usage

``` r
reaggregate_statistics(df, param)
```

## Arguments

- df:

  tbl or data.frame

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

## Value

same class as `df`.

## Examples

``` r
if (FALSE) { # \dontrun{
reaggregate_statistics(df, param)
} # }
```
