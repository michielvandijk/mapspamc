
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mapspamc

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The aim of the [`mapspamc` R
package](https://github.com/michielvandijk/mapspamc) is to facilitate
the creation of country level crop distribution maps. The model builds
on the global version of the [Spatial Production Allocation model
(SPAM)](http://www.mapspam.info) (You and Wood 2006; You, Wood, and
Wood-Sichra 2009; You et al. 2014; Yu et al. 2020), which uses a
cross-entropy optimization approach to ‘pixelate’ national and
subnational crop statistics on a spatial grid at a resolution of 5 arc
minutes (\~ 10 x 10 km). `mapspamc` provides the necessary
infrastructure to run SPAM at the country level and makes it possible to
incorporate national sources of information and potentially create maps
at a higher resolution of 30 arc seconds (\~ 1 x 1 km)(Dijk et al.
2022).

The articles in the Background section provide general information on
approaches to create [crop distribution
maps](articles/crop_distribution_maps.html), the
[model](articles/model_description.html), [input
data](articles/input_data.html) and an
[appendix](articles/appendix.html) with additional information on
specific topics.

## Installation

To install `mapspamc`:

``` r
install.packages("remotes")
remotes::install_github("michielvandijk/mapspamc")
```

Running `mapspamc` requires the installation of several other pieces of
software, which are described in the
[Installation](articles/software.html) section.

## Preparation

It takes some preparation before the crop distribution maps can be
generated. Most important and probably most time consuming is the
collection of input data. `mapspamc` requires a large variety of input
data, which can be grouped under three headers: (1) national crop
statistics, (2) data to construct the priors/fitness scores and (3) data
to determine the spatial constraints. The availability of data strongly
affects the structure of the model, how it will be solved and how long
it takes to solve. We highly recommend to start collecting input data
before running the model. The articles in the Preparation section gives
an overview of the [input data](articles/input_data.html) that is
requited by the package and show were to download several [country
applications](articles/country_examples.html), which can be used as an
example to work )

## Run `mapspamc`

Running `mapspamc` can be divided into six major steps which are split
into nine smaller steps in the Run mapspamc section.

-   [1. Model setup](articles/model_setup.html)
-   [2.1. Pre-processing - Subnational
    statistics](articles/preprocessing_subnational_statistics.html)
-   [2.2. Pre-processing - Spatial
    data](articles/preprocessing_spatial_data.html)
-   [2.3. Pre-processing -
    cropland](articles/preprocessing_cropland.html)
-   [2.4. Pre-processing - irrigated
    area](articles/pre_processing_irrigated_area.html)
-   [3. Model preparation](articles/model_preparation.html)
-   [4. Running the model](articles/run_model.html)
-   [5. Post-processing](articles/postprocessing.html)
-   [6. Model validation](articles/model_validation.html)

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-VanDijk2022b" class="csl-entry">

Dijk, Michiel van, Ulrike Wood-Sichra, Yating Ru, Amanda Palazzo, Petr
Havlik, and Liangzhi You. 2022. “<span class="nocase">Generating
multi-period crop distribution maps for Southern Africa using a data
fusion approach</span>.”

</div>

<div id="ref-You2006" class="csl-entry">

You, Liangzhi, and Stanley Wood. 2006. “<span class="nocase">An entropy
approach to spatial disaggregation of agricultural production</span>.”
*Agricultural Systems* 90 (1): 329–47.
<https://doi.org/10.1016/j.agsy.2006.01.008>.

</div>

<div id="ref-You2009" class="csl-entry">

You, Liangzhi, Stanley Wood, and Ulrike Wood-Sichra. 2009. “<span
class="nocase">Generating plausible crop distribution maps for
Sub-Saharan Africa using a spatially disaggregated data fusion and
optimization approach</span>.” *Agricultural Systems* 99 (2): 126–40.
<https://doi.org/10.1016/j.agsy.2008.11.003>.

</div>

<div id="ref-You2014a" class="csl-entry">

You, Liangzhi, Stanley Wood, Ulrike Wood-Sichra, and Wenbin Wu. 2014.
“<span class="nocase">Generating global crop distribution maps: From
census to grid</span>.” *Agricultural Systems* 127: 53–60.
<https://doi.org/10.1016/j.agsy.2014.01.002>.

</div>

<div id="ref-Yu2020" class="csl-entry">

Yu, Qiangyi, Liangzhi You, Ulrike Wood-Sichra, Yating Ru, Alison K. B.
Joglekar, Steffen Fritz, Wei Xiong, Miao Lu, Wenbin Wu, and Peng Yang.
2020. “<span class="nocase">A cultivated planet in 2010 – Part 2: The
global gridded agricultural-production maps</span>.” *Earth System
Science Data* 12 (4): 3545–72.
<https://doi.org/10.5194/essd-12-3545-2020>.

</div>

</div>
