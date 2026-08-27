# Combines GAMS output into one R rds file

Combines the GAMs results that are saved in one (`solve_level = 0`) or
multiple (`solve_level = 1`) gdx files into one single rds file, that
can be easily loaded into R. The file is saved in the
`processed_data/results` folder.

## Usage

``` r
combine_results(param, cut = 1e-04, out = FALSE)
```

## Arguments

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

- cut:

  numeric. Sets allocation smaller than a certain value to 0. The
  default is 0.0001 (1 m2).

- out:

  logical; should the results be returned as output?

## Examples

``` r
if (FALSE) { # \dontrun{
combine_results(param)
#'
} # }
```
