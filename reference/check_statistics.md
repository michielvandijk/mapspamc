# Checks the consistency of the subnational statistics

Subnational statistics must be of class `subnat`

## Usage

``` r
check_statistics(df, param, out = FALSE)
```

## Arguments

- df:

  data.frame with subnational statistics at various levels in the long
  format

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

- out:

  logical; should the checking report be returned as output?

## Value

data.frame `df` when out is set to `TRUE`

## Examples

``` r
if (FALSE) { # \dontrun{
check_statistics(df, param)
} # }
```
