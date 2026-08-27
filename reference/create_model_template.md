# Creates `mapspamc` model template

`create_model_template` creates a folder structure with template R
scripts to implement the various steps to produce crop distribution maps
with `mapspamc`.

## Usage

``` r
create_model_template(template_path = NULL)
```

## Arguments

- template_path:

  folder where template scripts will be copied.If NULL the current
  working directory will be used.

## Details

`create_model template()` creates nine folders in the `template_path`,
set by the user. The folders contain template R scripts to implement the
six steps to generate crop distribution maps with `mapspamc`, including:
(1) model setup, (2) pre-processing, (3) model preparation, (4) running
the model, (5) post-processing and (6) model validation. The user can
use the template as a starting point for a country case-study.

To run the template scripts, they have to be copied into an RStudio
project. We recommend to create such a project first and then use
`create_model_template()` to add the scripts to the RStudio project.
Note that `create_model_template()` only copies files if they do not
exist yet. In this way, the user cannot accidently replace already
modified scripts.

## Examples

``` r
if (FALSE) { # \dontrun{
create_model_template("c:/temp")
} # }
```
