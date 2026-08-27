# Combines all inputs into one GAMS gdx file

Combines all inputs, including the harmonized cropland, irrigated area
and statistics, and the scores/priors into one GAMS gdx file that can be
used by `mapspamc` as input. If solve_level = 1, a gdx file for each
administrative level 1 unit is created.'

## Usage

``` r
combine_inputs(param)
```

## Arguments

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

## Details

The gdx file contains a number of sets and parameter tables that define
the model. Sets describe the dimensions of the model, while parameters
contain the data along these dimensions. As part of the process to
combine all the inputs and if relevant, artificial administrative units
are created that represent the combination of all administrative units
per crop for which subnational statistics are missing. These units are
added to the list of administrative units from the subnational
statistics. The names of these units, stored in the `adm_area` parameter
table, start with the name of the lower level administrative unit which
nests the units with missing data, followed by `ART` and the level for
which data is missing and ending with the crop for which data is not
available.

## Examples

``` r
if (FALSE) { # \dontrun{
combine_inputs(param)
} # }
```
