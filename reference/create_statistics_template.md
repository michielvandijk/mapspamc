# Creates template for subnational crop statistics

To support the preparation of the subnational statistics,
`create_statistics_template()` can create three types of data templates:

- ha for harvest area statistics

- ps for production system share

- ci for cropping intensity.

## Usage

``` r
create_statistics_template(type, param)
```

## Arguments

- type:

  Character vector that refers to the type of template that needs to be
  created. See details for allowed input.

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

## Details

The function requires information on how the different administrative
unit levels are nested. This file needs to be created first by running
[`create_adm_list()`](https://michielvandijk.github.io/mapspamc/reference/create_adm_list.md).

The dimensions of the templates are determined by the parameters set by
means of
[`mapspamc_par()`](https://michielvandijk.github.io/mapspamc/reference/mapspamc_par.md).
The ha template dimension is determined by adm level parameter, while
the dimensions of the ps and cs templates (which are identical) are
determined by the solve level parameter.

## Examples

``` r
if (FALSE) { # \dontrun{
create_statistics_template(type = "ha", param)
} # }
```
