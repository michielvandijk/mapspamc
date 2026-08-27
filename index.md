# mapspamc

The aim of the [`mapspamc` R
package](https://github.com/michielvandijk/mapspamc) is to facilitate
the creation of country level crop distribution maps. The model builds
on the global version of the [Spatial Production Allocation model
(SPAM)](http://www.mapspam.info) (You and Wood 2006; You, Wood, and
Wood-Sichra 2009; You et al. 2014; Yu et al. 2020), which uses a
cross-entropy optimization approach to ‘pixelate’ national and
subnational crop statistics on a spatial grid at a resolution of 5 arc
minutes (~ 10 x 10 km). `mapspamc` provides the necessary infrastructure
to run SPAM at the country level and makes it possible to incorporate
national sources of information and potentially create maps at a higher
resolution of 30 arc seconds (~ 1 x 1 km)(Dijk et al. 2022).

The articles in the Background section provide general information on
approaches to create [crop distribution
maps](https://michielvandijk.github.io/mapspamc/articles/crop_distribution_maps.md),
the
[model](https://michielvandijk.github.io/mapspamc/articles/model_description.md),
[input
data](https://michielvandijk.github.io/mapspamc/articles/input_data.md),
[country
examples](https://michielvandijk.github.io/mapspamc/articles/country_examples.md)
and an
[appendix](https://michielvandijk.github.io/mapspamc/articles/appendix.md)
with additional information on specific topics.

## Installation

To install `mapspamc`:

``` r

install.packages("remotes")
remotes::install_github("michielvandijk/mapspamc")
```

Running `mapspamc` requires the installation of several other pieces of
software, which are described in the
[Installation](https://michielvandijk.github.io/mapspamc/articles/installation.md)
section.

## Preparation

It takes some preparation before the crop distribution maps can be
generated. Most important and probably most time consuming is the
collection of input data. `mapspamc` requires a large variety of input
data, which can be grouped under three headers: (1) national crop
statistics, (2) data to construct the priors/fitness scores and (3) data
to determine the spatial constraints. The availability of data strongly
affects the structure of the model, how it will be solved and how long
it takes to solve. We highly recommend to start collecting input data
before running the model. The articles in the Background section give an
overview of the [input
data](https://michielvandijk.github.io/mapspamc/articles/input_data.md)
that are required by the package and show were to download several
[country
examples](https://michielvandijk.github.io/mapspamc/articles/country_examples.md).

## Run `mapspamc`

Running `mapspamc` can be divided into six major steps which are split
into nine smaller steps in the Run mapspamc section.

- [Design and process
  flow](https://michielvandijk.github.io/mapspamc/articles/design.md)
- [1. Model
  setup](https://michielvandijk.github.io/mapspamc/articles/model_setup.md)
- [2.1. Pre-processing - Subnational
  statistics](https://michielvandijk.github.io/mapspamc/articles/preprocessing_subnational_statistics.md)
- [2.2. Pre-processing - Spatial
  data](https://michielvandijk.github.io/mapspamc/articles/preprocessing_spatial_data.md)
- [2.3. Pre-processing -
  cropland](https://michielvandijk.github.io/mapspamc/articles/preprocessing_cropland.md)
- [2.4. Pre-processing - irrigated
  area](https://michielvandijk.github.io/mapspamc/articles/preprocessing_irrigated_area.md)
- [3. Model
  preparation](https://michielvandijk.github.io/mapspamc/articles/model_preparation.md)
- [4. Running the
  model](https://michielvandijk.github.io/mapspamc/articles/run_model.md)
- [5.
  Post-processing](https://michielvandijk.github.io/mapspamc/articles/postprocessing.md)
- [6. Model
  validation](https://michielvandijk.github.io/mapspamc/articles/model_validation.md)

## References

Dijk, Michiel van, Ulrike Wood-Sichra, Yating Ru, Amanda Palazzo, Petr
Havlik, and Liangzhi You. 2022. “Generating multi-period crop
distribution maps for Southern Africa using a data fusion approach.”

You, Liangzhi, and Stanley Wood. 2006. “An entropy approach to spatial
disaggregation of agricultural production.” *Agricultural Systems* 90
(1): 329–47. <https://doi.org/10.1016/j.agsy.2006.01.008>.

You, Liangzhi, Stanley Wood, and Ulrike Wood-Sichra. 2009. “Generating
plausible crop distribution maps for Sub-Saharan Africa using a
spatially disaggregated data fusion and optimization approach.”
*Agricultural Systems* 99 (2): 126–40.
<https://doi.org/10.1016/j.agsy.2008.11.003>.

You, Liangzhi, Stanley Wood, Ulrike Wood-Sichra, and Wenbin Wu. 2014.
“Generating global crop distribution maps: From census to grid.”
*Agricultural Systems* 127: 53–60.
<https://doi.org/10.1016/j.agsy.2014.01.002>.

Yu, Qiangyi, Liangzhi You, Ulrike Wood-Sichra, Yating Ru, Alison K. B.
Joglekar, Steffen Fritz, Wei Xiong, Miao Lu, Wenbin Wu, and Peng Yang.
2020. “A cultivated planet in 2010 – Part 2: The global gridded
agricultural-production maps.” *Earth System Science Data* 12 (4):
3545–72. <https://doi.org/10.5194/essd-12-3545-2020>.
