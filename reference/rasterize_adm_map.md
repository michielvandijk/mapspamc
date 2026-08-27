# Rasterizes the map with the location of the subnational administrative units

For several internal operations, `mapspamc` needs a rasterized version
of the map with locations of the subnational administrative units. This
function creates this map and saves it into the
`/processed_data/maps/adm/` folder.

## Usage

``` r
rasterize_adm_map(param)
```

## Arguments

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

## Value

RasterLayer

## Examples

``` r
if (FALSE) { # \dontrun{
rasterize_adm_map(param)
} # }
```
