# Compares crop distribution maps using a panel for each production system

To quickly inspect the `mapspamc` results, `view_results()` shows crop
distribution maps for a selected crop using a panel for each production
system. This function works after
[`combine_results()`](https://michielvandijk.github.io/mapspamc/reference/combine_results.md)
is run. There is no need to run
[`create_all_tif()`](https://michielvandijk.github.io/mapspamc/reference/create_all_tif.md).
The maps are visualized using [leafletjs](https://leafletjs.com/), which
makes it possible to select a number of background tiles (e.g.
OpenStreetMap).

## Usage

``` r
view_results(crp, var, param, viewer = TRUE, polygon = TRUE)
```

## Arguments

- crp:

  Character. Crop for which the maps are shows. `crp` has to be one of
  the `mapspamc` four letter crop codes.

- var:

  Character. The variable to be plotted. `var` has to be physical area
  (`"pa"`) or harvested area (`"ha"`).

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

- viewer:

  Logical. Should the default web browers be used to show the maps?
  `FALSE` will show the maps in the RStudio viewer pane.

- polygon:

  Logical; should the country polygon be overlayed?

## Examples

``` r
if (FALSE) { # \dontrun{
view_results(crop = "maiz", var = "ha", viewer = FALSE, polygon = FALSE)
} # }
```
