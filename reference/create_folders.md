# Creates `mapspamc` folder structure

`create_folders` creates the folder structure that is needed store raw
data, processed data and parameters for `mapspamc`.

## Usage

``` r
create_folders(param = NULL)
```

## Arguments

- param:

  Object of type `mapspamc_par` that bundles all `mapspamc` parameters,
  including core model folders, alpha-3 country code, year, spatial
  resolution, most detailed level at which subnational statistics are
  available, administrative unit level at which the model is solved and
  type of model.

## Details

`create_folders` creates two folders in the `model_path`, set by the
user: mappings and processed_data (including subfolders). It copies a
number of cvs files into the mappings folder, which contain several data
tables that are needed to run the model and, if needed can be adjusted
by the user. If set by the user a mapspamc_db folder is created in
`db_path`. Otherwise the folder is created in the main model folder.

## Examples

``` r
if (FALSE) { # \dontrun{
create_folders(param)
} # }
```
