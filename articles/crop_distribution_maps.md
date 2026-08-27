# Crop distribution maps

Comprehensive, detailed and spatially explicit information on the
locations of crops is essential to inform agricultural and food
policies. crop distribution maps are used to as crucial input for
regional crop monitoring systems (Fritz et al. 2019; Becker-Reshef et
al. 2019), to analyse national irrigation potential (You et al. 2014;
Xie et al. 2017) and to assess the impact of climate change and
socioeconomic development on land use change and wider developmental
trade-offs (Ahmed et al. 2016).

Currently, only several global products provide spatial information on
the location of crops (Monfreda et al. 2008; Portmann et al. 2010; You
et al. 2014; see Anderson et al. 2015 for a comparison). These datasets
use spatial information on land cover, suitability and irrigation to
‘pixelate’ (sub)national agricultural statistics at 5 arc minute
resolution (~10x10 kilometer at the equator). Apart from the Spatial
Production Allocation Model (SPAM), which latest version covers the year
2010 (Yu et al. 2020), these datasets are rather outdated.

Global crop distribution maps are a useful starting point for national
analysis but are of limited use when more detailed and up to date
information is required. National decision makers often want to zoom in
on subnational regions (e.g. bread basket areas), which requires
(higher) resolution maps that are consistent with national data sources
such as land cover maps and subnational crop statistics.

An interesting alternative and new approach to create high resolution
crop distribution maps are machine learning techniques, which can be
used to identify the location of specific crops using satellite imagery
in combination with other predictors. Although promising, these
techniques are still under active development and the available studies
predominantly target large-scale crops (e.g. soy bean and palm oil),
which are easier to identify using machine learning classification
approaches (Zhong et al. 2016; Song et al. 2017; Danylo et al. 2020).

`mapspamc` provides the infrastructure to create plausible spatial
estimates of physical and harvested crop area at national scale using
the SPAM approach described in You and Wood (2006), You et al. (2009),
You et al. (2014) and Yu et al. (2020), which uses a cross-entropy
framework to allocate subnational land use information on a 5 arc minute
grid. Apart from the standard model, `mapspamc` offers an alternative
algorithm, which makes it possible to create crop distributions maps
with a resolution of 30 arc second (~1x1 kilometer at the equator) - see
Dijk et al. (2022) for more information.[^1]

## References

Ahmed, Kazi Farzan, Guiling Wang, Liangzhi You, and Miao Yu. 2016.
“Potential impact of climate and socioeconomic changes on future
agricultural land use in West Africa.” *Earth System Dynamics* 7 (1):
151–65. <https://doi.org/10.5194/esd-7-151-2016>.

Anderson, Weston, Liangzhi You, Stanley Wood, Ulrike Wood-Sichra, and
Wenbin Wu. 2015. “An analysis of methodological and spatial differences
in global cropping systems models and maps.” *Global Ecology and
Biogeography* 24 (2): 180–91. <https://doi.org/10.1111/geb.12243>.

Becker-Reshef, Inbal, Brian Barker, Michael Humber, et al. 2019. “The
GEOGLAM crop monitor for AMIS: Assessing crop conditions in the context
of global markets.” *Global Food Security* 23 (December): 173–81.
<https://doi.org/10.1016/j.gfs.2019.04.010>.

Danylo, Olha, Johannes Pirker, Guido Lemoine, et al. 2020. *Satellite
reveals age and extent of oil palm plantations in Southeast Asia*.
February. <http://arxiv.org/abs/2002.07163>.

Dijk, Michiel van, Ulrike Wood-Sichra, Yating Ru, Amanda Palazzo, Petr
Havlik, and Liangzhi You. 2022. “Generating multi-period crop
distribution maps for Southern Africa using a data fusion approach.”
Unpublished manuscript.

Fritz, Steffen, Linda See, Juan Carlos Laso Bayas, et al. 2019. “A
comparison of global agricultural monitoring systems and current gaps.”
*Agricultural Systems* 168 (January): 258–72.
<https://doi.org/10.1016/j.agsy.2018.05.010>.

Monfreda, Chad, Navin Ramankutty, and Jonathan A. Foley. 2008. “Farming
the planet: 2. Geographic distribution of crop areas, yields,
physiological types, and net primary production in the year 2000.”
*Global Biogeochemical Cycles* 22 (1).
<https://doi.org/10.1029/2007GB002947>.

Portmann, Felix T., Stefan Siebert, and Petra Döll. 2010.
“MIRCA2000—Global monthly irrigated and rainfed crop areas around the
year 2000: A new high-resolution data set for agricultural and
hydrological modeling.” *Global Biogeochemical Cycles* 24: 1–24.
<https://doi.org/10.1029/2008GB003435>.

Song, Xiao Peng, Peter V. Potapov, Alexander Krylov, et al. 2017.
“National-scale soybean mapping and area estimation in the United States
using medium resolution satellite imagery and field survey.” *Remote
Sensing of Environment* 190 (March): 383–95.
<https://doi.org/10.1016/j.rse.2017.01.008>.

Xie, Hua, Liangzhi You, and Hiroyuki Takeshima. 2017. “Invest in
small-scale irrigated agriculture: A national assessment on potential to
expand small-scale irrigation in Nigeria.” *Agricultural Water
Management* 193 (November): 251–64.
<https://doi.org/10.1016/j.agwat.2017.08.020>.

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

Yu, Qiangyi, Liangzhi You, Ulrike Wood-Sichra, et al. 2020. “A
cultivated planet in 2010 – Part 2: The global gridded
agricultural-production maps.” *Earth System Science Data* 12 (4):
3545–72. <https://doi.org/10.5194/essd-12-3545-2020>.

Zhong, Liheng, Lina Hu, Le Yu, Peng Gong, and Gregory S. Biging. 2016.
“Automated mapping of soybean and corn using phenology.” *ISPRS Journal
of Photogrammetry and Remote Sensing* 119 (September): 151–64.
<https://doi.org/10.1016/J.ISPRSJPRS.2016.05.014>.

[^1]: Note `mapspamc` does not support all the model extensions
    presented in Dijk et al. (2022). At the moment, it is not possible
    to blend in detailed information on the location of crops
    (e.g. OpenStreetMap information, large-farm surveys and machine
    learning products). `mapspamc` also does not include the approach to
    backcast crop distribution maps to earlier periods. These features
    might be added in an futured updates.
