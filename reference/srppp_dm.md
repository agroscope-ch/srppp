# Create a dm object from an XML version of the Swiss Register of Plant Protection Products

While reading in the data, the information obtained from the XML file is
left unchanged, with the exceptions listed in the section 'Details'. An
overview of the contents of the most important tables in the resulting
data object is given in
[`vignette("srppp")`](https://agroscope-ch.github.io/srppp/articles/srppp.md).

## Usage

``` r
srppp_dm(from = srppp_xml_url, remove_duplicates = TRUE, verbose = TRUE)

# S3 method for class 'srppp_dm'
print(x, ...)
```

## Arguments

- from:

  A specification of the way to retrieve the XML to be passed to
  [srppp_xml_get](https://agroscope-ch.github.io/srppp/reference/srppp_xml_get.md),
  or an object of the class 'srppp_xml'

- remove_duplicates:

  Should duplicates based on wNbrs be removed?

- verbose:

  Should we give some feedback?

- x:

  A srppp_dm object

- ...:

  Not used

## Value

A [dm::dm](https://dm.cynkra.com/reference/dm.html) object with tables
linked by foreign keys pointing to primary keys, i.e. with referential
integrity. Since version 1.1, the returned object has an attribute named
'culture_tree' of class
[data.tree::Node](https://rdrr.io/pkg/data.tree/man/Node.html).

## Details

### Corrections made to the data

- In the following case, the product composition is corrected while
  reading in the data: The active substance content of Dormex (W-3066)
  is not 667 g/L, but 520 g/L This was confirmed by a visit to the
  Wädenswil archive by Johannes Ranke and Daniel Baumgartner,
  2024-03-27.

### Removal of redundant information

- Information on products that has been duplicated across several
  products sharing the same P-Number has been associated directly with
  this P-Number, in order to avoid duplications. While reading in the
  XML file, it is checked that the resulting deduplication does not
  remove any data.

- In very few cases of historical XML files, there are two `<Product>`
  sections sharing the same W-Number. In these cases, one of these has
  apparently been included in error and an informed decision is taken
  while reading in the data which one of these sections is discarded.
  The details of this procedure can be found in the source code of the
  function `srppp_xml_get_products`.

### Amendments to the data

In the table of obligations, the following information on mitigation
measures is extracted from the ones relevant for the environment (SPe
3).

- "sw_drift_dist": Unsprayed buffer towards surface waters to mitigate
  spray drift in meters

- "sw_runoff_dist": Vegetated buffer towards surface waters to mitigate
  runoff in meters

- "sw_runoff_points": Required runoff mitigation points to mitigate
  runoff

- "biotope_drift_dist": Unsprayed buffer towards biotopes (as defined in
  articles 18a and 18b of the Federal Act on the Protection of Nature
  and Cultural Heritage) to mitigate spray drift in meters

## Examples

``` r
 # Avoid NOTE on CRAN caused by checks >5s
library(dplyr, warn.conflicts = FALSE)
library(dm, warn.conflicts = FALSE)

sr <- try(srppp_dm())

# Fall back to internal test data if downloading or reading fails
if (inherits(sr, "try-error")) {
  sr <- system.file("testdata/Daten_Pflanzenschutzmittelverzeichnis_2024-12-16.zip",
      package = "srppp") |>
    srppp_xml_get_from_path(from = "2024-12-16") |>
    srppp_dm()
}

dm_examine_constraints(sr)
#> ! Unsatisfied constraints:
#> • Table `pNbrs`: primary key `pNbr`: has 1 missing values
#> • Table `ingredients`: foreign key `pk` into table `substances`: values of `ingredients$pk` not in `substances$pk`: 50804ef0-5d85-46cc-b697-17a7bca5f8f0 (1), 738e64d8-6e48-415f-9341-50608bd3273c (1), c1966a3b-0a53-43aa-8abc-c736e118a497 (1)
#> • Table `parallel_imports`: foreign key `pNbr` into table `pNbrs`: values of `parallel_imports$pNbr` not in `pNbrs$pNbr`: 7738 (5), 8332 (1), 9033 (1)
dm_draw(sr)
%0


CodeR
CodeRpNbrpNbrs
pNbrspNbrCodeR:pNbr->pNbrs:pNbr
CodeS
CodeSpNbrCodeS:pNbr->pNbrs:pNbr
application_comments
application_commentspNbr, use_nruses
usespNbrpNbr, use_nrapplication_comments:pNbr, use_nr->uses:pNbr, use_nr
categories
categoriespNbrcategories:pNbr->pNbrs:pNbr
culture_forms
culture_formspNbr, use_nrculture_forms:pNbr, use_nr->uses:pNbr, use_nr
cultures
culturespNbr, use_nrcultures:pNbr, use_nr->uses:pNbr, use_nr
danger_symbols
danger_symbolspNbrdanger_symbols:pNbr->pNbrs:pNbr
formulation_codes
formulation_codespNbrformulation_codes:pNbr->pNbrs:pNbr
ingredients
ingredientspNbrpkingredients:pNbr->pNbrs:pNbr
substances
substancespkingredients:pk->substances:pk
obligations
obligationspNbr, use_nrobligations:pNbr, use_nr->uses:pNbr, use_nr
parallel_imports
parallel_importsidpNbrparallel_imports:pNbr->pNbrs:pNbr
pests
pestspNbr, use_nrpests:pNbr, use_nr->uses:pNbr, use_nr
products
productspNbrwNbrproducts:pNbr->pNbrs:pNbr
signal_words
signal_wordspNbrsignal_words:pNbr->pNbrs:pNbr
uses:pNbr->pNbrs:pNbr

# Show ingredients for products named 'Boxer'
sr$products |>
  filter(name == "Boxer") |>
  left_join(sr$ingredients, by = "pNbr") |>
  left_join(sr$substances, by = "pk") |>
  select(wNbr, name, pNbr, isSalePermission, substance_de, g_per_L)
#> # A tibble: 2 × 6
#>   wNbr   name   pNbr isSalePermission substance_de g_per_L
#>   <chr>  <chr> <int> <lgl>            <chr>          <dbl>
#> 1 6168   Boxer  7105 FALSE            Prosulfocarb     800
#> 2 6168-1 Boxer  7105 TRUE             Prosulfocarb     800

# Show authorised uses of the original product
boxer_uses <- sr$products |>
  filter(name == "Boxer", !isSalePermission) |>
  left_join(sr$uses, by = "pNbr") |>
  select(pNbr, use_nr,
    min_dosage, max_dosage, min_rate, max_rate, units_de,
    waiting_period, time_units_de, application_area_de)
print(boxer_uses)
#> # A tibble: 17 × 10
#>     pNbr use_nr min_dosage max_dosage min_rate max_rate units_de waiting_period
#>    <int>  <int>      <dbl>      <dbl>    <dbl>    <dbl> <chr>             <int>
#>  1  7105      1         NA         NA      2.5      5   l/ha                 NA
#>  2  7105      2         NA         NA      5       NA   l/ha                 90
#>  3  7105      3         NA         NA      3       NA   l/ha                 80
#>  4  7105      4         NA         NA      5       NA   l/ha                 60
#>  5  7105      5         NA         NA      3        5   l/ha                 NA
#>  6  7105      6         NA         NA      5       NA   l/ha                  0
#>  7  7105      7         NA         NA      3       NA   l/ha                 80
#>  8  7105      8         NA         NA      4       NA   l/ha                 80
#>  9  7105      9         NA         NA      4       NA   l/ha                 80
#> 10  7105     10         NA         NA      3        4.5 l/ha                  0
#> 11  7105     11         NA         NA      2.5      3   l/ha                 75
#> 12  7105     12         NA         NA      5       NA   l/ha                  0
#> 13  7105     13         NA         NA      2.5      5   l/ha                 NA
#> 14  7105     14         NA         NA      5       NA   l/ha                100
#> 15  7105     15         NA         NA      4       NA   l/ha                 80
#> 16  7105     16         NA         NA      4       NA   l/ha                 60
#> 17  7105     17         NA         NA      4       NA   l/ha                  0
#> # ℹ 2 more variables: time_units_de <chr>, application_area_de <chr>

# Show crop for use number 1
boxer_uses |>
  filter(use_nr == 1) |>
  left_join(sr$cultures, join_by(pNbr, use_nr)) |>
  select(use_nr, culture_de)
#> # A tibble: 3 × 2
#>   use_nr culture_de
#>    <int> <chr>     
#> 1      1 Gerste    
#> 2      1 Roggen    
#> 3      1 Weizen    

# Show target pests for use number 1
boxer_uses |>
  filter(use_nr == 1) |>
  left_join(sr$pests, join_by(pNbr, use_nr)) |>
  select(use_nr, pest_de)
#> # A tibble: 2 × 2
#>   use_nr pest_de                              
#>    <int> <chr>                                
#> 1      1 Einjährige Monocotyledonen (Ungräser)
#> 2      1 Einjährige Dicotyledonen (Unkräuter) 

# Show obligations for use number 1
boxer_uses |>
  filter(use_nr == 1) |>
  left_join(sr$obligations, join_by(pNbr, use_nr)) |>
  select(use_nr, sw_runoff_points, obligation_de) |>
  knitr::kable() |>
  print()
#> 
#> 
#> | use_nr| sw_runoff_points|obligation_de                                                                                                                                                                                                                                                                                                                                                                               |
#> |------:|----------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
#> |      1|               NA|Behandlung von im Herbst gesäten Kulturen.                                                                                                                                                                                                                                                                                                                                                  |
#> |      1|               NA|Maximal 1 Behandlung pro Kultur.                                                                                                                                                                                                                                                                                                                                                            |
#> |      1|                1|SPe 3: Zum Schutz von Gewässerorganismen muss das Abschwemmungsrisiko gemäss den Weisungen der Zulassungsstelle um 1 Punkt reduziert werden.                                                                                                                                                                                                                                                |
#> |      1|               NA|Niedrige Aufwandmenge nur in Tankmischung gemäss den Angaben der Bewilligungsinhaberin.                                                                                                                                                                                                                                                                                                     |
#> |      1|               NA|Nachfolgearbeiten in behandelten Kulturen: bis 48 Stunden nach Ausbringung des Mittels Schutzhandschuhe + Schutzanzug tragen.                                                                                                                                                                                                                                                               |
#> |      1|               NA|Ansetzen der Spritzbrühe: Schutzhandschuhe tragen. Ausbringen der Spritzbrühe: Schutzhandschuhe + Schutzanzug + Visier + Kopfbedeckung tragen. Technische Schutzvorrichtungen während des Ausbringens (z.B. geschlossene Traktorkabine) können die vorgeschriebene persönliche Schutzausrüstung ersetzen, wenn gewährleistet ist, dass sie einen vergleichbaren oder höheren Schutz bieten. |

# Show application comments for use number 1
boxer_uses |>
  filter(use_nr == 1) |>
  left_join(sr$application_comments, join_by(pNbr, use_nr)) |>
  select(use_nr, application_comment_de)
#> # A tibble: 1 × 2
#>   use_nr application_comment_de                           
#>    <int> <chr>                                            
#> 1      1 Herbst, Frühjahr; Vorauflauf, früher Nachauflauf.

# Illustrate 'obligations' indicating varying effects
sr$obligations |>
  filter(varying_effect) |>
  select(pNbr, use_nr, code, obligation_de)
#> # A tibble: 199 × 4
#>     pNbr use_nr code  obligation_de                                             
#>    <int>  <int> <chr> <chr>                                                     
#>  1  4683      1 NA    Die Wirkungseffizienz der Nützlinge kann je nach Pflanzen…
#>  2  4683      2 NA    Die Wirkungseffizienz der Nützlinge kann je nach Pflanzen…
#>  3  4683      3 NA    Die Wirkungseffizienz der Nützlinge kann je nach Pflanzen…
#>  4  4685      1 NA    Die Wirkungseffizienz der Nützlinge kann je nach Pflanzen…
#>  5  4685      2 NA    Die Wirkungseffizienz der Nützlinge kann je nach Pflanzen…
#>  6  4751      1 NA    Die Wirkungseffizienz der Nützlinge kann je nach Pflanzen…
#>  7  4751      2 NA    Die Wirkungseffizienz der Nützlinge kann je nach Pflanzen…
#>  8  4751      3 NA    Die Wirkungseffizienz der Nützlinge kann je nach Pflanzen…
#>  9  4751      4 NA    Die Wirkungseffizienz der Nützlinge kann je nach Pflanzen…
#> 10  4751      5 NA    Die Wirkungseffizienz der Nützlinge kann je nach Pflanzen…
#> # ℹ 189 more rows

```
