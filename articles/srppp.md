# The Swiss Register of Plant Protection Products as a Relational Data Model

Since the year 2011, the [Swiss Federal Office of Agriculture
(FOAG)](https://www.blw.admin.ch) and later the [Federal Food Safety and
Veterinary Office](https://www.blv.admin.ch), now responsible for the
authorisation of plant protection products in Switzerland, publish the
contents of the Swiss Register of Plant Protection Products (SRPPP) on
their respective websites in a custom format based on the Extensible
Markup Language (XML).

In our
[group](https://www.agroscope.admin.ch/agroscope/de/home/ueber-uns/organisation/kompetenzbereiche-strategische-forschungsbereiche/pflanzen-pflanzliche-produkte/pflanzenschutzmittel-wirkung-bewertung.html)
at Agroscope, different solutions have been used to read in, process and
use these data. This package offers a fresh approach to directly read in
the data into `R`.

The current download location of the latest published XML version of the
SRPPP is stored in the package as
[`srppp::srppp_xml_url`](https://agroscope-ch.github.io/srppp/reference/srppp_xml_url.md).
Reading in the current data is as simple as

``` r
library(srppp)
library(dplyr)
example_register <- try(srppp_dm())
```

    ## Warning in download.file(from, path): URL
    ## 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip':
    ## status was 'Failure when receiving data from the peer'

    ## Error in download.file(from, path) : 
    ##   cannot open URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip'

In case downloading the current register from the internet fails, we
read in the version from 16 December 2024 that is distributed with the
package.

``` r
if (inherits(example_register, "try-error")) {
  test_data <- system.file("testdata/Daten_Pflanzenschutzmittelverzeichnis_2024-12-16.zip",
  package = "srppp")
  test_xml <- srppp_xml_get_from_path(test_data, from = "2024-12-16")
  example_register <- srppp_dm(test_xml)
}
```

The resulting data object contains a number of related tables with
information on the authorized products and their uses. The relation
between those tables is shown below. The identification numbers of the
evaluated products (`pNbrs`) and the general information associated with
them are shown in dark blue. The tables defining their composition in
terms of the most important ingredients are shown in orange. Tables with
information on the authorized uses of the products are shown in dark
green. Finally, the tables giving names and expiration dates of products
and parallel imports as well as an identification number for the
authorization holder are shown in light blue.

``` r
library(DiagrammeR)
dm_draw(example_register)
```

## Substances

At the bottom of the table hierarchy, there is the list of substances.
For each substance, there is a primary key `pk`, a chemical name based
on [IUPAC nomenclature](https://iupac.org/what-we-do/nomenclature/), and
substance names in three of the four official languages of Switzerland.
The first four entries out of 453 are shown below.

``` r
library(knitr)
example_register$substances |> 
  select(pk, iupac, substance_de, substance_fr, substance_it) |> 
  head(n = 4L) |> 
  kable()
```

| pk   | iupac                                                                        | substance_de                                               | substance_fr                                               | substance_it                                               |
|:-----|:-----------------------------------------------------------------------------|:-----------------------------------------------------------|:-----------------------------------------------------------|:-----------------------------------------------------------|
| 1289 | \[S-(1alpha,2alpha,5alpha)\]-4,6,6-trimethylbicyclo-\[3,1,1\]-hept-3-en-2-ol | (S)-cis-Verbenol                                           | (S)-cis-Verbenol                                           | (S)-cis-Verbenol                                           |
| 1930 |                                                                              | (Z)-9-Octadecen-1-ol ethoxylated                           | (Z)-9-Octadecen-1-ol ethoxylated                           | (Z)-9-Octadecen-1-ol ethoxylated                           |
| 1689 | 1,2-Benzisothiazol-3(2H)-on                                                  | 1,2-Benzisothiazol-3(2H)-on                                | 1,2-benzisothiazol-3(2H)-on                                | 1,2-benzisotiazol-3(2H)-on                                 |
| 1879 |                                                                              | 1,2-benzisothiazol-3(2H)-one; 1,2-benzisothiazolin-1 3-one | 1,2-benzisothiazol-3(2H)-one; 1,2-benzisothiazolin-1 3-one | 1,2-benzisothiazol-3(2H)-one; 1,2-benzisothiazolin-1 3-one |

## Products

There are three tables defining the products, `pNbrs`, `products` and
`ingredients`. The P-Numbers contained in the table `pNbrs` are
identifiers of product compositions. Products with the same P-Number are
considered equivalent in terms of efficacy and risks. The table `pNbrs`
is only there for a technical reason. It simply contains a column
holding the P-Numbers.

### Unique products (P-Numbers) and their composition

The composition of these products in terms of active substances,
additives to declare, synergists and safeners is is defined in the table
`ingredients`, giving the contents in percent weight per weight
(`percent`). For liquid products, a content in grams per litre is also
given (`g_per_L`). If a substance is contained in a form that differs
from the definition given in the substance table, this is documented in
the respective additional columns as illustrated by the first five rows
shown below.

``` r
example_register$ingredients |> 
  select(pNbr, pk, type, percent, g_per_L, ingredient_de, ingredient_fr) |> 
  head(n = 5L) |> 
  kable()
```

| pNbr | pk   | type              | percent | g_per_L | ingredient_de                          | ingredient_fr                                        |
|-----:|:-----|:------------------|--------:|--------:|:---------------------------------------|:-----------------------------------------------------|
|   38 | 338  | ACTIVE_INGREDIENT |    80.0 |         |                                        |                                                      |
| 1182 | 1067 | ACTIVE_INGREDIENT |    34.7 |     400 | als 38.0% MCPB-Natrium-Salz (439 g/l)  | sous forme de 38.0 % MCPB de sel de sodium (439 g/L) |
| 1192 | 1067 | ACTIVE_INGREDIENT |    34.7 |     400 | als 38.0 % MCPB-Natrium-Salz (439 g/L) | sous forme de 38.0 % MCPB de sel de sodium (439 g/L) |
| 1263 | 338  | ACTIVE_INGREDIENT |    80.0 |         |                                        |                                                      |
| 1865 | 1027 | ACTIVE_INGREDIENT |    99.1 |     830 |                                        |                                                      |

The frequency of occurrence of the four different ingredient types is
quite different.

``` r
library(dplyr)
example_register$ingredients |> 
  select(pk, type) |> 
  unique() |> 
  group_by(type) |> 
  summarize(n = n()) |> 
  kable()
```

| type                |   n |
|:--------------------|----:|
| ACTIVE_INGREDIENT   | 340 |
| ADDITIVE_TO_DECLARE | 109 |
| SAFENER             |   5 |
| SYNERGIST           |   2 |

Additives to declare are additives that have an effect on classification
and labelling of the product. All substances occurring as synergists or
safeners are listed below.

``` r
example_register$ingredients |> 
  left_join(example_register$substances, by = "pk") |>
  filter(type %in% c("SYNERGIST", "SAFENER")) |>
  group_by(type, substance_de) |> 
  summarize(n = n(), .groups = "drop_last") |> 
  select(type, substance_de, n) |> 
  arrange(type, substance_de) |> 
  kable()
```

| type      | substance_de       |   n |
|:----------|:-------------------|----:|
| SAFENER   | Benoxacor          |   1 |
| SAFENER   | Cloquintocet-mexyl |  15 |
| SAFENER   | Cyprosulfamid      |   2 |
| SAFENER   | Isoxadifen-ethyl   |   3 |
| SAFENER   | Mefenpyr-Diethyl   |  10 |
| SYNERGIST | Piperonyl butoxid  |   6 |
| SYNERGIST | Sesamöl raffiniert |   3 |

Note that the first two lines in the code could also be replaced by

``` r
example_register |> 
  dm_flatten_to_tbl(ingredients) |> 
```

which makes use of the foreign key declaration in the data object.
However, the more explicit version using `left_join` is probably easier
to understand.

### Registered products (W-Numbers)

The registered products are identified by the so-called W-Numbers. The
relation between P-Numbers and W-Numbers is illustrated below by showing
the first five entries in the `products` table.

``` r
example_register$products |> 
  select(-terminationReason) |> 
  head() |> 
  kable()
```

| pNbr | wNbr | name                   | exhaustionDeadline | soldoutDeadline | isSalePermission | permission_holder |
|-----:|:-----|:-----------------------|:-------------------|:----------------|:-----------------|:------------------|
|   38 | 18   | Thiovit Jet            |                    |                 | FALSE            | 10388             |
|   38 | 18-1 | Sufralo                |                    |                 | TRUE             | 10712             |
|   38 | 18-2 | Capito Bio-Schwefel    |                    |                 | TRUE             | 10712             |
|   38 | 18-3 | Sanoplant Schwefel     |                    |                 | TRUE             | 10388             |
|   38 | 18-4 | Biorga Contra Schwefel |                    |                 | TRUE             | 10388             |
| 1182 | 923  | Divopan                |                    |                 | FALSE            | 10388             |

As can be seen in these example entries, several registrations
(W-Numbers) of the same product type (P-Number) can exist. The W-Numbers
without a dash (e.g. `18`) are the original registrations, and the ones
containing a dash and a trailing number (e.g. `18-1`, `18-2`) are
equivalent products with sales permissions that have a different legal
entity as permission holder.

If the product registration has been revoked, the relevant latest dates
for selling the product (`soldoutDeadline`) and for use of the product
(`exhaustionDeadline`) are given in the respective columns.

``` r
example_register$products |>
  filter(exhaustionDeadline != "") |> 
  select(-terminationReason) |> 
  head() |> 
  kable()
```

| pNbr | wNbr   | name                     | exhaustionDeadline | soldoutDeadline | isSalePermission | permission_holder |
|-----:|:-------|:-------------------------|:-------------------|:----------------|:-----------------|:------------------|
| 3726 | 2935   | Polyram DF               | 2025-07-01         | 2025-01-01      | FALSE            | 10019             |
| 3726 | 2935-1 | Metiram WG               | 2025-07-01         | 2025-01-01      | TRUE             | 10213             |
| 3726 | 2935-2 | Aviso                    | 2025-07-01         | 2025-01-01      | TRUE             | 10050             |
| 4163 | 4309   | Volpan                   | 2026-10-31         | 2025-10-31      | FALSE            | 10054             |
| 4163 | 4309-1 | MIOPLANT Windenvertilger | 2026-10-31         | 2025-10-31      | TRUE             | 10388             |
| 4426 | 4343   | Cypermethrin             | 2026-06-11         | 2025-06-11      | FALSE            | 10079             |

At the build time of this vignette, there were 1739 product
registrations for 1139 P-Numbers in the Swiss Register of Plant
Protection Products (SRPPP) as published on the website of the Federal
Food Safety and Veterinary Office.

### Example code for getting a product composition from a product name

If the name of a product is known, the associated P-Numbers and
W-Numbers as well as the product composition can be retrieved by a
command like the following.

``` r
example_register$products |>
  filter(name == "Plüsstar") |>
  left_join(example_register$ingredients, by = "pNbr") |>
  left_join(example_register$substances, by = "pk") |>
  select(pNbr, name, substance_de, percent, g_per_L) |> 
  kable()
```

| pNbr | name     | substance_de | percent | g_per_L |
|-----:|:---------|:-------------|--------:|--------:|
| 4077 | Plüsstar | 2,4-D        |    14.8 |     170 |
| 4077 | Plüsstar | Mecoprop-P   |    35.3 |     405 |

## Uses

For each product type (P-Number), the registered uses (tagged as
`<Indication>` in the XML file) are specified in the `uses` table. The
use numbers in the column `use_nr` are generated while reading in the
XML file, in order to be able to refer to each use by a combination of
P-Number (`pNbr`) and use number (`use_nr`).

``` r
example_register$uses |> 
  filter(pNbr %in% c(6521L, 7511L) & use_nr < 10) |> 
  select(pNbr, use_nr, ends_with("dosage"), ends_with("rate"), units_de,
    waiting_period, time_units_en, application_area_de) |> 
  head(20) |> 
  kable()
```

| pNbr | use_nr | min_dosage | max_dosage | min_rate | max_rate | units_de | waiting_period | time_units_en | application_area_de |
|-----:|-------:|-----------:|-----------:|---------:|---------:|:---------|---------------:|:--------------|:--------------------|
| 6521 |      1 |            |            |      1.0 |          | l/ha     |                |               | Gemüsebau           |
| 6521 |      2 |            |            |      0.5 |        1 | l/ha     |                |               | Feldbau             |
| 6521 |      3 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      4 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      5 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      6 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      7 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      8 |            |            |      1.0 |          | l/ha     |              3 | Week(s)       | Feldbau             |
| 6521 |      9 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 7511 |      1 |        0.4 |            |      4.0 |          | kg/ha    |              3 | Days          | Beerenbau           |
| 7511 |      2 |        0.2 |            |      3.2 |          | kg/ha    |              3 | Week(s)       | Obstbau             |
| 7511 |      3 |        0.3 |            |          |          |          |              3 | Days          | Gemüsebau           |
| 7511 |      4 |        0.3 |            |      3.0 |          | kg/ha    |              3 | Days          | Beerenbau           |
| 7511 |      5 |        0.2 |            |      3.2 |          | kg/ha    |              2 | Week(s)       | Obstbau             |
| 7511 |      6 |        0.4 |            |          |          |          |              3 | Days          | Beerenbau           |
| 7511 |      7 |        0.3 |            |          |          |          |              3 | Days          | Beerenbau           |
| 7511 |      8 |        0.4 |            |      4.0 |          | kg/ha    |              3 | Days          | Beerenbau           |
| 7511 |      9 |        0.3 |            |          |          | kg/ha    |              3 | Days          | Gemüsebau           |

The columns `min_dosage` and `max_dosage` contain either a range of
recommended product concentrations in the spraying solution in percent,
or, if only `min_dosage` is given, the recommended concentration.
Similarly, if there is a single recommended application rate, it is
stored in `min_rate`. Only if there is a recommended range of
application rates, `max_rate` is given as well. The units of the
application rate are given in the columns starting with `units_`. In
addition, a required waiting period before harvest can be specified, as
well as the application area associated with the use.

### Application rates

Application rates in terms of grams of the active substances contained
in the products per hectare can be calculated using the function
[`application_rate_g_per_ha()`](https://agroscope-ch.github.io/srppp/reference/application_rate_g_per_ha.md)
as illustrated in the example below.

In a first step, some `uses` need to be selected and joined with the
information in the `ingredients` table. The names of the active
substances can be joined as well.

``` r
example_uses <- example_register$products |> 
  filter(wNbr == "6168") |>
  left_join(example_register$uses, by = join_by(pNbr),
    relationship = "many-to-many") |> 
  left_join(example_register$ingredients, by = join_by(pNbr),
    relationship = "many-to-many") |>
  left_join(example_register$substances, by = join_by(pk)) |>
  select(pNbr, name, use_nr,
    min_dosage, max_dosage, min_rate, max_rate, units_de,
    application_area_de,
    substance_de, percent, g_per_L) |> 
  filter(use_nr %in% c(1:5, 12:17))

kable(example_uses)
```

| pNbr | name  | use_nr | min_dosage | max_dosage | min_rate | max_rate | units_de | application_area_de | substance_de | percent | g_per_L |
|-----:|:------|-------:|-----------:|-----------:|---------:|---------:|:---------|:--------------------|:-------------|--------:|--------:|
| 7105 | Boxer |      1 |            |            |      5.0 |          | l/ha     | Gemüsebau           | Prosulfocarb |    78.4 |     800 |
| 7105 | Boxer |      2 |            |            |      5.0 |          | l/ha     | Gemüsebau           | Prosulfocarb |    78.4 |     800 |
| 7105 | Boxer |      3 |            |            |      5.0 |          | l/ha     | Gemüsebau           | Prosulfocarb |    78.4 |     800 |
| 7105 | Boxer |      4 |            |            |      4.0 |          | l/ha     | Gemüsebau           | Prosulfocarb |    78.4 |     800 |
| 7105 | Boxer |      5 |            |            |      2.5 |      3.0 | l/ha     | Gemüsebau           | Prosulfocarb |    78.4 |     800 |
| 7105 | Boxer |     12 |            |            |      3.0 |      4.5 | l/ha     | Feldbau             | Prosulfocarb |    78.4 |     800 |
| 7105 | Boxer |     13 |            |            |      2.5 |      5.0 | l/ha     | Feldbau             | Prosulfocarb |    78.4 |     800 |
| 7105 | Boxer |     14 |            |            |      3.0 |      5.0 | l/ha     | Feldbau             | Prosulfocarb |    78.4 |     800 |
| 7105 | Boxer |     15 |            |            |      5.0 |          | l/ha     | Feldbau             | Prosulfocarb |    78.4 |     800 |
| 7105 | Boxer |     16 |            |            |      4.0 |          | l/ha     | Gemüsebau           | Prosulfocarb |    78.4 |     800 |
| 7105 | Boxer |     17 |            |            |      2.5 |      5.0 | l/ha     | Feldbau             | Prosulfocarb |    78.4 |     800 |

Then, the application rates can be calculated for these uses as
illustrated below.

``` r
application_rate_g_per_ha(example_uses) |>
  select(ai = substance_de, app_area = application_area_de,
  ends_with("rate"), units_de, rate = rate_g_per_ha) |> 
  head(n = 14) |> 
  kable()
```

| ai           | app_area  | min_rate | max_rate | units_de | rate |
|:-------------|:----------|---------:|---------:|:---------|-----:|
| Prosulfocarb | Gemüsebau |      5.0 |          | l/ha     | 4000 |
| Prosulfocarb | Gemüsebau |      5.0 |          | l/ha     | 4000 |
| Prosulfocarb | Gemüsebau |      5.0 |          | l/ha     | 4000 |
| Prosulfocarb | Gemüsebau |      4.0 |          | l/ha     | 3200 |
| Prosulfocarb | Gemüsebau |      2.5 |      3.0 | l/ha     | 2400 |
| Prosulfocarb | Feldbau   |      3.0 |      4.5 | l/ha     | 3600 |
| Prosulfocarb | Feldbau   |      2.5 |      5.0 | l/ha     | 4000 |
| Prosulfocarb | Feldbau   |      3.0 |      5.0 | l/ha     | 4000 |
| Prosulfocarb | Feldbau   |      5.0 |          | l/ha     | 4000 |
| Prosulfocarb | Gemüsebau |      4.0 |          | l/ha     | 3200 |
| Prosulfocarb | Feldbau   |      2.5 |      5.0 | l/ha     | 4000 |

### Culture forms and cultures

In the current SRPPP versions, there are only two culture forms,
greenhouse cultivation and field cultivation.

``` r
example_register$culture_forms |> 
  select(starts_with("culture")) |> 
  unique() |> 
  kable()
```

| culture_form_de | culture_form_fr | culture_form_it | culture_form_en |
|:----------------|:----------------|:----------------|:----------------|
| Gewächshaus     | serre           | Serra           |                 |
| Freiland        | plein air       | Pieno campo     |                 |

For specific uses, e.g. for uses number `1` and `10` of product “Kumulus
WG” with W-Number `4458`, the associated culture form and the registered
cultures can be listed as shown below. As each use is typically
associated with only one culture form, the culture form and the actual
cultures can be joined to the use numbers in one step.

``` r
example_register$products |> 
  filter(wNbr == "4458") |> 
  left_join(example_register$uses, by = "pNbr") |> 
  filter(use_nr %in% c(1, 10)) |> 
  left_join(example_register$culture_forms, by = c("pNbr", "use_nr")) |> 
  left_join(example_register$cultures, by = c("pNbr", "use_nr")) |> 
  select(pNbr, use_nr, application_area_de, culture_form_de, culture_de) |> 
  kable()
```

| pNbr | use_nr | application_area_de | culture_form_de | culture_de          |
|-----:|-------:|:--------------------|:----------------|:--------------------|
| 4470 |      1 | Beerenbau           | Freiland        | Gemeine Felsenbirne |
| 4470 |     10 | Beerenbau           | Gewächshaus     | Rubus Arten         |

Relations between the cultures are stored as a \[data.tree::Node\]
object in an attribute named ‘culture_tree’. The first entries from that
tree are shown below. A complete culture tree is shown in the
[Appendix](#complete-culture-tree). Note that a culture can be linked to
two parent cultures in the tree. Cultures that are additionally present
in another position of the tree are marked by appending ‘\[dup\]’ to
their name.

``` r
culture_tree <- attr(example_register, "culture_tree")
print(culture_tree, limit = 30, "culture_id")
```

    ##                                               levelName culture_id
    ## 1  Cultures                                                       
    ## 2   ¦--allg. Ökologische Ausgleichsflächen (gemäss DZV)      10172
    ## 3   ¦   °--Offene Ackerfläche                                10227
    ## 4   ¦--Zierpflanzen allg.                                    10190
    ## 5   ¦   ¦--Topf- und Kontainerpflanzen                       10021
    ## 6   ¦   ¦   ¦--Begonia [dup]                                 10040
    ## 7   ¦   ¦   ¦--Cyclame [dup]                                 10050
    ## 8   ¦   ¦   ¦--Pelargonien [dup]                             10097
    ## 9   ¦   ¦   °--Primeln [dup]                                 10098
    ## 10  ¦   ¦--Blumenknollen                                     10039
    ## 11  ¦   ¦   °--Dahlien                                       10162
    ## 12  ¦   ¦--Baumschule                                        10095
    ## 13  ¦   ¦--Ziergehölze (ausserhalb Forst)                    10101
    ## 14  ¦   ¦--Rosen                                             10104
    ## 15  ¦   ¦--Ein- und zweijährige Zierpflanzen                 10176
    ## 16  ¦   ¦   °--Sommerflor                                     9969
    ## 17  ¦   ¦--Bäume und Sträucher (ausserhalb Forst)            12096
    ## 18  ¦   ¦   ¦--Rhododendron                                  10100
    ## 19  ¦   ¦   ¦   °--Azaleen                                   10099
    ## 20  ¦   ¦   ¦--Kirschlorbeer                                 10103
    ## 21  ¦   ¦   ¦--Rosskastanie                                  10109
    ## 22  ¦   ¦   ¦--Blautanne [dup]                               10110
    ## 23  ¦   ¦   ¦--Buchsbäume (Buxus)                            10152
    ## 24  ¦   ¦   °--Weihnachtsbäume [dup]                         10290
    ## 25  ¦   ¦--Blumenkulturen und Grünpflanzen                   12097
    ## 26  ¦   ¦   ¦--Iris                                          10004
    ## 27  ¦   ¦   ¦--Begonia                                       10040
    ## 28  ¦   ¦   ¦--Cyclame                                       10050
    ## 29  ¦   ¦   ¦--Hyazinthe                                     10070
    ## 30  ¦   ¦   °--... 10 nodes w/ 0 sub                              
    ## 31  ¦   °--... 3 nodes w/ 14 sub                                  
    ## 32  °--... 52 nodes w/ 258 sub

### Target organisms

The target organisms for each use can be found in the table `pests`.
Example code for retrieving the target organisms for specific uses is
given below.

``` r
example_register$pests |> 
  filter(pNbr == 7105L, use_nr %in% 1:2) |> 
  select(use_nr, ends_with("de"), ends_with("fr")) |> 
  kable()
```

| use_nr | pest_de                               | pest_add_txt_de | pest_fr                   | pest_add_txt_fr |
|-------:|:--------------------------------------|:----------------|:--------------------------|:----------------|
|      1 | Einjährige Dicotyledonen (Unkräuter)  |                 | dicotylédones annuelles   |                 |
|      1 | Einjährige Monocotyledonen (Ungräser) |                 | monocotylédones annuelles |                 |
|      2 | Einjährige Dicotyledonen (Unkräuter)  |                 | dicotylédones annuelles   |                 |
|      2 | Einjährige Monocotyledonen (Ungräser) |                 | monocotylédones annuelles |                 |

### Unique combinations of cultures and target organisms

In the calculations of mean application rates for the Swiss National
Risk Indicator (Korkaric et al. 2022, 2023), unique combinations of
product, culture, and target organism were termed “indications”. Note
that when using this definition of indications, each XML section
`<Indication>` can describe several indications. The relation between
uses (`<Indication>` sections) and indications as defined in the
indicator project is illustrated below.

``` r
culture_pest_combinations <- example_register$uses |> 
  filter(pNbr == 6521L) |> 
  left_join(example_register$cultures, by = c("pNbr", "use_nr")) |> 
  left_join(example_register$pests, by = c("pNbr", "use_nr")) |> 
  select(pNbr, use_nr, application_area_de, culture_de, pest_de)

kable(culture_pest_combinations)
```

| pNbr | use_nr | application_area_de | culture_de                         | pest_de                             |
|-----:|-------:|:--------------------|:-----------------------------------|:------------------------------------|
| 6521 |      1 | Gemüsebau           | Spargel                            | Spargelrost                         |
| 6521 |      1 | Gemüsebau           | Spargel                            | Blattschwärze der Spargel           |
| 6521 |      2 | Feldbau             | Weizen                             | Gelbrost                            |
| 6521 |      3 | Feldbau             | Weizen                             | Septoria-Spelzenbräune (S. nodorum) |
| 6521 |      4 | Feldbau             | Weizen                             | Ährenfusariosen                     |
| 6521 |      5 | Feldbau             | Weizen                             | Echter Mehltau des Getreides        |
| 6521 |      6 | Feldbau             | Grasbestände zur Saatgutproduktion | Blattfleckenpilze                   |
| 6521 |      6 | Feldbau             | Grasbestände zur Saatgutproduktion | Rost der Gräser                     |
| 6521 |      7 | Feldbau             | Winterroggen                       | Braunrost                           |
| 6521 |      8 | Feldbau             | Lupinen                            | Anthraknose                         |
| 6521 |      9 | Feldbau             | Lein                               | Stängelbräune des Leins             |
| 6521 |      9 | Feldbau             | Lein                               | Pasmokrankheit                      |
| 6521 |      9 | Feldbau             | Lein                               | Echter Mehltau des Leins            |
| 6521 |     10 | Feldbau             | Raps                               | Erhöhung der Standfestigkeit        |
| 6521 |     10 | Feldbau             | Raps                               | Wurzelhals- und Stengelfäule        |
| 6521 |     11 | Feldbau             | Eiweisserbse                       | Graufäule (Botrytis cinerea)        |
| 6521 |     11 | Feldbau             | Eiweisserbse                       | Rost der Erbse                      |
| 6521 |     11 | Feldbau             | Eiweisserbse                       | Brennfleckenkrankheit der Erbse     |
| 6521 |     12 | Gemüsebau           | Erbsen                             | Brennfleckenkrankheit der Erbse     |
| 6521 |     12 | Gemüsebau           | Erbsen                             | Rost der Erbse                      |
| 6521 |     12 | Gemüsebau           | Erbsen                             | Graufäule (Botrytis cinerea)        |
| 6521 |     13 | Feldbau             | Ackerbohne                         | Rost der Ackerbohne                 |
| 6521 |     13 | Feldbau             | Ackerbohne                         | Braunfleckenkrankheit               |
| 6521 |     14 | Feldbau             | Raps                               | Wurzelhals- und Stengelfäule        |
| 6521 |     15 | Feldbau             | Raps                               | Sclerotinia-Fäule                   |

In this example, there are 25 such “indications” for the 15 uses.

### Application comments

Sometimes, use specific comments can be found in the
`application_comments` table.

``` r
example_register$application_comments |>
  filter(pNbr == 7105, use_nr %in% 1:2) |> 
  select(pNbr, use_nr, ends_with("de"), ends_with("fr")) |> 
  kable()
```

| pNbr | use_nr | application_comment_de    | application_comment_fr       |
|-----:|-------:|:--------------------------|:-----------------------------|
| 7105 |      1 | 7 Tage nach dem Pflanzen. | 7 jours après la plantation. |
| 7105 |      2 | 7 Tage nach dem Pflanzen. | 7 jours après la plantation. |

### Obligations

The use conditions for each use are listed in the table `obligations`.
In the following example, the column `sw_runoff_points` is selected in
the output, as both use authorisations are conditional on risk
mitigation for runoff to surface water amounting to at least one point.

``` r
example_register$obligations |>
  filter(pNbr == 7105, use_nr %in% 1:2) |> 
  select(pNbr, use_nr, code, obligation_de, sw_runoff_points) |> 
  kable()
```

| pNbr | use_nr | code                                     | obligation_de                                                                                                                                                                                                                                                                                                                                                                               | sw_runoff_points |
|-----:|-------:|:-----------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------:|
| 7105 |      1 | obligation 692                           | Nachbau anderer Kulturen: 16 Wochen Wartefrist.                                                                                                                                                                                                                                                                                                                                             |                  |
| 7105 |      1 | N01: Profi Re-entry                      | Nachfolgearbeiten in behandelten Kulturen: bis 48 Stunden nach Ausbringung des Mittels Schutzhandschuhe + Schutzanzug tragen.                                                                                                                                                                                                                                                               |                  |
| 7105 |      1 | obligation 1928                          | Maximal 1 Behandlung pro Kultur.                                                                                                                                                                                                                                                                                                                                                            |                  |
| 7105 |      1 | ML01_A04_T01                             | Ansetzen der Spritzbrühe: Schutzhandschuhe tragen. Ausbringen der Spritzbrühe: Schutzhandschuhe + Schutzanzug + Visier + Kopfbedeckung tragen. Technische Schutzvorrichtungen während des Ausbringens (z.B. geschlossene Traktorkabine) können die vorgeschriebene persönliche Schutzausrüstung ersetzen, wenn gewährleistet ist, dass sie einen vergleichbaren oder höheren Schutz bieten. |                  |
| 7105 |      1 | Abschwemmung 1 Punkt                     | SPe 3: Zum Schutz von Gewässerorganismen muss das Abschwemmungsrisiko gemäss den Weisungen der Zulassungsstelle um 1 Punkt reduziert werden.                                                                                                                                                                                                                                                |                1 |
| 7105 |      1 |                                          | Splitbehandlung gemäss den Angaben der Bewilligungsinhaberin (max. 3 l/ha je Split, angegebene Aufwandmenge entspricht total bewilligter Menge).                                                                                                                                                                                                                                            |                  |
| 7105 |      1 | obligation 2032                          | Phytotoxschäden bei empfindlichen Arten oder Sorten möglich; vor allgemeiner Anwendung Versuchspritzung durchführen.                                                                                                                                                                                                                                                                        |                  |
| 7105 |      1 | Bewilligt nach Art. 35 PSMV (minor use). | Bewilligt als geringfügige Verwendung nach Art. 35 PSMV (minor use).                                                                                                                                                                                                                                                                                                                        |                  |
| 7105 |      2 | Abschwemmung 1 Punkt                     | SPe 3: Zum Schutz von Gewässerorganismen muss das Abschwemmungsrisiko gemäss den Weisungen der Zulassungsstelle um 1 Punkt reduziert werden.                                                                                                                                                                                                                                                |                1 |
| 7105 |      2 | obligation 692                           | Nachbau anderer Kulturen: 16 Wochen Wartefrist.                                                                                                                                                                                                                                                                                                                                             |                  |
| 7105 |      2 | N01: Profi Re-entry                      | Nachfolgearbeiten in behandelten Kulturen: bis 48 Stunden nach Ausbringung des Mittels Schutzhandschuhe + Schutzanzug tragen.                                                                                                                                                                                                                                                               |                  |
| 7105 |      2 | ML01_A04_T01                             | Ansetzen der Spritzbrühe: Schutzhandschuhe tragen. Ausbringen der Spritzbrühe: Schutzhandschuhe + Schutzanzug + Visier + Kopfbedeckung tragen. Technische Schutzvorrichtungen während des Ausbringens (z.B. geschlossene Traktorkabine) können die vorgeschriebene persönliche Schutzausrüstung ersetzen, wenn gewährleistet ist, dass sie einen vergleichbaren oder höheren Schutz bieten. |                  |
| 7105 |      2 | obligation 1928                          | Maximal 1 Behandlung pro Kultur.                                                                                                                                                                                                                                                                                                                                                            |                  |
| 7105 |      2 | obligation 2032                          | Phytotoxschäden bei empfindlichen Arten oder Sorten möglich; vor allgemeiner Anwendung Versuchspritzung durchführen.                                                                                                                                                                                                                                                                        |                  |
| 7105 |      2 |                                          | Splitbehandlung gemäss den Angaben der Bewilligungsinhaberin (max. 3 l/ha je Split, angegebene Aufwandmenge entspricht total bewilligter Menge).                                                                                                                                                                                                                                            |                  |
| 7105 |      2 | Bewilligt nach Art. 35 PSMV (minor use). | Bewilligt als geringfügige Verwendung nach Art. 35 PSMV (minor use).                                                                                                                                                                                                                                                                                                                        |                  |

## References

Korkaric, M., L. Ammann, I. Hanke, J. Schneuwly, M. Lehto, T. Poiger, L.
de Baan, O. Daniel, and J. F. Blom. 2022. “Nationale Risikoindikatoren
Basierend Auf Dem Verkauf von Pflanzenschutzmitteln.” *Agrarforschung
Schweiz* 13: 1–10.

Korkaric, M., M. Lehto, T. Poiger, L. de Baan, M. Mathis, L. Ammann, I.
Hanke, M. Balmer, and J. Blom. 2023. “Nationale Risikoindikatoren Für
Pflanzenschutzmittel : Weiterführende Analysen.” Journal Article.
*Agroscope Science*, 1–48.

## Appendix

### Complete culture tree

Note that a culture can be linked to two parent cultures in the tree.
Cultures that are additionally present in another position of the tree
are marked by appending ‘\[dup\]’ to their name.

``` r
print(culture_tree, "culture_id", "name_fr", "name_it", limit = 800)
```

    ##                                                                        levelName
    ## 1   Cultures                                                                    
    ## 2    ¦--allg. Ökologische Ausgleichsflächen (gemäss DZV)                        
    ## 3    ¦   °--Offene Ackerfläche                                                  
    ## 4    ¦--Zierpflanzen allg.                                                      
    ## 5    ¦   ¦--Topf- und Kontainerpflanzen                                         
    ## 6    ¦   ¦   ¦--Begonia [dup]                                                   
    ## 7    ¦   ¦   ¦--Cyclame [dup]                                                   
    ## 8    ¦   ¦   ¦--Pelargonien [dup]                                               
    ## 9    ¦   ¦   °--Primeln [dup]                                                   
    ## 10   ¦   ¦--Blumenknollen                                                       
    ## 11   ¦   ¦   °--Dahlien                                                         
    ## 12   ¦   ¦--Baumschule                                                          
    ## 13   ¦   ¦--Ziergehölze (ausserhalb Forst)                                      
    ## 14   ¦   ¦--Rosen                                                               
    ## 15   ¦   ¦--Ein- und zweijährige Zierpflanzen                                   
    ## 16   ¦   ¦   °--Sommerflor                                                      
    ## 17   ¦   ¦--Bäume und Sträucher (ausserhalb Forst)                              
    ## 18   ¦   ¦   ¦--Rhododendron                                                    
    ## 19   ¦   ¦   ¦   °--Azaleen                                                     
    ## 20   ¦   ¦   ¦--Kirschlorbeer                                                   
    ## 21   ¦   ¦   ¦--Rosskastanie                                                    
    ## 22   ¦   ¦   ¦--Blautanne [dup]                                                 
    ## 23   ¦   ¦   ¦--Buchsbäume (Buxus)                                              
    ## 24   ¦   ¦   °--Weihnachtsbäume [dup]                                           
    ## 25   ¦   ¦--Blumenkulturen und Grünpflanzen                                     
    ## 26   ¦   ¦   ¦--Iris                                                            
    ## 27   ¦   ¦   ¦--Begonia                                                         
    ## 28   ¦   ¦   ¦--Cyclame                                                         
    ## 29   ¦   ¦   ¦--Hyazinthe                                                       
    ## 30   ¦   ¦   ¦--Gladiole                                                        
    ## 31   ¦   ¦   ¦--Chrysantheme                                                    
    ## 32   ¦   ¦   ¦--Pelargonien                                                     
    ## 33   ¦   ¦   ¦--Primeln                                                         
    ## 34   ¦   ¦   ¦--Blaudistel                                                      
    ## 35   ¦   ¦   ¦--Gerbera                                                         
    ## 36   ¦   ¦   ¦--Tulpe                                                           
    ## 37   ¦   ¦   ¦--Zierkürbis                                                      
    ## 38   ¦   ¦   ¦--Liliengewächse (Zierpflanzen)                                   
    ## 39   ¦   ¦   °--Nelken                                                          
    ## 40   ¦   ¦--Gehölze (ausserhalb Forst)                                          
    ## 41   ¦   ¦   °--Nadelgehölze (Koniferen)                                        
    ## 42   ¦   ¦       ¦--Blautanne                                                   
    ## 43   ¦   ¦       ¦--Fichte                                                      
    ## 44   ¦   ¦       °--Weihnachtsbäume                                             
    ## 45   ¦   ¦--Zier- und Sportrasen                                                
    ## 46   ¦   °--Stauden                                                             
    ## 47   ¦--allg. Obstbau                                                           
    ## 48   ¦   ¦--Hartschalenobst                                                     
    ## 49   ¦   ¦   °--Nüsse                                                           
    ## 50   ¦   ¦       °--Walnuss                                                     
    ## 51   ¦   ¦--Olive                                                               
    ## 52   ¦   ¦--Kernobst                                                            
    ## 53   ¦   ¦   ¦--Birne / Nashi                                                   
    ## 54   ¦   ¦   ¦   °--Birne                                                       
    ## 55   ¦   ¦   ¦--Apfel                                                           
    ## 56   ¦   ¦   °--Quitte                                                          
    ## 57   ¦   °--Steinobst                                                           
    ## 58   ¦       ¦--Zwetschge / Pflaume                                             
    ## 59   ¦       ¦   ¦--Zwetschge                                                   
    ## 60   ¦       ¦   °--Pflaume                                                     
    ## 61   ¦       ¦--Aprikose                                                        
    ## 62   ¦       ¦--Kirsche                                                         
    ## 63   ¦       °--Pfirsich / Nektarine                                            
    ## 64   ¦--allg. Beerenbau                                                         
    ## 65   ¦   ¦--Ribes Arten                                                         
    ## 66   ¦   ¦   ¦--Schwarze Johannisbeere                                          
    ## 67   ¦   ¦   ¦--Stachelbeere                                                    
    ## 68   ¦   ¦   ¦--Jostabeere                                                      
    ## 69   ¦   ¦   °--Rote Johannisbeere                                              
    ## 70   ¦   ¦--Schwarzer Holunder                                                  
    ## 71   ¦   ¦--Mini-Kiwi                                                           
    ## 72   ¦   ¦--Rubus Arten                                                         
    ## 73   ¦   ¦   ¦--Brombeere                                                       
    ## 74   ¦   ¦   °--Himbeere                                                        
    ## 75   ¦   ¦--Schwarze Apfelbeere                                                 
    ## 76   ¦   ¦--Erdbeere                                                            
    ## 77   ¦   °--Heidelbeere                                                         
    ## 78   ¦--allg. Weinbau                                                           
    ## 79   ¦   °--Reben                                                               
    ## 80   ¦       ¦--Jungreben                                                       
    ## 81   ¦       °--Ertragsreben                                                    
    ## 82   ¦--allg. Gemüsebau                                                         
    ## 83   ¦   ¦--Kürbisgewächse (Cucurbitaceae)                                      
    ## 84   ¦   ¦   ¦--Gurken                                                          
    ## 85   ¦   ¦   ¦   °--Einlegegurken                                               
    ## 86   ¦   ¦   ¦--Melonen                                                         
    ## 87   ¦   ¦   ¦--Wassermelonen                                                   
    ## 88   ¦   ¦   ¦--Ölkürbisse                                                      
    ## 89   ¦   ¦   ¦--Speisekürbisse (ungeniessbare Schale)                           
    ## 90   ¦   ¦   °--Kürbisse mit geniessbarer Schale                                
    ## 91   ¦   ¦       ¦--Zucchetti                                                   
    ## 92   ¦   ¦       ¦--Patisson                                                    
    ## 93   ¦   ¦       °--Rondini                                                     
    ## 94   ¦   ¦--Portulakgewächse (Portulacaceae)                                    
    ## 95   ¦   ¦   °--Portulak                                                        
    ## 96   ¦   ¦       °--Gemüseportulak                                              
    ## 97   ¦   ¦--Nachtschattengewächse (Solanaceae)                                  
    ## 98   ¦   ¦   ¦--Tomaten                                                         
    ## 99   ¦   ¦   ¦   ¦--Cherrytomaten                                               
    ## 100  ¦   ¦   ¦   ¦--Rispentomaten                                               
    ## 101  ¦   ¦   ¦   °--Tomaten Spezialitäten                                       
    ## 102  ¦   ¦   ¦--Aubergine                                                       
    ## 103  ¦   ¦   ¦--Paprika                                                         
    ## 104  ¦   ¦   ¦   ¦--Peperoni                                                    
    ## 105  ¦   ¦   ¦   °--Gemüsepaprika                                               
    ## 106  ¦   ¦   ¦--Andenbeere                                                      
    ## 107  ¦   ¦   °--Pepino                                                          
    ## 108  ¦   ¦--Speisepilze                                                         
    ## 109  ¦   ¦--Gänsefussgewächse (Chenopodiaceae)                                  
    ## 110  ¦   ¦   ¦--Spinat                                                          
    ## 111  ¦   ¦   ¦--Mangold                                                         
    ## 112  ¦   ¦   ¦   ¦--Krautstiel                                                  
    ## 113  ¦   ¦   ¦   °--Schnittmangold                                              
    ## 114  ¦   ¦   °--Rande                                                           
    ## 115  ¦   ¦--Gewürz- und Medizinalkräuter                                        
    ## 116  ¦   ¦   °--Johanniskraut                                                   
    ## 117  ¦   ¦--Küchenkräuter                                                       
    ## 118  ¦   ¦   ¦--Schnittlauch                                                    
    ## 119  ¦   ¦   ¦--Dill                                                            
    ## 120  ¦   ¦   ¦--Kümmel                                                          
    ## 121  ¦   ¦   ¦--Minze                                                           
    ## 122  ¦   ¦   ¦--Rosmarin                                                        
    ## 123  ¦   ¦   ¦--Basilikum                                                       
    ## 124  ¦   ¦   ¦--Salbei                                                          
    ## 125  ¦   ¦   ¦--Bohnenkraut                                                     
    ## 126  ¦   ¦   ¦--Liebstöckel                                                     
    ## 127  ¦   ¦   ¦--Estragon                                                        
    ## 128  ¦   ¦   ¦--Kerbel                                                          
    ## 129  ¦   ¦   ¦--Thymian                                                         
    ## 130  ¦   ¦   ¦--Koriander                                                       
    ## 131  ¦   ¦   ¦--Ysop                                                            
    ## 132  ¦   ¦   ¦--Römische Kamille                                                
    ## 133  ¦   ¦   °--Petersilie                                                      
    ## 134  ¦   ¦--Baldrian                                                            
    ## 135  ¦   ¦--Spargelgewächse (Asparagaceae)                                      
    ## 136  ¦   ¦   °--Spargel                                                         
    ## 137  ¦   ¦--Süssgräser (Poaceae)                                                
    ## 138  ¦   ¦   °--Zuckermais                                                      
    ## 139  ¦   ¦--Lippenblütler (Labiatae)                                            
    ## 140  ¦   ¦   °--Stachys                                                         
    ## 141  ¦   ¦--Baldriangewächse (Valerianaceae)                                    
    ## 142  ¦   ¦   °--Nüsslisalat                                                     
    ## 143  ¦   ¦--Doldenblütler (Apiaceae)                                            
    ## 144  ¦   ¦   ¦--Pastinake                                                       
    ## 145  ¦   ¦   ¦--Wurzelpetersilie                                                
    ## 146  ¦   ¦   ¦--Sellerie                                                        
    ## 147  ¦   ¦   ¦   ¦--Stangensellerie                                             
    ## 148  ¦   ¦   ¦   ¦--Suppensellerie                                              
    ## 149  ¦   ¦   ¦   °--Knollensellerie                                             
    ## 150  ¦   ¦   ¦--Karotten                                                        
    ## 151  ¦   ¦   °--Knollenfenchel                                                  
    ## 152  ¦   ¦--Hülsenfrüchtler (Fabaceae)                                          
    ## 153  ¦   ¦   ¦--Erbsen                                                          
    ## 154  ¦   ¦   ¦   ¦--Erbsen ohne Hülsen                                          
    ## 155  ¦   ¦   ¦   °--Erbsen mit Hülsen                                           
    ## 156  ¦   ¦   ¦--Bohnen                                                          
    ## 157  ¦   ¦   ¦   ¦--Bohnen mit Hülsen                                           
    ## 158  ¦   ¦   ¦   ¦   ¦--Buschbohne                                              
    ## 159  ¦   ¦   ¦   ¦   °--Stangenbohne                                            
    ## 160  ¦   ¦   ¦   °--Bohnen ohne Hülsen                                          
    ## 161  ¦   ¦   ¦--Puffbohne                                                       
    ## 162  ¦   ¦   °--Linse                                                           
    ## 163  ¦   ¦--Knöterichgewächse (Polygonaceae)                                    
    ## 164  ¦   ¦   °--Rhabarber                                                       
    ## 165  ¦   ¦--Korbblütler (Asteraceae)                                            
    ## 166  ¦   ¦   ¦--Artischocken                                                    
    ## 167  ¦   ¦   ¦--Chicorée                                                        
    ## 168  ¦   ¦   ¦--Schwarzwurzel                                                   
    ## 169  ¦   ¦   ¦--Topinambur                                                      
    ## 170  ¦   ¦   ¦--Salate (Asteraceae)                                             
    ## 171  ¦   ¦   ¦   ¦--Lactuca-Salate                                              
    ## 172  ¦   ¦   ¦   ¦   ¦--Kopfsalate                                              
    ## 173  ¦   ¦   ¦   ¦   ¦   °--Kopfsalat                                           
    ## 174  ¦   ¦   ¦   ¦   °--Blattsalate (Asteraceae)                                
    ## 175  ¦   ¦   ¦   ¦       °--Schnittsalat                                        
    ## 176  ¦   ¦   ¦   ¦--Endivien und Blattzichorien                                 
    ## 177  ¦   ¦   ¦   ¦   ¦--Endivien                                                
    ## 178  ¦   ¦   ¦   ¦   ¦--Zuckerhut                                               
    ## 179  ¦   ¦   ¦   ¦   °--Radicchio- und Cicorino-Typen                           
    ## 180  ¦   ¦   ¦   °--Löwenzahn                                                   
    ## 181  ¦   ¦   °--Kardy                                                           
    ## 182  ¦   ¦--Kreuzblütler (Brassicaceae)                                         
    ## 183  ¦   ¦   ¦--Kohlarten                                                       
    ## 184  ¦   ¦   ¦   ¦--Rosenkohl                                                   
    ## 185  ¦   ¦   ¦   ¦--Blattkohle                                                  
    ## 186  ¦   ¦   ¦   ¦   ¦--Federkohl                                               
    ## 187  ¦   ¦   ¦   ¦   ¦--Pak-Choi                                                
    ## 188  ¦   ¦   ¦   ¦   ¦--Stielmus                                                
    ## 189  ¦   ¦   ¦   ¦   ¦--Markstammkohl                                           
    ## 190  ¦   ¦   ¦   ¦   °--Chinakohl                                               
    ## 191  ¦   ¦   ¦   ¦--Blumenkohle                                                 
    ## 192  ¦   ¦   ¦   ¦   ¦--Romanesco                                               
    ## 193  ¦   ¦   ¦   ¦   ¦--Blumenkohl                                              
    ## 194  ¦   ¦   ¦   ¦   °--Broccoli                                                
    ## 195  ¦   ¦   ¦   ¦--Kopfkohle                                                   
    ## 196  ¦   ¦   ¦   °--Kohlrabi                                                    
    ## 197  ¦   ¦   ¦--Kresse                                                          
    ## 198  ¦   ¦   ¦--Meerrettich                                                     
    ## 199  ¦   ¦   ¦--Rucola                                                          
    ## 200  ¦   ¦   ¦--Barbarakraut                                                    
    ## 201  ¦   ¦   ¦--Speisekohlrüben                                                 
    ## 202  ¦   ¦   ¦   ¦--Brassica rapa-Rüben                                         
    ## 203  ¦   ¦   ¦   °--Brassica napus-Rüben                                        
    ## 204  ¦   ¦   ¦       °--Bodenkohlrabi                                           
    ## 205  ¦   ¦   ¦--Asia-Salate (Brassicaceae)                                      
    ## 206  ¦   ¦   ¦--Cima di Rapa                                                    
    ## 207  ¦   ¦   ¦--Brunnenkresse                                                   
    ## 208  ¦   ¦   ¦--Radies                                                          
    ## 209  ¦   ¦   °--Rettich                                                         
    ## 210  ¦   °--Liliengewächse (Liliaceae)                                          
    ## 211  ¦       ¦--Schalotten                                                      
    ## 212  ¦       ¦--Lauch                                                           
    ## 213  ¦       ¦--Zwiebeln                                                        
    ## 214  ¦       ¦   ¦--Gemüsezwiebel                                               
    ## 215  ¦       ¦   ¦--Speisezwiebel                                               
    ## 216  ¦       ¦   °--Bundzwiebeln                                                
    ## 217  ¦       °--Knoblauch                                                       
    ## 218  ¦--allg. Feldbau                                                           
    ## 219  ¦   ¦--Mais                                                                
    ## 220  ¦   ¦--Raps                                                                
    ## 221  ¦   ¦   °--Winterraps                                                      
    ## 222  ¦   ¦--Chinaschilf                                                         
    ## 223  ¦   ¦--Futter- und Zuckerrüben                                             
    ## 224  ¦   ¦   ¦--Futterrübe                                                      
    ## 225  ¦   ¦   °--Zuckerrübe                                                      
    ## 226  ¦   ¦--Kenaf                                                               
    ## 227  ¦   ¦--Tabak                                                               
    ## 228  ¦   ¦--Sojabohne                                                           
    ## 229  ¦   ¦--Getreide                                                            
    ## 230  ¦   ¦   ¦--Weizen                                                          
    ## 231  ¦   ¦   ¦   ¦--Korn (Dinkel) [dup]                                         
    ## 232  ¦   ¦   ¦   ¦--Emmer [dup]                                                 
    ## 233  ¦   ¦   ¦   ¦--Hartweizen                                                  
    ## 234  ¦   ¦   ¦   °--Weichweizen                                                 
    ## 235  ¦   ¦   ¦       ¦--Winterweizen [dup]                                      
    ## 236  ¦   ¦   ¦       °--Sommerweizen [dup]                                      
    ## 237  ¦   ¦   ¦--Gerste                                                          
    ## 238  ¦   ¦   ¦   ¦--Sommergerste [dup]                                          
    ## 239  ¦   ¦   ¦   °--Wintergerste [dup]                                          
    ## 240  ¦   ¦   ¦--Triticale                                                       
    ## 241  ¦   ¦   ¦   °--Wintertriticale [dup]                                       
    ## 242  ¦   ¦   ¦--Roggen                                                          
    ## 243  ¦   ¦   ¦   °--Winterroggen [dup]                                          
    ## 244  ¦   ¦   ¦--Hafer                                                           
    ## 245  ¦   ¦   ¦   °--Sommerhafer [dup]                                           
    ## 246  ¦   ¦   ¦--Sommergetreide                                                  
    ## 247  ¦   ¦   ¦   ¦--Sommerweizen                                                
    ## 248  ¦   ¦   ¦   ¦--Sommergerste                                                
    ## 249  ¦   ¦   ¦   °--Sommerhafer                                                 
    ## 250  ¦   ¦   °--Wintergetreide                                                  
    ## 251  ¦   ¦       ¦--Winterweizen                                                
    ## 252  ¦   ¦       ¦--Korn (Dinkel)                                               
    ## 253  ¦   ¦       ¦--Wintertriticale                                             
    ## 254  ¦   ¦       ¦--Emmer                                                       
    ## 255  ¦   ¦       ¦--Wintergerste                                                
    ## 256  ¦   ¦       °--Winterroggen                                                
    ## 257  ¦   ¦--Kartoffeln                                                          
    ## 258  ¦   ¦   ¦--Speise- und Futterkartoffeln                                    
    ## 259  ¦   ¦   °--Kartoffeln zur Pflanzgutproduktion                              
    ## 260  ¦   ¦--Hopfen                                                              
    ## 261  ¦   ¦--Ackerbohne                                                          
    ## 262  ¦   ¦--Eiweisserbse                                                        
    ## 263  ¦   ¦--Wiesen und Weiden                                                   
    ## 264  ¦   ¦   °--Kleegrasmischung (Kunstwiese)                                   
    ## 265  ¦   ¦--Sonnenblume                                                         
    ## 266  ¦   ¦--Luzerne                                                             
    ## 267  ¦   ¦--Lupinen                                                             
    ## 268  ¦   ¦--Anbautechnik                                                        
    ## 269  ¦   ¦   ¦--Frässaaten                                                      
    ## 270  ¦   ¦   °--Mulchsaaten                                                     
    ## 271  ¦   ¦--Lein                                                                
    ## 272  ¦   ¦--Grasbestände zur Saatgutproduktion                                  
    ## 273  ¦   ¦--Trockenreis                                                         
    ## 274  ¦   ¦--Färberdistel (Saflor)                                               
    ## 275  ¦   ¦--Klee zur Saatgutproduktion                                          
    ## 276  ¦   °--Sorghum                                                             
    ## 277  ¦--allg. Forstwirtschaft                                                   
    ## 278  ¦   °--Liegendes Rundholz im Wald und auf Lagerplätzen                     
    ## 279  ¦--Allgemein Vorratsschutz                                                 
    ## 280  ¦   ¦--Lagerhallen, Mühlen, Silogebäude                                    
    ## 281  ¦   ¦--Einrichtungen und Geräte                                            
    ## 282  ¦   ¦--Verarbeitungsräume                                                  
    ## 283  ¦   °--Lagerräume                                                          
    ## 284  ¦--Grünfläche                                                              
    ## 285  ¦--Mohn                                                                    
    ## 286  ¦--Baby-Leaf                                                               
    ## 287  ¦   ¦--Baby-Leaf (Brassicaceae)                                            
    ## 288  ¦   ¦--Baby-Leaf (Asteraceae)                                              
    ## 289  ¦   °--Baby-Leaf (Chenopodiaceae)                                          
    ## 290  ¦--Medizinalkräuter                                                        
    ## 291  ¦   °--Wolliger Fingerhut                                                  
    ## 292  ¦--Holzpaletten, Packholz, Stammholz                                       
    ## 293  ¦--Melisse                                                                 
    ## 294  ¦--Brachland                                                               
    ## 295  ¦--Humusdeponie                                                            
    ## 296  ¦--Anemone                                                                 
    ## 297  ¦--Ranunkel                                                                
    ## 298  ¦--Obstbau allg.                                                           
    ## 299  ¦--Beerenbau allg.                                                         
    ## 300  ¦--Gemüsebau allg.                                                         
    ## 301  ¦--Feldbau allg.                                                           
    ## 302  ¦   °--Hanf                                                                
    ## 303  ¦--Blumenzwiebeln und Blumenknollen                                        
    ## 304  ¦--Nichtkulturland allg.                                                   
    ## 305  ¦   ¦--Böschungen und Grünstreifen entlang von Verkehrswegen (gem. ChemRRV)
    ## 306  ¦   °--Auf und an National- und Kantonsstrassen (gem. ChemRRV)             
    ## 307  ¦--Forstwirtschaft allg.                                                   
    ## 308  ¦   ¦--Wald                                                                
    ## 309  ¦   ¦   °--Forstliche Pflanzgärten [dup]                                   
    ## 310  ¦   °--Forstliche Pflanzgärten                                             
    ## 311  ¦--Majoran                                                                 
    ## 312  ¦--Oregano                                                                 
    ## 313  ¦--Rosenwurz                                                               
    ## 314  ¦--Traubensilberkerze                                                      
    ## 315  ¦--Spitzwegerich                                                           
    ## 316  ¦--Erntegut                                                                
    ## 317  ¦--Gewürzfenchel                                                           
    ## 318  ¦--leere Lagerräume                                                        
    ## 319  ¦--leere Produktionsräume                                                  
    ## 320  ¦--Tabak produzierende Betriebe                                            
    ## 321  ¦--leere Verarbeitungsräume                                                
    ## 322  ¦--Lager- und Produktionsräume allg.                                       
    ## 323  ¦--Gojibeere                                                               
    ## 324  ¦--Quinoa                                                                  
    ## 325  ¦--Blaue Heckenkirsche                                                     
    ## 326  ¦--Lorbeer                                                                 
    ## 327  ¦--Hagebutten                                                              
    ## 328  ¦--Kichererbse                                                             
    ## 329  ¦--Sanddorn                                                                
    ## 330  ¦--Schwarze Maulbeere                                                      
    ## 331  ¦--Eberesche                                                               
    ## 332  ¦--Gemeine Felsenbirne                                                     
    ## 333  ¦--Süssdolde                                                               
    ## 334  ¦--Kerbelrübe                                                              
    ## 335  ¦--Windengewächse (Convolvulaceae)                                         
    ## 336  ¦   °--Süsskartoffel                                                       
    ## 337  ¦--Rispenhirse                                                             
    ## 338  ¦--Pflanzen                                                                
    ## 339  °--Brache                                                                  
    ##     culture_id
    ## 1             
    ## 2        10172
    ## 3        10227
    ## 4        10190
    ## 5        10021
    ## 6        10040
    ## 7        10050
    ## 8        10097
    ## 9        10098
    ## 10       10039
    ## 11       10162
    ## 12       10095
    ## 13       10101
    ## 14       10104
    ## 15       10176
    ## 16        9969
    ## 17       12096
    ## 18       10100
    ## 19       10099
    ## 20       10103
    ## 21       10109
    ## 22       10110
    ## 23       10152
    ## 24       10290
    ## 25       12097
    ## 26       10004
    ## 27       10040
    ## 28       10050
    ## 29       10070
    ## 30       10090
    ## 31       10096
    ## 32       10097
    ## 33       10098
    ## 34       10136
    ## 35       10147
    ## 36       10158
    ## 37       10256
    ## 38       11335
    ## 39        9955
    ## 40        9952
    ## 41       10111
    ## 42       10110
    ## 43       10157
    ## 44       10290
    ## 45        9967
    ## 46        9968
    ## 47       10192
    ## 48       10260
    ## 49       10117
    ## 50       10091
    ## 51       10277
    ## 52        9959
    ## 53       10296
    ## 54        9972
    ## 55        9970
    ## 56        9994
    ## 57        9965
    ## 58       10011
    ## 59       10126
    ## 60        9993
    ## 61        9971
    ## 62        9982
    ## 63        9992
    ## 64       10193
    ## 65       10127
    ## 66       10003
    ## 67       10007
    ## 68       10035
    ## 69        9999
    ## 70       10218
    ## 71       10288
    ## 72       10297
    ## 73        9975
    ## 74        9980
    ## 75       12829
    ## 76        9978
    ## 77        9979
    ## 78       10194
    ## 79        9953
    ## 80       10037
    ## 81       10114
    ## 82       10195
    ## 83       10017
    ## 84       10016
    ## 85       10258
    ## 86       10019
    ## 87       10022
    ## 88       10188
    ## 89       10264
    ## 90       10310
    ## 91       10018
    ## 92       10082
    ## 93       10266
    ## 94       10025
    ## 95       10342
    ## 96       10033
    ## 97       10026
    ## 98       10027
    ## 99       10332
    ## 100      10333
    ## 101      10335
    ## 102      10028
    ## 103      10029
    ## 104      10084
    ## 105      10336
    ## 106      10285
    ## 107      10286
    ## 108      10051
    ## 109      10068
    ## 110      10006
    ## 111      10306
    ## 112      10328
    ## 113      10329
    ## 114       9996
    ## 115      10159
    ## 116      10232
    ## 117      10186
    ## 118      10002
    ## 119      10242
    ## 120      10244
    ## 121      10270
    ## 122      10274
    ## 123      10307
    ## 124      10308
    ## 125      10309
    ## 126      10311
    ## 127      10312
    ## 128      11816
    ## 129      11817
    ## 130      11819
    ## 131      11820
    ## 132      12507
    ## 133       9991
    ## 134      10243
    ## 135      10338
    ## 136      10005
    ## 137      10339
    ## 138      10010
    ## 139      10340
    ## 140      10341
    ## 141       9948
    ## 142       9990
    ## 143       9951
    ## 144      10253
    ## 145      10281
    ## 146       9946
    ## 147      10067
    ## 148      10171
    ## 149       9985
    ## 150       9981
    ## 151       9984
    ## 152       9957
    ## 153      10034
    ## 154      10294
    ## 155      10295
    ## 156      10128
    ## 157      10292
    ## 158      10074
    ## 159      10081
    ## 160      10293
    ## 161      10330
    ## 162      12689
    ## 163       9960
    ## 164       9998
    ## 165       9961
    ## 166      10053
    ## 167      10056
    ## 168      10063
    ## 169      10064
    ## 170      10093
    ## 171      10304
    ## 172      10320
    ## 173      10060
    ## 174       9944
    ## 175      10323
    ## 176      10325
    ## 177      10059
    ## 178      10065
    ## 179      10326
    ## 180      10327
    ## 181      10272
    ## 182       9962
    ## 183      10020
    ## 184      10047
    ## 185      10210
    ## 186      10043
    ## 187      10315
    ## 188      10317
    ## 189      14985
    ## 190       9977
    ## 191      10284
    ## 192      10314
    ## 193       9973
    ## 194       9974
    ## 195      10316
    ## 196       9986
    ## 197      10044
    ## 198      10237
    ## 199      10245
    ## 200      10283
    ## 201      10298
    ## 202      10299
    ## 203      10300
    ## 204      10303
    ## 205      10305
    ## 206      10318
    ## 207      10319
    ## 208       9995
    ## 209       9997
    ## 210       9963
    ## 211      10001
    ## 212      10030
    ## 213      10031
    ## 214      10075
    ## 215      10078
    ## 216      10337
    ## 217       9983
    ## 218      10197
    ## 219      10000
    ## 220      10008
    ## 221      10155
    ## 222      10042
    ## 223      10046
    ## 224      10088
    ## 225      10089
    ## 226      10048
    ## 227      10071
    ## 228      10072
    ## 229      10080
    ## 230      10052
    ## 231      10122
    ## 232      10271
    ## 233      11321
    ## 234      13784
    ## 235      10094
    ## 236      10118
    ## 237      10083
    ## 238      10143
    ## 239       9943
    ## 240      10119
    ## 241      10180
    ## 242      10120
    ## 243       9945
    ## 244      10121
    ## 245      10144
    ## 246      10164
    ## 247      10118
    ## 248      10143
    ## 249      10144
    ## 250      10167
    ## 251      10094
    ## 252      10122
    ## 253      10180
    ## 254      10271
    ## 255       9943
    ## 256       9945
    ## 257      10086
    ## 258      10346
    ## 259      11326
    ## 260      10115
    ## 261      10116
    ## 262      10124
    ## 263      10135
    ## 264      10151
    ## 265      10137
    ## 266      10150
    ## 267      10187
    ## 268      10198
    ## 269      10133
    ## 270      10142
    ## 271      10225
    ## 272      10236
    ## 273      10248
    ## 274      10252
    ## 275      11325
    ## 276      11393
    ## 277      10202
    ## 278       9956
    ## 279      10203
    ## 280      10038
    ## 281      10132
    ## 282      10279
    ## 283      10280
    ## 284      10230
    ## 285      10238
    ## 286      10251
    ## 287      14382
    ## 288      14383
    ## 289      14384
    ## 290      10254
    ## 291      10267
    ## 292      10261
    ## 293      10268
    ## 294      11877
    ## 295      11878
    ## 296      11984
    ## 297      11985
    ## 298      12066
    ## 299      12067
    ## 300      12068
    ## 301      12069
    ## 302      14729
    ## 303      12098
    ## 304      12147
    ## 305      10178
    ## 306      10179
    ## 307      12465
    ## 308      12464
    ## 309       9954
    ## 310       9954
    ## 311      12626
    ## 312      12627
    ## 313      12628
    ## 314      12629
    ## 315      12630
    ## 316      12891
    ## 317      12970
    ## 318      12999
    ## 319      13000
    ## 320      13001
    ## 321      13002
    ## 322      13238
    ## 323      13362
    ## 324      13498
    ## 325      13785
    ## 326      13832
    ## 327      14001
    ## 328      14273
    ## 329      14786
    ## 330      14787
    ## 331      14799
    ## 332      14801
    ## 333      14904
    ## 334      15269
    ## 335      15866
    ## 336      13905
    ## 337      15872
    ## 338       9942
    ## 339       9950
    ##                                                                       name_fr
    ## 1                                                                            
    ## 2                     domaine surfaces de compensation écologique (selon OPD)
    ## 3                                                             terres ouvertes
    ## 4                                              culture ornementale en général
    ## 5                                              plantes en pot et en container
    ## 6                                                                     bégonia
    ## 7                                                                    cyclamen
    ## 8                                                                    géranium
    ## 9                                                                  primevères
    ## 10                                                       tubercules de fleurs
    ## 11                                                                     dahlia
    ## 12                                                                  pépinière
    ## 13                                           arbustes d'ornement (hors forêt)
    ## 14                                                                     rosier
    ## 15                             plantes ornementales annuelles et bisannuelles
    ## 16                                                           fleurs estivales
    ## 17                                            arbres et arbustes (hors fôret)
    ## 18                                                               rhododendron
    ## 19                                                                     azalée
    ## 20                                                             laurier-cerise
    ## 21                                                          marronnier d'Inde
    ## 22                                                                 sapin bleu
    ## 23                                                               buis (Buxus)
    ## 24                                                             arbres de Noël
    ## 25                                        cultures florales et plantes vertes
    ## 26                                                                       iris
    ## 27                                                                    bégonia
    ## 28                                                                   cyclamen
    ## 29                                                                   jacinthe
    ## 30                                                                    glaïeul
    ## 31                                                               chrysanthème
    ## 32                                                                   géranium
    ## 33                                                                 primevères
    ## 34                                                               chardon bleu
    ## 35                                                                    gerbera
    ## 36                                                                     tulipe
    ## 37                                                          courge d'ornement
    ## 38                                           liliacées (plantes ornementales)
    ## 39                                                                    oeillet
    ## 40                                             plantes ligneuses (hors forêt)
    ## 41                                                                  conifères
    ## 42                                                                 sapin bleu
    ## 43                                                                     épicéa
    ## 44                                                             arbres de Noël
    ## 45                                      gazon d'ornement et terrains de sport
    ## 46                                                            plantes vivaces
    ## 47                                                 domaine app. arboriculture
    ## 48                                                            noix en général
    ## 49                                                                       noix
    ## 50                                                                      noyer
    ## 51                                                                    olivier
    ## 52                                                            fruits à pépins
    ## 53                                                            poirier / nashi
    ## 54                                                                    poirier
    ## 55                                                                    pommier
    ## 56                                                                 cognassier
    ## 57                                                            fruits à noyaux
    ## 58                                                    prunier (pruneau/prune)
    ## 59                                                          prunier (pruneau)
    ## 60                                                            prunier (prune)
    ## 61                                                                 abricotier
    ## 62                                                                   cerisier
    ## 63                                                         pêcher / nectarine
    ## 64                                                         domaine app. baies
    ## 65                                                           espèces de Ribes
    ## 66                                                                     cassis
    ## 67                                                     groseilles à maquereau
    ## 68                                                                      josta
    ## 69                                                       groseilles à grappes
    ## 70                                                               grand sureau
    ## 71                                                          mini-Kiwi (Kiwaï)
    ## 72                                                           espèces de Rubus
    ## 73                                                                       mûre
    ## 74                                                                  framboise
    ## 75                                                               aronie noire
    ## 76                                                                     fraise
    ## 77                                                                   myrtille
    ## 78                                                        domaine app. vignes
    ## 79                                                                      vigne
    ## 80                                                                jeune vigne
    ## 81                                                        vigne en production
    ## 82                                                    domaine app. maraîchère
    ## 83                                                              cucurbitacées
    ## 84                                                                  concombre
    ## 85                                                                 cornichons
    ## 86                                                                     melons
    ## 87                                                                   pastèque
    ## 88                                                       courges oléagineuses
    ## 89                                            courges (écorce non comestible)
    ## 90                                                  courges à peau comestible
    ## 91                                                                  courgette
    ## 92                                                                   pâtisson
    ## 93                                                                    rondini
    ## 94                                              portulacacées (Portulacaceae)
    ## 95                                                                   pourpier
    ## 96                                                            pourpier commun
    ## 97                                                                 solanacées
    ## 98                                                                     tomate
    ## 99                                                              tomate-cerise
    ## 100                                                           tomate à grappe
    ## 101                                                      tomates, spécialités
    ## 102                                                                 aubergine
    ## 103                                                                   poivron
    ## 104                                                                   poivron
    ## 105                                                              poivron doux
    ## 106                                                         coqueret du Pérou
    ## 107                                                               poire melon
    ## 108                                                   champignons comestibles
    ## 109                                                            chénopodiacées
    ## 110                                                                   épinard
    ## 111                                                                     bette
    ## 112                                                              bette à côte
    ## 113                                                            bette à tondre
    ## 114                                                        betterave à salade
    ## 115                                         herbes aromatiques et médicinales
    ## 116                                                              millepertuis
    ## 117                                                              fines herbes
    ## 118                                                                ciboulette
    ## 119                                                                     aneth
    ## 120                                                                     carvi
    ## 121                                                                    menthe
    ## 122                                                                   romarin
    ## 123                                                                   basilic
    ## 124                                                                     sauge
    ## 125                                                                 sarriette
    ## 126                                                                   livèche
    ## 127                                                                  estragon
    ## 128                                                                  cerfeuil
    ## 129                                                                      thym
    ## 130                                                                 coriandre
    ## 131                                                                    Hysope
    ## 132                                                         Camomille romaine
    ## 133                                                                    persil
    ## 134                                                                 valériane
    ## 135                                               asparagacées (Asparagaceae)
    ## 136                                                                   asperge
    ## 137                                                       poacées (Gramineae)
    ## 138                                                                maïs sucré
    ## 139                                                      lamiacées (Labiatae)
    ## 140                                                          crosnes du japon
    ## 141                                                             valérianacées
    ## 142                                                             mâche, rampon
    ## 143                                                   ombellifères (Apiaceae)
    ## 144                                                                    Panais
    ## 145                                                    persil à grosse racine
    ## 146                                                                    céleri
    ## 147                                                            céleri-branche
    ## 148                                                céleri-pomme pour bouillon
    ## 149                                                              céleri-pomme
    ## 150                                                                   carotte
    ## 151                                                           fenouil bulbeux
    ## 152                                                   fabacées (légumineuses)
    ## 153                                                                      pois
    ## 154                                                              pois écossés
    ## 155                                                          pois non écossés
    ## 156                                                                  haricots
    ## 157                                                      haricots non écossés
    ## 158                                                              haricot nain
    ## 159                                                           haricot à rames
    ## 160                                                          haricots écossés
    ## 161                                                                      fève
    ## 162                                                                  lentille
    ## 163                                                              polygonacées
    ## 164                                                                  rhubarbe
    ## 165                                                     composées (Asteracea)
    ## 166                                                                 artichaut
    ## 167                                        chicorée witloof (chicorée-endive)
    ## 168                                                                scorsonère
    ## 169                                                               topinambour
    ## 170                                                      salades (Asteraceae)
    ## 171                                                           salades lactuca
    ## 172                                                           laitues pommées
    ## 173                                                             laitue pommée
    ## 174                                             laitues à tondre (Asteraceae)
    ## 175                                                           laitue à tondre
    ## 176                                    chicorée pommée et chicorée à feuilles
    ## 177                                         chicorée scarole, chicorée frisée
    ## 178                                                    chicorée pain de sucre
    ## 179                                   types de radicchio/trévises et cicorino
    ## 180                                                              dent-de-lion
    ## 181                                                                    cardon
    ## 182                                                 crucifères (Brassicaceae)
    ## 183                                                                     choux
    ## 184                                                         chou de Bruxelles
    ## 185                                                          choux à feuilles
    ## 186                                                      chou frisé non pommé
    ## 187                                                                   pakchoi
    ## 188                                                            navet à tondre
    ## 189                                                             chou moellier
    ## 190                                                             chou de Chine
    ## 191                                  choux (développement de l'inflorescence)
    ## 192                                                                 romanesco
    ## 193                                                                chou-fleur
    ## 194                                                                   brocoli
    ## 195                                                              choux pommés
    ## 196                                                                   colrave
    ## 197                                                         cresson de jardin
    ## 198                                                                   raifort
    ## 199                                                                  roquette
    ## 200                                                     Barbarée du printemps
    ## 201                                         rave de Brassica rapa et B. napus
    ## 202                                                     rave de Brassica rapa
    ## 203                                                    rave de Brassica napus
    ## 204                                                                  rutabaga
    ## 205                                               salades Asia (Brassicaceae)
    ## 206                                                              cima di rapa
    ## 207                                                       cresson de fontaine
    ## 208                                                    radis de tous les mois
    ## 209                                                                radis long
    ## 210                                                                 liliacées
    ## 211                                                                  échalote
    ## 212                                                                   poireau
    ## 213                                                                    oignon
    ## 214                                                            oignon potager
    ## 215                                                        oignon (condiment)
    ## 216                                                          oignons en botte
    ## 217                                                                       ail
    ## 218                                               domaine app. grande culture
    ## 219                                                                      Maïs
    ## 220                                                                     Colza
    ## 221                                                           Colza d'automne
    ## 222                                                           Roseau de Chine
    ## 223                                          betteraves à sucre et fourragère
    ## 224                                                      Betterave fourragère
    ## 225                                                         Betterave à sucre
    ## 226                                                                     Kenaf
    ## 227                                                                     Tabac
    ## 228                                                                      Soja
    ## 229                                                                  Céréales
    ## 230                                                                       Blé
    ## 231                                                                  Épeautre
    ## 232                                                                Amidonnier
    ## 233                                                                   Blé dur
    ## 234                                                                Blé tendre
    ## 235                                                             Blé d'automne
    ## 236                                                          Blé de printemps
    ## 237                                                                      Orge
    ## 238                                                         orge de printemps
    ## 239                                                            Orge d'automne
    ## 240                                                                 Triticale
    ## 241                                                       Triticale d'automne
    ## 242                                                                    Seigle
    ## 243                                                          Seigle d'automne
    ## 244                                                                    Avoine
    ## 245                                                       Avoine de printemps
    ## 246                                                     Céréales de printemps
    ## 247                                                          Blé de printemps
    ## 248                                                         orge de printemps
    ## 249                                                       Avoine de printemps
    ## 250                                                        Céréales d'automne
    ## 251                                                             Blé d'automne
    ## 252                                                                  Épeautre
    ## 253                                                       Triticale d'automne
    ## 254                                                                Amidonnier
    ## 255                                                            Orge d'automne
    ## 256                                                          Seigle d'automne
    ## 257                                                           pommes de terre
    ## 258                             pommes de terre de consommation et fourragère
    ## 259                              pommes de terre pour la production de plants
    ## 260                                                                   Houblon
    ## 261                                                                  féverole
    ## 262                                                         pois protéagineux
    ## 263                                                     Prairies et pâturages
    ## 264                           mélange trèfles-graminées (prairie arificielle)
    ## 265                                                                 Tournesol
    ## 266                                                                   Luzerne
    ## 267                                                                     Lupin
    ## 268                                                     techniques culturales
    ## 269                                           semis après travail superficiel
    ## 270                                                        semis sous litière
    ## 271                                                                       Lin
    ## 272                                  Graminées pour la production de semences
    ## 273                                                 Riz semis sur terrain sec
    ## 274                                                                  Carthame
    ## 275                                    Trèfles pour la production de semences
    ## 276                                                             Sorgho commun
    ## 277                                                 domaine app. sylviculture
    ## 278                             grumes en forêt et sur les places de stockage
    ## 279                                                   protection des récoltes
    ## 280                                                 entrepôts, moulins, silos
    ## 281                                                   installations et outils
    ## 282                                                  locaux de transformation
    ## 283                                                                 entrepôts
    ## 284                                                       surfaces herbagères
    ## 285                                                                     pavot
    ## 286                                                                 Baby-Leaf
    ## 287                                                  Baby-Leaf (Brassicaceae)
    ## 288                                                    Baby-Leaf (Asteraceae)
    ## 289                                                Baby-Leaf (Chenopodiaceae)
    ## 290                                                       plantes médicinales
    ## 291                                                         digitale lanifère
    ## 292                        Palette en bois, bois d'emballage, bois en général
    ## 293                                                                   mélisse
    ## 294                                                                    friche
    ## 295                                                   dépôt de terre végétale
    ## 296                                                                   anémone
    ## 297                                                                ranunculus
    ## 298                                                  arboriculture en général
    ## 299                                              culture des baies en général
    ## 300                                             culture maraîchère en général
    ## 301                                                 grande culture en général
    ## 302                                                                   Chanvre
    ## 303                                                        bulbes ornementaux
    ## 304                                           domaine non agricole en général
    ## 305 talus et bandes vertes le long des voies de communication (selon ORRChim)
    ## 306              le long des routes nationales et cantonales  (selon ORRChim)
    ## 307                                                   sylviculture en général
    ## 308                                                                     forêt
    ## 309                                                    pépinières forestières
    ## 310                                                    pépinières forestières
    ## 311                                                                marjolaine
    ## 312                                                                    origan
    ## 313                                                                Orpin rose
    ## 314                                                            actée à grappe
    ## 315                                                         plantain lancéolé
    ## 316                                                            denrée stockée
    ## 317                                                        fenouil aromatique
    ## 318                                                           Êntrepôts vides
    ## 319                                                Locaux de production vides
    ## 320                                               Les exploitations tabacoles
    ## 321                                            Locaux de transformation vides
    ## 322                                         Lager- und Produktionsräume allg.
    ## 323                                                             Baies de Goji
    ## 324                                                                    Quinoa
    ## 325                                                           camérisier bleu
    ## 326                                                                   Laurier
    ## 327                                                                cynorhodon
    ## 328                                                               pois chiche
    ## 329                                                                 argousier
    ## 330                                                               mûrier noir
    ## 331                                                     sorbier des oiseleurs
    ## 332                                                          amélavier commun
    ## 333                                                           Cerfeuil musqué
    ## 334                                                         Cerfeuil tubéreux
    ## 335                                           convolvulacées (Convolvulaceae)
    ## 336                                                              Patate douce
    ## 337                                                                    Millet
    ## 338                                                                   plantes
    ## 339                                                                   jachère
    ##                                                                             name_it
    ## 1                                                                                  
    ## 2              Superfici di compensazione ecologica in generale (conformemente OPD)
    ## 3                                                         Superficie coltiva aperta
    ## 4                                            Coltivazione piante ornam. in generale
    ## 5                                                     Pianta in vaso e in container
    ## 6                                                                           Begonia
    ## 7                                                                         Ciclamino
    ## 8                                                                           Geranio
    ## 9                                                                           Primule
    ## 10                                                         Radici tuberose floreali
    ## 11                                                                            Dalie
    ## 12                                                                           Vivaio
    ## 13                                  Arbusti ornamentali (al di fuori della foresta)
    ## 14                                                                             Rose
    ## 15                                            Piante ornamentali annuali e biennali
    ## 16                                                                     Fiori estivi
    ## 17                                     Alberi e arbusti (al di fuori della foresta)
    ## 18                                                                       Rododendro
    ## 19                                                                           Azalee
    ## 20                                                                     Lauro ceraso
    ## 21                                                                      Ippocastano
    ## 22                                                               Abete del Colorado
    ## 23                                                                    Bosso (Buxus)
    ## 24                                                                 Alberi di Natale
    ## 25                                                  Colture da fiore e piante verdi
    ## 26                                                                             Iris
    ## 27                                                                          Begonia
    ## 28                                                                        Ciclamino
    ## 29                                                                         Giacinto
    ## 30                                                                         Gladiolo
    ## 31                                                                       Crisantemo
    ## 32                                                                          Geranio
    ## 33                                                                          Primule
    ## 34                                                                    Cardo azzurro
    ## 35                                                                          Gerbera
    ## 36                                                                         Tulipano
    ## 37                                                                Zucca ornamentale
    ## 38                                                    Liliacee (pianti ornamentali)
    ## 39                                                                         Garofani
    ## 40                                                Boschetti (al di fuori del bosco)
    ## 41                                                                         Conifere
    ## 42                                                               Abete del Colorado
    ## 43                                                                      Abete rosso
    ## 44                                                                 Alberi di Natale
    ## 45                                                Tappeti erbosi e terreni sportivi
    ## 46                                                                          Arbusti
    ## 47                                                                                 
    ## 48                                                                Frutta con guscio
    ## 49                                                                             Noci
    ## 50                                                                      Noce comune
    ## 51                                                                            Olivo
    ## 52                                                                Frutta a granelli
    ## 53                                                                     Pero / Nashi
    ## 54                                                                             Pero
    ## 55                                                                             Melo
    ## 56                                                                          Cotogno
    ## 57                                                                Frutta a nocciolo
    ## 58                                                                    Prugno/Susino
    ## 59                                                                           Prugno
    ## 60                                                                         Prugnolo
    ## 61                                                                        Albicocco
    ## 62                                                                         Ciliegio
    ## 63                                                                 Pesco/pesco noce
    ## 64                                                                                 
    ## 65                                                                  Specie di ribes
    ## 66                                                                       Ribes nero
    ## 67                                                                        Uva spina
    ## 68                                                                            Josta
    ## 69                                                                      Ribes rosso
    ## 70                                                                     Sambuco nero
    ## 71                                                                        Mini-Kiwi
    ## 72                                                                  Specie di rubus
    ## 73                                                                             Mora
    ## 74                                                                          Lampone
    ## 75                                                                      Aronia nera
    ## 76                                                                          Fragola
    ## 77                                                                         Mirtillo
    ## 78                                                                                 
    ## 79                                                                             Vite
    ## 80                                                                    Ceppi giovani
    ## 81                                                               Vite in produzione
    ## 82                                                                                 
    ## 83                                                                     Cucurbitacee
    ## 84                                                                         Cetrioli
    ## 85                                                            cetrioli per conserva
    ## 86                                                                           Meloni
    ## 87                                                                          Angurie
    ## 88                                                                    Zucca da olio
    ## 89                                                 Zucche (buccia non commestibile)
    ## 90                                                   Zucche con buccia commestibile
    ## 91                                                                         Zucchine
    ## 92                                                                         Patisson
    ## 93                                                                          Rondini
    ## 94                                                       Portulacee (Portulacaceae)
    ## 95                                                                        Portulaca
    ## 96                                                                 Portulaca estiva
    ## 97                                                                        Solanacee
    ## 98                                                                         Pomodori
    ## 99                                                                Pomodoro ciliegia
    ## 100                                                                 Pomodoro ramato
    ## 101                                                 Varietà particolari di pomodoro
    ## 102                                                                       Melanzana
    ## 103                                                                        Peperone
    ## 104                                                                        Peperone
    ## 105                                                                  Peperone dolce
    ## 106                                                                    Alchechengio
    ## 107                                                                          Pepino
    ## 108                                                             Funghi commestibili
    ## 109                                                                   Chenopodiacee
    ## 110                                                                         Spinaci
    ## 111                                                                         Bietola
    ## 112                                                                           Costa
    ## 113                                                               Bietola da taglio
    ## 114                                                                    Barbabietola
    ## 115                                                    Erbe aromatiche e medicinali
    ## 116                                                                         Iperico
    ## 117                                                               Erbette da cucina
    ## 118                                                                  Erba cipollina
    ## 119                                                                           Aneto
    ## 120                                                                           Carvi
    ## 121                                                                           Menta
    ## 122                                                                       Rosmarino
    ## 123                                                                        Basilico
    ## 124                                                                          Salvia
    ## 125                                                                     Santoreggia
    ## 126                                                                       Levistico
    ## 127                                                                     Dragoncello
    ## 128                                                                       Cerfoglio
    ## 129                                                                            Timo
    ## 130                                                                      Coriandolo
    ## 131                                                                          Issopo
    ## 132                                                                Camomilla romana
    ## 133                                                                      Prezzemolo
    ## 134                                                                       Valeriana
    ## 135                                                      Asparagacee (Asparagaceae)
    ## 136                                                                        Asparagi
    ## 137                                                            Poacee (Graminaceae)
    ## 138                                                                      Mais dolce
    ## 139                                                             Lamiacee (Labiatae)
    ## 140                                                                        Tuberina
    ## 141                                                                    Valerianacee
    ## 142                                                                    Valerianella
    ## 143                                                          Ombrellifere (Apiacee)
    ## 144                                                                       Pastinaca
    ## 145                                                             Prezzemolo tuberoso
    ## 146                                                                          Sedano
    ## 147                                                                 Sedano da coste
    ## 148                                                            Sedano da condimento
    ## 149                                                                     Sedano rapa
    ## 150                                                                          Carote
    ## 151                                                                 Finocchio dolce
    ## 152                                                            Fabacee (Leguminose)
    ## 153                                                                         Piselli
    ## 154                                                          Piselli senza baccello
    ## 155                                                            Piselli con baccello
    ## 156                                                                         Fagioli
    ## 157                                                            Fagioli con baccello
    ## 158                                                                    Fagiolo nano
    ## 159                                                              Fagiolo rampicante
    ## 160                                                          Fagioli senza baccello
    ## 161                                                                            Fave
    ## 162                                                                      Lenticchia
    ## 163                                                                     Poligonacee
    ## 164                                                                       Rabarbaro
    ## 165                                                           Composite (Asteracee)
    ## 166                                                                        Carciofi
    ## 167                                                                   Cicoria belga
    ## 168                                                                      Scorzonera
    ## 169                                                                      Topinambur
    ## 170                                                            Insalate (Asteracee)
    ## 171                                                     Insalate del genere Lactuca
    ## 172                                                              Insalate cappuccio
    ## 173                                                               Lattuga cappuccio
    ## 174                                                   Insalate a foglie (Asteracee)
    ## 175                                                               Lattuga da taglio
    ## 176                                                     Indivia e cicoria da foglia
    ## 177                                                                         Indivia
    ## 178                                                         Cicoria pan di zucchero
    ## 179                                                    Tipi di radicchio e cicorino
    ## 180                                                                  Dente di leone
    ## 181                                                                           Cardo
    ## 182                                                         Crocifere (Brassicacee)
    ## 183                                                                Specie di cavoli
    ## 184                                                             Cavoli di Bruxelles
    ## 185                                                                Cavoli fogliacei
    ## 186                                                                    Cavolo piuma
    ## 187                                                                        Pak-Choi
    ## 188                                                         Cavoli / rape da taglio
    ## 189                                                                  Cavolo fustoso
    ## 190                                                                   Cavolo cinese
    ## 191                                                          Cavoli a infiorescenza
    ## 192                                                                       Romanesco
    ## 193                                                                      Cavolfiore
    ## 194                                                                        Broccoli
    ## 195                                                                  Cavoli a testa
    ## 196                                                                     Cavolo rapa
    ## 197                                                                       Crescione
    ## 198                                                   Rafano rusticana / Ramolaccio
    ## 199                                                                          Rucola
    ## 200                                                   Erba di Santa Barbara vernale
    ## 201                                                Rapa di Brassica rapa e B. napus
    ## 202                                                           Rapa di Brassica rapa
    ## 203                                                          Rapa di Brassica napus
    ## 204                                                                   Cavolo navone
    ## 205                                                Insalate asiatiche (Brassicacee)
    ## 206                                                                    Cima di rapa
    ## 207                                                             Crescione acquatico
    ## 208                                                                       Ravanello
    ## 209                                                                      Ramolaccio
    ## 210                                                                        Liliacee
    ## 211                                                                        Scalogni
    ## 212                                                                           Porro
    ## 213                                                                         Cipolle
    ## 214                                                                   Cipolle dolci
    ## 215                                                               Cipolle da tavola
    ## 216                                                              Cipollotti a mazzi
    ## 217                                                                           Aglio
    ## 218                                                                                
    ## 219                                                                            Mais
    ## 220                                                                           Colza
    ## 221                                                                 Colza autunnale
    ## 222                                                                        Miscanto
    ## 223                                          Barbabietole da foraggio e da zucchero
    ## 224                                                        Barbabietola da foraggio
    ## 225                                                        Barbabietola da zucchero
    ## 226                                                                           Kenaf
    ## 227                                                                         Tabacco
    ## 228                                                                            Soia
    ## 229                                                                         Cereali
    ## 230                                                                        Frumento
    ## 231                                                                          Spelta
    ## 232                                                                           Farro
    ## 233                                                                      Grano duro
    ## 234                                                                    Grano tenero
    ## 235                                                              Frumento autunnale
    ## 236                                                            Frumento primaverile
    ## 237                                                                            Orzo
    ## 238                                                                Orzo primaverile
    ## 239                                                                  Orzo autunnale
    ## 240                                                                       Triticale
    ## 241                                                             Triticale autunnale
    ## 242                                                                          Segale
    ## 243                                                                Segale autunnale
    ## 244                                                                           Avena
    ## 245                                                               Avena primaverile
    ## 246                                                             Cereali primaverili
    ## 247                                                            Frumento primaverile
    ## 248                                                                Orzo primaverile
    ## 249                                                               Avena primaverile
    ## 250                                                               Cereali autunnali
    ## 251                                                              Frumento autunnale
    ## 252                                                                          Spelta
    ## 253                                                             Triticale autunnale
    ## 254                                                                           Farro
    ## 255                                                                  Orzo autunnale
    ## 256                                                                Segale autunnale
    ## 257                                                                          Patate
    ## 258                                                  Patate da tavola e da foraggio
    ## 259                                         Patate per la produzione di tuberi-seme
    ## 260                                                                         Luppolo
    ## 261                                                                            Fava
    ## 262                                                                Pisello proteico
    ## 263                                                                 Prati e pascoli
    ## 264                                Miscela trifoglio-graminacee (prati artificiali)
    ## 265                                                                        Girasole
    ## 266                                                                     Erba medica
    ## 267                                                                          Lupini
    ## 268                                                         Tecnica di coltivazione
    ## 269                                                        Semine dopo la fresatura
    ## 270                                                               Semine a lattiera
    ## 271                                                                            Lino
    ## 272                                         Graminacee per la produzione di sementi
    ## 273                                               Riso seminato su terreno asciutto
    ## 274                                                                         Cartamo
    ## 275                                          Trifoglio per la produzione di sementi
    ## 276                                                                           Sorgo
    ## 277                                                                                
    ## 278                   Tronchi abbattuti nella foresta e presso piazzali di deposito
    ## 279                                           Protezione delle scorte (in generale)
    ## 280                                                          Depositi, mulini, sili
    ## 281                                                      Installazioni e apparecchi
    ## 282                                                       Locali per la lavorazione
    ## 283                                                                        Depositi
    ## 284                                                             Superficie inerbita
    ## 285                                                                        Papavero
    ## 286                                                                       Baby-Leaf
    ## 287                                                        Baby-Leaf (Brassicaceae)
    ## 288                                                          Baby-Leaf (Asteraceae)
    ## 289                                                      Baby-Leaf (Chenopodiaceae)
    ## 290                                                                 erbe medicinali
    ## 291                                                                 Digitale lanata
    ## 292                      Palette in legno, legno da imballaggio, legno non lavorato
    ## 293                                                                         Melissa
    ## 294                                                                 Terreno incolto
    ## 295                                                    Deposito di terreno vegetale
    ## 296                                                                         Anemone
    ## 297                                                                       ranuncolo
    ## 298                                                       Frutticoltura in generale
    ## 299                                              Coltivazione di bacche in generale
    ## 300                                                         Orticoltura in generale
    ## 301                                                        Campicoltura in generale
    ## 302                                                                          Canapa
    ## 303                                                               Bulbi ornamentali
    ## 304                                               Superfici non coltive in generale
    ## 305 Scarpate e strisce verdi lungo le vie di comunicazione (conformemente ORRPChim)
    ## 306                  Lungo le strade nazionali e cantonali (conformemente ORRPChim)
    ## 307                                                        Selvicoltura in generale
    ## 308                                                                           Bosco
    ## 309                                                                 Vivai forestali
    ## 310                                                                 Vivai forestali
    ## 311                                                                      maggiorana
    ## 312                                                                         origano
    ## 313                                                                  Rhodiola rosea
    ## 314                                                                 actaea racemosa
    ## 315                                                           piantaggine lanciuola
    ## 316                                                               Raccolto stoccato
    ## 317                                                             Finocchio aromatico
    ## 318                                                      Locali di stoccaggio vuoti
    ## 319                                                      Locali di produzione vuoti
    ## 320                                                  Aziende produttrici di tabacco
    ## 321                                                 Locali per la lavorazione vuoti
    ## 322                                               Lager- und Produktionsräume allg.
    ## 323                                                                  Bacche di Goji
    ## 324                                                                          Quinoa
    ## 325                                                            Caprifoglio turchino
    ## 326                                                                          Alloro
    ## 327                                                                     rosa canina
    ## 328                                                                            cece
    ## 329                                                                Olivello spinoso
    ## 330                                                                       Moro nero
    ## 331                                                          Sorbo degli ucellatori
    ## 332                                                                    Pero corvino
    ## 333                                                                    finocchiella
    ## 334                                                               Cerfoglio bulboso
    ## 335                                                                  Convolvulaceae
    ## 336                                                                    Patata dolce
    ## 337                                                                          Miglio
    ## 338                                                                          Piante
    ## 339                                                                         Maggese
