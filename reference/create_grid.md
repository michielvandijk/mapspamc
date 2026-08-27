# Creates country grid

Creates the spatial grid that is used by `mapspamc` to allocate physical
area shares for each crop and system. The border of the country is used
as mask to determine the grid and each grid cell is given a gridID
number.

## Usage

``` r
create_grid(param = NULL)
```

## Arguments

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

## Details

For technical reasons, gridID values are set before the raster is masked
with the country border, which means they are unique but non
consecutive. Note that grids at a resolution of 30 arcsec can become
very large and might make some time to create. The file is saved in
`/processed_data/maps/{resolution}/grid`

## Examples

``` r
if (FALSE) { # \dontrun{
create_grid(param)
} # }
```
