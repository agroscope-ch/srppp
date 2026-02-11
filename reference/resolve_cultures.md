# Resolve culture specifications to their lowest hierarchical level

Resolves culture levels in a dataset to their lowest hierarchical level
(leaf nodes) using a parent-child relationship dataset derived from a
culture tree using the German culture names. Only German culture names
are supported. If no match is found, the function assigns `NA` to the
`leaf_culture_de` column. If `correct_culture_names` is set to `TRUE`,
the function corrects variations in the naming of aggregated culture
groups with "allg.".

## Usage

``` r
resolve_cultures(
  dataset,
  srppp,
  culture_column = "culture_de",
  application_area_column = "application_area_de",
  correct_culture_names = TRUE,
  resolve_culture_allg = TRUE
)
```

## Arguments

- dataset:

  A data frame or tibble containing the data to be processed. It should
  include a column that represents the culture information to be
  resolved.

- srppp:

  An
  [srppp_dm](https://agroscope-ch.github.io/srppp/reference/srppp_dm.md)
  object. From this object the relations from each culture to the leaf
  cultures (lowest level in the hierarchical tree) are used, which are
  stored as attribute 'culture_leaf_df' of the culture tree, which is
  itself stored as an attribute of the object.

- culture_column:

  (Optional) A character string specifying the column in the dataset
  that contains the culture information to be resolved. Defaults to
  `"culture_de"`.

- application_area_column:

  (Optional). A character string specifing the name of the column in
  dataset containing application area information. Default is
  "application_area_de".

- correct_culture_names:

  If this argument is set to `TRUE`, the following corrections will be
  applied: In the `culture_tree`, and consequently in the
  `culture_leaf_df`, there are variations in the naming of aggregated
  culture groups with "allg.". For example, both "Obstbau allg." and
  "allg. Obstbau" exist. The information about the leaf nodes is only
  available in one of these terms. Therefore, the information from the
  term containing the leaf nodes is transferred to the corresponding
  "allg. ..." term.

- resolve_culture_allg:

  If this argument is set to `TRUE`, the culture "allg." is resolved to
  their lowest hierarchical level. The information on the application
  area is additionally used to resolve the culture "allg." to the lowest
  hierarchical level. For example if the culture "allg." is used in the
  application area "Obstbau", only the leaf cultures of the culture
  "Obstbau" are used to resolve the culture "allg.". If the application
  area is not found in the culture tree, all leaf cultures are used to
  resolve the culture "allg.".

## Value

A data frame or tibble with the same structure as the input `dataset`,
but with an additional column `"leaf_culture_de"` that contains the
resolved leaf culture levels. For cultures, that are not defined in the
register, the leaf culture is set to `NA`.

## Details

The `resolve_cultures` function processes the input dataset as follows

**Leaf Node Resolution**: The cultures in the specified column of the
dataset are resolved to their lowest hierarchical level (leaf nodes)
based on the `culture_leaf_df` mapping.

The result is an expanded dataset that includes an additional column
(`leaf_culture_de`) containing the resolved cultures at their lowest
level.

## Examples

``` r
# \donttest{
library(srppp)
sr <- try(srppp_dm())

if (inherits(sr, "try-error")) {
  sr <- system.file("testdata/Daten_Pflanzenschutzmittelverzeichnis_2024-12-16.zip",
      package = "srppp") |>
    srppp_xml_get_from_path(from = "2024-12-16") |>
    srppp_dm()
}

example_dataset_1 <- data.frame(
  substance_de = c("Spirotetramat", "Spirotetramat", "Spirotetramat", "Spirotetramat"),
  pNbr = c(7839, 7839, 7839, 7839),
  use_nr = c(5, 7, 18, 22),
  application_area_de = c("Obstbau", "Obstbau", "Obstbau", "Obstbau"),
  culture_de = c("Birne", "Kirsche", "Steinobst", "Kernobst"),
    pest_de = c("Birnblattsauger", "Kirschenfliege", "Blattläuse (Röhrenläuse)", "Spinnmilben"))

# Same as above, but with culture name "Kirschen" instead of "Kirsche"
example_dataset_2 <- data.frame(
  substance_de = c("Spirotetramat", "Spirotetramat", "Spirotetramat", "Spirotetramat"),
  pNbr = c(7839, 7839, 7839, 7839),
  use_nr = c(5, 7, 18, 22),
  application_area_de = c("Obstbau", "Obstbau", "Obstbau", "Obstbau"),
  culture_de = c("Birne", "Kirschen", "Steinobst", "Kernobst"),
  pest_de = c("Birnblattsauger", "Kirschenfliege", "Blattläuse (Röhrenläuse)", "Spinnmilben"))

resolve_cultures(example_dataset_1, sr)
#>     substance_de pNbr use_nr application_area_de culture_de
#> 1  Spirotetramat 7839      5             Obstbau      Birne
#> 2  Spirotetramat 7839      7             Obstbau    Kirsche
#> 3  Spirotetramat 7839     18             Obstbau  Steinobst
#> 4  Spirotetramat 7839     18             Obstbau  Steinobst
#> 5  Spirotetramat 7839     18             Obstbau  Steinobst
#> 6  Spirotetramat 7839     18             Obstbau  Steinobst
#> 7  Spirotetramat 7839     18             Obstbau  Steinobst
#> 8  Spirotetramat 7839     22             Obstbau   Kernobst
#> 9  Spirotetramat 7839     22             Obstbau   Kernobst
#> 10 Spirotetramat 7839     22             Obstbau   Kernobst
#>                     pest_de      leaf_culture_de
#> 1           Birnblattsauger                Birne
#> 2            Kirschenfliege              Kirsche
#> 3  Blattläuse (Röhrenläuse) Pfirsich / Nektarine
#> 4  Blattläuse (Röhrenläuse)             Aprikose
#> 5  Blattläuse (Röhrenläuse)              Kirsche
#> 6  Blattläuse (Röhrenläuse)            Zwetschge
#> 7  Blattläuse (Röhrenläuse)              Pflaume
#> 8               Spinnmilben               Quitte
#> 9               Spinnmilben                Apfel
#> 10              Spinnmilben                Birne

# Here we get NA for the leaf culture of "Kirschen"
resolve_cultures(example_dataset_2, sr)
#>     substance_de pNbr use_nr application_area_de culture_de
#> 1  Spirotetramat 7839      5             Obstbau      Birne
#> 2  Spirotetramat 7839      7             Obstbau   Kirschen
#> 3  Spirotetramat 7839     18             Obstbau  Steinobst
#> 4  Spirotetramat 7839     18             Obstbau  Steinobst
#> 5  Spirotetramat 7839     18             Obstbau  Steinobst
#> 6  Spirotetramat 7839     18             Obstbau  Steinobst
#> 7  Spirotetramat 7839     18             Obstbau  Steinobst
#> 8  Spirotetramat 7839     22             Obstbau   Kernobst
#> 9  Spirotetramat 7839     22             Obstbau   Kernobst
#> 10 Spirotetramat 7839     22             Obstbau   Kernobst
#>                     pest_de      leaf_culture_de
#> 1           Birnblattsauger                Birne
#> 2            Kirschenfliege                 <NA>
#> 3  Blattläuse (Röhrenläuse) Pfirsich / Nektarine
#> 4  Blattläuse (Röhrenläuse)             Aprikose
#> 5  Blattläuse (Röhrenläuse)              Kirsche
#> 6  Blattläuse (Röhrenläuse)            Zwetschge
#> 7  Blattläuse (Röhrenläuse)              Pflaume
#> 8               Spinnmilben               Quitte
#> 9               Spinnmilben                Apfel
#> 10              Spinnmilben                Birne

# Example showing how cereals "Getreide" are resolved
example_dataset_3 <- data.frame(
  substance_de = c("Pirimicarb"),
  pNbr = c(2210),
  use_nr = c(3),
  application_area_de = c("Feldbau"),
  culture_de = c("Getreide"),
  pest_de = c("Blattläuse (Röhrenläuse)") )

resolve_cultures(example_dataset_3, sr)
#>    substance_de pNbr use_nr application_area_de culture_de
#> 1    Pirimicarb 2210      3             Feldbau   Getreide
#> 2    Pirimicarb 2210      3             Feldbau   Getreide
#> 3    Pirimicarb 2210      3             Feldbau   Getreide
#> 4    Pirimicarb 2210      3             Feldbau   Getreide
#> 5    Pirimicarb 2210      3             Feldbau   Getreide
#> 6    Pirimicarb 2210      3             Feldbau   Getreide
#> 7    Pirimicarb 2210      3             Feldbau   Getreide
#> 8    Pirimicarb 2210      3             Feldbau   Getreide
#> 9    Pirimicarb 2210      3             Feldbau   Getreide
#> 10   Pirimicarb 2210      3             Feldbau   Getreide
#>                     pest_de leaf_culture_de
#> 1  Blattläuse (Röhrenläuse) Wintertriticale
#> 2  Blattläuse (Röhrenläuse)    Winterweizen
#> 3  Blattläuse (Röhrenläuse)    Wintergerste
#> 4  Blattläuse (Röhrenläuse)    Winterroggen
#> 5  Blattläuse (Röhrenläuse)   Korn (Dinkel)
#> 6  Blattläuse (Röhrenläuse)           Emmer
#> 7  Blattläuse (Röhrenläuse)    Sommerweizen
#> 8  Blattläuse (Röhrenläuse)    Sommergerste
#> 9  Blattläuse (Röhrenläuse)     Sommerhafer
#> 10 Blattläuse (Röhrenläuse)      Hartweizen

# Example resolving ornamental plants ("Zierpflanzen")
example_dataset_4 <- data.frame(substance_de = c("Metaldehyd"),
 pNbr = 6142, use_nr = 1, application_area_de = c("Zierpflanzen"),
 culture_de = c("Zierpflanzen allg."), pest_de = c("Ackerschnecken/Deroceras Arten") )

resolve_cultures(example_dataset_4, sr)
#>    substance_de pNbr use_nr application_area_de         culture_de
#> 1    Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 2    Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 3    Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 4    Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 5    Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 6    Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 7    Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 8    Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 9    Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 10   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 11   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 12   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 13   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 14   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 15   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 16   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 17   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 18   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 19   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 20   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 21   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 22   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 23   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 24   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 25   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 26   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 27   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 28   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 29   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#> 30   Metaldehyd 6142      1        Zierpflanzen allg. Zierpflanzen
#>                           pest_de                leaf_culture_de
#> 1  Ackerschnecken/Deroceras Arten                     Baumschule
#> 2  Ackerschnecken/Deroceras Arten           Zier- und Sportrasen
#> 3  Ackerschnecken/Deroceras Arten                          Rosen
#> 4  Ackerschnecken/Deroceras Arten                      Euphorbia
#> 5  Ackerschnecken/Deroceras Arten Ziergehölze (ausserhalb Forst)
#> 6  Ackerschnecken/Deroceras Arten                        Stauden
#> 7  Ackerschnecken/Deroceras Arten                     Sommerflor
#> 8  Ackerschnecken/Deroceras Arten                   Chrysantheme
#> 9  Ackerschnecken/Deroceras Arten                         Nelken
#> 10 Ackerschnecken/Deroceras Arten                        Gerbera
#> 11 Ackerschnecken/Deroceras Arten                     Blaudistel
#> 12 Ackerschnecken/Deroceras Arten                       Gladiole
#> 13 Ackerschnecken/Deroceras Arten                        Dahlien
#> 14 Ackerschnecken/Deroceras Arten                        Begonia
#> 15 Ackerschnecken/Deroceras Arten                        Cyclame
#> 16 Ackerschnecken/Deroceras Arten                    Pelargonien
#> 17 Ackerschnecken/Deroceras Arten                        Primeln
#> 18 Ackerschnecken/Deroceras Arten                     Zierkürbis
#> 19 Ackerschnecken/Deroceras Arten                      Hyazinthe
#> 20 Ackerschnecken/Deroceras Arten                           Iris
#> 21 Ackerschnecken/Deroceras Arten  Liliengewächse (Zierpflanzen)
#> 22 Ackerschnecken/Deroceras Arten                          Tulpe
#> 23 Ackerschnecken/Deroceras Arten                   Rosskastanie
#> 24 Ackerschnecken/Deroceras Arten                      Blautanne
#> 25 Ackerschnecken/Deroceras Arten                Weihnachtsbäume
#> 26 Ackerschnecken/Deroceras Arten                  Kirschlorbeer
#> 27 Ackerschnecken/Deroceras Arten             Buchsbäume (Buxus)
#> 28 Ackerschnecken/Deroceras Arten              Zypressengewächse
#> 29 Ackerschnecken/Deroceras Arten                         Fichte
#> 30 Ackerschnecken/Deroceras Arten                        Azaleen

# Illustrate the resolution of the culture "allg."
example_dataset_5 <- data.frame(
  substance_de = c("Kupfer (als Oxychlorid)","Metaldehyd","Metaldehyd","Schwefel"),
  pNbr = c(585,1090,1090,38),
  use_nr = c(12,4,4,1),
  application_area_de = c("Weinbau","Obstbau","Obstbau","Beerenbau"),
  culture_de = c("allg.","allg.","allg.","Brombeere"),
  pest_de = c("Graufäule (Botrytis cinerea)","Wegschnecken/Arion Arten",
    "Wegschnecken/Arion Arten","Gallmilben"))

 resolve_cultures(example_dataset_5, sr, resolve_culture_allg = FALSE)
#>              substance_de pNbr use_nr application_area_de culture_de
#> 1 Kupfer (als Oxychlorid)  585     12             Weinbau      allg.
#> 2              Metaldehyd 1090      4             Obstbau      allg.
#> 3              Metaldehyd 1090      4             Obstbau      allg.
#> 4                Schwefel   38      1           Beerenbau  Brombeere
#>                        pest_de leaf_culture_de
#> 1 Graufäule (Botrytis cinerea)            <NA>
#> 2     Wegschnecken/Arion Arten            <NA>
#> 3     Wegschnecken/Arion Arten            <NA>
#> 4                   Gallmilben       Brombeere
 resolve_cultures(example_dataset_5, sr)
#>               substance_de pNbr use_nr application_area_de           culture_de
#> 1                 Schwefel   38      1           Beerenbau            Brombeere
#> 2  Kupfer (als Oxychlorid)  585     12             Weinbau         Ertragsreben
#> 3  Kupfer (als Oxychlorid)  585     12             Weinbau            Jungreben
#> 4               Metaldehyd 1090      4             Obstbau                Olive
#> 5               Metaldehyd 1090      4             Obstbau               Quitte
#> 6               Metaldehyd 1090      4             Obstbau                Apfel
#> 7               Metaldehyd 1090      4             Obstbau Pfirsich / Nektarine
#> 8               Metaldehyd 1090      4             Obstbau             Aprikose
#> 9               Metaldehyd 1090      4             Obstbau              Kirsche
#> 10              Metaldehyd 1090      4             Obstbau                Birne
#> 11              Metaldehyd 1090      4             Obstbau              Walnuss
#> 12              Metaldehyd 1090      4             Obstbau            Zwetschge
#> 13              Metaldehyd 1090      4             Obstbau              Pflaume
#> 14              Metaldehyd 1090      4             Obstbau                Olive
#> 15              Metaldehyd 1090      4             Obstbau               Quitte
#> 16              Metaldehyd 1090      4             Obstbau                Apfel
#> 17              Metaldehyd 1090      4             Obstbau Pfirsich / Nektarine
#> 18              Metaldehyd 1090      4             Obstbau             Aprikose
#> 19              Metaldehyd 1090      4             Obstbau              Kirsche
#> 20              Metaldehyd 1090      4             Obstbau                Birne
#> 21              Metaldehyd 1090      4             Obstbau              Walnuss
#> 22              Metaldehyd 1090      4             Obstbau            Zwetschge
#> 23              Metaldehyd 1090      4             Obstbau              Pflaume
#>                         pest_de      leaf_culture_de
#> 1                    Gallmilben            Brombeere
#> 2  Graufäule (Botrytis cinerea)         Ertragsreben
#> 3  Graufäule (Botrytis cinerea)            Jungreben
#> 4      Wegschnecken/Arion Arten                Olive
#> 5      Wegschnecken/Arion Arten               Quitte
#> 6      Wegschnecken/Arion Arten                Apfel
#> 7      Wegschnecken/Arion Arten Pfirsich / Nektarine
#> 8      Wegschnecken/Arion Arten             Aprikose
#> 9      Wegschnecken/Arion Arten              Kirsche
#> 10     Wegschnecken/Arion Arten                Birne
#> 11     Wegschnecken/Arion Arten              Walnuss
#> 12     Wegschnecken/Arion Arten            Zwetschge
#> 13     Wegschnecken/Arion Arten              Pflaume
#> 14     Wegschnecken/Arion Arten                Olive
#> 15     Wegschnecken/Arion Arten               Quitte
#> 16     Wegschnecken/Arion Arten                Apfel
#> 17     Wegschnecken/Arion Arten Pfirsich / Nektarine
#> 18     Wegschnecken/Arion Arten             Aprikose
#> 19     Wegschnecken/Arion Arten              Kirsche
#> 20     Wegschnecken/Arion Arten                Birne
#> 21     Wegschnecken/Arion Arten              Walnuss
#> 22     Wegschnecken/Arion Arten            Zwetschge
#> 23     Wegschnecken/Arion Arten              Pflaume

# Illustrate the resolution of "Obstbau allg.", which does not have children in
# the XML files, but which should have children, because Obstbau allg. is
# not a leaf culture.
example_dataset_6 <- data.frame(
  substance_de = c("Schwefel"),
  pNbr = c(3561),
  use_nr = c(4),
  application_area_de = c("Obstbau"),
  culture_de = c("Obstbau allg."),
  pest_de = c("Wühl- oder Schermaus") )

 resolve_cultures(example_dataset_6, sr,
   correct_culture_names = FALSE)
#>   substance_de pNbr use_nr application_area_de    culture_de
#> 1     Schwefel 3561      4             Obstbau Obstbau allg.
#>                pest_de leaf_culture_de
#> 1 Wühl- oder Schermaus            <NA>
 resolve_cultures(example_dataset_6, sr,
   correct_culture_names = TRUE)
#>    substance_de pNbr use_nr application_area_de    culture_de
#> 1      Schwefel 3561      4             Obstbau allg. Obstbau
#> 2      Schwefel 3561      4             Obstbau allg. Obstbau
#> 3      Schwefel 3561      4             Obstbau allg. Obstbau
#> 4      Schwefel 3561      4             Obstbau allg. Obstbau
#> 5      Schwefel 3561      4             Obstbau allg. Obstbau
#> 6      Schwefel 3561      4             Obstbau allg. Obstbau
#> 7      Schwefel 3561      4             Obstbau allg. Obstbau
#> 8      Schwefel 3561      4             Obstbau allg. Obstbau
#> 9      Schwefel 3561      4             Obstbau allg. Obstbau
#> 10     Schwefel 3561      4             Obstbau allg. Obstbau
#>                 pest_de      leaf_culture_de
#> 1  Wühl- oder Schermaus                Olive
#> 2  Wühl- oder Schermaus               Quitte
#> 3  Wühl- oder Schermaus                Apfel
#> 4  Wühl- oder Schermaus Pfirsich / Nektarine
#> 5  Wühl- oder Schermaus             Aprikose
#> 6  Wühl- oder Schermaus              Kirsche
#> 7  Wühl- oder Schermaus                Birne
#> 8  Wühl- oder Schermaus              Walnuss
#> 9  Wühl- oder Schermaus            Zwetschge
#> 10 Wühl- oder Schermaus              Pflaume
# }
```
