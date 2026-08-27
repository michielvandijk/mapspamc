# Both clips a raster to polygon and aligns it to reference grid

`align_raster()` uses a polygon of a country to clip a raster and aligns
the raster with a country grid that is created by
[`create_grid()`](https://michielvandijk.github.io/mapspamc/reference/create_grid.md).
Aligning implies that the resulting map will have the same dimensions,
resolution, extent and projection as the country grid, and therefore can
be stacked and combined with other spatial data.

## Usage

``` r
align_raster(r, ref_grid, poly, method = "bilinear")
```

## Arguments

- r:

  SpatRaster or location of SpatRaster to be processed

- ref_grid:

  SpatRaster or location of SpatRaster with the geometry that r should
  be resampled to

- poly:

  SpatVector or sf object that will be used to clip r

- method:

  character. Method used for estimating the new cell values. See
  [`terra::resample()`](https://rspatial.github.io/terra/reference/resample.html)
  for options.

## Details

The selected method depends on the resolution. In case input maps have a
lower or similar resolution than the model resolution, method =
"bilinear" is recommended. In case input maps have a higher resolution,
method = "sum" or method = "average" is recommended, depending on the
type of data that is processed.

Note that input maps are resampled to the target resolution before they
are clipped to the polygon. In this way the edges of the resulting
raster will be more detailed than clipping a low-resolution map.

## Examples

``` r
if (FALSE) { # \dontrun{
align_raster(travel_time, grid, adm_map, method = "bilinear")
} # }
```
