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
#> Warning: Resolving cultures using srppp_dm objects created from version 2 of the XML files is experimental and does not always work correctly
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
#> Warning: Resolving cultures using srppp_dm objects created from version 2 of the XML files is experimental and does not always work correctly
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
#> Warning: Resolving cultures using srppp_dm objects created from version 2 of the XML files is experimental and does not always work correctly
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
#> 11   Pirimicarb 2210      3             Feldbau   Getreide
#> 12   Pirimicarb 2210      3             Feldbau   Getreide
#> 13   Pirimicarb 2210      3             Feldbau   Getreide
#>                     pest_de leaf_culture_de
#> 1  Blattläuse (Röhrenläuse)          Roggen
#> 2  Blattläuse (Röhrenläuse)           Hafer
#> 3  Blattläuse (Röhrenläuse) Wintertriticale
#> 4  Blattläuse (Röhrenläuse)    Winterweizen
#> 5  Blattläuse (Röhrenläuse)    Winterroggen
#> 6  Blattläuse (Röhrenläuse)   Korn (Dinkel)
#> 7  Blattläuse (Röhrenläuse)           Emmer
#> 8  Blattläuse (Röhrenläuse)    Sommerweizen
#> 9  Blattläuse (Röhrenläuse)    Sommergerste
#> 10 Blattläuse (Röhrenläuse)     Sommerhafer
#> 11 Blattläuse (Röhrenläuse)    Wintergerste
#> 12 Blattläuse (Röhrenläuse)      Hartweizen
#> 13 Blattläuse (Röhrenläuse)     Weichweizen

# Example resolving ornamental plants ("Zierpflanzen")
example_dataset_4 <- data.frame(substance_de = c("Metaldehyd"),
 pNbr = 6142, use_nr = 1, application_area_de = c("Zierpflanzen"),
 culture_de = c("Zierpflanzen allg."), pest_de = c("Ackerschnecken/Deroceras Arten") )

resolve_cultures(example_dataset_4, sr)
#> Warning: Resolving cultures using srppp_dm objects created from version 2 of the XML files is experimental and does not always work correctly
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
#>                           pest_de                        leaf_culture_de
#> 1  Ackerschnecken/Deroceras Arten                             Baumschule
#> 2  Ackerschnecken/Deroceras Arten                   Zier- und Sportrasen
#> 3  Ackerschnecken/Deroceras Arten             Gehölze (ausserhalb Forst)
#> 4  Ackerschnecken/Deroceras Arten                                  Rosen
#> 5  Ackerschnecken/Deroceras Arten Bäume und Sträucher (ausserhalb Forst)
#> 6  Ackerschnecken/Deroceras Arten         Ziergehölze (ausserhalb Forst)
#> 7  Ackerschnecken/Deroceras Arten                                Stauden
#> 8  Ackerschnecken/Deroceras Arten                             Sommerflor
#> 9  Ackerschnecken/Deroceras Arten                                Begonia
#> 10 Ackerschnecken/Deroceras Arten                                Cyclame
#> 11 Ackerschnecken/Deroceras Arten                            Pelargonien
#> 12 Ackerschnecken/Deroceras Arten                                Primeln
#> 13 Ackerschnecken/Deroceras Arten                             Zierkürbis
#> 14 Ackerschnecken/Deroceras Arten                              Hyazinthe
#> 15 Ackerschnecken/Deroceras Arten                                   Iris
#> 16 Ackerschnecken/Deroceras Arten          Liliengewächse (Zierpflanzen)
#> 17 Ackerschnecken/Deroceras Arten                                  Tulpe

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
#> Warning: Resolving cultures using srppp_dm objects created from version 2 of the XML files is experimental and does not always work correctly
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
#> Warning: Resolving cultures using srppp_dm objects created from version 2 of the XML files is experimental and does not always work correctly
#>                 substance_de pNbr use_nr application_area_de
#> 1                   Schwefel   38      1           Beerenbau
#> 2    Kupfer (als Oxychlorid)  585     12             Weinbau
#> 3    Kupfer (als Oxychlorid)  585     12             Weinbau
#> 4    Kupfer (als Oxychlorid)  585     12             Weinbau
#> 5    Kupfer (als Oxychlorid)  585     12             Weinbau
#> 6    Kupfer (als Oxychlorid)  585     12             Weinbau
#> 7    Kupfer (als Oxychlorid)  585     12             Weinbau
#> 8    Kupfer (als Oxychlorid)  585     12             Weinbau
#> 9    Kupfer (als Oxychlorid)  585     12             Weinbau
#> 10   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 11   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 12   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 13   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 14   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 15   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 16   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 17   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 18   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 19   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 20   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 21   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 22   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 23   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 24   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 25   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 26   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 27   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 28   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 29   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 30   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 31   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 32   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 33   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 34   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 35   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 36   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 37   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 38   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 39   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 40   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 41   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 42   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 43   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 44   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 45   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 46   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 47   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 48   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 49   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 50   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 51   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 52   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 53   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 54   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 55   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 56   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 57   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 58   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 59   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 60   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 61   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 62   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 63   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 64   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 65   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 66   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 67   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 68   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 69   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 70   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 71   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 72   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 73   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 74   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 75   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 76   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 77   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 78   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 79   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 80   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 81   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 82   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 83   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 84   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 85   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 86   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 87   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 88   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 89   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 90   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 91   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 92   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 93   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 94   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 95   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 96   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 97   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 98   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 99   Kupfer (als Oxychlorid)  585     12             Weinbau
#> 100  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 101  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 102  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 103  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 104  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 105  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 106  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 107  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 108  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 109  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 110  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 111  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 112  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 113  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 114  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 115  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 116  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 117  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 118  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 119  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 120  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 121  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 122  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 123  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 124  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 125  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 126  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 127  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 128  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 129  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 130  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 131  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 132  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 133  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 134  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 135  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 136  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 137  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 138  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 139  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 140  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 141  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 142  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 143  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 144  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 145  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 146  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 147  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 148  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 149  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 150  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 151  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 152  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 153  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 154  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 155  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 156  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 157  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 158  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 159  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 160  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 161  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 162  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 163  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 164  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 165  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 166  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 167  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 168  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 169  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 170  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 171  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 172  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 173  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 174  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 175  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 176  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 177  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 178  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 179  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 180  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 181  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 182  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 183  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 184  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 185  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 186  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 187  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 188  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 189  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 190  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 191  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 192  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 193  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 194  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 195  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 196  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 197  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 198  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 199  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 200  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 201  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 202  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 203  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 204  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 205  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 206  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 207  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 208  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 209  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 210  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 211  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 212  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 213  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 214  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 215  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 216  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 217  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 218  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 219  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 220  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 221  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 222  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 223  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 224  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 225  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 226  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 227  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 228  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 229  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 230  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 231  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 232  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 233  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 234  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 235  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 236  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 237  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 238  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 239  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 240  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 241  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 242  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 243  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 244  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 245  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 246  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 247  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 248  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 249  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 250  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 251  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 252  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 253  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 254  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 255  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 256  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 257  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 258  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 259  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 260  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 261  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 262  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 263  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 264  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 265  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 266  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 267  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 268  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 269  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 270  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 271  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 272  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 273  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 274  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 275  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 276  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 277  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 278  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 279  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 280  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 281  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 282  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 283  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 284  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 285  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 286  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 287  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 288  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 289  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 290  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 291  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 292  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 293  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 294  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 295  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 296  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 297  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 298  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 299  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 300  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 301  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 302  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 303  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 304  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 305  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 306  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 307  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 308  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 309  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 310  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 311  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 312  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 313  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 314  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 315  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 316  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 317  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 318  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 319  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 320  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 321  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 322  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 323  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 324  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 325  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 326  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 327  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 328  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 329  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 330  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 331  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 332  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 333  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 334  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 335  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 336  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 337  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 338  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 339  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 340  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 341  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 342  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 343  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 344  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 345  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 346  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 347  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 348  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 349  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 350  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 351  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 352  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 353  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 354  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 355  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 356  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 357  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 358  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 359  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 360  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 361  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 362  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 363  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 364  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 365  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 366  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 367  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 368  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 369  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 370  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 371  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 372  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 373  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 374  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 375  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 376  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 377  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 378  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 379  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 380  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 381  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 382  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 383  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 384  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 385  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 386  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 387  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 388  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 389  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 390  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 391  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 392  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 393  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 394  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 395  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 396  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 397  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 398  Kupfer (als Oxychlorid)  585     12             Weinbau
#> 399               Metaldehyd 1090      4             Obstbau
#> 400               Metaldehyd 1090      4             Obstbau
#> 401               Metaldehyd 1090      4             Obstbau
#> 402               Metaldehyd 1090      4             Obstbau
#> 403               Metaldehyd 1090      4             Obstbau
#> 404               Metaldehyd 1090      4             Obstbau
#> 405               Metaldehyd 1090      4             Obstbau
#> 406               Metaldehyd 1090      4             Obstbau
#> 407               Metaldehyd 1090      4             Obstbau
#> 408               Metaldehyd 1090      4             Obstbau
#> 409               Metaldehyd 1090      4             Obstbau
#> 410               Metaldehyd 1090      4             Obstbau
#> 411               Metaldehyd 1090      4             Obstbau
#> 412               Metaldehyd 1090      4             Obstbau
#> 413               Metaldehyd 1090      4             Obstbau
#> 414               Metaldehyd 1090      4             Obstbau
#> 415               Metaldehyd 1090      4             Obstbau
#> 416               Metaldehyd 1090      4             Obstbau
#> 417               Metaldehyd 1090      4             Obstbau
#> 418               Metaldehyd 1090      4             Obstbau
#> 419               Metaldehyd 1090      4             Obstbau
#> 420               Metaldehyd 1090      4             Obstbau
#> 421               Metaldehyd 1090      4             Obstbau
#> 422               Metaldehyd 1090      4             Obstbau
#> 423               Metaldehyd 1090      4             Obstbau
#> 424               Metaldehyd 1090      4             Obstbau
#> 425               Metaldehyd 1090      4             Obstbau
#> 426               Metaldehyd 1090      4             Obstbau
#> 427               Metaldehyd 1090      4             Obstbau
#> 428               Metaldehyd 1090      4             Obstbau
#> 429               Metaldehyd 1090      4             Obstbau
#> 430               Metaldehyd 1090      4             Obstbau
#> 431               Metaldehyd 1090      4             Obstbau
#> 432               Metaldehyd 1090      4             Obstbau
#> 433               Metaldehyd 1090      4             Obstbau
#> 434               Metaldehyd 1090      4             Obstbau
#> 435               Metaldehyd 1090      4             Obstbau
#> 436               Metaldehyd 1090      4             Obstbau
#> 437               Metaldehyd 1090      4             Obstbau
#> 438               Metaldehyd 1090      4             Obstbau
#> 439               Metaldehyd 1090      4             Obstbau
#> 440               Metaldehyd 1090      4             Obstbau
#> 441               Metaldehyd 1090      4             Obstbau
#> 442               Metaldehyd 1090      4             Obstbau
#> 443               Metaldehyd 1090      4             Obstbau
#> 444               Metaldehyd 1090      4             Obstbau
#> 445               Metaldehyd 1090      4             Obstbau
#> 446               Metaldehyd 1090      4             Obstbau
#> 447               Metaldehyd 1090      4             Obstbau
#> 448               Metaldehyd 1090      4             Obstbau
#> 449               Metaldehyd 1090      4             Obstbau
#> 450               Metaldehyd 1090      4             Obstbau
#> 451               Metaldehyd 1090      4             Obstbau
#> 452               Metaldehyd 1090      4             Obstbau
#> 453               Metaldehyd 1090      4             Obstbau
#> 454               Metaldehyd 1090      4             Obstbau
#> 455               Metaldehyd 1090      4             Obstbau
#> 456               Metaldehyd 1090      4             Obstbau
#> 457               Metaldehyd 1090      4             Obstbau
#> 458               Metaldehyd 1090      4             Obstbau
#> 459               Metaldehyd 1090      4             Obstbau
#> 460               Metaldehyd 1090      4             Obstbau
#> 461               Metaldehyd 1090      4             Obstbau
#> 462               Metaldehyd 1090      4             Obstbau
#> 463               Metaldehyd 1090      4             Obstbau
#> 464               Metaldehyd 1090      4             Obstbau
#> 465               Metaldehyd 1090      4             Obstbau
#> 466               Metaldehyd 1090      4             Obstbau
#> 467               Metaldehyd 1090      4             Obstbau
#> 468               Metaldehyd 1090      4             Obstbau
#> 469               Metaldehyd 1090      4             Obstbau
#> 470               Metaldehyd 1090      4             Obstbau
#> 471               Metaldehyd 1090      4             Obstbau
#> 472               Metaldehyd 1090      4             Obstbau
#> 473               Metaldehyd 1090      4             Obstbau
#> 474               Metaldehyd 1090      4             Obstbau
#> 475               Metaldehyd 1090      4             Obstbau
#> 476               Metaldehyd 1090      4             Obstbau
#> 477               Metaldehyd 1090      4             Obstbau
#> 478               Metaldehyd 1090      4             Obstbau
#> 479               Metaldehyd 1090      4             Obstbau
#> 480               Metaldehyd 1090      4             Obstbau
#> 481               Metaldehyd 1090      4             Obstbau
#> 482               Metaldehyd 1090      4             Obstbau
#> 483               Metaldehyd 1090      4             Obstbau
#> 484               Metaldehyd 1090      4             Obstbau
#> 485               Metaldehyd 1090      4             Obstbau
#> 486               Metaldehyd 1090      4             Obstbau
#> 487               Metaldehyd 1090      4             Obstbau
#> 488               Metaldehyd 1090      4             Obstbau
#> 489               Metaldehyd 1090      4             Obstbau
#> 490               Metaldehyd 1090      4             Obstbau
#> 491               Metaldehyd 1090      4             Obstbau
#> 492               Metaldehyd 1090      4             Obstbau
#> 493               Metaldehyd 1090      4             Obstbau
#> 494               Metaldehyd 1090      4             Obstbau
#> 495               Metaldehyd 1090      4             Obstbau
#> 496               Metaldehyd 1090      4             Obstbau
#> 497               Metaldehyd 1090      4             Obstbau
#> 498               Metaldehyd 1090      4             Obstbau
#> 499               Metaldehyd 1090      4             Obstbau
#> 500               Metaldehyd 1090      4             Obstbau
#> 501               Metaldehyd 1090      4             Obstbau
#> 502               Metaldehyd 1090      4             Obstbau
#> 503               Metaldehyd 1090      4             Obstbau
#> 504               Metaldehyd 1090      4             Obstbau
#> 505               Metaldehyd 1090      4             Obstbau
#> 506               Metaldehyd 1090      4             Obstbau
#> 507               Metaldehyd 1090      4             Obstbau
#> 508               Metaldehyd 1090      4             Obstbau
#> 509               Metaldehyd 1090      4             Obstbau
#> 510               Metaldehyd 1090      4             Obstbau
#> 511               Metaldehyd 1090      4             Obstbau
#> 512               Metaldehyd 1090      4             Obstbau
#> 513               Metaldehyd 1090      4             Obstbau
#> 514               Metaldehyd 1090      4             Obstbau
#> 515               Metaldehyd 1090      4             Obstbau
#> 516               Metaldehyd 1090      4             Obstbau
#> 517               Metaldehyd 1090      4             Obstbau
#> 518               Metaldehyd 1090      4             Obstbau
#> 519               Metaldehyd 1090      4             Obstbau
#> 520               Metaldehyd 1090      4             Obstbau
#> 521               Metaldehyd 1090      4             Obstbau
#> 522               Metaldehyd 1090      4             Obstbau
#> 523               Metaldehyd 1090      4             Obstbau
#> 524               Metaldehyd 1090      4             Obstbau
#> 525               Metaldehyd 1090      4             Obstbau
#> 526               Metaldehyd 1090      4             Obstbau
#> 527               Metaldehyd 1090      4             Obstbau
#> 528               Metaldehyd 1090      4             Obstbau
#> 529               Metaldehyd 1090      4             Obstbau
#> 530               Metaldehyd 1090      4             Obstbau
#> 531               Metaldehyd 1090      4             Obstbau
#> 532               Metaldehyd 1090      4             Obstbau
#> 533               Metaldehyd 1090      4             Obstbau
#> 534               Metaldehyd 1090      4             Obstbau
#> 535               Metaldehyd 1090      4             Obstbau
#> 536               Metaldehyd 1090      4             Obstbau
#> 537               Metaldehyd 1090      4             Obstbau
#> 538               Metaldehyd 1090      4             Obstbau
#> 539               Metaldehyd 1090      4             Obstbau
#> 540               Metaldehyd 1090      4             Obstbau
#> 541               Metaldehyd 1090      4             Obstbau
#> 542               Metaldehyd 1090      4             Obstbau
#> 543               Metaldehyd 1090      4             Obstbau
#> 544               Metaldehyd 1090      4             Obstbau
#> 545               Metaldehyd 1090      4             Obstbau
#> 546               Metaldehyd 1090      4             Obstbau
#> 547               Metaldehyd 1090      4             Obstbau
#> 548               Metaldehyd 1090      4             Obstbau
#> 549               Metaldehyd 1090      4             Obstbau
#> 550               Metaldehyd 1090      4             Obstbau
#> 551               Metaldehyd 1090      4             Obstbau
#> 552               Metaldehyd 1090      4             Obstbau
#> 553               Metaldehyd 1090      4             Obstbau
#> 554               Metaldehyd 1090      4             Obstbau
#> 555               Metaldehyd 1090      4             Obstbau
#> 556               Metaldehyd 1090      4             Obstbau
#> 557               Metaldehyd 1090      4             Obstbau
#> 558               Metaldehyd 1090      4             Obstbau
#> 559               Metaldehyd 1090      4             Obstbau
#> 560               Metaldehyd 1090      4             Obstbau
#> 561               Metaldehyd 1090      4             Obstbau
#> 562               Metaldehyd 1090      4             Obstbau
#> 563               Metaldehyd 1090      4             Obstbau
#> 564               Metaldehyd 1090      4             Obstbau
#> 565               Metaldehyd 1090      4             Obstbau
#> 566               Metaldehyd 1090      4             Obstbau
#> 567               Metaldehyd 1090      4             Obstbau
#> 568               Metaldehyd 1090      4             Obstbau
#> 569               Metaldehyd 1090      4             Obstbau
#> 570               Metaldehyd 1090      4             Obstbau
#> 571               Metaldehyd 1090      4             Obstbau
#> 572               Metaldehyd 1090      4             Obstbau
#> 573               Metaldehyd 1090      4             Obstbau
#> 574               Metaldehyd 1090      4             Obstbau
#> 575               Metaldehyd 1090      4             Obstbau
#> 576               Metaldehyd 1090      4             Obstbau
#> 577               Metaldehyd 1090      4             Obstbau
#> 578               Metaldehyd 1090      4             Obstbau
#> 579               Metaldehyd 1090      4             Obstbau
#> 580               Metaldehyd 1090      4             Obstbau
#> 581               Metaldehyd 1090      4             Obstbau
#> 582               Metaldehyd 1090      4             Obstbau
#> 583               Metaldehyd 1090      4             Obstbau
#> 584               Metaldehyd 1090      4             Obstbau
#> 585               Metaldehyd 1090      4             Obstbau
#> 586               Metaldehyd 1090      4             Obstbau
#> 587               Metaldehyd 1090      4             Obstbau
#> 588               Metaldehyd 1090      4             Obstbau
#> 589               Metaldehyd 1090      4             Obstbau
#> 590               Metaldehyd 1090      4             Obstbau
#> 591               Metaldehyd 1090      4             Obstbau
#> 592               Metaldehyd 1090      4             Obstbau
#> 593               Metaldehyd 1090      4             Obstbau
#> 594               Metaldehyd 1090      4             Obstbau
#> 595               Metaldehyd 1090      4             Obstbau
#> 596               Metaldehyd 1090      4             Obstbau
#> 597               Metaldehyd 1090      4             Obstbau
#> 598               Metaldehyd 1090      4             Obstbau
#> 599               Metaldehyd 1090      4             Obstbau
#> 600               Metaldehyd 1090      4             Obstbau
#> 601               Metaldehyd 1090      4             Obstbau
#> 602               Metaldehyd 1090      4             Obstbau
#> 603               Metaldehyd 1090      4             Obstbau
#> 604               Metaldehyd 1090      4             Obstbau
#> 605               Metaldehyd 1090      4             Obstbau
#> 606               Metaldehyd 1090      4             Obstbau
#> 607               Metaldehyd 1090      4             Obstbau
#> 608               Metaldehyd 1090      4             Obstbau
#> 609               Metaldehyd 1090      4             Obstbau
#> 610               Metaldehyd 1090      4             Obstbau
#> 611               Metaldehyd 1090      4             Obstbau
#> 612               Metaldehyd 1090      4             Obstbau
#> 613               Metaldehyd 1090      4             Obstbau
#> 614               Metaldehyd 1090      4             Obstbau
#> 615               Metaldehyd 1090      4             Obstbau
#> 616               Metaldehyd 1090      4             Obstbau
#> 617               Metaldehyd 1090      4             Obstbau
#> 618               Metaldehyd 1090      4             Obstbau
#> 619               Metaldehyd 1090      4             Obstbau
#> 620               Metaldehyd 1090      4             Obstbau
#> 621               Metaldehyd 1090      4             Obstbau
#> 622               Metaldehyd 1090      4             Obstbau
#> 623               Metaldehyd 1090      4             Obstbau
#> 624               Metaldehyd 1090      4             Obstbau
#> 625               Metaldehyd 1090      4             Obstbau
#> 626               Metaldehyd 1090      4             Obstbau
#> 627               Metaldehyd 1090      4             Obstbau
#> 628               Metaldehyd 1090      4             Obstbau
#> 629               Metaldehyd 1090      4             Obstbau
#> 630               Metaldehyd 1090      4             Obstbau
#> 631               Metaldehyd 1090      4             Obstbau
#> 632               Metaldehyd 1090      4             Obstbau
#> 633               Metaldehyd 1090      4             Obstbau
#> 634               Metaldehyd 1090      4             Obstbau
#> 635               Metaldehyd 1090      4             Obstbau
#> 636               Metaldehyd 1090      4             Obstbau
#> 637               Metaldehyd 1090      4             Obstbau
#> 638               Metaldehyd 1090      4             Obstbau
#> 639               Metaldehyd 1090      4             Obstbau
#> 640               Metaldehyd 1090      4             Obstbau
#> 641               Metaldehyd 1090      4             Obstbau
#> 642               Metaldehyd 1090      4             Obstbau
#> 643               Metaldehyd 1090      4             Obstbau
#> 644               Metaldehyd 1090      4             Obstbau
#> 645               Metaldehyd 1090      4             Obstbau
#> 646               Metaldehyd 1090      4             Obstbau
#> 647               Metaldehyd 1090      4             Obstbau
#> 648               Metaldehyd 1090      4             Obstbau
#> 649               Metaldehyd 1090      4             Obstbau
#> 650               Metaldehyd 1090      4             Obstbau
#> 651               Metaldehyd 1090      4             Obstbau
#> 652               Metaldehyd 1090      4             Obstbau
#> 653               Metaldehyd 1090      4             Obstbau
#> 654               Metaldehyd 1090      4             Obstbau
#> 655               Metaldehyd 1090      4             Obstbau
#> 656               Metaldehyd 1090      4             Obstbau
#> 657               Metaldehyd 1090      4             Obstbau
#> 658               Metaldehyd 1090      4             Obstbau
#> 659               Metaldehyd 1090      4             Obstbau
#> 660               Metaldehyd 1090      4             Obstbau
#> 661               Metaldehyd 1090      4             Obstbau
#> 662               Metaldehyd 1090      4             Obstbau
#> 663               Metaldehyd 1090      4             Obstbau
#> 664               Metaldehyd 1090      4             Obstbau
#> 665               Metaldehyd 1090      4             Obstbau
#> 666               Metaldehyd 1090      4             Obstbau
#> 667               Metaldehyd 1090      4             Obstbau
#> 668               Metaldehyd 1090      4             Obstbau
#> 669               Metaldehyd 1090      4             Obstbau
#> 670               Metaldehyd 1090      4             Obstbau
#> 671               Metaldehyd 1090      4             Obstbau
#> 672               Metaldehyd 1090      4             Obstbau
#> 673               Metaldehyd 1090      4             Obstbau
#> 674               Metaldehyd 1090      4             Obstbau
#> 675               Metaldehyd 1090      4             Obstbau
#> 676               Metaldehyd 1090      4             Obstbau
#> 677               Metaldehyd 1090      4             Obstbau
#> 678               Metaldehyd 1090      4             Obstbau
#> 679               Metaldehyd 1090      4             Obstbau
#> 680               Metaldehyd 1090      4             Obstbau
#> 681               Metaldehyd 1090      4             Obstbau
#> 682               Metaldehyd 1090      4             Obstbau
#> 683               Metaldehyd 1090      4             Obstbau
#> 684               Metaldehyd 1090      4             Obstbau
#> 685               Metaldehyd 1090      4             Obstbau
#> 686               Metaldehyd 1090      4             Obstbau
#> 687               Metaldehyd 1090      4             Obstbau
#> 688               Metaldehyd 1090      4             Obstbau
#> 689               Metaldehyd 1090      4             Obstbau
#> 690               Metaldehyd 1090      4             Obstbau
#> 691               Metaldehyd 1090      4             Obstbau
#> 692               Metaldehyd 1090      4             Obstbau
#> 693               Metaldehyd 1090      4             Obstbau
#> 694               Metaldehyd 1090      4             Obstbau
#> 695               Metaldehyd 1090      4             Obstbau
#> 696               Metaldehyd 1090      4             Obstbau
#> 697               Metaldehyd 1090      4             Obstbau
#> 698               Metaldehyd 1090      4             Obstbau
#> 699               Metaldehyd 1090      4             Obstbau
#> 700               Metaldehyd 1090      4             Obstbau
#> 701               Metaldehyd 1090      4             Obstbau
#> 702               Metaldehyd 1090      4             Obstbau
#> 703               Metaldehyd 1090      4             Obstbau
#> 704               Metaldehyd 1090      4             Obstbau
#> 705               Metaldehyd 1090      4             Obstbau
#> 706               Metaldehyd 1090      4             Obstbau
#> 707               Metaldehyd 1090      4             Obstbau
#> 708               Metaldehyd 1090      4             Obstbau
#> 709               Metaldehyd 1090      4             Obstbau
#> 710               Metaldehyd 1090      4             Obstbau
#> 711               Metaldehyd 1090      4             Obstbau
#> 712               Metaldehyd 1090      4             Obstbau
#> 713               Metaldehyd 1090      4             Obstbau
#> 714               Metaldehyd 1090      4             Obstbau
#> 715               Metaldehyd 1090      4             Obstbau
#> 716               Metaldehyd 1090      4             Obstbau
#> 717               Metaldehyd 1090      4             Obstbau
#> 718               Metaldehyd 1090      4             Obstbau
#> 719               Metaldehyd 1090      4             Obstbau
#> 720               Metaldehyd 1090      4             Obstbau
#> 721               Metaldehyd 1090      4             Obstbau
#> 722               Metaldehyd 1090      4             Obstbau
#> 723               Metaldehyd 1090      4             Obstbau
#> 724               Metaldehyd 1090      4             Obstbau
#> 725               Metaldehyd 1090      4             Obstbau
#> 726               Metaldehyd 1090      4             Obstbau
#> 727               Metaldehyd 1090      4             Obstbau
#> 728               Metaldehyd 1090      4             Obstbau
#> 729               Metaldehyd 1090      4             Obstbau
#> 730               Metaldehyd 1090      4             Obstbau
#> 731               Metaldehyd 1090      4             Obstbau
#> 732               Metaldehyd 1090      4             Obstbau
#> 733               Metaldehyd 1090      4             Obstbau
#> 734               Metaldehyd 1090      4             Obstbau
#> 735               Metaldehyd 1090      4             Obstbau
#> 736               Metaldehyd 1090      4             Obstbau
#> 737               Metaldehyd 1090      4             Obstbau
#> 738               Metaldehyd 1090      4             Obstbau
#> 739               Metaldehyd 1090      4             Obstbau
#> 740               Metaldehyd 1090      4             Obstbau
#> 741               Metaldehyd 1090      4             Obstbau
#> 742               Metaldehyd 1090      4             Obstbau
#> 743               Metaldehyd 1090      4             Obstbau
#> 744               Metaldehyd 1090      4             Obstbau
#> 745               Metaldehyd 1090      4             Obstbau
#> 746               Metaldehyd 1090      4             Obstbau
#> 747               Metaldehyd 1090      4             Obstbau
#> 748               Metaldehyd 1090      4             Obstbau
#> 749               Metaldehyd 1090      4             Obstbau
#> 750               Metaldehyd 1090      4             Obstbau
#> 751               Metaldehyd 1090      4             Obstbau
#> 752               Metaldehyd 1090      4             Obstbau
#> 753               Metaldehyd 1090      4             Obstbau
#> 754               Metaldehyd 1090      4             Obstbau
#> 755               Metaldehyd 1090      4             Obstbau
#> 756               Metaldehyd 1090      4             Obstbau
#> 757               Metaldehyd 1090      4             Obstbau
#> 758               Metaldehyd 1090      4             Obstbau
#> 759               Metaldehyd 1090      4             Obstbau
#> 760               Metaldehyd 1090      4             Obstbau
#> 761               Metaldehyd 1090      4             Obstbau
#> 762               Metaldehyd 1090      4             Obstbau
#> 763               Metaldehyd 1090      4             Obstbau
#> 764               Metaldehyd 1090      4             Obstbau
#> 765               Metaldehyd 1090      4             Obstbau
#> 766               Metaldehyd 1090      4             Obstbau
#> 767               Metaldehyd 1090      4             Obstbau
#> 768               Metaldehyd 1090      4             Obstbau
#> 769               Metaldehyd 1090      4             Obstbau
#> 770               Metaldehyd 1090      4             Obstbau
#> 771               Metaldehyd 1090      4             Obstbau
#> 772               Metaldehyd 1090      4             Obstbau
#> 773               Metaldehyd 1090      4             Obstbau
#> 774               Metaldehyd 1090      4             Obstbau
#> 775               Metaldehyd 1090      4             Obstbau
#> 776               Metaldehyd 1090      4             Obstbau
#> 777               Metaldehyd 1090      4             Obstbau
#> 778               Metaldehyd 1090      4             Obstbau
#> 779               Metaldehyd 1090      4             Obstbau
#> 780               Metaldehyd 1090      4             Obstbau
#> 781               Metaldehyd 1090      4             Obstbau
#> 782               Metaldehyd 1090      4             Obstbau
#> 783               Metaldehyd 1090      4             Obstbau
#> 784               Metaldehyd 1090      4             Obstbau
#> 785               Metaldehyd 1090      4             Obstbau
#> 786               Metaldehyd 1090      4             Obstbau
#> 787               Metaldehyd 1090      4             Obstbau
#> 788               Metaldehyd 1090      4             Obstbau
#> 789               Metaldehyd 1090      4             Obstbau
#> 790               Metaldehyd 1090      4             Obstbau
#> 791               Metaldehyd 1090      4             Obstbau
#> 792               Metaldehyd 1090      4             Obstbau
#> 793               Metaldehyd 1090      4             Obstbau
#> 794               Metaldehyd 1090      4             Obstbau
#> 795               Metaldehyd 1090      4             Obstbau
#> 796               Metaldehyd 1090      4             Obstbau
#> 797               Metaldehyd 1090      4             Obstbau
#> 798               Metaldehyd 1090      4             Obstbau
#> 799               Metaldehyd 1090      4             Obstbau
#> 800               Metaldehyd 1090      4             Obstbau
#> 801               Metaldehyd 1090      4             Obstbau
#> 802               Metaldehyd 1090      4             Obstbau
#> 803               Metaldehyd 1090      4             Obstbau
#> 804               Metaldehyd 1090      4             Obstbau
#> 805               Metaldehyd 1090      4             Obstbau
#> 806               Metaldehyd 1090      4             Obstbau
#> 807               Metaldehyd 1090      4             Obstbau
#> 808               Metaldehyd 1090      4             Obstbau
#> 809               Metaldehyd 1090      4             Obstbau
#> 810               Metaldehyd 1090      4             Obstbau
#> 811               Metaldehyd 1090      4             Obstbau
#> 812               Metaldehyd 1090      4             Obstbau
#> 813               Metaldehyd 1090      4             Obstbau
#> 814               Metaldehyd 1090      4             Obstbau
#> 815               Metaldehyd 1090      4             Obstbau
#> 816               Metaldehyd 1090      4             Obstbau
#> 817               Metaldehyd 1090      4             Obstbau
#> 818               Metaldehyd 1090      4             Obstbau
#> 819               Metaldehyd 1090      4             Obstbau
#> 820               Metaldehyd 1090      4             Obstbau
#> 821               Metaldehyd 1090      4             Obstbau
#> 822               Metaldehyd 1090      4             Obstbau
#> 823               Metaldehyd 1090      4             Obstbau
#> 824               Metaldehyd 1090      4             Obstbau
#> 825               Metaldehyd 1090      4             Obstbau
#> 826               Metaldehyd 1090      4             Obstbau
#> 827               Metaldehyd 1090      4             Obstbau
#> 828               Metaldehyd 1090      4             Obstbau
#> 829               Metaldehyd 1090      4             Obstbau
#> 830               Metaldehyd 1090      4             Obstbau
#> 831               Metaldehyd 1090      4             Obstbau
#> 832               Metaldehyd 1090      4             Obstbau
#> 833               Metaldehyd 1090      4             Obstbau
#> 834               Metaldehyd 1090      4             Obstbau
#> 835               Metaldehyd 1090      4             Obstbau
#> 836               Metaldehyd 1090      4             Obstbau
#> 837               Metaldehyd 1090      4             Obstbau
#> 838               Metaldehyd 1090      4             Obstbau
#> 839               Metaldehyd 1090      4             Obstbau
#> 840               Metaldehyd 1090      4             Obstbau
#> 841               Metaldehyd 1090      4             Obstbau
#> 842               Metaldehyd 1090      4             Obstbau
#> 843               Metaldehyd 1090      4             Obstbau
#> 844               Metaldehyd 1090      4             Obstbau
#> 845               Metaldehyd 1090      4             Obstbau
#> 846               Metaldehyd 1090      4             Obstbau
#> 847               Metaldehyd 1090      4             Obstbau
#> 848               Metaldehyd 1090      4             Obstbau
#> 849               Metaldehyd 1090      4             Obstbau
#> 850               Metaldehyd 1090      4             Obstbau
#> 851               Metaldehyd 1090      4             Obstbau
#> 852               Metaldehyd 1090      4             Obstbau
#> 853               Metaldehyd 1090      4             Obstbau
#> 854               Metaldehyd 1090      4             Obstbau
#> 855               Metaldehyd 1090      4             Obstbau
#> 856               Metaldehyd 1090      4             Obstbau
#> 857               Metaldehyd 1090      4             Obstbau
#> 858               Metaldehyd 1090      4             Obstbau
#> 859               Metaldehyd 1090      4             Obstbau
#> 860               Metaldehyd 1090      4             Obstbau
#> 861               Metaldehyd 1090      4             Obstbau
#> 862               Metaldehyd 1090      4             Obstbau
#> 863               Metaldehyd 1090      4             Obstbau
#> 864               Metaldehyd 1090      4             Obstbau
#> 865               Metaldehyd 1090      4             Obstbau
#> 866               Metaldehyd 1090      4             Obstbau
#> 867               Metaldehyd 1090      4             Obstbau
#> 868               Metaldehyd 1090      4             Obstbau
#> 869               Metaldehyd 1090      4             Obstbau
#> 870               Metaldehyd 1090      4             Obstbau
#> 871               Metaldehyd 1090      4             Obstbau
#> 872               Metaldehyd 1090      4             Obstbau
#> 873               Metaldehyd 1090      4             Obstbau
#> 874               Metaldehyd 1090      4             Obstbau
#> 875               Metaldehyd 1090      4             Obstbau
#> 876               Metaldehyd 1090      4             Obstbau
#> 877               Metaldehyd 1090      4             Obstbau
#> 878               Metaldehyd 1090      4             Obstbau
#> 879               Metaldehyd 1090      4             Obstbau
#> 880               Metaldehyd 1090      4             Obstbau
#> 881               Metaldehyd 1090      4             Obstbau
#> 882               Metaldehyd 1090      4             Obstbau
#> 883               Metaldehyd 1090      4             Obstbau
#> 884               Metaldehyd 1090      4             Obstbau
#> 885               Metaldehyd 1090      4             Obstbau
#> 886               Metaldehyd 1090      4             Obstbau
#> 887               Metaldehyd 1090      4             Obstbau
#> 888               Metaldehyd 1090      4             Obstbau
#> 889               Metaldehyd 1090      4             Obstbau
#> 890               Metaldehyd 1090      4             Obstbau
#> 891               Metaldehyd 1090      4             Obstbau
#> 892               Metaldehyd 1090      4             Obstbau
#> 893               Metaldehyd 1090      4             Obstbau
#> 894               Metaldehyd 1090      4             Obstbau
#> 895               Metaldehyd 1090      4             Obstbau
#> 896               Metaldehyd 1090      4             Obstbau
#> 897               Metaldehyd 1090      4             Obstbau
#> 898               Metaldehyd 1090      4             Obstbau
#> 899               Metaldehyd 1090      4             Obstbau
#> 900               Metaldehyd 1090      4             Obstbau
#> 901               Metaldehyd 1090      4             Obstbau
#> 902               Metaldehyd 1090      4             Obstbau
#> 903               Metaldehyd 1090      4             Obstbau
#> 904               Metaldehyd 1090      4             Obstbau
#> 905               Metaldehyd 1090      4             Obstbau
#> 906               Metaldehyd 1090      4             Obstbau
#> 907               Metaldehyd 1090      4             Obstbau
#> 908               Metaldehyd 1090      4             Obstbau
#> 909               Metaldehyd 1090      4             Obstbau
#> 910               Metaldehyd 1090      4             Obstbau
#> 911               Metaldehyd 1090      4             Obstbau
#> 912               Metaldehyd 1090      4             Obstbau
#> 913               Metaldehyd 1090      4             Obstbau
#> 914               Metaldehyd 1090      4             Obstbau
#> 915               Metaldehyd 1090      4             Obstbau
#> 916               Metaldehyd 1090      4             Obstbau
#> 917               Metaldehyd 1090      4             Obstbau
#> 918               Metaldehyd 1090      4             Obstbau
#> 919               Metaldehyd 1090      4             Obstbau
#> 920               Metaldehyd 1090      4             Obstbau
#> 921               Metaldehyd 1090      4             Obstbau
#> 922               Metaldehyd 1090      4             Obstbau
#> 923               Metaldehyd 1090      4             Obstbau
#> 924               Metaldehyd 1090      4             Obstbau
#> 925               Metaldehyd 1090      4             Obstbau
#> 926               Metaldehyd 1090      4             Obstbau
#> 927               Metaldehyd 1090      4             Obstbau
#> 928               Metaldehyd 1090      4             Obstbau
#> 929               Metaldehyd 1090      4             Obstbau
#> 930               Metaldehyd 1090      4             Obstbau
#> 931               Metaldehyd 1090      4             Obstbau
#> 932               Metaldehyd 1090      4             Obstbau
#> 933               Metaldehyd 1090      4             Obstbau
#> 934               Metaldehyd 1090      4             Obstbau
#> 935               Metaldehyd 1090      4             Obstbau
#> 936               Metaldehyd 1090      4             Obstbau
#> 937               Metaldehyd 1090      4             Obstbau
#> 938               Metaldehyd 1090      4             Obstbau
#> 939               Metaldehyd 1090      4             Obstbau
#> 940               Metaldehyd 1090      4             Obstbau
#> 941               Metaldehyd 1090      4             Obstbau
#> 942               Metaldehyd 1090      4             Obstbau
#> 943               Metaldehyd 1090      4             Obstbau
#> 944               Metaldehyd 1090      4             Obstbau
#> 945               Metaldehyd 1090      4             Obstbau
#> 946               Metaldehyd 1090      4             Obstbau
#> 947               Metaldehyd 1090      4             Obstbau
#> 948               Metaldehyd 1090      4             Obstbau
#> 949               Metaldehyd 1090      4             Obstbau
#> 950               Metaldehyd 1090      4             Obstbau
#> 951               Metaldehyd 1090      4             Obstbau
#> 952               Metaldehyd 1090      4             Obstbau
#> 953               Metaldehyd 1090      4             Obstbau
#> 954               Metaldehyd 1090      4             Obstbau
#> 955               Metaldehyd 1090      4             Obstbau
#> 956               Metaldehyd 1090      4             Obstbau
#> 957               Metaldehyd 1090      4             Obstbau
#> 958               Metaldehyd 1090      4             Obstbau
#> 959               Metaldehyd 1090      4             Obstbau
#> 960               Metaldehyd 1090      4             Obstbau
#> 961               Metaldehyd 1090      4             Obstbau
#> 962               Metaldehyd 1090      4             Obstbau
#> 963               Metaldehyd 1090      4             Obstbau
#> 964               Metaldehyd 1090      4             Obstbau
#> 965               Metaldehyd 1090      4             Obstbau
#> 966               Metaldehyd 1090      4             Obstbau
#> 967               Metaldehyd 1090      4             Obstbau
#> 968               Metaldehyd 1090      4             Obstbau
#> 969               Metaldehyd 1090      4             Obstbau
#> 970               Metaldehyd 1090      4             Obstbau
#> 971               Metaldehyd 1090      4             Obstbau
#> 972               Metaldehyd 1090      4             Obstbau
#> 973               Metaldehyd 1090      4             Obstbau
#> 974               Metaldehyd 1090      4             Obstbau
#> 975               Metaldehyd 1090      4             Obstbau
#> 976               Metaldehyd 1090      4             Obstbau
#> 977               Metaldehyd 1090      4             Obstbau
#> 978               Metaldehyd 1090      4             Obstbau
#> 979               Metaldehyd 1090      4             Obstbau
#> 980               Metaldehyd 1090      4             Obstbau
#> 981               Metaldehyd 1090      4             Obstbau
#> 982               Metaldehyd 1090      4             Obstbau
#> 983               Metaldehyd 1090      4             Obstbau
#> 984               Metaldehyd 1090      4             Obstbau
#> 985               Metaldehyd 1090      4             Obstbau
#> 986               Metaldehyd 1090      4             Obstbau
#> 987               Metaldehyd 1090      4             Obstbau
#> 988               Metaldehyd 1090      4             Obstbau
#> 989               Metaldehyd 1090      4             Obstbau
#> 990               Metaldehyd 1090      4             Obstbau
#> 991               Metaldehyd 1090      4             Obstbau
#> 992               Metaldehyd 1090      4             Obstbau
#> 993               Metaldehyd 1090      4             Obstbau
#> 994               Metaldehyd 1090      4             Obstbau
#> 995               Metaldehyd 1090      4             Obstbau
#> 996               Metaldehyd 1090      4             Obstbau
#> 997               Metaldehyd 1090      4             Obstbau
#> 998               Metaldehyd 1090      4             Obstbau
#> 999               Metaldehyd 1090      4             Obstbau
#> 1000              Metaldehyd 1090      4             Obstbau
#> 1001              Metaldehyd 1090      4             Obstbau
#> 1002              Metaldehyd 1090      4             Obstbau
#> 1003              Metaldehyd 1090      4             Obstbau
#> 1004              Metaldehyd 1090      4             Obstbau
#> 1005              Metaldehyd 1090      4             Obstbau
#> 1006              Metaldehyd 1090      4             Obstbau
#> 1007              Metaldehyd 1090      4             Obstbau
#> 1008              Metaldehyd 1090      4             Obstbau
#> 1009              Metaldehyd 1090      4             Obstbau
#> 1010              Metaldehyd 1090      4             Obstbau
#> 1011              Metaldehyd 1090      4             Obstbau
#> 1012              Metaldehyd 1090      4             Obstbau
#> 1013              Metaldehyd 1090      4             Obstbau
#> 1014              Metaldehyd 1090      4             Obstbau
#> 1015              Metaldehyd 1090      4             Obstbau
#> 1016              Metaldehyd 1090      4             Obstbau
#> 1017              Metaldehyd 1090      4             Obstbau
#> 1018              Metaldehyd 1090      4             Obstbau
#> 1019              Metaldehyd 1090      4             Obstbau
#> 1020              Metaldehyd 1090      4             Obstbau
#> 1021              Metaldehyd 1090      4             Obstbau
#> 1022              Metaldehyd 1090      4             Obstbau
#> 1023              Metaldehyd 1090      4             Obstbau
#> 1024              Metaldehyd 1090      4             Obstbau
#> 1025              Metaldehyd 1090      4             Obstbau
#> 1026              Metaldehyd 1090      4             Obstbau
#> 1027              Metaldehyd 1090      4             Obstbau
#> 1028              Metaldehyd 1090      4             Obstbau
#> 1029              Metaldehyd 1090      4             Obstbau
#> 1030              Metaldehyd 1090      4             Obstbau
#> 1031              Metaldehyd 1090      4             Obstbau
#> 1032              Metaldehyd 1090      4             Obstbau
#> 1033              Metaldehyd 1090      4             Obstbau
#> 1034              Metaldehyd 1090      4             Obstbau
#> 1035              Metaldehyd 1090      4             Obstbau
#> 1036              Metaldehyd 1090      4             Obstbau
#> 1037              Metaldehyd 1090      4             Obstbau
#> 1038              Metaldehyd 1090      4             Obstbau
#> 1039              Metaldehyd 1090      4             Obstbau
#> 1040              Metaldehyd 1090      4             Obstbau
#> 1041              Metaldehyd 1090      4             Obstbau
#> 1042              Metaldehyd 1090      4             Obstbau
#> 1043              Metaldehyd 1090      4             Obstbau
#> 1044              Metaldehyd 1090      4             Obstbau
#> 1045              Metaldehyd 1090      4             Obstbau
#> 1046              Metaldehyd 1090      4             Obstbau
#> 1047              Metaldehyd 1090      4             Obstbau
#> 1048              Metaldehyd 1090      4             Obstbau
#> 1049              Metaldehyd 1090      4             Obstbau
#> 1050              Metaldehyd 1090      4             Obstbau
#> 1051              Metaldehyd 1090      4             Obstbau
#> 1052              Metaldehyd 1090      4             Obstbau
#> 1053              Metaldehyd 1090      4             Obstbau
#> 1054              Metaldehyd 1090      4             Obstbau
#> 1055              Metaldehyd 1090      4             Obstbau
#> 1056              Metaldehyd 1090      4             Obstbau
#> 1057              Metaldehyd 1090      4             Obstbau
#> 1058              Metaldehyd 1090      4             Obstbau
#> 1059              Metaldehyd 1090      4             Obstbau
#> 1060              Metaldehyd 1090      4             Obstbau
#> 1061              Metaldehyd 1090      4             Obstbau
#> 1062              Metaldehyd 1090      4             Obstbau
#> 1063              Metaldehyd 1090      4             Obstbau
#> 1064              Metaldehyd 1090      4             Obstbau
#> 1065              Metaldehyd 1090      4             Obstbau
#> 1066              Metaldehyd 1090      4             Obstbau
#> 1067              Metaldehyd 1090      4             Obstbau
#> 1068              Metaldehyd 1090      4             Obstbau
#> 1069              Metaldehyd 1090      4             Obstbau
#> 1070              Metaldehyd 1090      4             Obstbau
#> 1071              Metaldehyd 1090      4             Obstbau
#> 1072              Metaldehyd 1090      4             Obstbau
#> 1073              Metaldehyd 1090      4             Obstbau
#> 1074              Metaldehyd 1090      4             Obstbau
#> 1075              Metaldehyd 1090      4             Obstbau
#> 1076              Metaldehyd 1090      4             Obstbau
#> 1077              Metaldehyd 1090      4             Obstbau
#> 1078              Metaldehyd 1090      4             Obstbau
#> 1079              Metaldehyd 1090      4             Obstbau
#> 1080              Metaldehyd 1090      4             Obstbau
#> 1081              Metaldehyd 1090      4             Obstbau
#> 1082              Metaldehyd 1090      4             Obstbau
#> 1083              Metaldehyd 1090      4             Obstbau
#> 1084              Metaldehyd 1090      4             Obstbau
#> 1085              Metaldehyd 1090      4             Obstbau
#> 1086              Metaldehyd 1090      4             Obstbau
#> 1087              Metaldehyd 1090      4             Obstbau
#> 1088              Metaldehyd 1090      4             Obstbau
#> 1089              Metaldehyd 1090      4             Obstbau
#> 1090              Metaldehyd 1090      4             Obstbau
#> 1091              Metaldehyd 1090      4             Obstbau
#> 1092              Metaldehyd 1090      4             Obstbau
#> 1093              Metaldehyd 1090      4             Obstbau
#> 1094              Metaldehyd 1090      4             Obstbau
#> 1095              Metaldehyd 1090      4             Obstbau
#> 1096              Metaldehyd 1090      4             Obstbau
#> 1097              Metaldehyd 1090      4             Obstbau
#> 1098              Metaldehyd 1090      4             Obstbau
#> 1099              Metaldehyd 1090      4             Obstbau
#> 1100              Metaldehyd 1090      4             Obstbau
#> 1101              Metaldehyd 1090      4             Obstbau
#> 1102              Metaldehyd 1090      4             Obstbau
#> 1103              Metaldehyd 1090      4             Obstbau
#> 1104              Metaldehyd 1090      4             Obstbau
#> 1105              Metaldehyd 1090      4             Obstbau
#> 1106              Metaldehyd 1090      4             Obstbau
#> 1107              Metaldehyd 1090      4             Obstbau
#> 1108              Metaldehyd 1090      4             Obstbau
#> 1109              Metaldehyd 1090      4             Obstbau
#> 1110              Metaldehyd 1090      4             Obstbau
#> 1111              Metaldehyd 1090      4             Obstbau
#> 1112              Metaldehyd 1090      4             Obstbau
#> 1113              Metaldehyd 1090      4             Obstbau
#> 1114              Metaldehyd 1090      4             Obstbau
#> 1115              Metaldehyd 1090      4             Obstbau
#> 1116              Metaldehyd 1090      4             Obstbau
#> 1117              Metaldehyd 1090      4             Obstbau
#> 1118              Metaldehyd 1090      4             Obstbau
#> 1119              Metaldehyd 1090      4             Obstbau
#> 1120              Metaldehyd 1090      4             Obstbau
#> 1121              Metaldehyd 1090      4             Obstbau
#> 1122              Metaldehyd 1090      4             Obstbau
#> 1123              Metaldehyd 1090      4             Obstbau
#> 1124              Metaldehyd 1090      4             Obstbau
#> 1125              Metaldehyd 1090      4             Obstbau
#> 1126              Metaldehyd 1090      4             Obstbau
#> 1127              Metaldehyd 1090      4             Obstbau
#> 1128              Metaldehyd 1090      4             Obstbau
#> 1129              Metaldehyd 1090      4             Obstbau
#> 1130              Metaldehyd 1090      4             Obstbau
#> 1131              Metaldehyd 1090      4             Obstbau
#> 1132              Metaldehyd 1090      4             Obstbau
#> 1133              Metaldehyd 1090      4             Obstbau
#> 1134              Metaldehyd 1090      4             Obstbau
#> 1135              Metaldehyd 1090      4             Obstbau
#> 1136              Metaldehyd 1090      4             Obstbau
#> 1137              Metaldehyd 1090      4             Obstbau
#> 1138              Metaldehyd 1090      4             Obstbau
#> 1139              Metaldehyd 1090      4             Obstbau
#> 1140              Metaldehyd 1090      4             Obstbau
#> 1141              Metaldehyd 1090      4             Obstbau
#> 1142              Metaldehyd 1090      4             Obstbau
#> 1143              Metaldehyd 1090      4             Obstbau
#> 1144              Metaldehyd 1090      4             Obstbau
#> 1145              Metaldehyd 1090      4             Obstbau
#> 1146              Metaldehyd 1090      4             Obstbau
#> 1147              Metaldehyd 1090      4             Obstbau
#> 1148              Metaldehyd 1090      4             Obstbau
#> 1149              Metaldehyd 1090      4             Obstbau
#> 1150              Metaldehyd 1090      4             Obstbau
#> 1151              Metaldehyd 1090      4             Obstbau
#> 1152              Metaldehyd 1090      4             Obstbau
#> 1153              Metaldehyd 1090      4             Obstbau
#> 1154              Metaldehyd 1090      4             Obstbau
#> 1155              Metaldehyd 1090      4             Obstbau
#> 1156              Metaldehyd 1090      4             Obstbau
#> 1157              Metaldehyd 1090      4             Obstbau
#> 1158              Metaldehyd 1090      4             Obstbau
#> 1159              Metaldehyd 1090      4             Obstbau
#> 1160              Metaldehyd 1090      4             Obstbau
#> 1161              Metaldehyd 1090      4             Obstbau
#> 1162              Metaldehyd 1090      4             Obstbau
#> 1163              Metaldehyd 1090      4             Obstbau
#> 1164              Metaldehyd 1090      4             Obstbau
#> 1165              Metaldehyd 1090      4             Obstbau
#> 1166              Metaldehyd 1090      4             Obstbau
#> 1167              Metaldehyd 1090      4             Obstbau
#> 1168              Metaldehyd 1090      4             Obstbau
#> 1169              Metaldehyd 1090      4             Obstbau
#> 1170              Metaldehyd 1090      4             Obstbau
#> 1171              Metaldehyd 1090      4             Obstbau
#> 1172              Metaldehyd 1090      4             Obstbau
#> 1173              Metaldehyd 1090      4             Obstbau
#> 1174              Metaldehyd 1090      4             Obstbau
#> 1175              Metaldehyd 1090      4             Obstbau
#> 1176              Metaldehyd 1090      4             Obstbau
#> 1177              Metaldehyd 1090      4             Obstbau
#> 1178              Metaldehyd 1090      4             Obstbau
#> 1179              Metaldehyd 1090      4             Obstbau
#> 1180              Metaldehyd 1090      4             Obstbau
#> 1181              Metaldehyd 1090      4             Obstbau
#> 1182              Metaldehyd 1090      4             Obstbau
#> 1183              Metaldehyd 1090      4             Obstbau
#> 1184              Metaldehyd 1090      4             Obstbau
#> 1185              Metaldehyd 1090      4             Obstbau
#> 1186              Metaldehyd 1090      4             Obstbau
#> 1187              Metaldehyd 1090      4             Obstbau
#> 1188              Metaldehyd 1090      4             Obstbau
#> 1189              Metaldehyd 1090      4             Obstbau
#> 1190              Metaldehyd 1090      4             Obstbau
#> 1191              Metaldehyd 1090      4             Obstbau
#> 1192              Metaldehyd 1090      4             Obstbau
#>                                                                culture_de
#> 1                                                               Brombeere
#> 2                                                              Sommerflor
#> 3                                                Baby-Leaf (Brassicaceae)
#> 4                                              Baby-Leaf (Chenopodiaceae)
#> 5                                                  Baby-Leaf (Asteraceae)
#> 6                                                                  Hopfen
#> 7                                                       Erbsen mit Hülsen
#> 8                                                               Knoblauch
#> 9                                                         Wintertriticale
#> 10                                                  Tomaten Spezialitäten
#> 11                                                             Zuckerrübe
#> 12                                                             Futterrübe
#> 13                                                          Wassermelonen
#> 14                                                            Sonnenblume
#> 15                                                               Peperoni
#> 16                                                          Gemüsepaprika
#> 17                                                                   Ysop
#> 18                                                         Knollenfenchel
#> 19                                                              Koriander
#> 20                                                                Oregano
#> 21                                                                 Quitte
#> 22                                                                  Apfel
#> 23                                                                  Birne
#> 24                                                     Bohnen ohne Hülsen
#> 25                                                              Eberesche
#> 26                        Liegendes Rundholz im Wald und auf Lagerplätzen
#> 27                                                               Rosmarin
#> 28                                           Tabak produzierende Betriebe
#> 29                                                         Suppensellerie
#> 30                                                          Brunnenkresse
#> 31                                                                   Wald
#> 32                                                             Petersilie
#> 33                                                           Artischocken
#> 34                                                          Cherrytomaten
#> 35                                                             Blumenkohl
#> 36                                          Kleegrasmischung (Kunstwiese)
#> 37                                                                Stachys
#> 38                                                       Wurzelpetersilie
#> 39                                                            Kichererbse
#> 40                                                               Ranunkel
#> 41                                                           Ertragsreben
#> 42                                                              Jungreben
#> 43                                                          Einlegegurken
#> 44                                                              Zwetschge
#> 45                                                                Pflaume
#> 46                                                             Grünfläche
#> 47                                                              Löwenzahn
#> 48                                                       Römische Kamille
#> 49                                                          Spitzwegerich
#> 50                                                              Rhabarber
#> 51                                                                Sorghum
#> 52                                                           Winterweizen
#> 53                                                           Winterroggen
#> 54                                                          Korn (Dinkel)
#> 55                                                                  Emmer
#> 56                                                 Leere Produktionsräume
#> 57                                                           Ertragsreben
#> 58                                                                Begonia
#> 59                                                                Cyclame
#> 60                                                            Pelargonien
#> 61                                                                Primeln
#> 62                                                               Karotten
#> 63                                                                 Kerbel
#> 64                                                                Begonia
#> 65                                                           Rosskastanie
#> 66                                                             Zierkürbis
#> 67                                                   Pfirsich / Nektarine
#> 68                                                               Baldrian
#> 69                                                          Einlegegurken
#> 70                                                         Nostranogurken
#> 71                                                      Gewächshausgurken
#> 72                                                                Azaleen
#> 73                                                                  Kardy
#> 74                                                              Kopfsalat
#> 75                                                           Schnittsalat
#> 76                                                               Patisson
#> 77                                                           Chrysantheme
#> 78                                                    Schwarze Apfelbeere
#> 79                                                                Anemone
#> 80                                                        Stangensellerie
#> 81                                                                  Minze
#> 82                                                               Pak-Choi
#> 83                                                                Melonen
#> 84                                                           Stachelbeere
#> 85                                                                Azaleen
#> 86                                                             Baumschule
#> 87                                                              Basilikum
#> 88                                                     Verarbeitungsräume
#> 89                                                                Lupinen
#> 90                                                                  Birne
#> 91                                                     Schwarzer Holunder
#> 92                                                              Rosenkohl
#> 93                                                              Kopfkohle
#> 94                                                               Kohlrabi
#> 95                                                             Blumenkohl
#> 96                                                              Romanesco
#> 97                                                               Broccoli
#> 98                                                               Pak-Choi
#> 99                                                          Markstammkohl
#> 100                                                             Chinakohl
#> 101                                                             Federkohl
#> 102                                                             Brombeere
#> 103                                                              Himbeere
#> 104                                               Forstliche Pflanzgärten
#> 105                                                          Stangenbohne
#> 106                                                          Sommerweizen
#> 107                                                          Sommergerste
#> 108                                                           Sommerhafer
#> 109                                              Einrichtungen und Geräte
#> 110                                                             Aubergine
#> 111                                                            Andenbeere
#> 112                                                                Pepino
#> 113                                                              Peperoni
#> 114                                                         Gemüsepaprika
#> 115                                                 Tomaten Spezialitäten
#> 116                                                         Cherrytomaten
#> 117                                                         Rispentomaten
#> 118                                                              Peperoni
#> 119                                                 Färberdistel (Saflor)
#> 120                                                            Blumenkohl
#> 121                                                             Romanesco
#> 122                                                              Broccoli
#> 123                                                           Chinaschilf
#> 124                                              leere Verarbeitungsräume
#> 125                                                               Lorbeer
#> 126                                                           Bohnenkraut
#> 127                                                             Kopfsalat
#> 128                                         Kleegrasmischung (Kunstwiese)
#> 129                                                Schwarze Johannisbeere
#> 130                                                             Jungreben
#> 131                                                           Mulchsaaten
#> 132                                                            Zuckermais
#> 133                                                                 Linse
#> 134                                                       Knollensellerie
#> 135                                                             Puffbohne
#> 136                                 Speisekürbisse (ungeniessbare Schale)
#> 137                                                            Winterraps
#> 138                                                             Blautanne
#> 139                                                  Zier- und Sportrasen
#> 140                                                     Erbsen mit Hülsen
#> 141                                                    Erbsen ohne Hülsen
#> 142                                                             Hyazinthe
#> 143                                                          Wintergerste
#> 144                                                              Endivien
#> 145                                            Klee zur Saatgutproduktion
#> 146                                                            Ackerbohne
#> 147                                                             Zwetschge
#> 148                                                         Gemüsepaprika
#> 149                                    Kartoffeln zur Pflanzgutproduktion
#> 150                                              Baby-Leaf (Brassicaceae)
#> 151                                                             Aubergine
#> 152                                                                 Kenaf
#> 153                                                               Walnuss
#> 154                                                       Hartschalenobst
#> 155                                                              Pak-Choi
#> 156                                                         Markstammkohl
#> 157                                                             Chinakohl
#> 158                                                             Federkohl
#> 159                                                               Majoran
#> 160                                                            Kerbelrübe
#> 161                                                               Thymian
#> 162                                                            Andenbeere
#> 163                                     Holzpaletten, Packholz, Stammholz
#> 164                                                            Zierkürbis
#> 165                                                             Hyazinthe
#> 166                                                                  Iris
#> 167                                         Liliengewächse (Zierpflanzen)
#> 168                                                                 Tulpe
#> 169                                                        Gemüseportulak
#> 170                                                            Hartweizen
#> 171                                                       Weihnachtsbäume
#> 172                                                                 Rande
#> 173                                                          Winterweizen
#> 174                                            Gehölze (ausserhalb Forst)
#> 175                                                             Rosenkohl
#> 176                                                                Kresse
#> 177                                                      leere Lagerräume
#> 178                                                          Eiweisserbse
#> 179                                                          Wintergerste
#> 180                                                                Roggen
#> 181                                                         Markstammkohl
#> 182                                                                Kümmel
#> 183                                                            Hartweizen
#> 184                                                           Weichweizen
#> 185                                                                 Tabak
#> 186                                                         Wassermelonen
#> 187                                                               Melonen
#> 188                                 Speisekürbisse (ungeniessbare Schale)
#> 189                                                            Ölkürbisse
#> 190                                                         Einlegegurken
#> 191                                                        Nostranogurken
#> 192                                                     Gewächshausgurken
#> 193                                                              Patisson
#> 194                                                             Zucchetti
#> 195                                                               Rondini
#> 196                                                                Nelken
#> 197                                                         Gemüsezwiebel
#> 198                                                         Gewürzfenchel
#> 199                                                             Brombeere
#> 200                                                          Bundzwiebeln
#> 201                                                        Gemüseportulak
#> 202                                                             Romanesco
#> 203                                                                Roggen
#> 204                                                                 Hafer
#> 205                                                       Wintertriticale
#> 206                                                          Winterweizen
#> 207                                                          Winterroggen
#> 208                                                         Korn (Dinkel)
#> 209                                                                 Emmer
#> 210                                                          Sommerweizen
#> 211                                                          Sommergerste
#> 212                                                           Sommerhafer
#> 213                                                          Wintergerste
#> 214                                                            Hartweizen
#> 215                                                           Weichweizen
#> 216                                                    Offene Ackerfläche
#> 217                                                              Endivien
#> 218                                                             Zuckerhut
#> 219                                         Radicchio- und Cicorino-Typen
#> 220                                                                 Lauch
#> 221                                                              Pflanzen
#> 222                                                                Radies
#> 223                                                    Rote Johannisbeere
#> 224                                                                  Dill
#> 225                                                            Krautstiel
#> 226                                          Speise- und Futterkartoffeln
#> 227                                                            Buschbohne
#> 228                                                                Spinat
#> 229                                                             Zuckerhut
#> 230                                                    Traubensilberkerze
#> 231                                                           Trockenreis
#> 232                                                         Schwarzwurzel
#> 233                                                               Cyclame
#> 234                                                           Nüsslisalat
#> 235                                                                  Mohn
#> 236                                                                  Lein
#> 237                                                              Aprikose
#> 238                                                                 Olive
#> 239                                            Baby-Leaf (Chenopodiaceae)
#> 240                                                               Pflaume
#> 241                                                               Gerbera
#> 242                                                          Schnittsalat
#> 243                                                             Sojabohne
#> 244                                      Blumenzwiebeln und Blumenknollen
#> 245                                                                 Rosen
#> 246                                                                Salbei
#> 247                                                   Brassica rapa-Rüben
#> 248                                                             Rosenwurz
#> 249                                                         Kirschlorbeer
#> 250  Böschungen und Grünstreifen entlang von Verkehrswegen (gem. ChemRRV)
#> 251                                                           Speisepilze
#> 252                                                             Süssdolde
#> 253                                                             Gojibeere
#> 254                                                          Schnittsalat
#> 255                                                           Liebstöckel
#> 256                                                                  Iris
#> 257                                                    Bohnen ohne Hülsen
#> 258                                                          Stangenbohne
#> 259                                                            Buschbohne
#> 260                                                           Heidelbeere
#> 261                                                            Krautstiel
#> 262                                                        Schnittmangold
#> 263                                                              Estragon
#> 264                                      Lagerhallen, Mühlen, Silogebäude
#> 265                                                             Brachland
#> 266                                                         Johanniskraut
#> 267                                                               Dahlien
#> 268                                                        Nostranogurken
#> 269                                                             Kopfsalat
#> 270                                    Kartoffeln zur Pflanzgutproduktion
#> 271                                          Speise- und Futterkartoffeln
#> 272                                         Radicchio- und Cicorino-Typen
#> 273                                                            Zuckerrübe
#> 274                                            Asia-Salate (Brassicaceae)
#> 275                                                          Sommerweizen
#> 276                                                          Winterroggen
#> 277                                                           Pelargonien
#> 278                                                        Schnittmangold
#> 279                                         Liliengewächse (Zierpflanzen)
#> 280                                                   Blaue Heckenkirsche
#> 281                                                              Broccoli
#> 282                                                          Barbarakraut
#> 283                                                          Humusdeponie
#> 284                                                               Rettich
#> 285                                                            Ölkürbisse
#> 286                                                            Topinambur
#> 287                                                          Stachelbeere
#> 288                                                Schwarze Johannisbeere
#> 289                                                    Rote Johannisbeere
#> 290                                                            Jostabeere
#> 291                                                   Brassica rapa-Rüben
#> 292                                                          Sommergerste
#> 293                                                             Zucchetti
#> 294                                                          Cima di Rapa
#> 295                                                             Chinakohl
#> 296                                                    Wolliger Fingerhut
#> 297               Auf und an National- und Kantonsstrassen (gem. ChemRRV)
#> 298                                                    Erbsen ohne Hülsen
#> 299                                                            Sommerflor
#> 300                                                            Futterrübe
#> 301                                                         Speisezwiebel
#> 302                                                                Brache
#> 303                                                               Spargel
#> 304                                                           Sommerhafer
#> 305                                                             Kopfkohle
#> 306                                                  Pfirsich / Nektarine
#> 307                                                              Aprikose
#> 308                                                               Kirsche
#> 309                                                             Zwetschge
#> 310                                                               Pflaume
#> 311                                                             Mini-Kiwi
#> 312                                                              Erntegut
#> 313                                                                Rucola
#> 314                                                              Erdbeere
#> 315                                    Grasbestände zur Saatgutproduktion
#> 316                                                     Gewächshausgurken
#> 317                                                       Wintertriticale
#> 318                                                               Kirsche
#> 319                                                         Rispentomaten
#> 320                                                    Schwarze Maulbeere
#> 321                                                              Sanddorn
#> 322                                                        Suppensellerie
#> 323                                                       Stangensellerie
#> 324                                                       Knollensellerie
#> 325                                                               Luzerne
#> 326                                                         Korn (Dinkel)
#> 327                                                           Weichweizen
#> 328                                Bäume und Sträucher (ausserhalb Forst)
#> 329                                                               Melisse
#> 330                                                                  Ysop
#> 331                                                             Koriander
#> 332                                                              Rosmarin
#> 333                                                            Petersilie
#> 334                                                      Römische Kamille
#> 335                                                                Kerbel
#> 336                                                                 Minze
#> 337                                                             Basilikum
#> 338                                                           Bohnenkraut
#> 339                                                               Thymian
#> 340                                                                Kümmel
#> 341                                                                  Dill
#> 342                                                                Salbei
#> 343                                                           Liebstöckel
#> 344                                                              Estragon
#> 345                                                          Schnittlauch
#> 346                                                   Gemeine Felsenbirne
#> 347                                                              Himbeere
#> 348                                                              Kohlrabi
#> 349                                                                Fichte
#> 350                                                              Stielmus
#> 351                                                            Blaudistel
#> 352                                                Baby-Leaf (Asteraceae)
#> 353                                                         Gemüsezwiebel
#> 354                                                          Bundzwiebeln
#> 355                                                         Speisezwiebel
#> 356                                                    Buchsbäume (Buxus)
#> 357                                                             Federkohl
#> 358                                                              Gladiole
#> 359                                                            Frässaaten
#> 360                                                            Winterraps
#> 361                                                              Chicorée
#> 362                                                             Löwenzahn
#> 363                                                              Endivien
#> 364                                                             Zuckerhut
#> 365                                         Radicchio- und Cicorino-Typen
#> 366                                                             Kopfsalat
#> 367                                                          Schnittsalat
#> 368                                                               Primeln
#> 369                                                    Wolliger Fingerhut
#> 370                                                 Tomaten Spezialitäten
#> 371                                                         Cherrytomaten
#> 372                                                         Rispentomaten
#> 373                                                                  Hanf
#> 374                                                           Meerrettich
#> 375                                                         Bodenkohlrabi
#> 376                                                            Hagebutten
#> 377                                                             Pastinake
#> 378                                                         Süsskartoffel
#> 379                                                            Lagerräume
#> 380                                        Ziergehölze (ausserhalb Forst)
#> 381                                                                Pepino
#> 382                                                               Rondini
#> 383                                                            Schalotten
#> 384                                                                 Emmer
#> 385                                                          Stangenbohne
#> 386                                                            Buschbohne
#> 387                                                                 Hafer
#> 388                                                                  Mais
#> 389                                                                 Birne
#> 390                                                          Schnittlauch
#> 391                                                               Stauden
#> 392                                                                Quitte
#> 393                                                                 Apfel
#> 394                                                              Patisson
#> 395                                                             Zucchetti
#> 396                                                               Rondini
#> 397                                                                 Tulpe
#> 398                                                            Jostabeere
#> 399                                                            Sommerflor
#> 400                                              Baby-Leaf (Brassicaceae)
#> 401                                            Baby-Leaf (Chenopodiaceae)
#> 402                                                Baby-Leaf (Asteraceae)
#> 403                                                                Hopfen
#> 404                                                     Erbsen mit Hülsen
#> 405                                                             Knoblauch
#> 406                                                       Wintertriticale
#> 407                                                 Tomaten Spezialitäten
#> 408                                                            Zuckerrübe
#> 409                                                            Futterrübe
#> 410                                                         Wassermelonen
#> 411                                                           Sonnenblume
#> 412                                                              Peperoni
#> 413                                                         Gemüsepaprika
#> 414                                                                  Ysop
#> 415                                                        Knollenfenchel
#> 416                                                             Koriander
#> 417                                                               Oregano
#> 418                                                                Quitte
#> 419                                                                 Apfel
#> 420                                                                 Birne
#> 421                                                    Bohnen ohne Hülsen
#> 422                                                             Eberesche
#> 423                       Liegendes Rundholz im Wald und auf Lagerplätzen
#> 424                                                              Rosmarin
#> 425                                          Tabak produzierende Betriebe
#> 426                                                        Suppensellerie
#> 427                                                         Brunnenkresse
#> 428                                                                  Wald
#> 429                                                            Petersilie
#> 430                                                          Artischocken
#> 431                                                         Cherrytomaten
#> 432                                                            Blumenkohl
#> 433                                         Kleegrasmischung (Kunstwiese)
#> 434                                                               Stachys
#> 435                                                      Wurzelpetersilie
#> 436                                                           Kichererbse
#> 437                                                              Ranunkel
#> 438                                                          Ertragsreben
#> 439                                                             Jungreben
#> 440                                                         Einlegegurken
#> 441                                                             Zwetschge
#> 442                                                               Pflaume
#> 443                                                            Grünfläche
#> 444                                                             Löwenzahn
#> 445                                                      Römische Kamille
#> 446                                                         Spitzwegerich
#> 447                                                             Rhabarber
#> 448                                                               Sorghum
#> 449                                                          Winterweizen
#> 450                                                          Winterroggen
#> 451                                                         Korn (Dinkel)
#> 452                                                                 Emmer
#> 453                                                Leere Produktionsräume
#> 454                                                          Ertragsreben
#> 455                                                               Begonia
#> 456                                                               Cyclame
#> 457                                                           Pelargonien
#> 458                                                               Primeln
#> 459                                                              Karotten
#> 460                                                                Kerbel
#> 461                                                               Begonia
#> 462                                                          Rosskastanie
#> 463                                                            Zierkürbis
#> 464                                                  Pfirsich / Nektarine
#> 465                                                              Baldrian
#> 466                                                         Einlegegurken
#> 467                                                        Nostranogurken
#> 468                                                     Gewächshausgurken
#> 469                                                               Azaleen
#> 470                                                                 Kardy
#> 471                                                             Kopfsalat
#> 472                                                          Schnittsalat
#> 473                                                              Patisson
#> 474                                                          Chrysantheme
#> 475                                                   Schwarze Apfelbeere
#> 476                                                               Anemone
#> 477                                                       Stangensellerie
#> 478                                                                 Minze
#> 479                                                              Pak-Choi
#> 480                                                               Melonen
#> 481                                                          Stachelbeere
#> 482                                                               Azaleen
#> 483                                                            Baumschule
#> 484                                                             Basilikum
#> 485                                                    Verarbeitungsräume
#> 486                                                               Lupinen
#> 487                                                                 Birne
#> 488                                                    Schwarzer Holunder
#> 489                                                             Rosenkohl
#> 490                                                             Kopfkohle
#> 491                                                              Kohlrabi
#> 492                                                            Blumenkohl
#> 493                                                             Romanesco
#> 494                                                              Broccoli
#> 495                                                              Pak-Choi
#> 496                                                         Markstammkohl
#> 497                                                             Chinakohl
#> 498                                                             Federkohl
#> 499                                                             Brombeere
#> 500                                                              Himbeere
#> 501                                               Forstliche Pflanzgärten
#> 502                                                          Stangenbohne
#> 503                                                          Sommerweizen
#> 504                                                          Sommergerste
#> 505                                                           Sommerhafer
#> 506                                              Einrichtungen und Geräte
#> 507                                                             Aubergine
#> 508                                                            Andenbeere
#> 509                                                                Pepino
#> 510                                                              Peperoni
#> 511                                                         Gemüsepaprika
#> 512                                                 Tomaten Spezialitäten
#> 513                                                         Cherrytomaten
#> 514                                                         Rispentomaten
#> 515                                                              Peperoni
#> 516                                                 Färberdistel (Saflor)
#> 517                                                            Blumenkohl
#> 518                                                             Romanesco
#> 519                                                              Broccoli
#> 520                                                           Chinaschilf
#> 521                                              leere Verarbeitungsräume
#> 522                                                               Lorbeer
#> 523                                                           Bohnenkraut
#> 524                                                             Kopfsalat
#> 525                                         Kleegrasmischung (Kunstwiese)
#> 526                                                Schwarze Johannisbeere
#> 527                                                             Jungreben
#> 528                                                           Mulchsaaten
#> 529                                                            Zuckermais
#> 530                                                                 Linse
#> 531                                                       Knollensellerie
#> 532                                                             Puffbohne
#> 533                                 Speisekürbisse (ungeniessbare Schale)
#> 534                                                            Winterraps
#> 535                                                             Blautanne
#> 536                                                  Zier- und Sportrasen
#> 537                                                     Erbsen mit Hülsen
#> 538                                                    Erbsen ohne Hülsen
#> 539                                                             Hyazinthe
#> 540                                                          Wintergerste
#> 541                                                              Endivien
#> 542                                            Klee zur Saatgutproduktion
#> 543                                                            Ackerbohne
#> 544                                                             Zwetschge
#> 545                                                         Gemüsepaprika
#> 546                                    Kartoffeln zur Pflanzgutproduktion
#> 547                                              Baby-Leaf (Brassicaceae)
#> 548                                                             Aubergine
#> 549                                                                 Kenaf
#> 550                                                               Walnuss
#> 551                                                       Hartschalenobst
#> 552                                                              Pak-Choi
#> 553                                                         Markstammkohl
#> 554                                                             Chinakohl
#> 555                                                             Federkohl
#> 556                                                               Majoran
#> 557                                                            Kerbelrübe
#> 558                                                               Thymian
#> 559                                                            Andenbeere
#> 560                                     Holzpaletten, Packholz, Stammholz
#> 561                                                            Zierkürbis
#> 562                                                             Hyazinthe
#> 563                                                                  Iris
#> 564                                         Liliengewächse (Zierpflanzen)
#> 565                                                                 Tulpe
#> 566                                                        Gemüseportulak
#> 567                                                            Hartweizen
#> 568                                                       Weihnachtsbäume
#> 569                                                                 Rande
#> 570                                                          Winterweizen
#> 571                                            Gehölze (ausserhalb Forst)
#> 572                                                             Rosenkohl
#> 573                                                                Kresse
#> 574                                                      leere Lagerräume
#> 575                                                          Eiweisserbse
#> 576                                                          Wintergerste
#> 577                                                                Roggen
#> 578                                                         Markstammkohl
#> 579                                                                Kümmel
#> 580                                                            Hartweizen
#> 581                                                           Weichweizen
#> 582                                                                 Tabak
#> 583                                                         Wassermelonen
#> 584                                                               Melonen
#> 585                                 Speisekürbisse (ungeniessbare Schale)
#> 586                                                            Ölkürbisse
#> 587                                                         Einlegegurken
#> 588                                                        Nostranogurken
#> 589                                                     Gewächshausgurken
#> 590                                                              Patisson
#> 591                                                             Zucchetti
#> 592                                                               Rondini
#> 593                                                                Nelken
#> 594                                                         Gemüsezwiebel
#> 595                                                         Gewürzfenchel
#> 596                                                             Brombeere
#> 597                                                          Bundzwiebeln
#> 598                                                        Gemüseportulak
#> 599                                                             Romanesco
#> 600                                                                Roggen
#> 601                                                                 Hafer
#> 602                                                       Wintertriticale
#> 603                                                          Winterweizen
#> 604                                                          Winterroggen
#> 605                                                         Korn (Dinkel)
#> 606                                                                 Emmer
#> 607                                                          Sommerweizen
#> 608                                                          Sommergerste
#> 609                                                           Sommerhafer
#> 610                                                          Wintergerste
#> 611                                                            Hartweizen
#> 612                                                           Weichweizen
#> 613                                                    Offene Ackerfläche
#> 614                                                              Endivien
#> 615                                                             Zuckerhut
#> 616                                         Radicchio- und Cicorino-Typen
#> 617                                                                 Lauch
#> 618                                                              Pflanzen
#> 619                                                                Radies
#> 620                                                    Rote Johannisbeere
#> 621                                                                  Dill
#> 622                                                            Krautstiel
#> 623                                          Speise- und Futterkartoffeln
#> 624                                                            Buschbohne
#> 625                                                                Spinat
#> 626                                                             Zuckerhut
#> 627                                                    Traubensilberkerze
#> 628                                                           Trockenreis
#> 629                                                         Schwarzwurzel
#> 630                                                               Cyclame
#> 631                                                           Nüsslisalat
#> 632                                                                  Mohn
#> 633                                                                  Lein
#> 634                                                              Aprikose
#> 635                                                                 Olive
#> 636                                            Baby-Leaf (Chenopodiaceae)
#> 637                                                               Pflaume
#> 638                                                               Gerbera
#> 639                                                          Schnittsalat
#> 640                                                             Sojabohne
#> 641                                      Blumenzwiebeln und Blumenknollen
#> 642                                                                 Rosen
#> 643                                                                Salbei
#> 644                                                   Brassica rapa-Rüben
#> 645                                                             Rosenwurz
#> 646                                                         Kirschlorbeer
#> 647  Böschungen und Grünstreifen entlang von Verkehrswegen (gem. ChemRRV)
#> 648                                                           Speisepilze
#> 649                                                             Süssdolde
#> 650                                                             Gojibeere
#> 651                                                          Schnittsalat
#> 652                                                           Liebstöckel
#> 653                                                                  Iris
#> 654                                                    Bohnen ohne Hülsen
#> 655                                                          Stangenbohne
#> 656                                                            Buschbohne
#> 657                                                           Heidelbeere
#> 658                                                            Krautstiel
#> 659                                                        Schnittmangold
#> 660                                                              Estragon
#> 661                                      Lagerhallen, Mühlen, Silogebäude
#> 662                                                             Brachland
#> 663                                                         Johanniskraut
#> 664                                                               Dahlien
#> 665                                                        Nostranogurken
#> 666                                                             Kopfsalat
#> 667                                    Kartoffeln zur Pflanzgutproduktion
#> 668                                          Speise- und Futterkartoffeln
#> 669                                         Radicchio- und Cicorino-Typen
#> 670                                                            Zuckerrübe
#> 671                                            Asia-Salate (Brassicaceae)
#> 672                                                          Sommerweizen
#> 673                                                          Winterroggen
#> 674                                                           Pelargonien
#> 675                                                        Schnittmangold
#> 676                                         Liliengewächse (Zierpflanzen)
#> 677                                                   Blaue Heckenkirsche
#> 678                                                              Broccoli
#> 679                                                          Barbarakraut
#> 680                                                          Humusdeponie
#> 681                                                               Rettich
#> 682                                                            Ölkürbisse
#> 683                                                            Topinambur
#> 684                                                          Stachelbeere
#> 685                                                Schwarze Johannisbeere
#> 686                                                    Rote Johannisbeere
#> 687                                                            Jostabeere
#> 688                                                   Brassica rapa-Rüben
#> 689                                                          Sommergerste
#> 690                                                             Zucchetti
#> 691                                                          Cima di Rapa
#> 692                                                             Chinakohl
#> 693                                                    Wolliger Fingerhut
#> 694               Auf und an National- und Kantonsstrassen (gem. ChemRRV)
#> 695                                                    Erbsen ohne Hülsen
#> 696                                                            Sommerflor
#> 697                                                            Futterrübe
#> 698                                                         Speisezwiebel
#> 699                                                                Brache
#> 700                                                               Spargel
#> 701                                                           Sommerhafer
#> 702                                                             Kopfkohle
#> 703                                                  Pfirsich / Nektarine
#> 704                                                              Aprikose
#> 705                                                               Kirsche
#> 706                                                             Zwetschge
#> 707                                                               Pflaume
#> 708                                                             Mini-Kiwi
#> 709                                                              Erntegut
#> 710                                                                Rucola
#> 711                                                              Erdbeere
#> 712                                    Grasbestände zur Saatgutproduktion
#> 713                                                     Gewächshausgurken
#> 714                                                       Wintertriticale
#> 715                                                               Kirsche
#> 716                                                         Rispentomaten
#> 717                                                    Schwarze Maulbeere
#> 718                                                              Sanddorn
#> 719                                                        Suppensellerie
#> 720                                                       Stangensellerie
#> 721                                                       Knollensellerie
#> 722                                                               Luzerne
#> 723                                                         Korn (Dinkel)
#> 724                                                           Weichweizen
#> 725                                Bäume und Sträucher (ausserhalb Forst)
#> 726                                                               Melisse
#> 727                                                                  Ysop
#> 728                                                             Koriander
#> 729                                                              Rosmarin
#> 730                                                            Petersilie
#> 731                                                      Römische Kamille
#> 732                                                                Kerbel
#> 733                                                                 Minze
#> 734                                                             Basilikum
#> 735                                                           Bohnenkraut
#> 736                                                               Thymian
#> 737                                                                Kümmel
#> 738                                                                  Dill
#> 739                                                                Salbei
#> 740                                                           Liebstöckel
#> 741                                                              Estragon
#> 742                                                          Schnittlauch
#> 743                                                   Gemeine Felsenbirne
#> 744                                                              Himbeere
#> 745                                                              Kohlrabi
#> 746                                                                Fichte
#> 747                                                              Stielmus
#> 748                                                            Blaudistel
#> 749                                                Baby-Leaf (Asteraceae)
#> 750                                                         Gemüsezwiebel
#> 751                                                          Bundzwiebeln
#> 752                                                         Speisezwiebel
#> 753                                                    Buchsbäume (Buxus)
#> 754                                                             Federkohl
#> 755                                                              Gladiole
#> 756                                                            Frässaaten
#> 757                                                            Winterraps
#> 758                                                              Chicorée
#> 759                                                             Löwenzahn
#> 760                                                              Endivien
#> 761                                                             Zuckerhut
#> 762                                         Radicchio- und Cicorino-Typen
#> 763                                                             Kopfsalat
#> 764                                                          Schnittsalat
#> 765                                                               Primeln
#> 766                                                    Wolliger Fingerhut
#> 767                                                 Tomaten Spezialitäten
#> 768                                                         Cherrytomaten
#> 769                                                         Rispentomaten
#> 770                                                                  Hanf
#> 771                                                           Meerrettich
#> 772                                                         Bodenkohlrabi
#> 773                                                            Hagebutten
#> 774                                                             Pastinake
#> 775                                                         Süsskartoffel
#> 776                                                            Lagerräume
#> 777                                        Ziergehölze (ausserhalb Forst)
#> 778                                                                Pepino
#> 779                                                               Rondini
#> 780                                                            Schalotten
#> 781                                                                 Emmer
#> 782                                                          Stangenbohne
#> 783                                                            Buschbohne
#> 784                                                                 Hafer
#> 785                                                                  Mais
#> 786                                                                 Birne
#> 787                                                          Schnittlauch
#> 788                                                               Stauden
#> 789                                                                Quitte
#> 790                                                                 Apfel
#> 791                                                              Patisson
#> 792                                                             Zucchetti
#> 793                                                               Rondini
#> 794                                                                 Tulpe
#> 795                                                            Jostabeere
#> 796                                                            Sommerflor
#> 797                                              Baby-Leaf (Brassicaceae)
#> 798                                            Baby-Leaf (Chenopodiaceae)
#> 799                                                Baby-Leaf (Asteraceae)
#> 800                                                                Hopfen
#> 801                                                     Erbsen mit Hülsen
#> 802                                                             Knoblauch
#> 803                                                       Wintertriticale
#> 804                                                 Tomaten Spezialitäten
#> 805                                                            Zuckerrübe
#> 806                                                            Futterrübe
#> 807                                                         Wassermelonen
#> 808                                                           Sonnenblume
#> 809                                                              Peperoni
#> 810                                                         Gemüsepaprika
#> 811                                                                  Ysop
#> 812                                                        Knollenfenchel
#> 813                                                             Koriander
#> 814                                                               Oregano
#> 815                                                                Quitte
#> 816                                                                 Apfel
#> 817                                                                 Birne
#> 818                                                    Bohnen ohne Hülsen
#> 819                                                             Eberesche
#> 820                       Liegendes Rundholz im Wald und auf Lagerplätzen
#> 821                                                              Rosmarin
#> 822                                          Tabak produzierende Betriebe
#> 823                                                        Suppensellerie
#> 824                                                         Brunnenkresse
#> 825                                                                  Wald
#> 826                                                            Petersilie
#> 827                                                          Artischocken
#> 828                                                         Cherrytomaten
#> 829                                                            Blumenkohl
#> 830                                         Kleegrasmischung (Kunstwiese)
#> 831                                                               Stachys
#> 832                                                      Wurzelpetersilie
#> 833                                                           Kichererbse
#> 834                                                              Ranunkel
#> 835                                                          Ertragsreben
#> 836                                                             Jungreben
#> 837                                                         Einlegegurken
#> 838                                                             Zwetschge
#> 839                                                               Pflaume
#> 840                                                            Grünfläche
#> 841                                                             Löwenzahn
#> 842                                                      Römische Kamille
#> 843                                                         Spitzwegerich
#> 844                                                             Rhabarber
#> 845                                                               Sorghum
#> 846                                                          Winterweizen
#> 847                                                          Winterroggen
#> 848                                                         Korn (Dinkel)
#> 849                                                                 Emmer
#> 850                                                Leere Produktionsräume
#> 851                                                          Ertragsreben
#> 852                                                               Begonia
#> 853                                                               Cyclame
#> 854                                                           Pelargonien
#> 855                                                               Primeln
#> 856                                                              Karotten
#> 857                                                                Kerbel
#> 858                                                               Begonia
#> 859                                                          Rosskastanie
#> 860                                                            Zierkürbis
#> 861                                                  Pfirsich / Nektarine
#> 862                                                              Baldrian
#> 863                                                         Einlegegurken
#> 864                                                        Nostranogurken
#> 865                                                     Gewächshausgurken
#> 866                                                               Azaleen
#> 867                                                                 Kardy
#> 868                                                             Kopfsalat
#> 869                                                          Schnittsalat
#> 870                                                              Patisson
#> 871                                                          Chrysantheme
#> 872                                                   Schwarze Apfelbeere
#> 873                                                               Anemone
#> 874                                                       Stangensellerie
#> 875                                                                 Minze
#> 876                                                              Pak-Choi
#> 877                                                               Melonen
#> 878                                                          Stachelbeere
#> 879                                                               Azaleen
#> 880                                                            Baumschule
#> 881                                                             Basilikum
#> 882                                                    Verarbeitungsräume
#> 883                                                               Lupinen
#> 884                                                                 Birne
#> 885                                                    Schwarzer Holunder
#> 886                                                             Rosenkohl
#> 887                                                             Kopfkohle
#> 888                                                              Kohlrabi
#> 889                                                            Blumenkohl
#> 890                                                             Romanesco
#> 891                                                              Broccoli
#> 892                                                              Pak-Choi
#> 893                                                         Markstammkohl
#> 894                                                             Chinakohl
#> 895                                                             Federkohl
#> 896                                                             Brombeere
#> 897                                                              Himbeere
#> 898                                               Forstliche Pflanzgärten
#> 899                                                          Stangenbohne
#> 900                                                          Sommerweizen
#> 901                                                          Sommergerste
#> 902                                                           Sommerhafer
#> 903                                              Einrichtungen und Geräte
#> 904                                                             Aubergine
#> 905                                                            Andenbeere
#> 906                                                                Pepino
#> 907                                                              Peperoni
#> 908                                                         Gemüsepaprika
#> 909                                                 Tomaten Spezialitäten
#> 910                                                         Cherrytomaten
#> 911                                                         Rispentomaten
#> 912                                                              Peperoni
#> 913                                                 Färberdistel (Saflor)
#> 914                                                            Blumenkohl
#> 915                                                             Romanesco
#> 916                                                              Broccoli
#> 917                                                           Chinaschilf
#> 918                                              leere Verarbeitungsräume
#> 919                                                               Lorbeer
#> 920                                                           Bohnenkraut
#> 921                                                             Kopfsalat
#> 922                                         Kleegrasmischung (Kunstwiese)
#> 923                                                Schwarze Johannisbeere
#> 924                                                             Jungreben
#> 925                                                           Mulchsaaten
#> 926                                                            Zuckermais
#> 927                                                                 Linse
#> 928                                                       Knollensellerie
#> 929                                                             Puffbohne
#> 930                                 Speisekürbisse (ungeniessbare Schale)
#> 931                                                            Winterraps
#> 932                                                             Blautanne
#> 933                                                  Zier- und Sportrasen
#> 934                                                     Erbsen mit Hülsen
#> 935                                                    Erbsen ohne Hülsen
#> 936                                                             Hyazinthe
#> 937                                                          Wintergerste
#> 938                                                              Endivien
#> 939                                            Klee zur Saatgutproduktion
#> 940                                                            Ackerbohne
#> 941                                                             Zwetschge
#> 942                                                         Gemüsepaprika
#> 943                                    Kartoffeln zur Pflanzgutproduktion
#> 944                                              Baby-Leaf (Brassicaceae)
#> 945                                                             Aubergine
#> 946                                                                 Kenaf
#> 947                                                               Walnuss
#> 948                                                       Hartschalenobst
#> 949                                                              Pak-Choi
#> 950                                                         Markstammkohl
#> 951                                                             Chinakohl
#> 952                                                             Federkohl
#> 953                                                               Majoran
#> 954                                                            Kerbelrübe
#> 955                                                               Thymian
#> 956                                                            Andenbeere
#> 957                                     Holzpaletten, Packholz, Stammholz
#> 958                                                            Zierkürbis
#> 959                                                             Hyazinthe
#> 960                                                                  Iris
#> 961                                         Liliengewächse (Zierpflanzen)
#> 962                                                                 Tulpe
#> 963                                                        Gemüseportulak
#> 964                                                            Hartweizen
#> 965                                                       Weihnachtsbäume
#> 966                                                                 Rande
#> 967                                                          Winterweizen
#> 968                                            Gehölze (ausserhalb Forst)
#> 969                                                             Rosenkohl
#> 970                                                                Kresse
#> 971                                                      leere Lagerräume
#> 972                                                          Eiweisserbse
#> 973                                                          Wintergerste
#> 974                                                                Roggen
#> 975                                                         Markstammkohl
#> 976                                                                Kümmel
#> 977                                                            Hartweizen
#> 978                                                           Weichweizen
#> 979                                                                 Tabak
#> 980                                                         Wassermelonen
#> 981                                                               Melonen
#> 982                                 Speisekürbisse (ungeniessbare Schale)
#> 983                                                            Ölkürbisse
#> 984                                                         Einlegegurken
#> 985                                                        Nostranogurken
#> 986                                                     Gewächshausgurken
#> 987                                                              Patisson
#> 988                                                             Zucchetti
#> 989                                                               Rondini
#> 990                                                                Nelken
#> 991                                                         Gemüsezwiebel
#> 992                                                         Gewürzfenchel
#> 993                                                             Brombeere
#> 994                                                          Bundzwiebeln
#> 995                                                        Gemüseportulak
#> 996                                                             Romanesco
#> 997                                                                Roggen
#> 998                                                                 Hafer
#> 999                                                       Wintertriticale
#> 1000                                                         Winterweizen
#> 1001                                                         Winterroggen
#> 1002                                                        Korn (Dinkel)
#> 1003                                                                Emmer
#> 1004                                                         Sommerweizen
#> 1005                                                         Sommergerste
#> 1006                                                          Sommerhafer
#> 1007                                                         Wintergerste
#> 1008                                                           Hartweizen
#> 1009                                                          Weichweizen
#> 1010                                                   Offene Ackerfläche
#> 1011                                                             Endivien
#> 1012                                                            Zuckerhut
#> 1013                                        Radicchio- und Cicorino-Typen
#> 1014                                                                Lauch
#> 1015                                                             Pflanzen
#> 1016                                                               Radies
#> 1017                                                   Rote Johannisbeere
#> 1018                                                                 Dill
#> 1019                                                           Krautstiel
#> 1020                                         Speise- und Futterkartoffeln
#> 1021                                                           Buschbohne
#> 1022                                                               Spinat
#> 1023                                                            Zuckerhut
#> 1024                                                   Traubensilberkerze
#> 1025                                                          Trockenreis
#> 1026                                                        Schwarzwurzel
#> 1027                                                              Cyclame
#> 1028                                                          Nüsslisalat
#> 1029                                                                 Mohn
#> 1030                                                                 Lein
#> 1031                                                             Aprikose
#> 1032                                                                Olive
#> 1033                                           Baby-Leaf (Chenopodiaceae)
#> 1034                                                              Pflaume
#> 1035                                                              Gerbera
#> 1036                                                         Schnittsalat
#> 1037                                                            Sojabohne
#> 1038                                     Blumenzwiebeln und Blumenknollen
#> 1039                                                                Rosen
#> 1040                                                               Salbei
#> 1041                                                  Brassica rapa-Rüben
#> 1042                                                            Rosenwurz
#> 1043                                                        Kirschlorbeer
#> 1044 Böschungen und Grünstreifen entlang von Verkehrswegen (gem. ChemRRV)
#> 1045                                                          Speisepilze
#> 1046                                                            Süssdolde
#> 1047                                                            Gojibeere
#> 1048                                                         Schnittsalat
#> 1049                                                          Liebstöckel
#> 1050                                                                 Iris
#> 1051                                                   Bohnen ohne Hülsen
#> 1052                                                         Stangenbohne
#> 1053                                                           Buschbohne
#> 1054                                                          Heidelbeere
#> 1055                                                           Krautstiel
#> 1056                                                       Schnittmangold
#> 1057                                                             Estragon
#> 1058                                     Lagerhallen, Mühlen, Silogebäude
#> 1059                                                            Brachland
#> 1060                                                        Johanniskraut
#> 1061                                                              Dahlien
#> 1062                                                       Nostranogurken
#> 1063                                                            Kopfsalat
#> 1064                                   Kartoffeln zur Pflanzgutproduktion
#> 1065                                         Speise- und Futterkartoffeln
#> 1066                                        Radicchio- und Cicorino-Typen
#> 1067                                                           Zuckerrübe
#> 1068                                           Asia-Salate (Brassicaceae)
#> 1069                                                         Sommerweizen
#> 1070                                                         Winterroggen
#> 1071                                                          Pelargonien
#> 1072                                                       Schnittmangold
#> 1073                                        Liliengewächse (Zierpflanzen)
#> 1074                                                  Blaue Heckenkirsche
#> 1075                                                             Broccoli
#> 1076                                                         Barbarakraut
#> 1077                                                         Humusdeponie
#> 1078                                                              Rettich
#> 1079                                                           Ölkürbisse
#> 1080                                                           Topinambur
#> 1081                                                         Stachelbeere
#> 1082                                               Schwarze Johannisbeere
#> 1083                                                   Rote Johannisbeere
#> 1084                                                           Jostabeere
#> 1085                                                  Brassica rapa-Rüben
#> 1086                                                         Sommergerste
#> 1087                                                            Zucchetti
#> 1088                                                         Cima di Rapa
#> 1089                                                            Chinakohl
#> 1090                                                   Wolliger Fingerhut
#> 1091              Auf und an National- und Kantonsstrassen (gem. ChemRRV)
#> 1092                                                   Erbsen ohne Hülsen
#> 1093                                                           Sommerflor
#> 1094                                                           Futterrübe
#> 1095                                                        Speisezwiebel
#> 1096                                                               Brache
#> 1097                                                              Spargel
#> 1098                                                          Sommerhafer
#> 1099                                                            Kopfkohle
#> 1100                                                 Pfirsich / Nektarine
#> 1101                                                             Aprikose
#> 1102                                                              Kirsche
#> 1103                                                            Zwetschge
#> 1104                                                              Pflaume
#> 1105                                                            Mini-Kiwi
#> 1106                                                             Erntegut
#> 1107                                                               Rucola
#> 1108                                                             Erdbeere
#> 1109                                   Grasbestände zur Saatgutproduktion
#> 1110                                                    Gewächshausgurken
#> 1111                                                      Wintertriticale
#> 1112                                                              Kirsche
#> 1113                                                        Rispentomaten
#> 1114                                                   Schwarze Maulbeere
#> 1115                                                             Sanddorn
#> 1116                                                       Suppensellerie
#> 1117                                                      Stangensellerie
#> 1118                                                      Knollensellerie
#> 1119                                                              Luzerne
#> 1120                                                        Korn (Dinkel)
#> 1121                                                          Weichweizen
#> 1122                               Bäume und Sträucher (ausserhalb Forst)
#> 1123                                                              Melisse
#> 1124                                                                 Ysop
#> 1125                                                            Koriander
#> 1126                                                             Rosmarin
#> 1127                                                           Petersilie
#> 1128                                                     Römische Kamille
#> 1129                                                               Kerbel
#> 1130                                                                Minze
#> 1131                                                            Basilikum
#> 1132                                                          Bohnenkraut
#> 1133                                                              Thymian
#> 1134                                                               Kümmel
#> 1135                                                                 Dill
#> 1136                                                               Salbei
#> 1137                                                          Liebstöckel
#> 1138                                                             Estragon
#> 1139                                                         Schnittlauch
#> 1140                                                  Gemeine Felsenbirne
#> 1141                                                             Himbeere
#> 1142                                                             Kohlrabi
#> 1143                                                               Fichte
#> 1144                                                             Stielmus
#> 1145                                                           Blaudistel
#> 1146                                               Baby-Leaf (Asteraceae)
#> 1147                                                        Gemüsezwiebel
#> 1148                                                         Bundzwiebeln
#> 1149                                                        Speisezwiebel
#> 1150                                                   Buchsbäume (Buxus)
#> 1151                                                            Federkohl
#> 1152                                                             Gladiole
#> 1153                                                           Frässaaten
#> 1154                                                           Winterraps
#> 1155                                                             Chicorée
#> 1156                                                            Löwenzahn
#> 1157                                                             Endivien
#> 1158                                                            Zuckerhut
#> 1159                                        Radicchio- und Cicorino-Typen
#> 1160                                                            Kopfsalat
#> 1161                                                         Schnittsalat
#> 1162                                                              Primeln
#> 1163                                                   Wolliger Fingerhut
#> 1164                                                Tomaten Spezialitäten
#> 1165                                                        Cherrytomaten
#> 1166                                                        Rispentomaten
#> 1167                                                                 Hanf
#> 1168                                                          Meerrettich
#> 1169                                                        Bodenkohlrabi
#> 1170                                                           Hagebutten
#> 1171                                                            Pastinake
#> 1172                                                        Süsskartoffel
#> 1173                                                           Lagerräume
#> 1174                                       Ziergehölze (ausserhalb Forst)
#> 1175                                                               Pepino
#> 1176                                                              Rondini
#> 1177                                                           Schalotten
#> 1178                                                                Emmer
#> 1179                                                         Stangenbohne
#> 1180                                                           Buschbohne
#> 1181                                                                Hafer
#> 1182                                                                 Mais
#> 1183                                                                Birne
#> 1184                                                         Schnittlauch
#> 1185                                                              Stauden
#> 1186                                                               Quitte
#> 1187                                                                Apfel
#> 1188                                                             Patisson
#> 1189                                                            Zucchetti
#> 1190                                                              Rondini
#> 1191                                                                Tulpe
#> 1192                                                           Jostabeere
#>                           pest_de
#> 1                      Gallmilben
#> 2    Graufäule (Botrytis cinerea)
#> 3    Graufäule (Botrytis cinerea)
#> 4    Graufäule (Botrytis cinerea)
#> 5    Graufäule (Botrytis cinerea)
#> 6    Graufäule (Botrytis cinerea)
#> 7    Graufäule (Botrytis cinerea)
#> 8    Graufäule (Botrytis cinerea)
#> 9    Graufäule (Botrytis cinerea)
#> 10   Graufäule (Botrytis cinerea)
#> 11   Graufäule (Botrytis cinerea)
#> 12   Graufäule (Botrytis cinerea)
#> 13   Graufäule (Botrytis cinerea)
#> 14   Graufäule (Botrytis cinerea)
#> 15   Graufäule (Botrytis cinerea)
#> 16   Graufäule (Botrytis cinerea)
#> 17   Graufäule (Botrytis cinerea)
#> 18   Graufäule (Botrytis cinerea)
#> 19   Graufäule (Botrytis cinerea)
#> 20   Graufäule (Botrytis cinerea)
#> 21   Graufäule (Botrytis cinerea)
#> 22   Graufäule (Botrytis cinerea)
#> 23   Graufäule (Botrytis cinerea)
#> 24   Graufäule (Botrytis cinerea)
#> 25   Graufäule (Botrytis cinerea)
#> 26   Graufäule (Botrytis cinerea)
#> 27   Graufäule (Botrytis cinerea)
#> 28   Graufäule (Botrytis cinerea)
#> 29   Graufäule (Botrytis cinerea)
#> 30   Graufäule (Botrytis cinerea)
#> 31   Graufäule (Botrytis cinerea)
#> 32   Graufäule (Botrytis cinerea)
#> 33   Graufäule (Botrytis cinerea)
#> 34   Graufäule (Botrytis cinerea)
#> 35   Graufäule (Botrytis cinerea)
#> 36   Graufäule (Botrytis cinerea)
#> 37   Graufäule (Botrytis cinerea)
#> 38   Graufäule (Botrytis cinerea)
#> 39   Graufäule (Botrytis cinerea)
#> 40   Graufäule (Botrytis cinerea)
#> 41   Graufäule (Botrytis cinerea)
#> 42   Graufäule (Botrytis cinerea)
#> 43   Graufäule (Botrytis cinerea)
#> 44   Graufäule (Botrytis cinerea)
#> 45   Graufäule (Botrytis cinerea)
#> 46   Graufäule (Botrytis cinerea)
#> 47   Graufäule (Botrytis cinerea)
#> 48   Graufäule (Botrytis cinerea)
#> 49   Graufäule (Botrytis cinerea)
#> 50   Graufäule (Botrytis cinerea)
#> 51   Graufäule (Botrytis cinerea)
#> 52   Graufäule (Botrytis cinerea)
#> 53   Graufäule (Botrytis cinerea)
#> 54   Graufäule (Botrytis cinerea)
#> 55   Graufäule (Botrytis cinerea)
#> 56   Graufäule (Botrytis cinerea)
#> 57   Graufäule (Botrytis cinerea)
#> 58   Graufäule (Botrytis cinerea)
#> 59   Graufäule (Botrytis cinerea)
#> 60   Graufäule (Botrytis cinerea)
#> 61   Graufäule (Botrytis cinerea)
#> 62   Graufäule (Botrytis cinerea)
#> 63   Graufäule (Botrytis cinerea)
#> 64   Graufäule (Botrytis cinerea)
#> 65   Graufäule (Botrytis cinerea)
#> 66   Graufäule (Botrytis cinerea)
#> 67   Graufäule (Botrytis cinerea)
#> 68   Graufäule (Botrytis cinerea)
#> 69   Graufäule (Botrytis cinerea)
#> 70   Graufäule (Botrytis cinerea)
#> 71   Graufäule (Botrytis cinerea)
#> 72   Graufäule (Botrytis cinerea)
#> 73   Graufäule (Botrytis cinerea)
#> 74   Graufäule (Botrytis cinerea)
#> 75   Graufäule (Botrytis cinerea)
#> 76   Graufäule (Botrytis cinerea)
#> 77   Graufäule (Botrytis cinerea)
#> 78   Graufäule (Botrytis cinerea)
#> 79   Graufäule (Botrytis cinerea)
#> 80   Graufäule (Botrytis cinerea)
#> 81   Graufäule (Botrytis cinerea)
#> 82   Graufäule (Botrytis cinerea)
#> 83   Graufäule (Botrytis cinerea)
#> 84   Graufäule (Botrytis cinerea)
#> 85   Graufäule (Botrytis cinerea)
#> 86   Graufäule (Botrytis cinerea)
#> 87   Graufäule (Botrytis cinerea)
#> 88   Graufäule (Botrytis cinerea)
#> 89   Graufäule (Botrytis cinerea)
#> 90   Graufäule (Botrytis cinerea)
#> 91   Graufäule (Botrytis cinerea)
#> 92   Graufäule (Botrytis cinerea)
#> 93   Graufäule (Botrytis cinerea)
#> 94   Graufäule (Botrytis cinerea)
#> 95   Graufäule (Botrytis cinerea)
#> 96   Graufäule (Botrytis cinerea)
#> 97   Graufäule (Botrytis cinerea)
#> 98   Graufäule (Botrytis cinerea)
#> 99   Graufäule (Botrytis cinerea)
#> 100  Graufäule (Botrytis cinerea)
#> 101  Graufäule (Botrytis cinerea)
#> 102  Graufäule (Botrytis cinerea)
#> 103  Graufäule (Botrytis cinerea)
#> 104  Graufäule (Botrytis cinerea)
#> 105  Graufäule (Botrytis cinerea)
#> 106  Graufäule (Botrytis cinerea)
#> 107  Graufäule (Botrytis cinerea)
#> 108  Graufäule (Botrytis cinerea)
#> 109  Graufäule (Botrytis cinerea)
#> 110  Graufäule (Botrytis cinerea)
#> 111  Graufäule (Botrytis cinerea)
#> 112  Graufäule (Botrytis cinerea)
#> 113  Graufäule (Botrytis cinerea)
#> 114  Graufäule (Botrytis cinerea)
#> 115  Graufäule (Botrytis cinerea)
#> 116  Graufäule (Botrytis cinerea)
#> 117  Graufäule (Botrytis cinerea)
#> 118  Graufäule (Botrytis cinerea)
#> 119  Graufäule (Botrytis cinerea)
#> 120  Graufäule (Botrytis cinerea)
#> 121  Graufäule (Botrytis cinerea)
#> 122  Graufäule (Botrytis cinerea)
#> 123  Graufäule (Botrytis cinerea)
#> 124  Graufäule (Botrytis cinerea)
#> 125  Graufäule (Botrytis cinerea)
#> 126  Graufäule (Botrytis cinerea)
#> 127  Graufäule (Botrytis cinerea)
#> 128  Graufäule (Botrytis cinerea)
#> 129  Graufäule (Botrytis cinerea)
#> 130  Graufäule (Botrytis cinerea)
#> 131  Graufäule (Botrytis cinerea)
#> 132  Graufäule (Botrytis cinerea)
#> 133  Graufäule (Botrytis cinerea)
#> 134  Graufäule (Botrytis cinerea)
#> 135  Graufäule (Botrytis cinerea)
#> 136  Graufäule (Botrytis cinerea)
#> 137  Graufäule (Botrytis cinerea)
#> 138  Graufäule (Botrytis cinerea)
#> 139  Graufäule (Botrytis cinerea)
#> 140  Graufäule (Botrytis cinerea)
#> 141  Graufäule (Botrytis cinerea)
#> 142  Graufäule (Botrytis cinerea)
#> 143  Graufäule (Botrytis cinerea)
#> 144  Graufäule (Botrytis cinerea)
#> 145  Graufäule (Botrytis cinerea)
#> 146  Graufäule (Botrytis cinerea)
#> 147  Graufäule (Botrytis cinerea)
#> 148  Graufäule (Botrytis cinerea)
#> 149  Graufäule (Botrytis cinerea)
#> 150  Graufäule (Botrytis cinerea)
#> 151  Graufäule (Botrytis cinerea)
#> 152  Graufäule (Botrytis cinerea)
#> 153  Graufäule (Botrytis cinerea)
#> 154  Graufäule (Botrytis cinerea)
#> 155  Graufäule (Botrytis cinerea)
#> 156  Graufäule (Botrytis cinerea)
#> 157  Graufäule (Botrytis cinerea)
#> 158  Graufäule (Botrytis cinerea)
#> 159  Graufäule (Botrytis cinerea)
#> 160  Graufäule (Botrytis cinerea)
#> 161  Graufäule (Botrytis cinerea)
#> 162  Graufäule (Botrytis cinerea)
#> 163  Graufäule (Botrytis cinerea)
#> 164  Graufäule (Botrytis cinerea)
#> 165  Graufäule (Botrytis cinerea)
#> 166  Graufäule (Botrytis cinerea)
#> 167  Graufäule (Botrytis cinerea)
#> 168  Graufäule (Botrytis cinerea)
#> 169  Graufäule (Botrytis cinerea)
#> 170  Graufäule (Botrytis cinerea)
#> 171  Graufäule (Botrytis cinerea)
#> 172  Graufäule (Botrytis cinerea)
#> 173  Graufäule (Botrytis cinerea)
#> 174  Graufäule (Botrytis cinerea)
#> 175  Graufäule (Botrytis cinerea)
#> 176  Graufäule (Botrytis cinerea)
#> 177  Graufäule (Botrytis cinerea)
#> 178  Graufäule (Botrytis cinerea)
#> 179  Graufäule (Botrytis cinerea)
#> 180  Graufäule (Botrytis cinerea)
#> 181  Graufäule (Botrytis cinerea)
#> 182  Graufäule (Botrytis cinerea)
#> 183  Graufäule (Botrytis cinerea)
#> 184  Graufäule (Botrytis cinerea)
#> 185  Graufäule (Botrytis cinerea)
#> 186  Graufäule (Botrytis cinerea)
#> 187  Graufäule (Botrytis cinerea)
#> 188  Graufäule (Botrytis cinerea)
#> 189  Graufäule (Botrytis cinerea)
#> 190  Graufäule (Botrytis cinerea)
#> 191  Graufäule (Botrytis cinerea)
#> 192  Graufäule (Botrytis cinerea)
#> 193  Graufäule (Botrytis cinerea)
#> 194  Graufäule (Botrytis cinerea)
#> 195  Graufäule (Botrytis cinerea)
#> 196  Graufäule (Botrytis cinerea)
#> 197  Graufäule (Botrytis cinerea)
#> 198  Graufäule (Botrytis cinerea)
#> 199  Graufäule (Botrytis cinerea)
#> 200  Graufäule (Botrytis cinerea)
#> 201  Graufäule (Botrytis cinerea)
#> 202  Graufäule (Botrytis cinerea)
#> 203  Graufäule (Botrytis cinerea)
#> 204  Graufäule (Botrytis cinerea)
#> 205  Graufäule (Botrytis cinerea)
#> 206  Graufäule (Botrytis cinerea)
#> 207  Graufäule (Botrytis cinerea)
#> 208  Graufäule (Botrytis cinerea)
#> 209  Graufäule (Botrytis cinerea)
#> 210  Graufäule (Botrytis cinerea)
#> 211  Graufäule (Botrytis cinerea)
#> 212  Graufäule (Botrytis cinerea)
#> 213  Graufäule (Botrytis cinerea)
#> 214  Graufäule (Botrytis cinerea)
#> 215  Graufäule (Botrytis cinerea)
#> 216  Graufäule (Botrytis cinerea)
#> 217  Graufäule (Botrytis cinerea)
#> 218  Graufäule (Botrytis cinerea)
#> 219  Graufäule (Botrytis cinerea)
#> 220  Graufäule (Botrytis cinerea)
#> 221  Graufäule (Botrytis cinerea)
#> 222  Graufäule (Botrytis cinerea)
#> 223  Graufäule (Botrytis cinerea)
#> 224  Graufäule (Botrytis cinerea)
#> 225  Graufäule (Botrytis cinerea)
#> 226  Graufäule (Botrytis cinerea)
#> 227  Graufäule (Botrytis cinerea)
#> 228  Graufäule (Botrytis cinerea)
#> 229  Graufäule (Botrytis cinerea)
#> 230  Graufäule (Botrytis cinerea)
#> 231  Graufäule (Botrytis cinerea)
#> 232  Graufäule (Botrytis cinerea)
#> 233  Graufäule (Botrytis cinerea)
#> 234  Graufäule (Botrytis cinerea)
#> 235  Graufäule (Botrytis cinerea)
#> 236  Graufäule (Botrytis cinerea)
#> 237  Graufäule (Botrytis cinerea)
#> 238  Graufäule (Botrytis cinerea)
#> 239  Graufäule (Botrytis cinerea)
#> 240  Graufäule (Botrytis cinerea)
#> 241  Graufäule (Botrytis cinerea)
#> 242  Graufäule (Botrytis cinerea)
#> 243  Graufäule (Botrytis cinerea)
#> 244  Graufäule (Botrytis cinerea)
#> 245  Graufäule (Botrytis cinerea)
#> 246  Graufäule (Botrytis cinerea)
#> 247  Graufäule (Botrytis cinerea)
#> 248  Graufäule (Botrytis cinerea)
#> 249  Graufäule (Botrytis cinerea)
#> 250  Graufäule (Botrytis cinerea)
#> 251  Graufäule (Botrytis cinerea)
#> 252  Graufäule (Botrytis cinerea)
#> 253  Graufäule (Botrytis cinerea)
#> 254  Graufäule (Botrytis cinerea)
#> 255  Graufäule (Botrytis cinerea)
#> 256  Graufäule (Botrytis cinerea)
#> 257  Graufäule (Botrytis cinerea)
#> 258  Graufäule (Botrytis cinerea)
#> 259  Graufäule (Botrytis cinerea)
#> 260  Graufäule (Botrytis cinerea)
#> 261  Graufäule (Botrytis cinerea)
#> 262  Graufäule (Botrytis cinerea)
#> 263  Graufäule (Botrytis cinerea)
#> 264  Graufäule (Botrytis cinerea)
#> 265  Graufäule (Botrytis cinerea)
#> 266  Graufäule (Botrytis cinerea)
#> 267  Graufäule (Botrytis cinerea)
#> 268  Graufäule (Botrytis cinerea)
#> 269  Graufäule (Botrytis cinerea)
#> 270  Graufäule (Botrytis cinerea)
#> 271  Graufäule (Botrytis cinerea)
#> 272  Graufäule (Botrytis cinerea)
#> 273  Graufäule (Botrytis cinerea)
#> 274  Graufäule (Botrytis cinerea)
#> 275  Graufäule (Botrytis cinerea)
#> 276  Graufäule (Botrytis cinerea)
#> 277  Graufäule (Botrytis cinerea)
#> 278  Graufäule (Botrytis cinerea)
#> 279  Graufäule (Botrytis cinerea)
#> 280  Graufäule (Botrytis cinerea)
#> 281  Graufäule (Botrytis cinerea)
#> 282  Graufäule (Botrytis cinerea)
#> 283  Graufäule (Botrytis cinerea)
#> 284  Graufäule (Botrytis cinerea)
#> 285  Graufäule (Botrytis cinerea)
#> 286  Graufäule (Botrytis cinerea)
#> 287  Graufäule (Botrytis cinerea)
#> 288  Graufäule (Botrytis cinerea)
#> 289  Graufäule (Botrytis cinerea)
#> 290  Graufäule (Botrytis cinerea)
#> 291  Graufäule (Botrytis cinerea)
#> 292  Graufäule (Botrytis cinerea)
#> 293  Graufäule (Botrytis cinerea)
#> 294  Graufäule (Botrytis cinerea)
#> 295  Graufäule (Botrytis cinerea)
#> 296  Graufäule (Botrytis cinerea)
#> 297  Graufäule (Botrytis cinerea)
#> 298  Graufäule (Botrytis cinerea)
#> 299  Graufäule (Botrytis cinerea)
#> 300  Graufäule (Botrytis cinerea)
#> 301  Graufäule (Botrytis cinerea)
#> 302  Graufäule (Botrytis cinerea)
#> 303  Graufäule (Botrytis cinerea)
#> 304  Graufäule (Botrytis cinerea)
#> 305  Graufäule (Botrytis cinerea)
#> 306  Graufäule (Botrytis cinerea)
#> 307  Graufäule (Botrytis cinerea)
#> 308  Graufäule (Botrytis cinerea)
#> 309  Graufäule (Botrytis cinerea)
#> 310  Graufäule (Botrytis cinerea)
#> 311  Graufäule (Botrytis cinerea)
#> 312  Graufäule (Botrytis cinerea)
#> 313  Graufäule (Botrytis cinerea)
#> 314  Graufäule (Botrytis cinerea)
#> 315  Graufäule (Botrytis cinerea)
#> 316  Graufäule (Botrytis cinerea)
#> 317  Graufäule (Botrytis cinerea)
#> 318  Graufäule (Botrytis cinerea)
#> 319  Graufäule (Botrytis cinerea)
#> 320  Graufäule (Botrytis cinerea)
#> 321  Graufäule (Botrytis cinerea)
#> 322  Graufäule (Botrytis cinerea)
#> 323  Graufäule (Botrytis cinerea)
#> 324  Graufäule (Botrytis cinerea)
#> 325  Graufäule (Botrytis cinerea)
#> 326  Graufäule (Botrytis cinerea)
#> 327  Graufäule (Botrytis cinerea)
#> 328  Graufäule (Botrytis cinerea)
#> 329  Graufäule (Botrytis cinerea)
#> 330  Graufäule (Botrytis cinerea)
#> 331  Graufäule (Botrytis cinerea)
#> 332  Graufäule (Botrytis cinerea)
#> 333  Graufäule (Botrytis cinerea)
#> 334  Graufäule (Botrytis cinerea)
#> 335  Graufäule (Botrytis cinerea)
#> 336  Graufäule (Botrytis cinerea)
#> 337  Graufäule (Botrytis cinerea)
#> 338  Graufäule (Botrytis cinerea)
#> 339  Graufäule (Botrytis cinerea)
#> 340  Graufäule (Botrytis cinerea)
#> 341  Graufäule (Botrytis cinerea)
#> 342  Graufäule (Botrytis cinerea)
#> 343  Graufäule (Botrytis cinerea)
#> 344  Graufäule (Botrytis cinerea)
#> 345  Graufäule (Botrytis cinerea)
#> 346  Graufäule (Botrytis cinerea)
#> 347  Graufäule (Botrytis cinerea)
#> 348  Graufäule (Botrytis cinerea)
#> 349  Graufäule (Botrytis cinerea)
#> 350  Graufäule (Botrytis cinerea)
#> 351  Graufäule (Botrytis cinerea)
#> 352  Graufäule (Botrytis cinerea)
#> 353  Graufäule (Botrytis cinerea)
#> 354  Graufäule (Botrytis cinerea)
#> 355  Graufäule (Botrytis cinerea)
#> 356  Graufäule (Botrytis cinerea)
#> 357  Graufäule (Botrytis cinerea)
#> 358  Graufäule (Botrytis cinerea)
#> 359  Graufäule (Botrytis cinerea)
#> 360  Graufäule (Botrytis cinerea)
#> 361  Graufäule (Botrytis cinerea)
#> 362  Graufäule (Botrytis cinerea)
#> 363  Graufäule (Botrytis cinerea)
#> 364  Graufäule (Botrytis cinerea)
#> 365  Graufäule (Botrytis cinerea)
#> 366  Graufäule (Botrytis cinerea)
#> 367  Graufäule (Botrytis cinerea)
#> 368  Graufäule (Botrytis cinerea)
#> 369  Graufäule (Botrytis cinerea)
#> 370  Graufäule (Botrytis cinerea)
#> 371  Graufäule (Botrytis cinerea)
#> 372  Graufäule (Botrytis cinerea)
#> 373  Graufäule (Botrytis cinerea)
#> 374  Graufäule (Botrytis cinerea)
#> 375  Graufäule (Botrytis cinerea)
#> 376  Graufäule (Botrytis cinerea)
#> 377  Graufäule (Botrytis cinerea)
#> 378  Graufäule (Botrytis cinerea)
#> 379  Graufäule (Botrytis cinerea)
#> 380  Graufäule (Botrytis cinerea)
#> 381  Graufäule (Botrytis cinerea)
#> 382  Graufäule (Botrytis cinerea)
#> 383  Graufäule (Botrytis cinerea)
#> 384  Graufäule (Botrytis cinerea)
#> 385  Graufäule (Botrytis cinerea)
#> 386  Graufäule (Botrytis cinerea)
#> 387  Graufäule (Botrytis cinerea)
#> 388  Graufäule (Botrytis cinerea)
#> 389  Graufäule (Botrytis cinerea)
#> 390  Graufäule (Botrytis cinerea)
#> 391  Graufäule (Botrytis cinerea)
#> 392  Graufäule (Botrytis cinerea)
#> 393  Graufäule (Botrytis cinerea)
#> 394  Graufäule (Botrytis cinerea)
#> 395  Graufäule (Botrytis cinerea)
#> 396  Graufäule (Botrytis cinerea)
#> 397  Graufäule (Botrytis cinerea)
#> 398  Graufäule (Botrytis cinerea)
#> 399      Wegschnecken/Arion Arten
#> 400      Wegschnecken/Arion Arten
#> 401      Wegschnecken/Arion Arten
#> 402      Wegschnecken/Arion Arten
#> 403      Wegschnecken/Arion Arten
#> 404      Wegschnecken/Arion Arten
#> 405      Wegschnecken/Arion Arten
#> 406      Wegschnecken/Arion Arten
#> 407      Wegschnecken/Arion Arten
#> 408      Wegschnecken/Arion Arten
#> 409      Wegschnecken/Arion Arten
#> 410      Wegschnecken/Arion Arten
#> 411      Wegschnecken/Arion Arten
#> 412      Wegschnecken/Arion Arten
#> 413      Wegschnecken/Arion Arten
#> 414      Wegschnecken/Arion Arten
#> 415      Wegschnecken/Arion Arten
#> 416      Wegschnecken/Arion Arten
#> 417      Wegschnecken/Arion Arten
#> 418      Wegschnecken/Arion Arten
#> 419      Wegschnecken/Arion Arten
#> 420      Wegschnecken/Arion Arten
#> 421      Wegschnecken/Arion Arten
#> 422      Wegschnecken/Arion Arten
#> 423      Wegschnecken/Arion Arten
#> 424      Wegschnecken/Arion Arten
#> 425      Wegschnecken/Arion Arten
#> 426      Wegschnecken/Arion Arten
#> 427      Wegschnecken/Arion Arten
#> 428      Wegschnecken/Arion Arten
#> 429      Wegschnecken/Arion Arten
#> 430      Wegschnecken/Arion Arten
#> 431      Wegschnecken/Arion Arten
#> 432      Wegschnecken/Arion Arten
#> 433      Wegschnecken/Arion Arten
#> 434      Wegschnecken/Arion Arten
#> 435      Wegschnecken/Arion Arten
#> 436      Wegschnecken/Arion Arten
#> 437      Wegschnecken/Arion Arten
#> 438      Wegschnecken/Arion Arten
#> 439      Wegschnecken/Arion Arten
#> 440      Wegschnecken/Arion Arten
#> 441      Wegschnecken/Arion Arten
#> 442      Wegschnecken/Arion Arten
#> 443      Wegschnecken/Arion Arten
#> 444      Wegschnecken/Arion Arten
#> 445      Wegschnecken/Arion Arten
#> 446      Wegschnecken/Arion Arten
#> 447      Wegschnecken/Arion Arten
#> 448      Wegschnecken/Arion Arten
#> 449      Wegschnecken/Arion Arten
#> 450      Wegschnecken/Arion Arten
#> 451      Wegschnecken/Arion Arten
#> 452      Wegschnecken/Arion Arten
#> 453      Wegschnecken/Arion Arten
#> 454      Wegschnecken/Arion Arten
#> 455      Wegschnecken/Arion Arten
#> 456      Wegschnecken/Arion Arten
#> 457      Wegschnecken/Arion Arten
#> 458      Wegschnecken/Arion Arten
#> 459      Wegschnecken/Arion Arten
#> 460      Wegschnecken/Arion Arten
#> 461      Wegschnecken/Arion Arten
#> 462      Wegschnecken/Arion Arten
#> 463      Wegschnecken/Arion Arten
#> 464      Wegschnecken/Arion Arten
#> 465      Wegschnecken/Arion Arten
#> 466      Wegschnecken/Arion Arten
#> 467      Wegschnecken/Arion Arten
#> 468      Wegschnecken/Arion Arten
#> 469      Wegschnecken/Arion Arten
#> 470      Wegschnecken/Arion Arten
#> 471      Wegschnecken/Arion Arten
#> 472      Wegschnecken/Arion Arten
#> 473      Wegschnecken/Arion Arten
#> 474      Wegschnecken/Arion Arten
#> 475      Wegschnecken/Arion Arten
#> 476      Wegschnecken/Arion Arten
#> 477      Wegschnecken/Arion Arten
#> 478      Wegschnecken/Arion Arten
#> 479      Wegschnecken/Arion Arten
#> 480      Wegschnecken/Arion Arten
#> 481      Wegschnecken/Arion Arten
#> 482      Wegschnecken/Arion Arten
#> 483      Wegschnecken/Arion Arten
#> 484      Wegschnecken/Arion Arten
#> 485      Wegschnecken/Arion Arten
#> 486      Wegschnecken/Arion Arten
#> 487      Wegschnecken/Arion Arten
#> 488      Wegschnecken/Arion Arten
#> 489      Wegschnecken/Arion Arten
#> 490      Wegschnecken/Arion Arten
#> 491      Wegschnecken/Arion Arten
#> 492      Wegschnecken/Arion Arten
#> 493      Wegschnecken/Arion Arten
#> 494      Wegschnecken/Arion Arten
#> 495      Wegschnecken/Arion Arten
#> 496      Wegschnecken/Arion Arten
#> 497      Wegschnecken/Arion Arten
#> 498      Wegschnecken/Arion Arten
#> 499      Wegschnecken/Arion Arten
#> 500      Wegschnecken/Arion Arten
#> 501      Wegschnecken/Arion Arten
#> 502      Wegschnecken/Arion Arten
#> 503      Wegschnecken/Arion Arten
#> 504      Wegschnecken/Arion Arten
#> 505      Wegschnecken/Arion Arten
#> 506      Wegschnecken/Arion Arten
#> 507      Wegschnecken/Arion Arten
#> 508      Wegschnecken/Arion Arten
#> 509      Wegschnecken/Arion Arten
#> 510      Wegschnecken/Arion Arten
#> 511      Wegschnecken/Arion Arten
#> 512      Wegschnecken/Arion Arten
#> 513      Wegschnecken/Arion Arten
#> 514      Wegschnecken/Arion Arten
#> 515      Wegschnecken/Arion Arten
#> 516      Wegschnecken/Arion Arten
#> 517      Wegschnecken/Arion Arten
#> 518      Wegschnecken/Arion Arten
#> 519      Wegschnecken/Arion Arten
#> 520      Wegschnecken/Arion Arten
#> 521      Wegschnecken/Arion Arten
#> 522      Wegschnecken/Arion Arten
#> 523      Wegschnecken/Arion Arten
#> 524      Wegschnecken/Arion Arten
#> 525      Wegschnecken/Arion Arten
#> 526      Wegschnecken/Arion Arten
#> 527      Wegschnecken/Arion Arten
#> 528      Wegschnecken/Arion Arten
#> 529      Wegschnecken/Arion Arten
#> 530      Wegschnecken/Arion Arten
#> 531      Wegschnecken/Arion Arten
#> 532      Wegschnecken/Arion Arten
#> 533      Wegschnecken/Arion Arten
#> 534      Wegschnecken/Arion Arten
#> 535      Wegschnecken/Arion Arten
#> 536      Wegschnecken/Arion Arten
#> 537      Wegschnecken/Arion Arten
#> 538      Wegschnecken/Arion Arten
#> 539      Wegschnecken/Arion Arten
#> 540      Wegschnecken/Arion Arten
#> 541      Wegschnecken/Arion Arten
#> 542      Wegschnecken/Arion Arten
#> 543      Wegschnecken/Arion Arten
#> 544      Wegschnecken/Arion Arten
#> 545      Wegschnecken/Arion Arten
#> 546      Wegschnecken/Arion Arten
#> 547      Wegschnecken/Arion Arten
#> 548      Wegschnecken/Arion Arten
#> 549      Wegschnecken/Arion Arten
#> 550      Wegschnecken/Arion Arten
#> 551      Wegschnecken/Arion Arten
#> 552      Wegschnecken/Arion Arten
#> 553      Wegschnecken/Arion Arten
#> 554      Wegschnecken/Arion Arten
#> 555      Wegschnecken/Arion Arten
#> 556      Wegschnecken/Arion Arten
#> 557      Wegschnecken/Arion Arten
#> 558      Wegschnecken/Arion Arten
#> 559      Wegschnecken/Arion Arten
#> 560      Wegschnecken/Arion Arten
#> 561      Wegschnecken/Arion Arten
#> 562      Wegschnecken/Arion Arten
#> 563      Wegschnecken/Arion Arten
#> 564      Wegschnecken/Arion Arten
#> 565      Wegschnecken/Arion Arten
#> 566      Wegschnecken/Arion Arten
#> 567      Wegschnecken/Arion Arten
#> 568      Wegschnecken/Arion Arten
#> 569      Wegschnecken/Arion Arten
#> 570      Wegschnecken/Arion Arten
#> 571      Wegschnecken/Arion Arten
#> 572      Wegschnecken/Arion Arten
#> 573      Wegschnecken/Arion Arten
#> 574      Wegschnecken/Arion Arten
#> 575      Wegschnecken/Arion Arten
#> 576      Wegschnecken/Arion Arten
#> 577      Wegschnecken/Arion Arten
#> 578      Wegschnecken/Arion Arten
#> 579      Wegschnecken/Arion Arten
#> 580      Wegschnecken/Arion Arten
#> 581      Wegschnecken/Arion Arten
#> 582      Wegschnecken/Arion Arten
#> 583      Wegschnecken/Arion Arten
#> 584      Wegschnecken/Arion Arten
#> 585      Wegschnecken/Arion Arten
#> 586      Wegschnecken/Arion Arten
#> 587      Wegschnecken/Arion Arten
#> 588      Wegschnecken/Arion Arten
#> 589      Wegschnecken/Arion Arten
#> 590      Wegschnecken/Arion Arten
#> 591      Wegschnecken/Arion Arten
#> 592      Wegschnecken/Arion Arten
#> 593      Wegschnecken/Arion Arten
#> 594      Wegschnecken/Arion Arten
#> 595      Wegschnecken/Arion Arten
#> 596      Wegschnecken/Arion Arten
#> 597      Wegschnecken/Arion Arten
#> 598      Wegschnecken/Arion Arten
#> 599      Wegschnecken/Arion Arten
#> 600      Wegschnecken/Arion Arten
#> 601      Wegschnecken/Arion Arten
#> 602      Wegschnecken/Arion Arten
#> 603      Wegschnecken/Arion Arten
#> 604      Wegschnecken/Arion Arten
#> 605      Wegschnecken/Arion Arten
#> 606      Wegschnecken/Arion Arten
#> 607      Wegschnecken/Arion Arten
#> 608      Wegschnecken/Arion Arten
#> 609      Wegschnecken/Arion Arten
#> 610      Wegschnecken/Arion Arten
#> 611      Wegschnecken/Arion Arten
#> 612      Wegschnecken/Arion Arten
#> 613      Wegschnecken/Arion Arten
#> 614      Wegschnecken/Arion Arten
#> 615      Wegschnecken/Arion Arten
#> 616      Wegschnecken/Arion Arten
#> 617      Wegschnecken/Arion Arten
#> 618      Wegschnecken/Arion Arten
#> 619      Wegschnecken/Arion Arten
#> 620      Wegschnecken/Arion Arten
#> 621      Wegschnecken/Arion Arten
#> 622      Wegschnecken/Arion Arten
#> 623      Wegschnecken/Arion Arten
#> 624      Wegschnecken/Arion Arten
#> 625      Wegschnecken/Arion Arten
#> 626      Wegschnecken/Arion Arten
#> 627      Wegschnecken/Arion Arten
#> 628      Wegschnecken/Arion Arten
#> 629      Wegschnecken/Arion Arten
#> 630      Wegschnecken/Arion Arten
#> 631      Wegschnecken/Arion Arten
#> 632      Wegschnecken/Arion Arten
#> 633      Wegschnecken/Arion Arten
#> 634      Wegschnecken/Arion Arten
#> 635      Wegschnecken/Arion Arten
#> 636      Wegschnecken/Arion Arten
#> 637      Wegschnecken/Arion Arten
#> 638      Wegschnecken/Arion Arten
#> 639      Wegschnecken/Arion Arten
#> 640      Wegschnecken/Arion Arten
#> 641      Wegschnecken/Arion Arten
#> 642      Wegschnecken/Arion Arten
#> 643      Wegschnecken/Arion Arten
#> 644      Wegschnecken/Arion Arten
#> 645      Wegschnecken/Arion Arten
#> 646      Wegschnecken/Arion Arten
#> 647      Wegschnecken/Arion Arten
#> 648      Wegschnecken/Arion Arten
#> 649      Wegschnecken/Arion Arten
#> 650      Wegschnecken/Arion Arten
#> 651      Wegschnecken/Arion Arten
#> 652      Wegschnecken/Arion Arten
#> 653      Wegschnecken/Arion Arten
#> 654      Wegschnecken/Arion Arten
#> 655      Wegschnecken/Arion Arten
#> 656      Wegschnecken/Arion Arten
#> 657      Wegschnecken/Arion Arten
#> 658      Wegschnecken/Arion Arten
#> 659      Wegschnecken/Arion Arten
#> 660      Wegschnecken/Arion Arten
#> 661      Wegschnecken/Arion Arten
#> 662      Wegschnecken/Arion Arten
#> 663      Wegschnecken/Arion Arten
#> 664      Wegschnecken/Arion Arten
#> 665      Wegschnecken/Arion Arten
#> 666      Wegschnecken/Arion Arten
#> 667      Wegschnecken/Arion Arten
#> 668      Wegschnecken/Arion Arten
#> 669      Wegschnecken/Arion Arten
#> 670      Wegschnecken/Arion Arten
#> 671      Wegschnecken/Arion Arten
#> 672      Wegschnecken/Arion Arten
#> 673      Wegschnecken/Arion Arten
#> 674      Wegschnecken/Arion Arten
#> 675      Wegschnecken/Arion Arten
#> 676      Wegschnecken/Arion Arten
#> 677      Wegschnecken/Arion Arten
#> 678      Wegschnecken/Arion Arten
#> 679      Wegschnecken/Arion Arten
#> 680      Wegschnecken/Arion Arten
#> 681      Wegschnecken/Arion Arten
#> 682      Wegschnecken/Arion Arten
#> 683      Wegschnecken/Arion Arten
#> 684      Wegschnecken/Arion Arten
#> 685      Wegschnecken/Arion Arten
#> 686      Wegschnecken/Arion Arten
#> 687      Wegschnecken/Arion Arten
#> 688      Wegschnecken/Arion Arten
#> 689      Wegschnecken/Arion Arten
#> 690      Wegschnecken/Arion Arten
#> 691      Wegschnecken/Arion Arten
#> 692      Wegschnecken/Arion Arten
#> 693      Wegschnecken/Arion Arten
#> 694      Wegschnecken/Arion Arten
#> 695      Wegschnecken/Arion Arten
#> 696      Wegschnecken/Arion Arten
#> 697      Wegschnecken/Arion Arten
#> 698      Wegschnecken/Arion Arten
#> 699      Wegschnecken/Arion Arten
#> 700      Wegschnecken/Arion Arten
#> 701      Wegschnecken/Arion Arten
#> 702      Wegschnecken/Arion Arten
#> 703      Wegschnecken/Arion Arten
#> 704      Wegschnecken/Arion Arten
#> 705      Wegschnecken/Arion Arten
#> 706      Wegschnecken/Arion Arten
#> 707      Wegschnecken/Arion Arten
#> 708      Wegschnecken/Arion Arten
#> 709      Wegschnecken/Arion Arten
#> 710      Wegschnecken/Arion Arten
#> 711      Wegschnecken/Arion Arten
#> 712      Wegschnecken/Arion Arten
#> 713      Wegschnecken/Arion Arten
#> 714      Wegschnecken/Arion Arten
#> 715      Wegschnecken/Arion Arten
#> 716      Wegschnecken/Arion Arten
#> 717      Wegschnecken/Arion Arten
#> 718      Wegschnecken/Arion Arten
#> 719      Wegschnecken/Arion Arten
#> 720      Wegschnecken/Arion Arten
#> 721      Wegschnecken/Arion Arten
#> 722      Wegschnecken/Arion Arten
#> 723      Wegschnecken/Arion Arten
#> 724      Wegschnecken/Arion Arten
#> 725      Wegschnecken/Arion Arten
#> 726      Wegschnecken/Arion Arten
#> 727      Wegschnecken/Arion Arten
#> 728      Wegschnecken/Arion Arten
#> 729      Wegschnecken/Arion Arten
#> 730      Wegschnecken/Arion Arten
#> 731      Wegschnecken/Arion Arten
#> 732      Wegschnecken/Arion Arten
#> 733      Wegschnecken/Arion Arten
#> 734      Wegschnecken/Arion Arten
#> 735      Wegschnecken/Arion Arten
#> 736      Wegschnecken/Arion Arten
#> 737      Wegschnecken/Arion Arten
#> 738      Wegschnecken/Arion Arten
#> 739      Wegschnecken/Arion Arten
#> 740      Wegschnecken/Arion Arten
#> 741      Wegschnecken/Arion Arten
#> 742      Wegschnecken/Arion Arten
#> 743      Wegschnecken/Arion Arten
#> 744      Wegschnecken/Arion Arten
#> 745      Wegschnecken/Arion Arten
#> 746      Wegschnecken/Arion Arten
#> 747      Wegschnecken/Arion Arten
#> 748      Wegschnecken/Arion Arten
#> 749      Wegschnecken/Arion Arten
#> 750      Wegschnecken/Arion Arten
#> 751      Wegschnecken/Arion Arten
#> 752      Wegschnecken/Arion Arten
#> 753      Wegschnecken/Arion Arten
#> 754      Wegschnecken/Arion Arten
#> 755      Wegschnecken/Arion Arten
#> 756      Wegschnecken/Arion Arten
#> 757      Wegschnecken/Arion Arten
#> 758      Wegschnecken/Arion Arten
#> 759      Wegschnecken/Arion Arten
#> 760      Wegschnecken/Arion Arten
#> 761      Wegschnecken/Arion Arten
#> 762      Wegschnecken/Arion Arten
#> 763      Wegschnecken/Arion Arten
#> 764      Wegschnecken/Arion Arten
#> 765      Wegschnecken/Arion Arten
#> 766      Wegschnecken/Arion Arten
#> 767      Wegschnecken/Arion Arten
#> 768      Wegschnecken/Arion Arten
#> 769      Wegschnecken/Arion Arten
#> 770      Wegschnecken/Arion Arten
#> 771      Wegschnecken/Arion Arten
#> 772      Wegschnecken/Arion Arten
#> 773      Wegschnecken/Arion Arten
#> 774      Wegschnecken/Arion Arten
#> 775      Wegschnecken/Arion Arten
#> 776      Wegschnecken/Arion Arten
#> 777      Wegschnecken/Arion Arten
#> 778      Wegschnecken/Arion Arten
#> 779      Wegschnecken/Arion Arten
#> 780      Wegschnecken/Arion Arten
#> 781      Wegschnecken/Arion Arten
#> 782      Wegschnecken/Arion Arten
#> 783      Wegschnecken/Arion Arten
#> 784      Wegschnecken/Arion Arten
#> 785      Wegschnecken/Arion Arten
#> 786      Wegschnecken/Arion Arten
#> 787      Wegschnecken/Arion Arten
#> 788      Wegschnecken/Arion Arten
#> 789      Wegschnecken/Arion Arten
#> 790      Wegschnecken/Arion Arten
#> 791      Wegschnecken/Arion Arten
#> 792      Wegschnecken/Arion Arten
#> 793      Wegschnecken/Arion Arten
#> 794      Wegschnecken/Arion Arten
#> 795      Wegschnecken/Arion Arten
#> 796      Wegschnecken/Arion Arten
#> 797      Wegschnecken/Arion Arten
#> 798      Wegschnecken/Arion Arten
#> 799      Wegschnecken/Arion Arten
#> 800      Wegschnecken/Arion Arten
#> 801      Wegschnecken/Arion Arten
#> 802      Wegschnecken/Arion Arten
#> 803      Wegschnecken/Arion Arten
#> 804      Wegschnecken/Arion Arten
#> 805      Wegschnecken/Arion Arten
#> 806      Wegschnecken/Arion Arten
#> 807      Wegschnecken/Arion Arten
#> 808      Wegschnecken/Arion Arten
#> 809      Wegschnecken/Arion Arten
#> 810      Wegschnecken/Arion Arten
#> 811      Wegschnecken/Arion Arten
#> 812      Wegschnecken/Arion Arten
#> 813      Wegschnecken/Arion Arten
#> 814      Wegschnecken/Arion Arten
#> 815      Wegschnecken/Arion Arten
#> 816      Wegschnecken/Arion Arten
#> 817      Wegschnecken/Arion Arten
#> 818      Wegschnecken/Arion Arten
#> 819      Wegschnecken/Arion Arten
#> 820      Wegschnecken/Arion Arten
#> 821      Wegschnecken/Arion Arten
#> 822      Wegschnecken/Arion Arten
#> 823      Wegschnecken/Arion Arten
#> 824      Wegschnecken/Arion Arten
#> 825      Wegschnecken/Arion Arten
#> 826      Wegschnecken/Arion Arten
#> 827      Wegschnecken/Arion Arten
#> 828      Wegschnecken/Arion Arten
#> 829      Wegschnecken/Arion Arten
#> 830      Wegschnecken/Arion Arten
#> 831      Wegschnecken/Arion Arten
#> 832      Wegschnecken/Arion Arten
#> 833      Wegschnecken/Arion Arten
#> 834      Wegschnecken/Arion Arten
#> 835      Wegschnecken/Arion Arten
#> 836      Wegschnecken/Arion Arten
#> 837      Wegschnecken/Arion Arten
#> 838      Wegschnecken/Arion Arten
#> 839      Wegschnecken/Arion Arten
#> 840      Wegschnecken/Arion Arten
#> 841      Wegschnecken/Arion Arten
#> 842      Wegschnecken/Arion Arten
#> 843      Wegschnecken/Arion Arten
#> 844      Wegschnecken/Arion Arten
#> 845      Wegschnecken/Arion Arten
#> 846      Wegschnecken/Arion Arten
#> 847      Wegschnecken/Arion Arten
#> 848      Wegschnecken/Arion Arten
#> 849      Wegschnecken/Arion Arten
#> 850      Wegschnecken/Arion Arten
#> 851      Wegschnecken/Arion Arten
#> 852      Wegschnecken/Arion Arten
#> 853      Wegschnecken/Arion Arten
#> 854      Wegschnecken/Arion Arten
#> 855      Wegschnecken/Arion Arten
#> 856      Wegschnecken/Arion Arten
#> 857      Wegschnecken/Arion Arten
#> 858      Wegschnecken/Arion Arten
#> 859      Wegschnecken/Arion Arten
#> 860      Wegschnecken/Arion Arten
#> 861      Wegschnecken/Arion Arten
#> 862      Wegschnecken/Arion Arten
#> 863      Wegschnecken/Arion Arten
#> 864      Wegschnecken/Arion Arten
#> 865      Wegschnecken/Arion Arten
#> 866      Wegschnecken/Arion Arten
#> 867      Wegschnecken/Arion Arten
#> 868      Wegschnecken/Arion Arten
#> 869      Wegschnecken/Arion Arten
#> 870      Wegschnecken/Arion Arten
#> 871      Wegschnecken/Arion Arten
#> 872      Wegschnecken/Arion Arten
#> 873      Wegschnecken/Arion Arten
#> 874      Wegschnecken/Arion Arten
#> 875      Wegschnecken/Arion Arten
#> 876      Wegschnecken/Arion Arten
#> 877      Wegschnecken/Arion Arten
#> 878      Wegschnecken/Arion Arten
#> 879      Wegschnecken/Arion Arten
#> 880      Wegschnecken/Arion Arten
#> 881      Wegschnecken/Arion Arten
#> 882      Wegschnecken/Arion Arten
#> 883      Wegschnecken/Arion Arten
#> 884      Wegschnecken/Arion Arten
#> 885      Wegschnecken/Arion Arten
#> 886      Wegschnecken/Arion Arten
#> 887      Wegschnecken/Arion Arten
#> 888      Wegschnecken/Arion Arten
#> 889      Wegschnecken/Arion Arten
#> 890      Wegschnecken/Arion Arten
#> 891      Wegschnecken/Arion Arten
#> 892      Wegschnecken/Arion Arten
#> 893      Wegschnecken/Arion Arten
#> 894      Wegschnecken/Arion Arten
#> 895      Wegschnecken/Arion Arten
#> 896      Wegschnecken/Arion Arten
#> 897      Wegschnecken/Arion Arten
#> 898      Wegschnecken/Arion Arten
#> 899      Wegschnecken/Arion Arten
#> 900      Wegschnecken/Arion Arten
#> 901      Wegschnecken/Arion Arten
#> 902      Wegschnecken/Arion Arten
#> 903      Wegschnecken/Arion Arten
#> 904      Wegschnecken/Arion Arten
#> 905      Wegschnecken/Arion Arten
#> 906      Wegschnecken/Arion Arten
#> 907      Wegschnecken/Arion Arten
#> 908      Wegschnecken/Arion Arten
#> 909      Wegschnecken/Arion Arten
#> 910      Wegschnecken/Arion Arten
#> 911      Wegschnecken/Arion Arten
#> 912      Wegschnecken/Arion Arten
#> 913      Wegschnecken/Arion Arten
#> 914      Wegschnecken/Arion Arten
#> 915      Wegschnecken/Arion Arten
#> 916      Wegschnecken/Arion Arten
#> 917      Wegschnecken/Arion Arten
#> 918      Wegschnecken/Arion Arten
#> 919      Wegschnecken/Arion Arten
#> 920      Wegschnecken/Arion Arten
#> 921      Wegschnecken/Arion Arten
#> 922      Wegschnecken/Arion Arten
#> 923      Wegschnecken/Arion Arten
#> 924      Wegschnecken/Arion Arten
#> 925      Wegschnecken/Arion Arten
#> 926      Wegschnecken/Arion Arten
#> 927      Wegschnecken/Arion Arten
#> 928      Wegschnecken/Arion Arten
#> 929      Wegschnecken/Arion Arten
#> 930      Wegschnecken/Arion Arten
#> 931      Wegschnecken/Arion Arten
#> 932      Wegschnecken/Arion Arten
#> 933      Wegschnecken/Arion Arten
#> 934      Wegschnecken/Arion Arten
#> 935      Wegschnecken/Arion Arten
#> 936      Wegschnecken/Arion Arten
#> 937      Wegschnecken/Arion Arten
#> 938      Wegschnecken/Arion Arten
#> 939      Wegschnecken/Arion Arten
#> 940      Wegschnecken/Arion Arten
#> 941      Wegschnecken/Arion Arten
#> 942      Wegschnecken/Arion Arten
#> 943      Wegschnecken/Arion Arten
#> 944      Wegschnecken/Arion Arten
#> 945      Wegschnecken/Arion Arten
#> 946      Wegschnecken/Arion Arten
#> 947      Wegschnecken/Arion Arten
#> 948      Wegschnecken/Arion Arten
#> 949      Wegschnecken/Arion Arten
#> 950      Wegschnecken/Arion Arten
#> 951      Wegschnecken/Arion Arten
#> 952      Wegschnecken/Arion Arten
#> 953      Wegschnecken/Arion Arten
#> 954      Wegschnecken/Arion Arten
#> 955      Wegschnecken/Arion Arten
#> 956      Wegschnecken/Arion Arten
#> 957      Wegschnecken/Arion Arten
#> 958      Wegschnecken/Arion Arten
#> 959      Wegschnecken/Arion Arten
#> 960      Wegschnecken/Arion Arten
#> 961      Wegschnecken/Arion Arten
#> 962      Wegschnecken/Arion Arten
#> 963      Wegschnecken/Arion Arten
#> 964      Wegschnecken/Arion Arten
#> 965      Wegschnecken/Arion Arten
#> 966      Wegschnecken/Arion Arten
#> 967      Wegschnecken/Arion Arten
#> 968      Wegschnecken/Arion Arten
#> 969      Wegschnecken/Arion Arten
#> 970      Wegschnecken/Arion Arten
#> 971      Wegschnecken/Arion Arten
#> 972      Wegschnecken/Arion Arten
#> 973      Wegschnecken/Arion Arten
#> 974      Wegschnecken/Arion Arten
#> 975      Wegschnecken/Arion Arten
#> 976      Wegschnecken/Arion Arten
#> 977      Wegschnecken/Arion Arten
#> 978      Wegschnecken/Arion Arten
#> 979      Wegschnecken/Arion Arten
#> 980      Wegschnecken/Arion Arten
#> 981      Wegschnecken/Arion Arten
#> 982      Wegschnecken/Arion Arten
#> 983      Wegschnecken/Arion Arten
#> 984      Wegschnecken/Arion Arten
#> 985      Wegschnecken/Arion Arten
#> 986      Wegschnecken/Arion Arten
#> 987      Wegschnecken/Arion Arten
#> 988      Wegschnecken/Arion Arten
#> 989      Wegschnecken/Arion Arten
#> 990      Wegschnecken/Arion Arten
#> 991      Wegschnecken/Arion Arten
#> 992      Wegschnecken/Arion Arten
#> 993      Wegschnecken/Arion Arten
#> 994      Wegschnecken/Arion Arten
#> 995      Wegschnecken/Arion Arten
#> 996      Wegschnecken/Arion Arten
#> 997      Wegschnecken/Arion Arten
#> 998      Wegschnecken/Arion Arten
#> 999      Wegschnecken/Arion Arten
#> 1000     Wegschnecken/Arion Arten
#> 1001     Wegschnecken/Arion Arten
#> 1002     Wegschnecken/Arion Arten
#> 1003     Wegschnecken/Arion Arten
#> 1004     Wegschnecken/Arion Arten
#> 1005     Wegschnecken/Arion Arten
#> 1006     Wegschnecken/Arion Arten
#> 1007     Wegschnecken/Arion Arten
#> 1008     Wegschnecken/Arion Arten
#> 1009     Wegschnecken/Arion Arten
#> 1010     Wegschnecken/Arion Arten
#> 1011     Wegschnecken/Arion Arten
#> 1012     Wegschnecken/Arion Arten
#> 1013     Wegschnecken/Arion Arten
#> 1014     Wegschnecken/Arion Arten
#> 1015     Wegschnecken/Arion Arten
#> 1016     Wegschnecken/Arion Arten
#> 1017     Wegschnecken/Arion Arten
#> 1018     Wegschnecken/Arion Arten
#> 1019     Wegschnecken/Arion Arten
#> 1020     Wegschnecken/Arion Arten
#> 1021     Wegschnecken/Arion Arten
#> 1022     Wegschnecken/Arion Arten
#> 1023     Wegschnecken/Arion Arten
#> 1024     Wegschnecken/Arion Arten
#> 1025     Wegschnecken/Arion Arten
#> 1026     Wegschnecken/Arion Arten
#> 1027     Wegschnecken/Arion Arten
#> 1028     Wegschnecken/Arion Arten
#> 1029     Wegschnecken/Arion Arten
#> 1030     Wegschnecken/Arion Arten
#> 1031     Wegschnecken/Arion Arten
#> 1032     Wegschnecken/Arion Arten
#> 1033     Wegschnecken/Arion Arten
#> 1034     Wegschnecken/Arion Arten
#> 1035     Wegschnecken/Arion Arten
#> 1036     Wegschnecken/Arion Arten
#> 1037     Wegschnecken/Arion Arten
#> 1038     Wegschnecken/Arion Arten
#> 1039     Wegschnecken/Arion Arten
#> 1040     Wegschnecken/Arion Arten
#> 1041     Wegschnecken/Arion Arten
#> 1042     Wegschnecken/Arion Arten
#> 1043     Wegschnecken/Arion Arten
#> 1044     Wegschnecken/Arion Arten
#> 1045     Wegschnecken/Arion Arten
#> 1046     Wegschnecken/Arion Arten
#> 1047     Wegschnecken/Arion Arten
#> 1048     Wegschnecken/Arion Arten
#> 1049     Wegschnecken/Arion Arten
#> 1050     Wegschnecken/Arion Arten
#> 1051     Wegschnecken/Arion Arten
#> 1052     Wegschnecken/Arion Arten
#> 1053     Wegschnecken/Arion Arten
#> 1054     Wegschnecken/Arion Arten
#> 1055     Wegschnecken/Arion Arten
#> 1056     Wegschnecken/Arion Arten
#> 1057     Wegschnecken/Arion Arten
#> 1058     Wegschnecken/Arion Arten
#> 1059     Wegschnecken/Arion Arten
#> 1060     Wegschnecken/Arion Arten
#> 1061     Wegschnecken/Arion Arten
#> 1062     Wegschnecken/Arion Arten
#> 1063     Wegschnecken/Arion Arten
#> 1064     Wegschnecken/Arion Arten
#> 1065     Wegschnecken/Arion Arten
#> 1066     Wegschnecken/Arion Arten
#> 1067     Wegschnecken/Arion Arten
#> 1068     Wegschnecken/Arion Arten
#> 1069     Wegschnecken/Arion Arten
#> 1070     Wegschnecken/Arion Arten
#> 1071     Wegschnecken/Arion Arten
#> 1072     Wegschnecken/Arion Arten
#> 1073     Wegschnecken/Arion Arten
#> 1074     Wegschnecken/Arion Arten
#> 1075     Wegschnecken/Arion Arten
#> 1076     Wegschnecken/Arion Arten
#> 1077     Wegschnecken/Arion Arten
#> 1078     Wegschnecken/Arion Arten
#> 1079     Wegschnecken/Arion Arten
#> 1080     Wegschnecken/Arion Arten
#> 1081     Wegschnecken/Arion Arten
#> 1082     Wegschnecken/Arion Arten
#> 1083     Wegschnecken/Arion Arten
#> 1084     Wegschnecken/Arion Arten
#> 1085     Wegschnecken/Arion Arten
#> 1086     Wegschnecken/Arion Arten
#> 1087     Wegschnecken/Arion Arten
#> 1088     Wegschnecken/Arion Arten
#> 1089     Wegschnecken/Arion Arten
#> 1090     Wegschnecken/Arion Arten
#> 1091     Wegschnecken/Arion Arten
#> 1092     Wegschnecken/Arion Arten
#> 1093     Wegschnecken/Arion Arten
#> 1094     Wegschnecken/Arion Arten
#> 1095     Wegschnecken/Arion Arten
#> 1096     Wegschnecken/Arion Arten
#> 1097     Wegschnecken/Arion Arten
#> 1098     Wegschnecken/Arion Arten
#> 1099     Wegschnecken/Arion Arten
#> 1100     Wegschnecken/Arion Arten
#> 1101     Wegschnecken/Arion Arten
#> 1102     Wegschnecken/Arion Arten
#> 1103     Wegschnecken/Arion Arten
#> 1104     Wegschnecken/Arion Arten
#> 1105     Wegschnecken/Arion Arten
#> 1106     Wegschnecken/Arion Arten
#> 1107     Wegschnecken/Arion Arten
#> 1108     Wegschnecken/Arion Arten
#> 1109     Wegschnecken/Arion Arten
#> 1110     Wegschnecken/Arion Arten
#> 1111     Wegschnecken/Arion Arten
#> 1112     Wegschnecken/Arion Arten
#> 1113     Wegschnecken/Arion Arten
#> 1114     Wegschnecken/Arion Arten
#> 1115     Wegschnecken/Arion Arten
#> 1116     Wegschnecken/Arion Arten
#> 1117     Wegschnecken/Arion Arten
#> 1118     Wegschnecken/Arion Arten
#> 1119     Wegschnecken/Arion Arten
#> 1120     Wegschnecken/Arion Arten
#> 1121     Wegschnecken/Arion Arten
#> 1122     Wegschnecken/Arion Arten
#> 1123     Wegschnecken/Arion Arten
#> 1124     Wegschnecken/Arion Arten
#> 1125     Wegschnecken/Arion Arten
#> 1126     Wegschnecken/Arion Arten
#> 1127     Wegschnecken/Arion Arten
#> 1128     Wegschnecken/Arion Arten
#> 1129     Wegschnecken/Arion Arten
#> 1130     Wegschnecken/Arion Arten
#> 1131     Wegschnecken/Arion Arten
#> 1132     Wegschnecken/Arion Arten
#> 1133     Wegschnecken/Arion Arten
#> 1134     Wegschnecken/Arion Arten
#> 1135     Wegschnecken/Arion Arten
#> 1136     Wegschnecken/Arion Arten
#> 1137     Wegschnecken/Arion Arten
#> 1138     Wegschnecken/Arion Arten
#> 1139     Wegschnecken/Arion Arten
#> 1140     Wegschnecken/Arion Arten
#> 1141     Wegschnecken/Arion Arten
#> 1142     Wegschnecken/Arion Arten
#> 1143     Wegschnecken/Arion Arten
#> 1144     Wegschnecken/Arion Arten
#> 1145     Wegschnecken/Arion Arten
#> 1146     Wegschnecken/Arion Arten
#> 1147     Wegschnecken/Arion Arten
#> 1148     Wegschnecken/Arion Arten
#> 1149     Wegschnecken/Arion Arten
#> 1150     Wegschnecken/Arion Arten
#> 1151     Wegschnecken/Arion Arten
#> 1152     Wegschnecken/Arion Arten
#> 1153     Wegschnecken/Arion Arten
#> 1154     Wegschnecken/Arion Arten
#> 1155     Wegschnecken/Arion Arten
#> 1156     Wegschnecken/Arion Arten
#> 1157     Wegschnecken/Arion Arten
#> 1158     Wegschnecken/Arion Arten
#> 1159     Wegschnecken/Arion Arten
#> 1160     Wegschnecken/Arion Arten
#> 1161     Wegschnecken/Arion Arten
#> 1162     Wegschnecken/Arion Arten
#> 1163     Wegschnecken/Arion Arten
#> 1164     Wegschnecken/Arion Arten
#> 1165     Wegschnecken/Arion Arten
#> 1166     Wegschnecken/Arion Arten
#> 1167     Wegschnecken/Arion Arten
#> 1168     Wegschnecken/Arion Arten
#> 1169     Wegschnecken/Arion Arten
#> 1170     Wegschnecken/Arion Arten
#> 1171     Wegschnecken/Arion Arten
#> 1172     Wegschnecken/Arion Arten
#> 1173     Wegschnecken/Arion Arten
#> 1174     Wegschnecken/Arion Arten
#> 1175     Wegschnecken/Arion Arten
#> 1176     Wegschnecken/Arion Arten
#> 1177     Wegschnecken/Arion Arten
#> 1178     Wegschnecken/Arion Arten
#> 1179     Wegschnecken/Arion Arten
#> 1180     Wegschnecken/Arion Arten
#> 1181     Wegschnecken/Arion Arten
#> 1182     Wegschnecken/Arion Arten
#> 1183     Wegschnecken/Arion Arten
#> 1184     Wegschnecken/Arion Arten
#> 1185     Wegschnecken/Arion Arten
#> 1186     Wegschnecken/Arion Arten
#> 1187     Wegschnecken/Arion Arten
#> 1188     Wegschnecken/Arion Arten
#> 1189     Wegschnecken/Arion Arten
#> 1190     Wegschnecken/Arion Arten
#> 1191     Wegschnecken/Arion Arten
#> 1192     Wegschnecken/Arion Arten
#>                                                           leaf_culture_de
#> 1                                                               Brombeere
#> 2                                                              Sommerflor
#> 3                                                Baby-Leaf (Brassicaceae)
#> 4                                              Baby-Leaf (Chenopodiaceae)
#> 5                                                  Baby-Leaf (Asteraceae)
#> 6                                                                  Hopfen
#> 7                                                       Erbsen mit Hülsen
#> 8                                                               Knoblauch
#> 9                                                         Wintertriticale
#> 10                                                  Tomaten Spezialitäten
#> 11                                                             Zuckerrübe
#> 12                                                             Futterrübe
#> 13                                                          Wassermelonen
#> 14                                                            Sonnenblume
#> 15                                                               Peperoni
#> 16                                                          Gemüsepaprika
#> 17                                                                   Ysop
#> 18                                                         Knollenfenchel
#> 19                                                              Koriander
#> 20                                                                Oregano
#> 21                                                                 Quitte
#> 22                                                                  Apfel
#> 23                                                                  Birne
#> 24                                                     Bohnen ohne Hülsen
#> 25                                                              Eberesche
#> 26                        Liegendes Rundholz im Wald und auf Lagerplätzen
#> 27                                                               Rosmarin
#> 28                                           Tabak produzierende Betriebe
#> 29                                                         Suppensellerie
#> 30                                                          Brunnenkresse
#> 31                                                                   Wald
#> 32                                                             Petersilie
#> 33                                                           Artischocken
#> 34                                                          Cherrytomaten
#> 35                                                             Blumenkohl
#> 36                                          Kleegrasmischung (Kunstwiese)
#> 37                                                                Stachys
#> 38                                                       Wurzelpetersilie
#> 39                                                            Kichererbse
#> 40                                                               Ranunkel
#> 41                                                           Ertragsreben
#> 42                                                              Jungreben
#> 43                                                          Einlegegurken
#> 44                                                              Zwetschge
#> 45                                                                Pflaume
#> 46                                                             Grünfläche
#> 47                                                              Löwenzahn
#> 48                                                       Römische Kamille
#> 49                                                          Spitzwegerich
#> 50                                                              Rhabarber
#> 51                                                                Sorghum
#> 52                                                           Winterweizen
#> 53                                                           Winterroggen
#> 54                                                          Korn (Dinkel)
#> 55                                                                  Emmer
#> 56                                                 Leere Produktionsräume
#> 57                                                           Ertragsreben
#> 58                                                                Begonia
#> 59                                                                Cyclame
#> 60                                                            Pelargonien
#> 61                                                                Primeln
#> 62                                                               Karotten
#> 63                                                                 Kerbel
#> 64                                                                Begonia
#> 65                                                           Rosskastanie
#> 66                                                             Zierkürbis
#> 67                                                   Pfirsich / Nektarine
#> 68                                                               Baldrian
#> 69                                                          Einlegegurken
#> 70                                                         Nostranogurken
#> 71                                                      Gewächshausgurken
#> 72                                                                Azaleen
#> 73                                                                  Kardy
#> 74                                                              Kopfsalat
#> 75                                                           Schnittsalat
#> 76                                                               Patisson
#> 77                                                           Chrysantheme
#> 78                                                    Schwarze Apfelbeere
#> 79                                                                Anemone
#> 80                                                        Stangensellerie
#> 81                                                                  Minze
#> 82                                                               Pak-Choi
#> 83                                                                Melonen
#> 84                                                           Stachelbeere
#> 85                                                                Azaleen
#> 86                                                             Baumschule
#> 87                                                              Basilikum
#> 88                                                     Verarbeitungsräume
#> 89                                                                Lupinen
#> 90                                                                  Birne
#> 91                                                     Schwarzer Holunder
#> 92                                                              Rosenkohl
#> 93                                                              Kopfkohle
#> 94                                                               Kohlrabi
#> 95                                                             Blumenkohl
#> 96                                                              Romanesco
#> 97                                                               Broccoli
#> 98                                                               Pak-Choi
#> 99                                                          Markstammkohl
#> 100                                                             Chinakohl
#> 101                                                             Federkohl
#> 102                                                             Brombeere
#> 103                                                              Himbeere
#> 104                                               Forstliche Pflanzgärten
#> 105                                                          Stangenbohne
#> 106                                                          Sommerweizen
#> 107                                                          Sommergerste
#> 108                                                           Sommerhafer
#> 109                                              Einrichtungen und Geräte
#> 110                                                             Aubergine
#> 111                                                            Andenbeere
#> 112                                                                Pepino
#> 113                                                              Peperoni
#> 114                                                         Gemüsepaprika
#> 115                                                 Tomaten Spezialitäten
#> 116                                                         Cherrytomaten
#> 117                                                         Rispentomaten
#> 118                                                              Peperoni
#> 119                                                 Färberdistel (Saflor)
#> 120                                                            Blumenkohl
#> 121                                                             Romanesco
#> 122                                                              Broccoli
#> 123                                                           Chinaschilf
#> 124                                              leere Verarbeitungsräume
#> 125                                                               Lorbeer
#> 126                                                           Bohnenkraut
#> 127                                                             Kopfsalat
#> 128                                         Kleegrasmischung (Kunstwiese)
#> 129                                                Schwarze Johannisbeere
#> 130                                                             Jungreben
#> 131                                                           Mulchsaaten
#> 132                                                            Zuckermais
#> 133                                                                 Linse
#> 134                                                       Knollensellerie
#> 135                                                             Puffbohne
#> 136                                 Speisekürbisse (ungeniessbare Schale)
#> 137                                                            Winterraps
#> 138                                                             Blautanne
#> 139                                                  Zier- und Sportrasen
#> 140                                                     Erbsen mit Hülsen
#> 141                                                    Erbsen ohne Hülsen
#> 142                                                             Hyazinthe
#> 143                                                          Wintergerste
#> 144                                                              Endivien
#> 145                                            Klee zur Saatgutproduktion
#> 146                                                            Ackerbohne
#> 147                                                             Zwetschge
#> 148                                                         Gemüsepaprika
#> 149                                    Kartoffeln zur Pflanzgutproduktion
#> 150                                              Baby-Leaf (Brassicaceae)
#> 151                                                             Aubergine
#> 152                                                                 Kenaf
#> 153                                                               Walnuss
#> 154                                                       Hartschalenobst
#> 155                                                              Pak-Choi
#> 156                                                         Markstammkohl
#> 157                                                             Chinakohl
#> 158                                                             Federkohl
#> 159                                                               Majoran
#> 160                                                            Kerbelrübe
#> 161                                                               Thymian
#> 162                                                            Andenbeere
#> 163                                     Holzpaletten, Packholz, Stammholz
#> 164                                                            Zierkürbis
#> 165                                                             Hyazinthe
#> 166                                                                  Iris
#> 167                                         Liliengewächse (Zierpflanzen)
#> 168                                                                 Tulpe
#> 169                                                        Gemüseportulak
#> 170                                                            Hartweizen
#> 171                                                       Weihnachtsbäume
#> 172                                                                 Rande
#> 173                                                          Winterweizen
#> 174                                            Gehölze (ausserhalb Forst)
#> 175                                                             Rosenkohl
#> 176                                                                Kresse
#> 177                                                      leere Lagerräume
#> 178                                                          Eiweisserbse
#> 179                                                          Wintergerste
#> 180                                                                Roggen
#> 181                                                         Markstammkohl
#> 182                                                                Kümmel
#> 183                                                            Hartweizen
#> 184                                                           Weichweizen
#> 185                                                                 Tabak
#> 186                                                         Wassermelonen
#> 187                                                               Melonen
#> 188                                 Speisekürbisse (ungeniessbare Schale)
#> 189                                                            Ölkürbisse
#> 190                                                         Einlegegurken
#> 191                                                        Nostranogurken
#> 192                                                     Gewächshausgurken
#> 193                                                              Patisson
#> 194                                                             Zucchetti
#> 195                                                               Rondini
#> 196                                                                Nelken
#> 197                                                         Gemüsezwiebel
#> 198                                                         Gewürzfenchel
#> 199                                                             Brombeere
#> 200                                                          Bundzwiebeln
#> 201                                                        Gemüseportulak
#> 202                                                             Romanesco
#> 203                                                                Roggen
#> 204                                                                 Hafer
#> 205                                                       Wintertriticale
#> 206                                                          Winterweizen
#> 207                                                          Winterroggen
#> 208                                                         Korn (Dinkel)
#> 209                                                                 Emmer
#> 210                                                          Sommerweizen
#> 211                                                          Sommergerste
#> 212                                                           Sommerhafer
#> 213                                                          Wintergerste
#> 214                                                            Hartweizen
#> 215                                                           Weichweizen
#> 216                                                    Offene Ackerfläche
#> 217                                                              Endivien
#> 218                                                             Zuckerhut
#> 219                                         Radicchio- und Cicorino-Typen
#> 220                                                                 Lauch
#> 221                                                              Pflanzen
#> 222                                                                Radies
#> 223                                                    Rote Johannisbeere
#> 224                                                                  Dill
#> 225                                                            Krautstiel
#> 226                                          Speise- und Futterkartoffeln
#> 227                                                            Buschbohne
#> 228                                                                Spinat
#> 229                                                             Zuckerhut
#> 230                                                    Traubensilberkerze
#> 231                                                           Trockenreis
#> 232                                                         Schwarzwurzel
#> 233                                                               Cyclame
#> 234                                                           Nüsslisalat
#> 235                                                                  Mohn
#> 236                                                                  Lein
#> 237                                                              Aprikose
#> 238                                                                 Olive
#> 239                                            Baby-Leaf (Chenopodiaceae)
#> 240                                                               Pflaume
#> 241                                                               Gerbera
#> 242                                                          Schnittsalat
#> 243                                                             Sojabohne
#> 244                                      Blumenzwiebeln und Blumenknollen
#> 245                                                                 Rosen
#> 246                                                                Salbei
#> 247                                                   Brassica rapa-Rüben
#> 248                                                             Rosenwurz
#> 249                                                         Kirschlorbeer
#> 250  Böschungen und Grünstreifen entlang von Verkehrswegen (gem. ChemRRV)
#> 251                                                           Speisepilze
#> 252                                                             Süssdolde
#> 253                                                             Gojibeere
#> 254                                                          Schnittsalat
#> 255                                                           Liebstöckel
#> 256                                                                  Iris
#> 257                                                    Bohnen ohne Hülsen
#> 258                                                          Stangenbohne
#> 259                                                            Buschbohne
#> 260                                                           Heidelbeere
#> 261                                                            Krautstiel
#> 262                                                        Schnittmangold
#> 263                                                              Estragon
#> 264                                      Lagerhallen, Mühlen, Silogebäude
#> 265                                                             Brachland
#> 266                                                         Johanniskraut
#> 267                                                               Dahlien
#> 268                                                        Nostranogurken
#> 269                                                             Kopfsalat
#> 270                                    Kartoffeln zur Pflanzgutproduktion
#> 271                                          Speise- und Futterkartoffeln
#> 272                                         Radicchio- und Cicorino-Typen
#> 273                                                            Zuckerrübe
#> 274                                            Asia-Salate (Brassicaceae)
#> 275                                                          Sommerweizen
#> 276                                                          Winterroggen
#> 277                                                           Pelargonien
#> 278                                                        Schnittmangold
#> 279                                         Liliengewächse (Zierpflanzen)
#> 280                                                   Blaue Heckenkirsche
#> 281                                                              Broccoli
#> 282                                                          Barbarakraut
#> 283                                                          Humusdeponie
#> 284                                                               Rettich
#> 285                                                            Ölkürbisse
#> 286                                                            Topinambur
#> 287                                                          Stachelbeere
#> 288                                                Schwarze Johannisbeere
#> 289                                                    Rote Johannisbeere
#> 290                                                            Jostabeere
#> 291                                                   Brassica rapa-Rüben
#> 292                                                          Sommergerste
#> 293                                                             Zucchetti
#> 294                                                          Cima di Rapa
#> 295                                                             Chinakohl
#> 296                                                    Wolliger Fingerhut
#> 297               Auf und an National- und Kantonsstrassen (gem. ChemRRV)
#> 298                                                    Erbsen ohne Hülsen
#> 299                                                            Sommerflor
#> 300                                                            Futterrübe
#> 301                                                         Speisezwiebel
#> 302                                                                Brache
#> 303                                                               Spargel
#> 304                                                           Sommerhafer
#> 305                                                             Kopfkohle
#> 306                                                  Pfirsich / Nektarine
#> 307                                                              Aprikose
#> 308                                                               Kirsche
#> 309                                                             Zwetschge
#> 310                                                               Pflaume
#> 311                                                             Mini-Kiwi
#> 312                                                              Erntegut
#> 313                                                                Rucola
#> 314                                                              Erdbeere
#> 315                                    Grasbestände zur Saatgutproduktion
#> 316                                                     Gewächshausgurken
#> 317                                                       Wintertriticale
#> 318                                                               Kirsche
#> 319                                                         Rispentomaten
#> 320                                                    Schwarze Maulbeere
#> 321                                                              Sanddorn
#> 322                                                        Suppensellerie
#> 323                                                       Stangensellerie
#> 324                                                       Knollensellerie
#> 325                                                               Luzerne
#> 326                                                         Korn (Dinkel)
#> 327                                                           Weichweizen
#> 328                                Bäume und Sträucher (ausserhalb Forst)
#> 329                                                               Melisse
#> 330                                                                  Ysop
#> 331                                                             Koriander
#> 332                                                              Rosmarin
#> 333                                                            Petersilie
#> 334                                                      Römische Kamille
#> 335                                                                Kerbel
#> 336                                                                 Minze
#> 337                                                             Basilikum
#> 338                                                           Bohnenkraut
#> 339                                                               Thymian
#> 340                                                                Kümmel
#> 341                                                                  Dill
#> 342                                                                Salbei
#> 343                                                           Liebstöckel
#> 344                                                              Estragon
#> 345                                                          Schnittlauch
#> 346                                                   Gemeine Felsenbirne
#> 347                                                              Himbeere
#> 348                                                              Kohlrabi
#> 349                                                                Fichte
#> 350                                                              Stielmus
#> 351                                                            Blaudistel
#> 352                                                Baby-Leaf (Asteraceae)
#> 353                                                         Gemüsezwiebel
#> 354                                                          Bundzwiebeln
#> 355                                                         Speisezwiebel
#> 356                                                    Buchsbäume (Buxus)
#> 357                                                             Federkohl
#> 358                                                              Gladiole
#> 359                                                            Frässaaten
#> 360                                                            Winterraps
#> 361                                                              Chicorée
#> 362                                                             Löwenzahn
#> 363                                                              Endivien
#> 364                                                             Zuckerhut
#> 365                                         Radicchio- und Cicorino-Typen
#> 366                                                             Kopfsalat
#> 367                                                          Schnittsalat
#> 368                                                               Primeln
#> 369                                                    Wolliger Fingerhut
#> 370                                                 Tomaten Spezialitäten
#> 371                                                         Cherrytomaten
#> 372                                                         Rispentomaten
#> 373                                                                  Hanf
#> 374                                                           Meerrettich
#> 375                                                         Bodenkohlrabi
#> 376                                                            Hagebutten
#> 377                                                             Pastinake
#> 378                                                         Süsskartoffel
#> 379                                                            Lagerräume
#> 380                                        Ziergehölze (ausserhalb Forst)
#> 381                                                                Pepino
#> 382                                                               Rondini
#> 383                                                            Schalotten
#> 384                                                                 Emmer
#> 385                                                          Stangenbohne
#> 386                                                            Buschbohne
#> 387                                                                 Hafer
#> 388                                                                  Mais
#> 389                                                                 Birne
#> 390                                                          Schnittlauch
#> 391                                                               Stauden
#> 392                                                                Quitte
#> 393                                                                 Apfel
#> 394                                                              Patisson
#> 395                                                             Zucchetti
#> 396                                                               Rondini
#> 397                                                                 Tulpe
#> 398                                                            Jostabeere
#> 399                                                            Sommerflor
#> 400                                              Baby-Leaf (Brassicaceae)
#> 401                                            Baby-Leaf (Chenopodiaceae)
#> 402                                                Baby-Leaf (Asteraceae)
#> 403                                                                Hopfen
#> 404                                                     Erbsen mit Hülsen
#> 405                                                             Knoblauch
#> 406                                                       Wintertriticale
#> 407                                                 Tomaten Spezialitäten
#> 408                                                            Zuckerrübe
#> 409                                                            Futterrübe
#> 410                                                         Wassermelonen
#> 411                                                           Sonnenblume
#> 412                                                              Peperoni
#> 413                                                         Gemüsepaprika
#> 414                                                                  Ysop
#> 415                                                        Knollenfenchel
#> 416                                                             Koriander
#> 417                                                               Oregano
#> 418                                                                Quitte
#> 419                                                                 Apfel
#> 420                                                                 Birne
#> 421                                                    Bohnen ohne Hülsen
#> 422                                                             Eberesche
#> 423                       Liegendes Rundholz im Wald und auf Lagerplätzen
#> 424                                                              Rosmarin
#> 425                                          Tabak produzierende Betriebe
#> 426                                                        Suppensellerie
#> 427                                                         Brunnenkresse
#> 428                                                                  Wald
#> 429                                                            Petersilie
#> 430                                                          Artischocken
#> 431                                                         Cherrytomaten
#> 432                                                            Blumenkohl
#> 433                                         Kleegrasmischung (Kunstwiese)
#> 434                                                               Stachys
#> 435                                                      Wurzelpetersilie
#> 436                                                           Kichererbse
#> 437                                                              Ranunkel
#> 438                                                          Ertragsreben
#> 439                                                             Jungreben
#> 440                                                         Einlegegurken
#> 441                                                             Zwetschge
#> 442                                                               Pflaume
#> 443                                                            Grünfläche
#> 444                                                             Löwenzahn
#> 445                                                      Römische Kamille
#> 446                                                         Spitzwegerich
#> 447                                                             Rhabarber
#> 448                                                               Sorghum
#> 449                                                          Winterweizen
#> 450                                                          Winterroggen
#> 451                                                         Korn (Dinkel)
#> 452                                                                 Emmer
#> 453                                                Leere Produktionsräume
#> 454                                                          Ertragsreben
#> 455                                                               Begonia
#> 456                                                               Cyclame
#> 457                                                           Pelargonien
#> 458                                                               Primeln
#> 459                                                              Karotten
#> 460                                                                Kerbel
#> 461                                                               Begonia
#> 462                                                          Rosskastanie
#> 463                                                            Zierkürbis
#> 464                                                  Pfirsich / Nektarine
#> 465                                                              Baldrian
#> 466                                                         Einlegegurken
#> 467                                                        Nostranogurken
#> 468                                                     Gewächshausgurken
#> 469                                                               Azaleen
#> 470                                                                 Kardy
#> 471                                                             Kopfsalat
#> 472                                                          Schnittsalat
#> 473                                                              Patisson
#> 474                                                          Chrysantheme
#> 475                                                   Schwarze Apfelbeere
#> 476                                                               Anemone
#> 477                                                       Stangensellerie
#> 478                                                                 Minze
#> 479                                                              Pak-Choi
#> 480                                                               Melonen
#> 481                                                          Stachelbeere
#> 482                                                               Azaleen
#> 483                                                            Baumschule
#> 484                                                             Basilikum
#> 485                                                    Verarbeitungsräume
#> 486                                                               Lupinen
#> 487                                                                 Birne
#> 488                                                    Schwarzer Holunder
#> 489                                                             Rosenkohl
#> 490                                                             Kopfkohle
#> 491                                                              Kohlrabi
#> 492                                                            Blumenkohl
#> 493                                                             Romanesco
#> 494                                                              Broccoli
#> 495                                                              Pak-Choi
#> 496                                                         Markstammkohl
#> 497                                                             Chinakohl
#> 498                                                             Federkohl
#> 499                                                             Brombeere
#> 500                                                              Himbeere
#> 501                                               Forstliche Pflanzgärten
#> 502                                                          Stangenbohne
#> 503                                                          Sommerweizen
#> 504                                                          Sommergerste
#> 505                                                           Sommerhafer
#> 506                                              Einrichtungen und Geräte
#> 507                                                             Aubergine
#> 508                                                            Andenbeere
#> 509                                                                Pepino
#> 510                                                              Peperoni
#> 511                                                         Gemüsepaprika
#> 512                                                 Tomaten Spezialitäten
#> 513                                                         Cherrytomaten
#> 514                                                         Rispentomaten
#> 515                                                              Peperoni
#> 516                                                 Färberdistel (Saflor)
#> 517                                                            Blumenkohl
#> 518                                                             Romanesco
#> 519                                                              Broccoli
#> 520                                                           Chinaschilf
#> 521                                              leere Verarbeitungsräume
#> 522                                                               Lorbeer
#> 523                                                           Bohnenkraut
#> 524                                                             Kopfsalat
#> 525                                         Kleegrasmischung (Kunstwiese)
#> 526                                                Schwarze Johannisbeere
#> 527                                                             Jungreben
#> 528                                                           Mulchsaaten
#> 529                                                            Zuckermais
#> 530                                                                 Linse
#> 531                                                       Knollensellerie
#> 532                                                             Puffbohne
#> 533                                 Speisekürbisse (ungeniessbare Schale)
#> 534                                                            Winterraps
#> 535                                                             Blautanne
#> 536                                                  Zier- und Sportrasen
#> 537                                                     Erbsen mit Hülsen
#> 538                                                    Erbsen ohne Hülsen
#> 539                                                             Hyazinthe
#> 540                                                          Wintergerste
#> 541                                                              Endivien
#> 542                                            Klee zur Saatgutproduktion
#> 543                                                            Ackerbohne
#> 544                                                             Zwetschge
#> 545                                                         Gemüsepaprika
#> 546                                    Kartoffeln zur Pflanzgutproduktion
#> 547                                              Baby-Leaf (Brassicaceae)
#> 548                                                             Aubergine
#> 549                                                                 Kenaf
#> 550                                                               Walnuss
#> 551                                                       Hartschalenobst
#> 552                                                              Pak-Choi
#> 553                                                         Markstammkohl
#> 554                                                             Chinakohl
#> 555                                                             Federkohl
#> 556                                                               Majoran
#> 557                                                            Kerbelrübe
#> 558                                                               Thymian
#> 559                                                            Andenbeere
#> 560                                     Holzpaletten, Packholz, Stammholz
#> 561                                                            Zierkürbis
#> 562                                                             Hyazinthe
#> 563                                                                  Iris
#> 564                                         Liliengewächse (Zierpflanzen)
#> 565                                                                 Tulpe
#> 566                                                        Gemüseportulak
#> 567                                                            Hartweizen
#> 568                                                       Weihnachtsbäume
#> 569                                                                 Rande
#> 570                                                          Winterweizen
#> 571                                            Gehölze (ausserhalb Forst)
#> 572                                                             Rosenkohl
#> 573                                                                Kresse
#> 574                                                      leere Lagerräume
#> 575                                                          Eiweisserbse
#> 576                                                          Wintergerste
#> 577                                                                Roggen
#> 578                                                         Markstammkohl
#> 579                                                                Kümmel
#> 580                                                            Hartweizen
#> 581                                                           Weichweizen
#> 582                                                                 Tabak
#> 583                                                         Wassermelonen
#> 584                                                               Melonen
#> 585                                 Speisekürbisse (ungeniessbare Schale)
#> 586                                                            Ölkürbisse
#> 587                                                         Einlegegurken
#> 588                                                        Nostranogurken
#> 589                                                     Gewächshausgurken
#> 590                                                              Patisson
#> 591                                                             Zucchetti
#> 592                                                               Rondini
#> 593                                                                Nelken
#> 594                                                         Gemüsezwiebel
#> 595                                                         Gewürzfenchel
#> 596                                                             Brombeere
#> 597                                                          Bundzwiebeln
#> 598                                                        Gemüseportulak
#> 599                                                             Romanesco
#> 600                                                                Roggen
#> 601                                                                 Hafer
#> 602                                                       Wintertriticale
#> 603                                                          Winterweizen
#> 604                                                          Winterroggen
#> 605                                                         Korn (Dinkel)
#> 606                                                                 Emmer
#> 607                                                          Sommerweizen
#> 608                                                          Sommergerste
#> 609                                                           Sommerhafer
#> 610                                                          Wintergerste
#> 611                                                            Hartweizen
#> 612                                                           Weichweizen
#> 613                                                    Offene Ackerfläche
#> 614                                                              Endivien
#> 615                                                             Zuckerhut
#> 616                                         Radicchio- und Cicorino-Typen
#> 617                                                                 Lauch
#> 618                                                              Pflanzen
#> 619                                                                Radies
#> 620                                                    Rote Johannisbeere
#> 621                                                                  Dill
#> 622                                                            Krautstiel
#> 623                                          Speise- und Futterkartoffeln
#> 624                                                            Buschbohne
#> 625                                                                Spinat
#> 626                                                             Zuckerhut
#> 627                                                    Traubensilberkerze
#> 628                                                           Trockenreis
#> 629                                                         Schwarzwurzel
#> 630                                                               Cyclame
#> 631                                                           Nüsslisalat
#> 632                                                                  Mohn
#> 633                                                                  Lein
#> 634                                                              Aprikose
#> 635                                                                 Olive
#> 636                                            Baby-Leaf (Chenopodiaceae)
#> 637                                                               Pflaume
#> 638                                                               Gerbera
#> 639                                                          Schnittsalat
#> 640                                                             Sojabohne
#> 641                                      Blumenzwiebeln und Blumenknollen
#> 642                                                                 Rosen
#> 643                                                                Salbei
#> 644                                                   Brassica rapa-Rüben
#> 645                                                             Rosenwurz
#> 646                                                         Kirschlorbeer
#> 647  Böschungen und Grünstreifen entlang von Verkehrswegen (gem. ChemRRV)
#> 648                                                           Speisepilze
#> 649                                                             Süssdolde
#> 650                                                             Gojibeere
#> 651                                                          Schnittsalat
#> 652                                                           Liebstöckel
#> 653                                                                  Iris
#> 654                                                    Bohnen ohne Hülsen
#> 655                                                          Stangenbohne
#> 656                                                            Buschbohne
#> 657                                                           Heidelbeere
#> 658                                                            Krautstiel
#> 659                                                        Schnittmangold
#> 660                                                              Estragon
#> 661                                      Lagerhallen, Mühlen, Silogebäude
#> 662                                                             Brachland
#> 663                                                         Johanniskraut
#> 664                                                               Dahlien
#> 665                                                        Nostranogurken
#> 666                                                             Kopfsalat
#> 667                                    Kartoffeln zur Pflanzgutproduktion
#> 668                                          Speise- und Futterkartoffeln
#> 669                                         Radicchio- und Cicorino-Typen
#> 670                                                            Zuckerrübe
#> 671                                            Asia-Salate (Brassicaceae)
#> 672                                                          Sommerweizen
#> 673                                                          Winterroggen
#> 674                                                           Pelargonien
#> 675                                                        Schnittmangold
#> 676                                         Liliengewächse (Zierpflanzen)
#> 677                                                   Blaue Heckenkirsche
#> 678                                                              Broccoli
#> 679                                                          Barbarakraut
#> 680                                                          Humusdeponie
#> 681                                                               Rettich
#> 682                                                            Ölkürbisse
#> 683                                                            Topinambur
#> 684                                                          Stachelbeere
#> 685                                                Schwarze Johannisbeere
#> 686                                                    Rote Johannisbeere
#> 687                                                            Jostabeere
#> 688                                                   Brassica rapa-Rüben
#> 689                                                          Sommergerste
#> 690                                                             Zucchetti
#> 691                                                          Cima di Rapa
#> 692                                                             Chinakohl
#> 693                                                    Wolliger Fingerhut
#> 694               Auf und an National- und Kantonsstrassen (gem. ChemRRV)
#> 695                                                    Erbsen ohne Hülsen
#> 696                                                            Sommerflor
#> 697                                                            Futterrübe
#> 698                                                         Speisezwiebel
#> 699                                                                Brache
#> 700                                                               Spargel
#> 701                                                           Sommerhafer
#> 702                                                             Kopfkohle
#> 703                                                  Pfirsich / Nektarine
#> 704                                                              Aprikose
#> 705                                                               Kirsche
#> 706                                                             Zwetschge
#> 707                                                               Pflaume
#> 708                                                             Mini-Kiwi
#> 709                                                              Erntegut
#> 710                                                                Rucola
#> 711                                                              Erdbeere
#> 712                                    Grasbestände zur Saatgutproduktion
#> 713                                                     Gewächshausgurken
#> 714                                                       Wintertriticale
#> 715                                                               Kirsche
#> 716                                                         Rispentomaten
#> 717                                                    Schwarze Maulbeere
#> 718                                                              Sanddorn
#> 719                                                        Suppensellerie
#> 720                                                       Stangensellerie
#> 721                                                       Knollensellerie
#> 722                                                               Luzerne
#> 723                                                         Korn (Dinkel)
#> 724                                                           Weichweizen
#> 725                                Bäume und Sträucher (ausserhalb Forst)
#> 726                                                               Melisse
#> 727                                                                  Ysop
#> 728                                                             Koriander
#> 729                                                              Rosmarin
#> 730                                                            Petersilie
#> 731                                                      Römische Kamille
#> 732                                                                Kerbel
#> 733                                                                 Minze
#> 734                                                             Basilikum
#> 735                                                           Bohnenkraut
#> 736                                                               Thymian
#> 737                                                                Kümmel
#> 738                                                                  Dill
#> 739                                                                Salbei
#> 740                                                           Liebstöckel
#> 741                                                              Estragon
#> 742                                                          Schnittlauch
#> 743                                                   Gemeine Felsenbirne
#> 744                                                              Himbeere
#> 745                                                              Kohlrabi
#> 746                                                                Fichte
#> 747                                                              Stielmus
#> 748                                                            Blaudistel
#> 749                                                Baby-Leaf (Asteraceae)
#> 750                                                         Gemüsezwiebel
#> 751                                                          Bundzwiebeln
#> 752                                                         Speisezwiebel
#> 753                                                    Buchsbäume (Buxus)
#> 754                                                             Federkohl
#> 755                                                              Gladiole
#> 756                                                            Frässaaten
#> 757                                                            Winterraps
#> 758                                                              Chicorée
#> 759                                                             Löwenzahn
#> 760                                                              Endivien
#> 761                                                             Zuckerhut
#> 762                                         Radicchio- und Cicorino-Typen
#> 763                                                             Kopfsalat
#> 764                                                          Schnittsalat
#> 765                                                               Primeln
#> 766                                                    Wolliger Fingerhut
#> 767                                                 Tomaten Spezialitäten
#> 768                                                         Cherrytomaten
#> 769                                                         Rispentomaten
#> 770                                                                  Hanf
#> 771                                                           Meerrettich
#> 772                                                         Bodenkohlrabi
#> 773                                                            Hagebutten
#> 774                                                             Pastinake
#> 775                                                         Süsskartoffel
#> 776                                                            Lagerräume
#> 777                                        Ziergehölze (ausserhalb Forst)
#> 778                                                                Pepino
#> 779                                                               Rondini
#> 780                                                            Schalotten
#> 781                                                                 Emmer
#> 782                                                          Stangenbohne
#> 783                                                            Buschbohne
#> 784                                                                 Hafer
#> 785                                                                  Mais
#> 786                                                                 Birne
#> 787                                                          Schnittlauch
#> 788                                                               Stauden
#> 789                                                                Quitte
#> 790                                                                 Apfel
#> 791                                                              Patisson
#> 792                                                             Zucchetti
#> 793                                                               Rondini
#> 794                                                                 Tulpe
#> 795                                                            Jostabeere
#> 796                                                            Sommerflor
#> 797                                              Baby-Leaf (Brassicaceae)
#> 798                                            Baby-Leaf (Chenopodiaceae)
#> 799                                                Baby-Leaf (Asteraceae)
#> 800                                                                Hopfen
#> 801                                                     Erbsen mit Hülsen
#> 802                                                             Knoblauch
#> 803                                                       Wintertriticale
#> 804                                                 Tomaten Spezialitäten
#> 805                                                            Zuckerrübe
#> 806                                                            Futterrübe
#> 807                                                         Wassermelonen
#> 808                                                           Sonnenblume
#> 809                                                              Peperoni
#> 810                                                         Gemüsepaprika
#> 811                                                                  Ysop
#> 812                                                        Knollenfenchel
#> 813                                                             Koriander
#> 814                                                               Oregano
#> 815                                                                Quitte
#> 816                                                                 Apfel
#> 817                                                                 Birne
#> 818                                                    Bohnen ohne Hülsen
#> 819                                                             Eberesche
#> 820                       Liegendes Rundholz im Wald und auf Lagerplätzen
#> 821                                                              Rosmarin
#> 822                                          Tabak produzierende Betriebe
#> 823                                                        Suppensellerie
#> 824                                                         Brunnenkresse
#> 825                                                                  Wald
#> 826                                                            Petersilie
#> 827                                                          Artischocken
#> 828                                                         Cherrytomaten
#> 829                                                            Blumenkohl
#> 830                                         Kleegrasmischung (Kunstwiese)
#> 831                                                               Stachys
#> 832                                                      Wurzelpetersilie
#> 833                                                           Kichererbse
#> 834                                                              Ranunkel
#> 835                                                          Ertragsreben
#> 836                                                             Jungreben
#> 837                                                         Einlegegurken
#> 838                                                             Zwetschge
#> 839                                                               Pflaume
#> 840                                                            Grünfläche
#> 841                                                             Löwenzahn
#> 842                                                      Römische Kamille
#> 843                                                         Spitzwegerich
#> 844                                                             Rhabarber
#> 845                                                               Sorghum
#> 846                                                          Winterweizen
#> 847                                                          Winterroggen
#> 848                                                         Korn (Dinkel)
#> 849                                                                 Emmer
#> 850                                                Leere Produktionsräume
#> 851                                                          Ertragsreben
#> 852                                                               Begonia
#> 853                                                               Cyclame
#> 854                                                           Pelargonien
#> 855                                                               Primeln
#> 856                                                              Karotten
#> 857                                                                Kerbel
#> 858                                                               Begonia
#> 859                                                          Rosskastanie
#> 860                                                            Zierkürbis
#> 861                                                  Pfirsich / Nektarine
#> 862                                                              Baldrian
#> 863                                                         Einlegegurken
#> 864                                                        Nostranogurken
#> 865                                                     Gewächshausgurken
#> 866                                                               Azaleen
#> 867                                                                 Kardy
#> 868                                                             Kopfsalat
#> 869                                                          Schnittsalat
#> 870                                                              Patisson
#> 871                                                          Chrysantheme
#> 872                                                   Schwarze Apfelbeere
#> 873                                                               Anemone
#> 874                                                       Stangensellerie
#> 875                                                                 Minze
#> 876                                                              Pak-Choi
#> 877                                                               Melonen
#> 878                                                          Stachelbeere
#> 879                                                               Azaleen
#> 880                                                            Baumschule
#> 881                                                             Basilikum
#> 882                                                    Verarbeitungsräume
#> 883                                                               Lupinen
#> 884                                                                 Birne
#> 885                                                    Schwarzer Holunder
#> 886                                                             Rosenkohl
#> 887                                                             Kopfkohle
#> 888                                                              Kohlrabi
#> 889                                                            Blumenkohl
#> 890                                                             Romanesco
#> 891                                                              Broccoli
#> 892                                                              Pak-Choi
#> 893                                                         Markstammkohl
#> 894                                                             Chinakohl
#> 895                                                             Federkohl
#> 896                                                             Brombeere
#> 897                                                              Himbeere
#> 898                                               Forstliche Pflanzgärten
#> 899                                                          Stangenbohne
#> 900                                                          Sommerweizen
#> 901                                                          Sommergerste
#> 902                                                           Sommerhafer
#> 903                                              Einrichtungen und Geräte
#> 904                                                             Aubergine
#> 905                                                            Andenbeere
#> 906                                                                Pepino
#> 907                                                              Peperoni
#> 908                                                         Gemüsepaprika
#> 909                                                 Tomaten Spezialitäten
#> 910                                                         Cherrytomaten
#> 911                                                         Rispentomaten
#> 912                                                              Peperoni
#> 913                                                 Färberdistel (Saflor)
#> 914                                                            Blumenkohl
#> 915                                                             Romanesco
#> 916                                                              Broccoli
#> 917                                                           Chinaschilf
#> 918                                              leere Verarbeitungsräume
#> 919                                                               Lorbeer
#> 920                                                           Bohnenkraut
#> 921                                                             Kopfsalat
#> 922                                         Kleegrasmischung (Kunstwiese)
#> 923                                                Schwarze Johannisbeere
#> 924                                                             Jungreben
#> 925                                                           Mulchsaaten
#> 926                                                            Zuckermais
#> 927                                                                 Linse
#> 928                                                       Knollensellerie
#> 929                                                             Puffbohne
#> 930                                 Speisekürbisse (ungeniessbare Schale)
#> 931                                                            Winterraps
#> 932                                                             Blautanne
#> 933                                                  Zier- und Sportrasen
#> 934                                                     Erbsen mit Hülsen
#> 935                                                    Erbsen ohne Hülsen
#> 936                                                             Hyazinthe
#> 937                                                          Wintergerste
#> 938                                                              Endivien
#> 939                                            Klee zur Saatgutproduktion
#> 940                                                            Ackerbohne
#> 941                                                             Zwetschge
#> 942                                                         Gemüsepaprika
#> 943                                    Kartoffeln zur Pflanzgutproduktion
#> 944                                              Baby-Leaf (Brassicaceae)
#> 945                                                             Aubergine
#> 946                                                                 Kenaf
#> 947                                                               Walnuss
#> 948                                                       Hartschalenobst
#> 949                                                              Pak-Choi
#> 950                                                         Markstammkohl
#> 951                                                             Chinakohl
#> 952                                                             Federkohl
#> 953                                                               Majoran
#> 954                                                            Kerbelrübe
#> 955                                                               Thymian
#> 956                                                            Andenbeere
#> 957                                     Holzpaletten, Packholz, Stammholz
#> 958                                                            Zierkürbis
#> 959                                                             Hyazinthe
#> 960                                                                  Iris
#> 961                                         Liliengewächse (Zierpflanzen)
#> 962                                                                 Tulpe
#> 963                                                        Gemüseportulak
#> 964                                                            Hartweizen
#> 965                                                       Weihnachtsbäume
#> 966                                                                 Rande
#> 967                                                          Winterweizen
#> 968                                            Gehölze (ausserhalb Forst)
#> 969                                                             Rosenkohl
#> 970                                                                Kresse
#> 971                                                      leere Lagerräume
#> 972                                                          Eiweisserbse
#> 973                                                          Wintergerste
#> 974                                                                Roggen
#> 975                                                         Markstammkohl
#> 976                                                                Kümmel
#> 977                                                            Hartweizen
#> 978                                                           Weichweizen
#> 979                                                                 Tabak
#> 980                                                         Wassermelonen
#> 981                                                               Melonen
#> 982                                 Speisekürbisse (ungeniessbare Schale)
#> 983                                                            Ölkürbisse
#> 984                                                         Einlegegurken
#> 985                                                        Nostranogurken
#> 986                                                     Gewächshausgurken
#> 987                                                              Patisson
#> 988                                                             Zucchetti
#> 989                                                               Rondini
#> 990                                                                Nelken
#> 991                                                         Gemüsezwiebel
#> 992                                                         Gewürzfenchel
#> 993                                                             Brombeere
#> 994                                                          Bundzwiebeln
#> 995                                                        Gemüseportulak
#> 996                                                             Romanesco
#> 997                                                                Roggen
#> 998                                                                 Hafer
#> 999                                                       Wintertriticale
#> 1000                                                         Winterweizen
#> 1001                                                         Winterroggen
#> 1002                                                        Korn (Dinkel)
#> 1003                                                                Emmer
#> 1004                                                         Sommerweizen
#> 1005                                                         Sommergerste
#> 1006                                                          Sommerhafer
#> 1007                                                         Wintergerste
#> 1008                                                           Hartweizen
#> 1009                                                          Weichweizen
#> 1010                                                   Offene Ackerfläche
#> 1011                                                             Endivien
#> 1012                                                            Zuckerhut
#> 1013                                        Radicchio- und Cicorino-Typen
#> 1014                                                                Lauch
#> 1015                                                             Pflanzen
#> 1016                                                               Radies
#> 1017                                                   Rote Johannisbeere
#> 1018                                                                 Dill
#> 1019                                                           Krautstiel
#> 1020                                         Speise- und Futterkartoffeln
#> 1021                                                           Buschbohne
#> 1022                                                               Spinat
#> 1023                                                            Zuckerhut
#> 1024                                                   Traubensilberkerze
#> 1025                                                          Trockenreis
#> 1026                                                        Schwarzwurzel
#> 1027                                                              Cyclame
#> 1028                                                          Nüsslisalat
#> 1029                                                                 Mohn
#> 1030                                                                 Lein
#> 1031                                                             Aprikose
#> 1032                                                                Olive
#> 1033                                           Baby-Leaf (Chenopodiaceae)
#> 1034                                                              Pflaume
#> 1035                                                              Gerbera
#> 1036                                                         Schnittsalat
#> 1037                                                            Sojabohne
#> 1038                                     Blumenzwiebeln und Blumenknollen
#> 1039                                                                Rosen
#> 1040                                                               Salbei
#> 1041                                                  Brassica rapa-Rüben
#> 1042                                                            Rosenwurz
#> 1043                                                        Kirschlorbeer
#> 1044 Böschungen und Grünstreifen entlang von Verkehrswegen (gem. ChemRRV)
#> 1045                                                          Speisepilze
#> 1046                                                            Süssdolde
#> 1047                                                            Gojibeere
#> 1048                                                         Schnittsalat
#> 1049                                                          Liebstöckel
#> 1050                                                                 Iris
#> 1051                                                   Bohnen ohne Hülsen
#> 1052                                                         Stangenbohne
#> 1053                                                           Buschbohne
#> 1054                                                          Heidelbeere
#> 1055                                                           Krautstiel
#> 1056                                                       Schnittmangold
#> 1057                                                             Estragon
#> 1058                                     Lagerhallen, Mühlen, Silogebäude
#> 1059                                                            Brachland
#> 1060                                                        Johanniskraut
#> 1061                                                              Dahlien
#> 1062                                                       Nostranogurken
#> 1063                                                            Kopfsalat
#> 1064                                   Kartoffeln zur Pflanzgutproduktion
#> 1065                                         Speise- und Futterkartoffeln
#> 1066                                        Radicchio- und Cicorino-Typen
#> 1067                                                           Zuckerrübe
#> 1068                                           Asia-Salate (Brassicaceae)
#> 1069                                                         Sommerweizen
#> 1070                                                         Winterroggen
#> 1071                                                          Pelargonien
#> 1072                                                       Schnittmangold
#> 1073                                        Liliengewächse (Zierpflanzen)
#> 1074                                                  Blaue Heckenkirsche
#> 1075                                                             Broccoli
#> 1076                                                         Barbarakraut
#> 1077                                                         Humusdeponie
#> 1078                                                              Rettich
#> 1079                                                           Ölkürbisse
#> 1080                                                           Topinambur
#> 1081                                                         Stachelbeere
#> 1082                                               Schwarze Johannisbeere
#> 1083                                                   Rote Johannisbeere
#> 1084                                                           Jostabeere
#> 1085                                                  Brassica rapa-Rüben
#> 1086                                                         Sommergerste
#> 1087                                                            Zucchetti
#> 1088                                                         Cima di Rapa
#> 1089                                                            Chinakohl
#> 1090                                                   Wolliger Fingerhut
#> 1091              Auf und an National- und Kantonsstrassen (gem. ChemRRV)
#> 1092                                                   Erbsen ohne Hülsen
#> 1093                                                           Sommerflor
#> 1094                                                           Futterrübe
#> 1095                                                        Speisezwiebel
#> 1096                                                               Brache
#> 1097                                                              Spargel
#> 1098                                                          Sommerhafer
#> 1099                                                            Kopfkohle
#> 1100                                                 Pfirsich / Nektarine
#> 1101                                                             Aprikose
#> 1102                                                              Kirsche
#> 1103                                                            Zwetschge
#> 1104                                                              Pflaume
#> 1105                                                            Mini-Kiwi
#> 1106                                                             Erntegut
#> 1107                                                               Rucola
#> 1108                                                             Erdbeere
#> 1109                                   Grasbestände zur Saatgutproduktion
#> 1110                                                    Gewächshausgurken
#> 1111                                                      Wintertriticale
#> 1112                                                              Kirsche
#> 1113                                                        Rispentomaten
#> 1114                                                   Schwarze Maulbeere
#> 1115                                                             Sanddorn
#> 1116                                                       Suppensellerie
#> 1117                                                      Stangensellerie
#> 1118                                                      Knollensellerie
#> 1119                                                              Luzerne
#> 1120                                                        Korn (Dinkel)
#> 1121                                                          Weichweizen
#> 1122                               Bäume und Sträucher (ausserhalb Forst)
#> 1123                                                              Melisse
#> 1124                                                                 Ysop
#> 1125                                                            Koriander
#> 1126                                                             Rosmarin
#> 1127                                                           Petersilie
#> 1128                                                     Römische Kamille
#> 1129                                                               Kerbel
#> 1130                                                                Minze
#> 1131                                                            Basilikum
#> 1132                                                          Bohnenkraut
#> 1133                                                              Thymian
#> 1134                                                               Kümmel
#> 1135                                                                 Dill
#> 1136                                                               Salbei
#> 1137                                                          Liebstöckel
#> 1138                                                             Estragon
#> 1139                                                         Schnittlauch
#> 1140                                                  Gemeine Felsenbirne
#> 1141                                                             Himbeere
#> 1142                                                             Kohlrabi
#> 1143                                                               Fichte
#> 1144                                                             Stielmus
#> 1145                                                           Blaudistel
#> 1146                                               Baby-Leaf (Asteraceae)
#> 1147                                                        Gemüsezwiebel
#> 1148                                                         Bundzwiebeln
#> 1149                                                        Speisezwiebel
#> 1150                                                   Buchsbäume (Buxus)
#> 1151                                                            Federkohl
#> 1152                                                             Gladiole
#> 1153                                                           Frässaaten
#> 1154                                                           Winterraps
#> 1155                                                             Chicorée
#> 1156                                                            Löwenzahn
#> 1157                                                             Endivien
#> 1158                                                            Zuckerhut
#> 1159                                        Radicchio- und Cicorino-Typen
#> 1160                                                            Kopfsalat
#> 1161                                                         Schnittsalat
#> 1162                                                              Primeln
#> 1163                                                   Wolliger Fingerhut
#> 1164                                                Tomaten Spezialitäten
#> 1165                                                        Cherrytomaten
#> 1166                                                        Rispentomaten
#> 1167                                                                 Hanf
#> 1168                                                          Meerrettich
#> 1169                                                        Bodenkohlrabi
#> 1170                                                           Hagebutten
#> 1171                                                            Pastinake
#> 1172                                                        Süsskartoffel
#> 1173                                                           Lagerräume
#> 1174                                       Ziergehölze (ausserhalb Forst)
#> 1175                                                               Pepino
#> 1176                                                              Rondini
#> 1177                                                           Schalotten
#> 1178                                                                Emmer
#> 1179                                                         Stangenbohne
#> 1180                                                           Buschbohne
#> 1181                                                                Hafer
#> 1182                                                                 Mais
#> 1183                                                                Birne
#> 1184                                                         Schnittlauch
#> 1185                                                              Stauden
#> 1186                                                               Quitte
#> 1187                                                                Apfel
#> 1188                                                             Patisson
#> 1189                                                            Zucchetti
#> 1190                                                              Rondini
#> 1191                                                                Tulpe
#> 1192                                                           Jostabeere

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
#> Warning: Resolving cultures using srppp_dm objects created from version 2 of the XML files is experimental and does not always work correctly
#>   substance_de pNbr use_nr application_area_de    culture_de
#> 1     Schwefel 3561      4             Obstbau Obstbau allg.
#>                pest_de leaf_culture_de
#> 1 Wühl- oder Schermaus            <NA>
 resolve_cultures(example_dataset_6, sr,
   correct_culture_names = TRUE)
#> Warning: Resolving cultures using srppp_dm objects created from version 2 of the XML files is experimental and does not always work correctly
#>   substance_de pNbr use_nr application_area_de    culture_de
#> 1     Schwefel 3561      4             Obstbau allg. Obstbau
#>                pest_de leaf_culture_de
#> 1 Wühl- oder Schermaus            <NA>
# }
```
