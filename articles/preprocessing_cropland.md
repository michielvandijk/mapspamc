# 2.3. Pre-processing - cropland

A key feature of `mapspamc` is to allocate the crop statistics to areas
identified as cropland on a map - the cropland extent. As described in
the section on [Input
data](https://michielvandijk.github.io/mapspamc/articles/inputdata.md),
we use a so-called synergy cropland map to account for the uncertainty
in the location of cropland. The synergy cropland map combines different
cropland products to construct a single cropland map that presents the
mean and maximum available crop area per grid cell as well as a ranking
that measures the agreement between the various cropland products for
each grid cell. A ranking of 1 means that all sources agree there is
cropland in a grid cell, while a higher rank signals disagreement.

The package contains a script to create a synergy cropland map using
global land use products that are included in the maspamc database:
COPERNICUS, ESACCI, ESRI, GLAD and MODIS (see the database documentation
for details). The script is located in the
`02_3_pre_processing_cropland` folder. Before the synergy cropland map
can be created the user needs to clip target country from the global
datasets and ensure the maps have the right format (i.e. desired extent,
resolution and coordinate reference system). Scripts to do this for each
global land use product are provided in the same folder.

For the Malawi example, we can make use of an existing global synergy
cropland map (SASAM) that was prepared for SPAM2010, which can be
selected by running `select_sasam.R`. For the Ethiopia country example
we used information from four datasets that represent global cropland
around the period 2015: GLAD, COPERNICUS, ESACCI and MODIS. The user
needs to run `select_*.R` first to process the global maps. The script
`create_synergy_cropland_map.R` combines the selected land use maps and
creates a country synergy cropland map.

In order to create the synergy map, a ranking table is needed that
indicates, which (combination) of the inputs maps is regarded as the
most reliable. In case all the global cropland maps signal a grid cell
contains cropland the ranking is 1 (highest and most reliable). For all
other combinations the user needs to prepare a ranking table. The table
for Ethiopia is added to the mapspamc
database(`synergy_cropland_table/synergy_cropland_table_2015.xlsx`) and
contains a ranking from 1 to 16 (see below) because it is based on four
maps. For Ethiopia, we decided on the following order of increasing
importance when creating the scoring table: (1) GLAD, (2) COPERNICUS,
(3) ESACCI and (4) MODIS. GLAD receives the highest score because it has
the highest original resolution (30 meter) and is therefore assumed to
be the most accurate, followed by COPERNICUS (100 meter), ESACCI (300
meter) and MODIS (500 meter).

| agreement | rank | glad | copernicus | esacci | modis |
|----------:|-----:|-----:|-----------:|-------:|------:|
|         4 |    1 |    1 |          1 |      1 |     1 |
|         3 |    2 |    1 |          1 |      1 |     0 |
|         3 |    3 |    1 |          1 |      0 |     1 |
|         3 |    4 |    1 |          0 |      1 |     1 |
|         2 |    5 |    0 |          1 |      1 |     1 |
|         2 |    6 |    1 |          1 |      0 |     0 |
|         2 |    7 |    1 |          0 |      1 |     0 |
|         2 |    8 |    1 |          0 |      0 |     1 |
|         2 |    9 |    0 |          1 |      1 |     0 |
|         2 |   10 |    0 |          1 |      0 |     1 |
|         2 |   11 |    0 |          0 |      1 |     1 |
|         1 |   12 |    1 |          0 |      0 |     0 |
|         1 |   13 |    0 |          1 |      0 |     0 |
|         1 |   14 |    0 |          0 |      1 |     0 |
|         1 |   15 |    0 |          0 |      0 |     1 |
|         0 |   16 |    0 |          0 |      0 |     0 |

Ranking table for 2015 synergy cropland map {.table}

If the user is interested in creating a more recent synergy cropland map
(e.g. for around 2020), we recommend using the following combination of
cropland products, which are available in the mapspamc database: ESRI
(2020), GLAD (2019), COPERNICUS (2019) and ESACCI (2020), and modify the
2015 ranking table accordingly. Alternatively, and if available, the
user could add a national land use product and create a ranking with
five different inputs that goes up to 32.

## References
