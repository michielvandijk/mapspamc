# Creates a pdf file with maps of administrative unit locations

The function creates and saves a pdf file with the location of the
administrative units in the `/processed_data/maps/adm` folder. Depending
on the adm level, maps are produced for level 1 and/or level 2
administrative units. The function will automatically load the file with
the polygon information on the location of administrative units, that
needs to be created first by the user (see Articles).

## Usage

``` r
create_adm_map_pdf(param, font_size = 3)
```

## Arguments

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

- font_size:

  Parameter to specify the font size of administrative unit name that is
  plotted on the map (default size = 3). If names are long or
  administrative unit polygons are small, the labels may get cluttered.
  Better results can be obtained by decreasing the font size.

## Value

An rds file with the created grid is saved in the
`processed_data/maps/grid` folder.

## Examples

``` r
if (FALSE) { # \dontrun{
create_adm_map_pdf(param)
} # }
```
