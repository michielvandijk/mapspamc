# Aggregates gridded results of alternative model to the administrative unit level of the target model

`aggregate_to_adm` aggregates gridded results of an alternative model
specified by `alt_param` to the administrative unit level determined by
`adm_level` of the target model specified by `param`. The model
described by `alt_param` must be identical to the target model apart
from the `adm_level` parameter, which is set to a less-detailed level. A
comparison of the output of `aggregate_to_adm` with subnational
information at the most detailed level available is a validation of the
alternative model and, indirectly, also of the target model.

## Usage

``` r
aggregate_to_adm(param, alt_param)
```

## Arguments

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

- alt_param:

  Object of type spamc_par that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

## Value

data.frame with `mapspamc` results aggregated to the administrative unit
level specified in `alt_param`.

## Examples

``` r
if (FALSE) { # \dontrun{
aggregate_to_adm(param, alt_param)
} # }
```
