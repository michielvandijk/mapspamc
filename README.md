
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mapspamc

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![R-CMD-check](https://github.com/michielvandijk/mapspamc/workflows/R-CMD-check/badge.svg)](https://github.com/michielvandijk/mapspamc/actions)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

The aim of the [`mapspamc` R
package](https://github.com/michielvandijk/mapspamc) is to facilitate
the creation of country level crop distribution maps. The model builds
on the global version of the [Spatial Production Allocation model
(SPAM)](www.mapspam.info) (You and Wood 2006; You, Wood, and Wood-Sichra
2009; You et al. 2014; Yu et al. 2020), which uses an cross-entropy
optimization approach to ‘pixelate’ national and subnational crop
statistics on a spatial grid at a resolution of 5 arcmin (\~ 10 x 10
km). `mapspamc` provides the necessary infrastructure to run the Spatial
Production Allocation Model at the country level and makes it possible
to incorporate national sources of information and potentially create
maps at a higher resolution of 30 arcsec (Dijk et al. 2022).

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
