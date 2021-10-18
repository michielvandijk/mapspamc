
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mapspamc

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The aim of the [mapspamc R package](https://iiasa.github.io/mapspamc) is
to facilitate the creation of country level crop distribution maps.
mapspamc provides the necessary infrastructure to run the Spatial
Production Allocation Model for Country level studies (SPAMc). The model
builds on the global version of SPAM (You and Wood 2006; You, Wood, and
Wood-Sichra 2009; You et al. 2014; Yu et al. 2020), which uses an
cross-entropy optimization approach to ‘pixelate’ national and
subnational crop statistics on a spatial grid at a 5 arcmin resolution.
SPAMc was specifically developed to support country level analysis and
makes it possible to incorporate national sources of information and
potentially create maps at a higher resolution of 30 arcsec (Van Dijk et
al. 2020). The articles in the Background section provide more
information on [Crop distribution
maps](articles/crop_distribution_maps.html) in general, the
[model](articles/model_description.html), [input
data](articles/data.html) and an [Appendix](articles/appendix.html) with
additional information on specific topics. Apart from implementing
SPAMc, mapspamc includes functions to aggregate the SPAMc output to the
spatial (i.e. simulation units) and crop-level (18 major crops) format
that is used by GLOBIOM.

## Installation

To install mapspamc:

``` r
install.packages("remotes")
remotes::install_github("michielvandijk/mapspamc")
```

Apart from the mapspamc package, several other pieces of software are
essential to run SPAMc, which are described in the
[Installation](articles/software.html) section.

## Preparation

It takes some preparation before SPAMc can be run. Most important and
probably most time consuming is the collection of input data. SPAMc is a
data-driven model and therefore requires a large variety of input data,
which can be grouped under two headers: (1) (Sub)national agricultural
statistics and (2) spatial information. The availability of data
strongly affects the structure of the model and how can be solved. We
highly recommend to start collecting input data before running the
model. The articles in the Preparation section give an overview of all
the information that is requited by SPAMc and shows were to download
country examples, which can be used as a template to implement SPAMc to
other countries:

-   [Input data collection](articles/input_data_collection.html).
-   [Country examples/templates](articles/template.html)

## Run SPAMc

Running SPAMc can be divided into eight steps, which are described in
the articles in the Run SPAMc section. The other two articlesdescribe
how to update the land cover and land use maps in GLOBIOM and how to add
a new crop in GLOBIOM, which both require SPAMc output:

1.  [Model setup](articles/model_structure.html)
2.  [Processing of subnational
    statistics](articles/process_subnational_statistics.html)
3.  [Processing of spatial data](articles/process_spatial_data.html)
4.  [Create synergy cropland map](articles/create_synergy_cropland.html)
5.  [Create synergy irrigated area
    map](articles/create_synergy_irrigated_area.html)
6.  [Combine input data](articles/combine_input_data.html)
7.  [Run model](articles/run_spamc.html)
8.  [Post-processing](articles/post_process.html)
9.  [Replace GLOBIOM land use and land
    cover](articles/replace_globiom_land_cover_land_use.html)
10. [Adding a new crop to
    GLOBIOM](articles/add_new_crop_to_globiom.html)

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-VanDijk2020" class="csl-entry">

Van Dijk, Michiel, Ulrike Wood-Sichra, Yating Ru, Amanda Palazzo, Petr
Havlik, and Liangzhi You. 2020. “<span class="nocase">Mapping the change
in crop distribution over time using a data fusion approach</span>.”

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
Joglekar, Steffen Fritz, Wei Xiong, Wenbin Wu, and Peng Yang. 2020.
“<span class="nocase">A cultivated planet in 2010: 2. the global gridded
agricultural production maps</span>.” *Earth System Science Data*.
https://doi.org/<https://doi.org/10.5194/essd-2020-11>.

</div>

</div>
