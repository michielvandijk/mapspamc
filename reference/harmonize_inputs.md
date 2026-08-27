# Harmonizes crop statistics, cropland and irrigated area extent

Function that compares and harmonizes the subnational physical area with
gridded information on the location and extend of cropland and irrigated
area.

## Usage

``` r
harmonize_inputs(
  param,
  cl_slackp = 0.05,
  cl_slackn = 5,
  ia_slackp = 0.05,
  ia_slackn = 5
)
```

## Arguments

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

- cl_slackp:

  percentage of total cropland that will be added when comparing
  physical area statistics to cropland extent.

- cl_slackn:

  times the area of the largest grid cell will be added when comparing
  physical area statistics to cropland extent.

- ia_slackp:

  percentage of total irrigated area that will be added when comparing
  irrigated area statistics to irrigated area extent.

- ia_slackn:

  times the area of the largest grid cell will be added when comparing
  physical area statistics to irrigated area extent.

## Examples

``` r
if (FALSE) { # \dontrun{
harmonize_inputs(param, cl_slackp = 0.05, cl_slackn = 5, ia_slackp = 0.05, ia_slackn = 5)
} # }
```
