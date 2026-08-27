# Appendix

## Use of GAMS to solve the `mapspamc` models

The `mapspamc` package depends on General Algebraic Modeling System
(GAMS) (GAMS Development Corporation 2019) to solve the cross-entropy
and fitness score models. GAMS is commercial software, designed for
modelling and solving large complex optimization problems. To be able to
solve the models in `mapspamc` a GAMS licence is required that includes
full access (without size limitations) to CPLEX and IPOPT solvers (but
see below for potential alternative solvers). The function
`run_mapspamc` activates GAMS to run the model as defined by the user in
the model setup step. The GAMS model log will be sent to the screen
after the model run has finished. The log is a text file, which names
starts with `model_log_` and is saved in the
`processed_data/intermediate_output` folder after the model has
finished. The GAMS code (gms files) is stored in the `gams` folder in
the `mapspamc` R library folder. Interested users might want to take a
look and, if necessary, modify the code and run it directly in GAMS,
separately from the `mapspamc` package.

## Use of slack when solving models

The GAMS code involves the use of a slack variable to deal with data
inconsistencies, which result in infeasible models. A slack variable
transforms an inequality constraint in an equality constraint by adding
‘slack’ (Boyd and Vandenberghe 2004). This makes it possible to solve
the model even though it is technically infeasible. Different weights
(i.e. penalties) are used to capture the interaction and trade-offs
between the different slack variables (e.g. a lower slack for irrigated
area may result in a higher slack for available cropland). Relatively
high weights are used to minimize the slack for cropland availability
and irrigated area, whereas low weights are used for the subnational
statistics, which values are considered less reliable (see GAMS gms
files for which weights are used). After the model is run, the slack
variables are saved in the model output gdx file, which is stored in the
`processed_data/intermediate_output` folder.

Excessive slack points at inconsistencies between the (sub)national
statistics and the available crop and irrigated area to which the
statistics are allocated. To deal with these inconsistencies, the first
step is to closely inspect the data, and in particular the subnational
crop statistics, for data entry errors (e.g. missing values) and, if
needed, correct them. If there are still problems, we recommend by
adjusting the subnational statistics as they are sometimes inconsistent
with the FAOSTAT national statistics.

## GAMS solvers

Depending on the licence, GAMS is installed with several solvers. For
each type of problem a default solver is pre-selected. Unless changed by
the user, the `run_mapspamc` function will use the GAMS default solvers
for linear-problems (i.e. the `max_score` model) and non-linear problems
(i.e. the `min_entropy` model) to solve the models. To find out which
solvers are available and which are the default, open the GAMS IDE: file
-\> options -\> solvers. The user has the option to select one of the
other linear- and non-linear solvers supported by GAMS: ANTIGONE, BARON,
CPC, CPLEX, CONOPT4, CONOPT, GUROBI, IPOPT, IPOPTH, KNITRO, LGO, LINDO,
LOCALSOLVER, MINOS, MOSEK, MSNLP, OSICPLEX, OSIGUROBI, OSIMOSEK,
OSIXPRESS, PATHNLP, SCIP, SNOPT, SOPLEX, XA, XPRESS.

For the `max_score` model, which is a linear problem, it is recommended
to use [CPLEX](https://www.gams.com/latest/docs/S_CPLEX.html). For
non-linear problems, such as the `min_entropy` model, is not possible to
predict at forehand, which solver performs best. It is recommended to
start with using the
[IPOPT](https://www.gams.com/latest/docs/S_IPOPT.html), which has shown
good performance in solving cross-entropy models. An alternative option
is [CONOPT4](https://www.gams.com/latest/docs/S_CONOPT4.html), which,
however, is often much slower, and in some cases is not able to solve
the model.

## Differences between `mapspamc` and SPAM

There are several differences between `mapspamc` and SPAM (Yu et al.
2020) related to the allocation algorithm, calculation of priors and the
input data (Table @ref(tab:tab-spam-dif)). A main innovation is that
apart from the SPAM cross-entropy model, `mapspamc` also provides the
option to use an alternative ‘fitness score’ model. This model was
developed to create crop distribution maps at a higher resolution of 30
arc seconds (Dijk et al. 2022). As a consequence of using priors based
on socio-economic and biophysical suitability measures, the
cross-entropy approach allocates relatively small shares of a large
number of crops and farmings systems to grid cells. This is plausible
for a 5 arc minute resolution when grid cells are relatively large (~
10x10 km) and a large diversity of crops and farmings systems is to be
expected. This is, however, less likely for high resolutions of 30 arc
seconds, where grid cells are much smaller (~ 1x1 km) and it is more
likely to observe clusters of grid cells that are populated by a small
number of crops and production systems. To simulate this process, a
‘fitness’ score between 0 and 100, which measures both the
socio-economic and biophysical suitability, is calculated for each grid
cell. Crops and production systems will be allocated in such a way that
the crop area weighted fitness score is maximized, subject to
subnational crop area information and availability of cropland and
irrigated area.

Another difference related to the allocation algorithm is the use of
slacks in the constraints to better deal with data inconsistencies (see
above). We also dropped the suitability constraint in `mapspamc`. In
SPAM, the suitable crop area, calculated as the biophyiscal suitability
times the cropland area in a grid cell, was used as a hard constraint.
In practice, this constraint was often dropped because it severely
limits the space to allocate crops, resulting in infeasible models. As
an alternative, the cross-entropy and fitness score models in `mapspam`
use the suitability information to inform the priors and fitness scores,
in particular for the subsistence and low-input production systems. We
also slightly modified the calculation of the high-input and irrigated
crops, which are now based on the geometric average of accessibility and
potential revenue indicators that are normalized by means of the min-max
method.

Finally, we updated several input data sources with more recent and
higher resolution products, in particular (a) accessibility, which is
now based on travel time (Weiss et al. 2018), (b) population, taken from
Tatem (2017), (c) urban extent taken from Schiavina et al. (2022), (d)
irrigated area, which is a synergy product, based on GIA (Siebert et al.
2013) and GMIA (Meier et al. 2018), and (e) cropland, taken from several
recent cropland products that can be combined to generate a synergy
cropland map in the pre-processing step. We also reduced the number of
standard crops from 42 in SPAM to 40 in `mapspamc` by merging the two
millet (pearl and small millet) and coffee (arabica and robusta) species
because statistical information is difficult to find at such detailed
crop level (see below).

As a consequence of these modifications, the maps created with
`mapspamc` will deviate from comparable information presented by SPAM.
Nonetheless, output is expected to be comparable if similar model
settings are used.

| item | SPAM | mapspamc |
|----|----|----|
| **Allocation algorithm** |  |  |
| Objective function | Minimization of cross-entropy | Minimization of cross-entropy and maximization of fitness score |
| Resolution | 5 arc minutes | 5 arc minutes & 30 arc seconds |
| Slack variable | Used for model checking only | Added to the objective function to improve flexibility |
| Suitability constraint | Allocation cannot be larger than biophysically suitable cropland area | No longer implemented |
| **Calculation of priors** |  |  |
| Subsistence priors | based on share of rural population | based on share of rural population but set to zero when bio-physical suitability is zero |
| Low-input priors | based on potential revenue times accessibility | based on min-max normalized suitability |
| High-input priors | based on potential revenue times accessibility | based on weighted average of min-max normalized potential revenue and accessibility |
| Irrigated-area priors | based on potential revenue times accessibility | based on weighted average of min-max normalized potential revenue and accessibility |
| **Data** |  |  |
| Number of crops | 42 | 40 |
| Accessibility | Based on population density | Based on time to travel |
| Population | SEDAC v4 | WorldPop |
| Urban extent | GRUMP | GHL-SMOD |
| Irrigation | GMIA | GIA & GMIA |
| Cropland | SASAM | Recent cropland products |

Differences between `mapspamc` and SPAM. SPAM refers to the latest
version, which was used to generate SPAM2010 (Yu et al. 2020) {.table
.table style="font-size: 9px; margin-left: auto; margin-right: auto;"}

## List of `mapspamc` crops

`mapspamc` identifies 40 different crop (and crop groups) that together
cover the full agricultural sector and are each identified by a four
letter code (Table 1). The main reason for this classification is the
limited availability of crop-specific biophysical suitability maps,
which form a key input of the crop allocation process (see
[pre-processing spatial
data](https://michielvandijk.github.io/mapspamc/articles/preprocessing_spatial_data.html.md)
for more information). It would be relatively easy to add new crops by
splitting them off from broader crop groups (e.g. separate tomatoes from
vegetables) if appropriate agricultural statistics and suitability maps
are available. We plan to add an example on how to do this in future
updates. The actual number of crops in the model is determined by the
number of crops for which statistical information is provided.

| number | name              | group          |
|-------:|:------------------|:---------------|
|      1 | Wheat             | Cereals        |
|      2 | Rice              | Cereals        |
|      3 | Maize             | Cereals        |
|      4 | Barley            | Cereals        |
|      5 | Millet            | Cereals        |
|      6 | Sorghum           | Cereals        |
|      7 | Other Cereals     | Cereals        |
|      8 | Potato            | Roots & Tubers |
|      9 | Sweet Potato      | Roots & Tubers |
|     10 | Yams              | Roots & Tubers |
|     11 | Cassava           | Roots & Tubers |
|     12 | Other Roots       | Roots & Tubers |
|     13 | Bean              | Pulses         |
|     14 | Chickpea          | Pulses         |
|     15 | Cowpea            | Pulses         |
|     16 | Pigeon Pea        | Pulses         |
|     17 | Lentil            | Pulses         |
|     18 | Other Pulses      | Pulses         |
|     19 | Soybean           | Oilcrops       |
|     20 | Groundnut         | Oilcrops       |
|     21 | Coconut           | Oilcrops       |
|     22 | Oilpalm           | Oilcrops       |
|     23 | Sunflower         | Oilcrops       |
|     24 | Rapeseed          | Oilcrops       |
|     25 | Sesame Seed       | Oilcrops       |
|     26 | Other Oil Crops   | Oilcrops       |
|     27 | Sugarcane         | Sugar Crops    |
|     28 | Sugarbeet         | Sugar Crops    |
|     29 | Cotton            | Fibres         |
|     30 | Other Fibre Crops | Fibres         |
|     31 | Coffee            | Stimulates     |
|     32 | Cocoa             | Stimulates     |
|     33 | Tea               | Stimulates     |
|     34 | Tobacco           | Stimulates     |
|     35 | Banana            | Fruits         |
|     36 | Plantain          | Fruits         |
|     37 | Tropical Fruit    | Fruits         |
|     38 | Temperate Fruit   | Fruits         |
|     39 | Vegetables        | Vegetables     |
|     40 | Rest Of Crops     | Other          |

List of `mapspamc` crops {.table}

## References

Boyd, Stephen, and Lieven Vandenberghe. 2004. *Convex Optimization*.
Cambridge University Press. <https://doi.org/10.1017/CBO9780511804441>.

Dijk, Michiel van, Ulrike Wood-Sichra, Yating Ru, Amanda Palazzo, Petr
Havlik, and Liangzhi You. 2022. “Generating multi-period crop
distribution maps for Southern Africa using a data fusion approach.”
Unpublished manuscript.

GAMS Development Corporation. 2019. *General Algebraic Modeling System
(GAMS)*. Fairfax, VA. [www.gams.com](https://www.gams.com).

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

Tatem, Andrew J. 2017. *WorldPop, open data for spatial demography*.
No. 1. Vol. 4. Nature Publishing Groups.
<https://doi.org/10.1038/sdata.2017.4>.

Weiss, D. J., A. Nelson, H. S. Gibson, et al. 2018. “A global map of
travel time to cities to assess inequalities in accessibility in 2015.”
*Nature* 553 (7688): 333–36. <https://doi.org/10.1038/nature25181>.

Yu, Qiangyi, Liangzhi You, Ulrike Wood-Sichra, et al. 2020. “A
cultivated planet in 2010 – Part 2: The global gridded
agricultural-production maps.” *Earth System Science Data* 12 (4):
3545–72. <https://doi.org/10.5194/essd-12-3545-2020>.
