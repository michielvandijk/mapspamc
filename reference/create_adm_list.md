# Creates a file with information on how administrative units are nested

To organize and process the subnational statistics, a data.frame is
needed that lists all administrative units at all available levels and
how they are nested. The data.frame should have columns with the name
and code for each level of administrative unit data using the following
format: admX_name and admX_code, where X corresponds with the
administrative unit level for which data is available.

## Usage

``` r
create_adm_list(x, param)
```

## Arguments

- x:

  object of class sf with the location of the administrative units
  including an attribute table with information on how they are nested

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

## Details

All the required information should be contained in the attribute table
of the polygon file with the location of the administrative units. This
function strips the attribute table from the polygon file and saves it
as `adm_list.csv` in the `processed_data/lists/` folder. The package
documentation provides information on how to create the polygon file.

## Examples

``` r
if (FALSE) { # \dontrun{
create_adm_list(adm_map, param)
} # }
```
