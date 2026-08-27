# 5. Post-processing

The function
[`create_all_tif()`](https://michielvandijk.github.io/mapspamc/reference/create_all_tif.md)
produces tif files of all crop distribution maps that are produced after
the downscaling algorithm is solved and the results are combined in one
rds file using `combine_results(param)`. In theory, the function creates
320 maps: 2 (harvested area and physical area) x 40 (crops) x 4
(production systems) but in practice the number will be lower, depending
on the actual number of crops and production systems observed in a
country.

``` r

create_all_tif(param)
```
