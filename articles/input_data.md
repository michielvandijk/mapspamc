# Input data

To create crop distribution maps with `mapspamc`, various types of data
are required, including national and subnational agricultural
statistics, cropland and irrigated area extent, and spatially explicit
information on economic and bio-physical suitability. Users of
`mapspamc` can use country-specific sources for each of these
categories, such as national irrigation, cropland and crop suitability
maps. However, apart from the subnational statistics, most of the data
can be taken from global data products. To support easy implementation
of the package, `mapspamc` is accompanied by a [public data
repository](https://doi.org/10.5281/zenodo.7031917) (referred to as the
mapspamc_db) that contains a large number of global maps that are
publicly available. The table below shows the global data products that
are included in the database. They are briefly discussed below.

| Description | Included | Scale | Source |
|:---|:---|:---|:---|
| Shapefile with location of administrative units | \- | National | National statistics and Yu et al. (2020) |
| Subnational crop statistics | \- | National | National statistics and Yu et al. (2020) |
| National crop and price statistics | 1961-2020 | Global | fao.org/faostat/en |
| Land cover map | 2015, 2019 | Global | land.copernicus.eu/global/products/lc |
| Land cover map | 2000, 2005, 2010, 2015, 2020 | Global | esa-landcover-cci.org |
| Land cover map | 2020 | Global | livingatlas.arcgis.com/landcover |
| Land cover map | 2003, 2007, 2011, 2015, 2019 | Global | glad.umd.edu/dataset/croplands |
| Land cover map | 2015 | Global | lpdaac.usgs.gov/products/mcd12q1v006/ |
| Synergy cropland map | 2010 | Global | Lu et al. (2020) |
| Table to rank cropland products | 2015 | Global | authors |
| Irrigated area map | 2010 | Global | Meier et al. (2018) |
| Irrigated area map | 2005 | Global | fao.org/aquastat/en/geospatial-information/global-maps-irrigated-areas |
| Biophysical suitability and potential yield maps | 2000 | Global | IIASA and FAO (2012) |
| Travel time map | 2015 | Global | malariaatlas.org/research-project/accessibility-to-cities |
| Population maps | 2010, 2015, 2020 | Global | worldpop.org |
| Urban area map | 2010, 2015, 2020 | Global | ghsl.jrc.ec.europa.eu |

Data products in the mapspamc database {.table}

## Crop statistics

The aim of `mapspamc` is to spatially allocate national and subnational
information on harvested and physical crop area for four different
production systems (subsistence, low-input rainfed, high-input rainfed
and high-input irrigated). The use of subnational statistics is of key
importance and greatly improves the quality of the gridded maps
(Joglekar et al. 2019). Four pieces of information need to be collected
by the user:

- **Harvested area statistics.** Data on crop level harvested area at
  administrative unit level 1 and, if possible, level 2. `mapspamc` is
  designed to handle missing information at the subnational level so any
  data is useful.

- **Subnational administrative unit map.**. It is essential to have a
  map (e.g. shapefile or any other polygon format) with the location of
  the subnational administrative units that corresponds with the
  subnational statistics. These two sources of information need to be
  perfectly consistent or made consistent.

- **Cropping intensity statistics.** Information on the cropping
  intensity (e.g. the number of crop rotations in case of multicropping)
  per crop at the national level and, if available, at the subnational 1
  level. This information will be combined with the harvested area
  statistics to estimate the physical crop area at the national and
  subnational level.

- **production system area shares.** Data on the area share for each
  crop and all four production systems, preferably at the national and,
  if available, subnational 1 level. This information will be combined
  with physical area estimation to calculate the physical crop area for
  each of the four production systems times crop combinations at the
  national and subnational level.

Finding subnational information on harvested area is not easy as they
are not always collected and/or published by national statistical
agencies and if they are available they often cover a selection of crops
and might have many missing values. Cropping intensity and production
system shares are probably even much more difficult to find and often
requires making a lot of assumptions to fill data gaps (e.g. assuming
the same cropping intensity for similar crops).

Some places where you might look for subnational statistics:

- National statistical agencies and agricultural research institutes,
  are the best places to find subnational agricultural statistics.

- [CountryStat](http://www.fao.org/economic/ess/countrystat) is database
  with Food and agriculture statistics at the subnational level. Its
  predecessor [Agro-Maps](http://kids.fao.org/agromaps/) with older data
  can also still be accessed. Coverage of both databases is, however,
  limited.

- Knowing in which regions crops are not produced is also very useful.
  By setting the harvested area to 0 for some regions the model will be
  forced to allocate the (national) statistics in other subnational
  units.

- Agricultural trade statistics in FAOSTAT might give you an idea about
  the production system shares. If most crop production is exported, a
  large share of the farmers can probably be categorized as high-input
  (or irrigated) farming.

- As mentioned above, the
  [AQUASTAT](http://www.fao.org/nr/water/aquastat/data/query/index.html?lang=en)
  database provides information on irrigated area shares.

Information on harvested area at the national level can be obtained from
[FAOSTAT](http://www.fao.org/faostat/en/#home), which is also included
in mapspamc_db. Data on irrigated crop area can be taken from
[AQUASTAT](http://www.fao.org/nr/water/aquastat/data/query/index.html?lang=en).

## Cropland extent

To allocate the physical area statistics `mapspamc` requires a cropland
extent, which shows the location of cropland in a country for the target
year. There are several global cropland products and often countries
produce a national land cover map, which shows the location of cropland.
To account for the uncertainty in the location of cropland, Fritz et al.
(2011) combined several different products into one so-called synergy
cropland map.

The synergy cropland approach combines all available (global) cropland
maps and creates a ranking for each grid cell that measures the level of
agreement between the various input maps. In the `mapspamc` the grid
cells with the least uncertainty are selected first when allocating
physical area of individual crops. Apart from the ranking, the synergy
cropland approach also prepares maps with the mean and maximum cropland
area per grid cell. The mean area product is used as the base layer by
`mapspamc` but in case this is not sufficient to allocate all the
physical area, grid cells from the maximum cropland map can be used (see
[Model
preparation](https://michielvandijk.github.io/mapspamc/articles/model_preparation.md)
for more information on how this is done).

There are two options to obtain a synergy cropland map. The first is to
take an existing product. If `mapspamc` is used to produce crop
distribution maps for around 2010, the user can use an existing global
product (Lu et al. 2020) that was also used as input for SPAM2010. A
second option is to construct a country specific synergy cropland
extent. mapspamc_db includes several recent cropland products that can
be combined using scripts in `mapspamc` to create a country-specific
synergy cropland map.

## Irrigation

To allocate the irrigated crops, `mapspamc` needs an irrigated area
extent. Similar to the synergy cropland map, we create a synergy
irrigated area map that takes into account the uncertainties related to
the location of irrigated areas. At present, there are only two global
products that provide this information. the Global Map of Irrigated
Areas (GMIA) (Siebert et al. 2013), shows the areas that are equipped
for irrigation based on national survey data and maps for 2005 at 5 arc
minutes. The Global Irrigated Areas (GIA) map (Meier et al. 2018)
depicts actual irrigated areas around the period 2005. It combines
normalized difference vegetation index (NDVI) maps, crop suitability
data and information on the location of areas equipped for irrigation to
create an irrigated area map at a resolution of 30 arc seconds. In
comparison to the GMIA, it shows 18% more irrigated area globally.

## Biophysical suitability and potential yield

Spatially explicit information on biophysical suitability and potential
yield is taken from IIASA and FAO (2012). The International Institute
for Applied Systems Analysis (IIASA) in collaboration with FAO,
developed the global agro-ecological zones (GAEZ) methodology that
assesses the biophysical potential for a large number of crops across
three production systems: low-input rainfed, high-input rainfed and
high-input irrigated systems. The first class is used for both the
subsistence and low-input system in `mapspamc`. GAEZ presents spatially
explicit information on the biophysical suitability (on a scale from 1
to 100) and potential yield (in t/ha) separate for each production
system. mapspamc_db includes data for GAEZv3.[^1].

## Accessibility

As a proxy for access to markets and quality of road infrastructure we
used a global map with travel time to high-density urban centers. Weiss
et al. (2018) depicts the global road infrastructure in 2015 by
presenting travel time to urban areas at a resolution of 1×1 kilometer.

## Rural population density

We used the WorldPop (Tatem 2017) database as a our primary source of
information for national population density. WorldPop combines a random
forest model with census data to generate a gridded prediction of
population density at ~100 meter spatial resolution (Stevens et al.
2015). Data is available for at a number of spatial resolutions and
various years. We used the global maps at 1x1 kilometer as input for our
analysis. To identify the rural population, we used the urban extent
from Schiavina et al. (2022). Rural population was selected by removing
grid cells that are located within the urban extent.

## Crop price

To calculate the potential revenue of a crop at the grid cell level, we
followed the SPAM approach (Wood-Sichra et al. 2016) and multiplied the
potential yield from IIASA and FAO (2012) with crop prices from FAO
(2019).

## References

FAO. 2019. *FAOSTAT*. <http://www.fao.org/faostat>.

Fritz, Steffen, Liangzhi You, Andriy Bun, et al. 2011. “Cropland for
sub-Saharan Africa: A synergistic approach using five land cover data
sets.” *Geophysical Research Letters* 38 (4): n/a–.
<https://doi.org/10.1029/2010GL046213>.

IIASA, and FAO. 2012. *Global Agro‐ecological Zones (GAEZv3.0)*. IIASA &
FAO.

Joglekar, Alison K. B., Ulrike Wood-Sichra, and Philip G. Pardey. 2019.
“Pixelating crop production: Consequences of methodological choices.”
*PLOS ONE* 14 (2): e0212281.
<https://doi.org/10.1371/journal.pone.0212281>.

Lu, Miao, Wenbin Wu, Liangzhi You, et al. 2020. “A cultivated planet in
2010: 1. the global synergy cropland map.” *Earth System Science Data*,
ahead of print. <https://doi.org/doi.org/10.5194/essd-2020-12>.

Meier, Jonas, Florian Zabel, and Wolfram Mauser. 2018. “A global
approach to estimate irrigated areas – a comparison between different
data and statistics.” *Hydrology and Earth System Sciences* 22 (2):
1119–33. <https://doi.org/10.5194/hess-22-1119-2018>.

Schiavina, Marcello, M. Melchiorri, Martino Pesaresi, et al. 2022. *GHSL
Data Package 2022*. Publications Office of the European Union.
[https://doi.org/10.2760/19817, JRC
129516](https://doi.org/10.2760/19817,%20JRC%20129516).

Siebert, Stefan, Verena Henrich, Karen Frenken, and Jacob Burke. 2013.
“Global Map of Irrigation Areas version 5.” Rheinisch
Friedrich-Wilhelms-University.

Stevens, Forrest R., Andrea E. Gaughan, Catherine Linard, Andrew J.
Tatem, A Jarvis, and H Hashimoto. 2015. “Disaggregating Census Data for
Population Mapping Using Random Forests with Remotely-Sensed and
Ancillary Data.” *PLOS ONE* 10 (2): e0107042.
<https://doi.org/10.1371/journal.pone.0107042>.

Tatem, Andrew J. 2017. *WorldPop, open data for spatial demography*.
No. 1. Vol. 4. Nature Publishing Groups.
<https://doi.org/10.1038/sdata.2017.4>.

Weiss, D. J., A. Nelson, H. S. Gibson, et al. 2018. “A global map of
travel time to cities to assess inequalities in accessibility in 2015.”
*Nature* 553 (7688): 333–36. <https://doi.org/10.1038/nature25181>.

Wood-Sichra, Ulrike, Alison B. Joglekar, and Liangzhi You. 2016.
“Spatial Producion Allocation Model (SPAM) 2005: Technical
Documentation.” Harvest Choice Working Paper. International Food Policy
Research (IFPRI).

[^1]: Recently GAEZv4 was released, which we aim to add in an update of
    mapspamc_db
