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

| pk | iupac | substance_de | substance_fr | substance_it |
|:---|:---|:---|:---|:---|
| 0A7BFE30-AC31-4326-9CF4-8A93ED26D3AB | (E)-8-dodecen-1-yl acetate | (E)-8-Dodecen-1-yl acetat | (E)-8-dodecen-1-yl acetate | (E)-8-dodecen-1-yl acetate |
| 96054844-EF1E-4817-BD0D-A196D2CD8A24 | (E,Z)-2,13-octadecadien-1-yl acetate | (E,Z)-2,13-Octadecadien-1-yl acetat | (E,Z)-2,13-Octadecadien-1-yl acétate | (E,Z)-2,13-Octadecadien-1-yl acetato |
| CC42B743-0C24-4493-AE64-7EAA3BB04EFD | (E,Z)-3,13-octadecadien-1-yl acetate | (E,Z)-3,13-Octadecadien-1-yl acetat | (E,Z)-3,13-Octadecadien-1-yl acétate | (E,Z)-3,13-Octadecadien-1-yl acetato |
| DC2C6844-BE99-4B8A-B066-A09B030A7461 | (E,Z)-3,8-tetradecadien-1-yl acetate | (E,Z)-3,8-Tetradecadien-1-yl acetat | (E,Z)-3,8-Tetradecadien-1-yl acetate | (E,Z)-3,8-Tetradecadien-1-yl acetate |

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

| pNbr | pk | type | percent | g_per_L | ingredient_de | ingredient_fr |
|---:|:---|:---|---:|---:|:---|:---|
| 38 | D95F01F3-9ED2-4D08-92FD-A58AF1B5F49F | ACTIVE_INGREDIENT | 80.00 |  |  |  |
| 1182 | 057FC3E0-B59E-45EB-8CCB-B2EA4527E479 | ACTIVE_INGREDIENT | 38.00 | 438.5 | entspricht 34.7 % MCPB (400g/L) | correspond à 34.7 % de MCPB (400 g/L) |
| 1192 | 057FC3E0-B59E-45EB-8CCB-B2EA4527E479 | ACTIVE_INGREDIENT | 38.00 | 438.5 | entspricht 34.7 % MCPB (400 g/L) | correspond à 34,7 % de MCPB (400 g/L) |
| 1263 | D95F01F3-9ED2-4D08-92FD-A58AF1B5F49F | ACTIVE_INGREDIENT | 80.00 |  |  |  |
| 1865 | 1D7FC783-1AA4-47FD-B973-83867751B87B | ACTIVE_INGREDIENT | 99.16 | 830.0 |  |  |

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
| ACTIVE_INGREDIENT   | 333 |
| ADDITIVE_TO_DECLARE | 114 |
| SAFENER             |   4 |
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
| SAFENER   | Cloquintocet-mexyl |  17 |
| SAFENER   | Cyprosulfamid      |   2 |
| SAFENER   | Isoxadifen-ethyl   |   3 |
| SAFENER   | Mefenpyr-diethyl   |  10 |
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

| pNbr | wNbr | name | exhaustionDeadline | soldoutDeadline | isSalePermission | permission_holder |
|---:|:---|:---|:---|:---|:---|:---|
| 38 | 18 | Thiovit Jet |  |  | FALSE | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
| 38 | 18-1 | Sufralo |  |  | TRUE | 15BAC516-7F05-4353-82D7-A2BA41438215 |
| 38 | 18-2 | Capito Bio-Schwefel |  |  | TRUE | 15BAC516-7F05-4353-82D7-A2BA41438215 |
| 38 | 18-3 | Sanoplant Schwefel |  |  | TRUE | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
| 38 | 18-4 | Biorga Contra Schwefel |  |  | TRUE | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
| 38 | 18-5 | Gesal Schrotschuss Spezial |  |  | TRUE | A128E9C6-FBC1-4649-8E3C-92073B82925B |

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

| pNbr | wNbr | name | exhaustionDeadline | soldoutDeadline | isSalePermission | permission_holder |
|---:|:---|:---|:---|:---|:---|:---|
| 2092 | 1698 | Asulox | 2026-07-01 00:00:00.0000000 | 2025-07-01 00:00:00.0000000 | FALSE | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
| 3948 | 4034 | Asulam | 2026-07-01 00:00:00.0000000 | 2025-07-01 00:00:00.0000000 | FALSE | 5E2915EB-369E-4C9C-B8B7-9FAAABF0E127 |
| 4163 | 4309 | Volpan | 2026-10-31 00:00:00.0000000 | 2025-10-31 00:00:00.0000000 | FALSE | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
| 4163 | 4309-1 | MIOPLANT Windenvertilger | 2026-10-31 00:00:00.0000000 | 2025-10-31 00:00:00.0000000 | TRUE | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
| 4251 | 4234 | Capex 2 | 2026-07-01 00:00:00.0000000 | 2025-07-01 00:00:00.0000000 | FALSE | F05FD7E3-EA3C-46CE-A537-B40375F273AA |
| 4426 | 4343 | Cypermethrin | 2026-06-11 00:00:00.0000000 | 2025-06-11 00:00:00.0000000 | FALSE | 5E2915EB-369E-4C9C-B8B7-9FAAABF0E127 |

At the build time of this vignette, there were 1740 product
registrations for 1119 P-Numbers in the Swiss Register of Plant
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

| pNbr | name     | substance_de                | percent | g_per_L |
|-----:|:---------|:----------------------------|--------:|--------:|
| 4077 | Plüsstar | Mecoprop-P-Dimethylammonium |   42.77 |   490.1 |
| 4077 | Plüsstar | 2,4-D-Dimethylammonium      |   17.86 |   204.7 |

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
|---:|---:|---:|---:|---:|---:|:---|---:|:---|:---|
| 6521 | 1 |  |  | 1.0 |  | l/ha |  |  | Feldbau |
| 6521 | 2 |  |  | 1.0 |  | l/ha |  |  | Feldbau |
| 6521 | 3 |  |  | 1.5 |  | l/ha |  |  | Feldbau |
| 6521 | 4 |  |  | 1.0 |  | l/ha | 3 | Week(s) | Feldbau |
| 6521 | 5 |  |  | 1.0 |  | l/ha |  |  | Feldbau |
| 6521 | 6 |  |  | 1.0 |  | l/ha | 3 | Week(s) | Feldbau |
| 6521 | 7 |  |  | 1.0 |  | l/ha |  |  | Feldbau |
| 6521 | 8 |  |  | 1.0 |  | l/ha | 3 | Week(s) | Feldbau |
| 6521 | 9 |  |  | 1.0 |  | l/ha |  |  | Feldbau |
| 7511 | 1 | 0.3 |  |  |  | kg/ha | 3 | Days | Gemüsebau |
| 7511 | 2 |  |  | 5.0 |  | kg/ha |  |  | Obstbau |
| 7511 | 3 | 0.3 |  | 4.8 |  | kg/ha |  |  | Obstbau |
| 7511 | 4 | 0.3 |  | 4.8 |  | kg/ha | 8 | Days | Obstbau |
| 7511 | 5 |  |  | 3.0 |  | kg/ha | 1 | Days | Gemüsebau |
| 7511 | 6 | 0.3 |  |  |  |  | 3 | Days | Beerenbau |
| 7511 | 7 |  |  | 3.0 |  | kg/ha | 1 | Days | Gemüsebau |
| 7511 | 8 |  |  | 3.0 |  | kg/ha | 1 | Days | Gemüsebau |
| 7511 | 9 |  |  | 5.0 |  | kg/ha | 3 | Days | Gemüsebau |

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
  left_join(example_register$cultures, by = join_by(pNbr, use_nr),
    relationship = "many-to-many") |>
  left_join(example_register$ingredients, by = join_by(pNbr),
    relationship = "many-to-many") |>
  left_join(example_register$substances, by = join_by(pk)) |>
  select(pNbr, name, use_nr,
    min_dosage, max_dosage, min_rate, max_rate, units_de,
    application_area_de, culture_de,
    substance_de, percent, g_per_L) |> 
  filter(use_nr %in% c(1:5, 12:17))

kable(example_uses)
```

| pNbr | name | use_nr | min_dosage | max_dosage | min_rate | max_rate | units_de | application_area_de | culture_de | substance_de | percent | g_per_L |
|---:|:---|---:|---:|---:|---:|---:|:---|:---|:---|:---|---:|---:|
| 7105 | Boxer | 1 |  |  | 2.5 | 5 | l/ha | Feldbau | Roggen | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 1 |  |  | 2.5 | 5 | l/ha | Feldbau | Weizen | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 1 |  |  | 2.5 | 5 | l/ha | Feldbau | Gerste | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 2 |  |  | 5.0 |  | l/ha | Gemüsebau | Karotten | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 3 |  |  | 3.0 |  | l/ha | Gemüsebau | Meerrettich | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 4 |  |  | 5.0 |  | l/ha | Gemüsebau | Stangensellerie | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 5 |  |  | 3.0 | 5 | l/ha | Feldbau | Kartoffeln | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 12 |  |  | 5.0 |  | l/ha | Feldbau | Lupinen | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 13 |  |  | 2.5 | 5 | l/ha | Feldbau | Triticale | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 13 |  |  | 2.5 | 5 | l/ha | Feldbau | Korn (Dinkel) | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 14 |  |  | 5.0 |  | l/ha | Gemüsebau | Knollensellerie | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 15 |  |  | 4.0 |  | l/ha | Gemüsebau | Schwarzwurzel | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 16 |  |  | 4.0 |  | l/ha | Gemüsebau | Knoblauch | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 16 |  |  | 4.0 |  | l/ha | Gemüsebau | Schalotten | Prosulfocarb | 78.43 | 800 |
| 7105 | Boxer | 17 |  |  | 4.0 |  | l/ha | Gemüsebau | Zwiebeln | Prosulfocarb | 78.43 | 800 |

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
| Prosulfocarb | Feldbau   |      2.5 |        5 | l/ha     | 4000 |
| Prosulfocarb | Feldbau   |      2.5 |        5 | l/ha     | 4000 |
| Prosulfocarb | Feldbau   |      2.5 |        5 | l/ha     | 4000 |
| Prosulfocarb | Gemüsebau |      5.0 |          | l/ha     | 4000 |
| Prosulfocarb | Gemüsebau |      3.0 |          | l/ha     | 2400 |
| Prosulfocarb | Gemüsebau |      5.0 |          | l/ha     | 4000 |
| Prosulfocarb | Feldbau   |      3.0 |        5 | l/ha     | 4000 |
| Prosulfocarb | Feldbau   |      5.0 |          | l/ha     | 4000 |
| Prosulfocarb | Feldbau   |      2.5 |        5 | l/ha     | 4000 |
| Prosulfocarb | Feldbau   |      2.5 |        5 | l/ha     | 4000 |
| Prosulfocarb | Gemüsebau |      5.0 |          | l/ha     | 4000 |
| Prosulfocarb | Gemüsebau |      4.0 |          | l/ha     | 3200 |
| Prosulfocarb | Gemüsebau |      4.0 |          | l/ha     | 3200 |
| Prosulfocarb | Gemüsebau |      4.0 |          | l/ha     | 3200 |

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

| pNbr | use_nr | application_area_de | culture_form_de | culture_de  |
|-----:|-------:|:--------------------|:----------------|:------------|
| 4470 |      1 | Beerenbau           |                 | Erdbeere    |
| 4470 |     10 | Beerenbau           | Freiland        | Rubus Arten |

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

    ##                                         levelName
    ## 1  Cultures                                      
    ## 2   ¦--Lager- und Produktionsräume allg.         
    ## 3   ¦   ¦--Tabak produzierende Betriebe          
    ## 4   ¦   ¦--Leere Produktionsräume                
    ## 5   ¦   ¦--Einrichtungen und Geräte              
    ## 6   ¦   ¦--leere Verarbeitungsräume              
    ## 7   ¦   ¦--Holzpaletten, Packholz, Stammholz     
    ## 8   ¦   ¦--leere Lagerräume                      
    ## 9   ¦   °--Erntegut                              
    ## 10  ¦--Feldbau allg.                             
    ## 11  ¦   ¦--Hopfen                                
    ## 12  ¦   ¦--Futter- und Zuckerrüben               
    ## 13  ¦   ¦   ¦--Zuckerrübe                        
    ## 14  ¦   ¦   °--Futterrübe                        
    ## 15  ¦   ¦--Sonnenblume                           
    ## 16  ¦   ¦--Sorghum                               
    ## 17  ¦   ¦--Lupinen                               
    ## 18  ¦   ¦--Färberdistel (Saflor)                 
    ## 19  ¦   ¦--Chinaschilf                           
    ## 20  ¦   ¦--Kartoffeln                            
    ## 21  ¦   ¦   ¦--Speise- und Futterkartoffeln      
    ## 22  ¦   ¦   °--Kartoffeln zur Pflanzgutproduktion
    ## 23  ¦   ¦--Klee zur Saatgutproduktion            
    ## 24  ¦   ¦--Ackerbohne                            
    ## 25  ¦   ¦--Kenaf                                 
    ## 26  ¦   ¦--Eiweisserbse                          
    ## 27  ¦   ¦--Tabak                                 
    ## 28  ¦   ¦--Getreide                              
    ## 29  ¦   ¦   ¦--Triticale                         
    ## 30  ¦   ¦   ¦   °--... 1 nodes w/ 0 sub          
    ## 31  ¦   ¦   °--... 6 nodes w/ 20 sub             
    ## 32  ¦   °--... 12 nodes w/ 30 sub                
    ## 33  °--... 19 nodes w/ 306 sub                   
    ##                              culture_id
    ## 1                                      
    ## 2  0FC26BDD-5CD1-4321-93D0-6AB24FA678B5
    ## 3  17B69B05-E650-4A6F-815A-D6DA55A92CDB
    ## 4  28ECDBFE-F44F-44C6-BF06-9B7E6EBFC1F6
    ## 5  465E7118-95AB-46A2-9A85-7A0B9070E63A
    ## 6  4B6DC713-3B11-42C5-92A8-E504D594E978
    ## 7  75047A9C-12E2-4BAC-89D8-B14BC4C6B100
    ## 8  7D23702C-980B-4B90-A86B-70013806D3EA
    ## 9  CC08E1E6-655D-4FAA-B0E8-AD968A68A536
    ## 10 3783A322-9E9C-44F6-B683-FE35221CA6AC
    ## 11 01AFF6EB-9C8D-4D0D-B225-0BA07B59A72F
    ## 12 086E34F3-82E5-4F92-9224-41C9F7529E70
    ## 13 B542EC7D-B423-43B4-9010-82A6889BB3B4
    ## 14 C763D817-B4AC-43DB-9C6E-A262CC32F400
    ## 15 095E9650-A880-4BD2-A1BB-39297582BCE6
    ## 16 27FBFA25-5091-4D7E-9C96-3C0BC05B6474
    ## 17 404C1D02-5666-4AA3-8487-65A9EEE0B53D
    ## 18 49F7DA15-E241-4080-9D42-1523ECA834B5
    ## 19 4A386AE2-A36F-4A55-8668-7B896A1E8092
    ## 20 575A1469-EF59-4B4E-96C3-38FC0CAEF637
    ## 21 4FC4A2B5-73DC-4C30-940C-813BBB4DFD10
    ## 22 B9DC95B4-DD22-49F9-9048-4B37F8DD8F8F
    ## 23 6388D9E7-CD0D-4823-80DD-E6FA472AF12C
    ## 24 657E4B0A-50BD-424B-9DB4-1B84582AD3D7
    ## 25 6D06A7F9-DF91-4BB5-84B8-FB877C211E66
    ## 26 7D52C099-7C6F-453C-8513-4BBFB94EE66A
    ## 27 8262D735-4D45-4499-AE0B-497FF4C0C4AA
    ## 28 8B5A3E2B-2534-4FC0-84C5-685915165A77
    ## 29 048FDB44-710A-4801-849C-72F1A458DB82
    ## 30                                     
    ## 31                                     
    ## 32                                     
    ## 33

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

| use_nr | pest_de | pest_add_txt_de | pest_fr | pest_add_txt_fr |
|---:|:---|:---|:---|:---|
| 1 | Einjährige Monocotyledonen (Ungräser) |  | monocotylédones annuelles |  |
| 1 | Einjährige Dicotyledonen (Unkräuter) |  | dicotylédones annuelles |  |
| 2 | Einjährige Monocotyledonen (Ungräser) |  | monocotylédones annuelles |  |
| 2 | Einjährige Dicotyledonen (Unkräuter) |  | dicotylédones annuelles |  |

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

| pNbr | use_nr | application_area_de | culture_de | pest_de |
|---:|---:|:---|:---|:---|
| 6521 | 1 | Feldbau | Weizen | Septoria-Spelzenbräune (S. nodorum) |
| 6521 | 2 | Feldbau | Winterroggen | Braunrost |
| 6521 | 3 | Feldbau | Raps | Wurzelhals- und Stengelfäule |
| 6521 | 4 | Feldbau | Lupinen | Anthraknose |
| 6521 | 5 | Feldbau | Weizen | Echter Mehltau des Getreides |
| 6521 | 6 | Feldbau | Eiweisserbse | Graufäule (Botrytis cinerea) |
| 6521 | 6 | Feldbau | Eiweisserbse | Rost der Erbse |
| 6521 | 6 | Feldbau | Eiweisserbse | Brennfleckenkrankheit der Erbse |
| 6521 | 7 | Feldbau | Weizen | Ährenfusariosen |
| 6521 | 8 | Feldbau | Ackerbohne | Rost der Ackerbohne |
| 6521 | 8 | Feldbau | Ackerbohne | Braunfleckenkrankheit |
| 6521 | 9 | Feldbau | Lein | Stängelbräune des Leins |
| 6521 | 9 | Feldbau | Lein | Pasmokrankheit |
| 6521 | 9 | Feldbau | Lein | Echter Mehltau des Leins |
| 6521 | 10 | Gemüsebau | Spargel | Blattschwärze der Spargel |
| 6521 | 10 | Gemüsebau | Spargel | Spargelrost |
| 6521 | 11 | Feldbau | Grasbestände zur Saatgutproduktion | Rost der Gräser |
| 6521 | 11 | Feldbau | Grasbestände zur Saatgutproduktion | Blattfleckenpilze |
| 6521 | 12 | Gemüsebau | Erbsen | Graufäule (Botrytis cinerea) |
| 6521 | 12 | Gemüsebau | Erbsen | Rost der Erbse |
| 6521 | 12 | Gemüsebau | Erbsen | Brennfleckenkrankheit der Erbse |
| 6521 | 13 | Feldbau | Raps | Sclerotinia-Fäule |
| 6521 | 14 | Feldbau | Raps | Wurzelhals- und Stengelfäule |
| 6521 | 14 | Feldbau | Raps | Erhöhung der Standfestigkeit |
| 6521 | 15 | Feldbau | Weizen | Gelbrost |

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

| pNbr | use_nr | application_comment_de | application_comment_fr |
|---:|---:|:---|:---|
| 7105 | 1 | Herbst, Frühjahr; Vorauflauf, früher Nachauflauf. | automne, printemps; pré-levée, post-levée précoce. |
| 7105 | 2 | Nachauflauf, Stadium 12-13. | post-levée, stade 12-13. |

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

| pNbr | use_nr | code | obligation_de | sw_runoff_points |
|---:|---:|:---|:---|---:|
| 7105 | 1 | 9824 | Niedrige Aufwandmenge nur in Tankmischung gemäss den Angaben der Bewilligungsinhaberin. |  |
| 7105 | 1 | 11380 | Nachfolgearbeiten in behandelten Kulturen: bis 48 Stunden nach Ausbringung des Mittels Schutzhandschuhe + Schutzanzug tragen. |  |
| 7105 | 1 | 12827 | Ansetzen der Spritzbrühe: Schutzhandschuhe tragen. Ausbringen der Spritzbrühe: Schutzhandschuhe + Schutzanzug + Visier + Kopfbedeckung tragen. Technische Schutzvorrichtungen während des Ausbringens (z.B. geschlossene Traktorkabine) können die vorgeschriebene persönliche Schutzausrüstung ersetzen, wenn gewährleistet ist, dass sie einen vergleichbaren oder höheren Schutz bieten. |  |
| 7105 | 1 | 14120 | SPe 3: Zum Schutz von Gewässerorganismen muss das Abschwemmungsrisiko gemäss den Weisungen der Zulassungsstelle um 1 Punkt reduziert werden. | 1 |
| 7105 | 1 | 9457 | Maximal 1 Behandlung pro Kultur. |  |
| 7105 | 1 | 13804 | Behandlung von im Herbst gesäten Kulturen. |  |
| 7105 | 2 | 11380 | Nachfolgearbeiten in behandelten Kulturen: bis 48 Stunden nach Ausbringung des Mittels Schutzhandschuhe + Schutzanzug tragen. |  |
| 7105 | 2 | 8614 | Nachbau anderer Kulturen: 16 Wochen Wartefrist. |  |
| 7105 | 2 | 12827 | Ansetzen der Spritzbrühe: Schutzhandschuhe tragen. Ausbringen der Spritzbrühe: Schutzhandschuhe + Schutzanzug + Visier + Kopfbedeckung tragen. Technische Schutzvorrichtungen während des Ausbringens (z.B. geschlossene Traktorkabine) können die vorgeschriebene persönliche Schutzausrüstung ersetzen, wenn gewährleistet ist, dass sie einen vergleichbaren oder höheren Schutz bieten. |  |
| 7105 | 2 | 9561 | Phytotoxschäden bei empfindlichen Arten oder Sorten möglich; vor allgemeiner Anwendung Versuchspritzung durchführen. |  |
| 7105 | 2 | 14120 | SPe 3: Zum Schutz von Gewässerorganismen muss das Abschwemmungsrisiko gemäss den Weisungen der Zulassungsstelle um 1 Punkt reduziert werden. | 1 |
| 7105 | 2 | 9457 | Maximal 1 Behandlung pro Kultur. |  |

## References

Korkaric, M., L. Ammann, I. Hanke, et al. 2022. “Nationale
Risikoindikatoren Basierend Auf Dem Verkauf von Pflanzenschutzmitteln.”
*Agrarforschung Schweiz* 13: 1–10.

Korkaric, M., M. Lehto, T. Poiger, et al. 2023. “Nationale
Risikoindikatoren Für Pflanzenschutzmittel : Weiterführende Analysen.”
Journal Article. *Agroscope Science*, 1–48.

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
    ## 2    ¦--Lager- und Produktionsräume allg.                                       
    ## 3    ¦   ¦--Tabak produzierende Betriebe                                        
    ## 4    ¦   ¦--Leere Produktionsräume                                              
    ## 5    ¦   ¦--Einrichtungen und Geräte                                            
    ## 6    ¦   ¦--leere Verarbeitungsräume                                            
    ## 7    ¦   ¦--Holzpaletten, Packholz, Stammholz                                   
    ## 8    ¦   ¦--leere Lagerräume                                                    
    ## 9    ¦   °--Erntegut                                                            
    ## 10   ¦--Feldbau allg.                                                           
    ## 11   ¦   ¦--Hopfen                                                              
    ## 12   ¦   ¦--Futter- und Zuckerrüben                                             
    ## 13   ¦   ¦   ¦--Zuckerrübe                                                      
    ## 14   ¦   ¦   °--Futterrübe                                                      
    ## 15   ¦   ¦--Sonnenblume                                                         
    ## 16   ¦   ¦--Sorghum                                                             
    ## 17   ¦   ¦--Lupinen                                                             
    ## 18   ¦   ¦--Färberdistel (Saflor)                                               
    ## 19   ¦   ¦--Chinaschilf                                                         
    ## 20   ¦   ¦--Kartoffeln                                                          
    ## 21   ¦   ¦   ¦--Speise- und Futterkartoffeln                                    
    ## 22   ¦   ¦   °--Kartoffeln zur Pflanzgutproduktion                              
    ## 23   ¦   ¦--Klee zur Saatgutproduktion                                          
    ## 24   ¦   ¦--Ackerbohne                                                          
    ## 25   ¦   ¦--Kenaf                                                               
    ## 26   ¦   ¦--Eiweisserbse                                                        
    ## 27   ¦   ¦--Tabak                                                               
    ## 28   ¦   ¦--Getreide                                                            
    ## 29   ¦   ¦   ¦--Triticale                                                       
    ## 30   ¦   ¦   ¦   °--Wintertriticale                                             
    ## 31   ¦   ¦   ¦--Wintergetreide                                                  
    ## 32   ¦   ¦   ¦   ¦--Winterweizen                                                
    ## 33   ¦   ¦   ¦   ¦--Wintergerste                                                
    ## 34   ¦   ¦   ¦   ¦--Winterroggen                                                
    ## 35   ¦   ¦   ¦   ¦--Wintertriticale [dup]                                       
    ## 36   ¦   ¦   ¦   ¦--Korn (Dinkel)                                               
    ## 37   ¦   ¦   ¦   °--Emmer                                                       
    ## 38   ¦   ¦   ¦--Sommergetreide                                                  
    ## 39   ¦   ¦   ¦   ¦--Sommerweizen                                                
    ## 40   ¦   ¦   ¦   ¦--Sommergerste                                                
    ## 41   ¦   ¦   ¦   °--Sommerhafer                                                 
    ## 42   ¦   ¦   ¦--Roggen                                                          
    ## 43   ¦   ¦   ¦   °--Winterroggen [dup]                                          
    ## 44   ¦   ¦   ¦--Weizen                                                          
    ## 45   ¦   ¦   ¦   ¦--Hartweizen                                                  
    ## 46   ¦   ¦   ¦   ¦--Korn (Dinkel) [dup]                                         
    ## 47   ¦   ¦   ¦   ¦--Weichweizen                                                 
    ## 48   ¦   ¦   ¦   ¦   ¦--Winterweizen [dup]                                      
    ## 49   ¦   ¦   ¦   ¦   °--Sommerweizen [dup]                                      
    ## 50   ¦   ¦   ¦   °--Emmer [dup]                                                 
    ## 51   ¦   ¦   ¦--Gerste                                                          
    ## 52   ¦   ¦   ¦   ¦--Wintergerste [dup]                                          
    ## 53   ¦   ¦   ¦   °--Sommergerste [dup]                                          
    ## 54   ¦   ¦   °--Hafer                                                           
    ## 55   ¦   ¦       °--Sommerhafer [dup]                                           
    ## 56   ¦   ¦--Trockenreis                                                         
    ## 57   ¦   ¦--Mohn                                                                
    ## 58   ¦   ¦--Lein                                                                
    ## 59   ¦   ¦--Sojabohne                                                           
    ## 60   ¦   ¦--Mais                                                                
    ## 61   ¦   ¦--Raps                                                                
    ## 62   ¦   ¦   °--Winterraps                                                      
    ## 63   ¦   ¦--Rispenhirse                                                         
    ## 64   ¦   ¦--Grasbestände zur Saatgutproduktion                                  
    ## 65   ¦   ¦--Luzerne                                                             
    ## 66   ¦   ¦--Anbautechnik                                                        
    ## 67   ¦   ¦   ¦--Mulchsaaten                                                     
    ## 68   ¦   ¦   °--Frässaaten                                                      
    ## 69   ¦   ¦--Wiesen und Weiden                                                   
    ## 70   ¦   ¦   °--Kleegrasmischung (Kunstwiese)                                   
    ## 71   ¦   °--Hanf                                                                
    ## 72   ¦--Rosenwurz                                                               
    ## 73   ¦--Forstwirtschaft allg.                                                   
    ## 74   ¦   ¦--Liegendes Rundholz im Wald und auf Lagerplätzen                     
    ## 75   ¦   ¦--Wald                                                                
    ## 76   ¦   ¦   °--Forstliche Pflanzgärten                                         
    ## 77   ¦   °--Forstliche Pflanzgärten [dup]                                       
    ## 78   ¦--allg. Weinbau                                                           
    ## 79   ¦   °--Reben                                                               
    ## 80   ¦       ¦--Ertragsreben                                                    
    ## 81   ¦       °--Jungreben                                                       
    ## 82   ¦--Medizinalkräuter                                                        
    ## 83   ¦   ¦--Baldrian                                                            
    ## 84   ¦   °--Wolliger Fingerhut                                                  
    ## 85   ¦--Nichtkulturland allg.                                                   
    ## 86   ¦   ¦--Böschungen und Grünstreifen entlang von Verkehrswegen (gem. ChemRRV)
    ## 87   ¦   ¦--Brachland                                                           
    ## 88   ¦   ¦--Humusdeponie                                                        
    ## 89   ¦   °--Auf und an National- und Kantonsstrassen (gem. ChemRRV)             
    ## 90   ¦--Allgemein Vorratsschutz                                                 
    ## 91   ¦   ¦--Verarbeitungsräume                                                  
    ## 92   ¦   ¦--Lagerhallen, Mühlen, Silogebäude                                    
    ## 93   ¦   °--Lagerräume                                                          
    ## 94   ¦--Zierpflanzen allg.                                                      
    ## 95   ¦   ¦--Ein- und zweijährige Zierpflanzen                                   
    ## 96   ¦   ¦   °--Sommerflor                                                      
    ## 97   ¦   ¦--Schnittblumen                                                       
    ## 98   ¦   ¦   ¦--Chrysantheme                                                    
    ## 99   ¦   ¦   ¦--Nelken                                                          
    ## 100  ¦   ¦   ¦--Gerbera                                                         
    ## 101  ¦   ¦   ¦--Blaudistel                                                      
    ## 102  ¦   ¦   °--Gladiole                                                        
    ## 103  ¦   ¦--Blumenknollen                                                       
    ## 104  ¦   ¦   °--Dahlien                                                         
    ## 105  ¦   ¦--Topf- und Kontainerpflanzen                                         
    ## 106  ¦   ¦   ¦--Begonia                                                         
    ## 107  ¦   ¦   ¦--Cyclame                                                         
    ## 108  ¦   ¦   ¦--Pelargonien                                                     
    ## 109  ¦   ¦   °--Primeln                                                         
    ## 110  ¦   ¦--Baumschule                                                          
    ## 111  ¦   ¦--Bäume und Sträucher (ausserhalb Forst)                              
    ## 112  ¦   ¦   ¦--Rosskastanie                                                    
    ## 113  ¦   ¦   ¦--Rhododendron                                                    
    ## 114  ¦   ¦   ¦   °--Azaleen                                                     
    ## 115  ¦   ¦   ¦--Blautanne [dup]                                                 
    ## 116  ¦   ¦   ¦--Weihnachtsbäume [dup]                                           
    ## 117  ¦   ¦   ¦--Kirschlorbeer                                                   
    ## 118  ¦   ¦   ¦--Buchsbäume (Buxus)                                              
    ## 119  ¦   ¦   °--Zypressengewächse [dup]                                         
    ## 120  ¦   ¦--Zier- und Sportrasen                                                
    ## 121  ¦   ¦--Blumenkulturen und Grünpflanzen                                     
    ## 122  ¦   ¦   ¦--Ranunkel                                                        
    ## 123  ¦   ¦   ¦--Begonia [dup]                                                   
    ## 124  ¦   ¦   ¦--Zierkürbis                                                      
    ## 125  ¦   ¦   ¦--Chrysantheme [dup]                                              
    ## 126  ¦   ¦   ¦--Anemone                                                         
    ## 127  ¦   ¦   ¦--Hyazinthe                                                       
    ## 128  ¦   ¦   ¦--Nelken [dup]                                                    
    ## 129  ¦   ¦   ¦--Cyclame [dup]                                                   
    ## 130  ¦   ¦   ¦--Gerbera [dup]                                                   
    ## 131  ¦   ¦   ¦--Iris                                                            
    ## 132  ¦   ¦   ¦--Pelargonien [dup]                                               
    ## 133  ¦   ¦   ¦--Liliengewächse (Zierpflanzen)                                   
    ## 134  ¦   ¦   ¦--Blaudistel [dup]                                                
    ## 135  ¦   ¦   ¦--Gladiole [dup]                                                  
    ## 136  ¦   ¦   ¦--Primeln [dup]                                                   
    ## 137  ¦   ¦   °--Tulpe                                                           
    ## 138  ¦   ¦--Gehölze (ausserhalb Forst)                                          
    ## 139  ¦   ¦   ¦--Nadelgehölze (Koniferen)                                        
    ## 140  ¦   ¦   ¦   ¦--Blautanne                                                   
    ## 141  ¦   ¦   ¦   ¦--Weihnachtsbäume                                             
    ## 142  ¦   ¦   ¦   ¦--Fichte                                                      
    ## 143  ¦   ¦   ¦   °--Zypressengewächse                                           
    ## 144  ¦   ¦   °--Laubgehölze                                                     
    ## 145  ¦   ¦       ¦--Rosskastanie [dup]                                          
    ## 146  ¦   ¦       ¦--Rhododendron [dup]                                          
    ## 147  ¦   ¦       ¦--Kirschlorbeer [dup]                                         
    ## 148  ¦   ¦       °--Buchsbäume (Buxus) [dup]                                    
    ## 149  ¦   ¦--Blumenzwiebeln und Blumenknollen                                    
    ## 150  ¦   ¦--Rosen                                                               
    ## 151  ¦   ¦--Blumenzwiebeln                                                      
    ## 152  ¦   ¦   °--Hyazinthe [dup]                                                 
    ## 153  ¦   ¦--Euphorbia                                                           
    ## 154  ¦   ¦--Ziergehölze (ausserhalb Forst)                                      
    ## 155  ¦   °--Stauden                                                             
    ## 156  ¦--Pflanzen                                                                
    ## 157  ¦--Beerenbau allg.                                                         
    ## 158  ¦   ¦--Eberesche                                                           
    ## 159  ¦   ¦--Schwarze Apfelbeere                                                 
    ## 160  ¦   ¦--Schwarzer Holunder                                                  
    ## 161  ¦   ¦--Rubus Arten                                                         
    ## 162  ¦   ¦   ¦--Brombeere                                                       
    ## 163  ¦   ¦   °--Himbeere                                                        
    ## 164  ¦   ¦--Erdbeere                                                            
    ## 165  ¦   ¦--Gojibeere                                                           
    ## 166  ¦   ¦--Heidelbeere                                                         
    ## 167  ¦   ¦--Blaue Heckenkirsche                                                 
    ## 168  ¦   ¦--Ribes Arten                                                         
    ## 169  ¦   ¦   ¦--Stachelbeere                                                    
    ## 170  ¦   ¦   ¦--Schwarze Johannisbeere                                          
    ## 171  ¦   ¦   ¦--Rote Johannisbeere                                              
    ## 172  ¦   ¦   °--Jostabeere                                                      
    ## 173  ¦   ¦--Schwarze Maulbeere                                                  
    ## 174  ¦   ¦--Sanddorn                                                            
    ## 175  ¦   ¦--Gemeine Felsenbirne                                                 
    ## 176  ¦   ¦--Mini-Kiwi                                                           
    ## 177  ¦   °--Hagebutten                                                          
    ## 178  ¦--Spitzwegerich                                                           
    ## 179  ¦--Lorbeer                                                                 
    ## 180  ¦--Speisepilze                                                             
    ## 181  ¦--Kerbelrübe                                                              
    ## 182  ¦--Gemüsebau allg.                                                         
    ## 183  ¦   ¦--Baby-Leaf                                                           
    ## 184  ¦   ¦   ¦--Baby-Leaf (Brassicaceae)                                        
    ## 185  ¦   ¦   ¦--Baby-Leaf (Chenopodiaceae)                                      
    ## 186  ¦   ¦   °--Baby-Leaf (Asteraceae)                                          
    ## 187  ¦   ¦--Knöterichgewächse (Polygonaceae)                                    
    ## 188  ¦   ¦   °--Rhabarber                                                       
    ## 189  ¦   ¦--Amaryllidaceae                                                      
    ## 190  ¦   ¦   ¦--Knoblauch                                                       
    ## 191  ¦   ¦   ¦--Lauch                                                           
    ## 192  ¦   ¦   ¦--Zwiebeln                                                        
    ## 193  ¦   ¦   ¦   ¦--Gemüsezwiebel                                               
    ## 194  ¦   ¦   ¦   ¦--Bundzwiebeln                                                
    ## 195  ¦   ¦   ¦   °--Speisezwiebel                                               
    ## 196  ¦   ¦   °--Schalotten                                                      
    ## 197  ¦   ¦--Portulakgewächse (Portulacaceae)                                    
    ## 198  ¦   ¦   °--Portulak                                                        
    ## 199  ¦   ¦       °--Gemüseportulak                                              
    ## 200  ¦   ¦--Spargelgewächse (Asparagaceae)                                      
    ## 201  ¦   ¦   °--Spargel                                                         
    ## 202  ¦   ¦--Baldriangewächse (Valerianaceae)                                    
    ## 203  ¦   ¦   °--Nüsslisalat                                                     
    ## 204  ¦   ¦--Gewürz- und Medizinalkräuter                                        
    ## 205  ¦   ¦   °--Johanniskraut                                                   
    ## 206  ¦   ¦--Gänsefussgewächse (Chenopodiaceae)                                  
    ## 207  ¦   ¦   ¦--Rande                                                           
    ## 208  ¦   ¦   ¦--Spinat                                                          
    ## 209  ¦   ¦   °--Mangold                                                         
    ## 210  ¦   ¦       ¦--Krautstiel                                                  
    ## 211  ¦   ¦       °--Schnittmangold                                              
    ## 212  ¦   ¦--Nachtschattengewächse (Solanaceae)                                  
    ## 213  ¦   ¦   ¦--Paprika                                                         
    ## 214  ¦   ¦   ¦   ¦--Peperoni                                                    
    ## 215  ¦   ¦   ¦   °--Gemüsepaprika                                               
    ## 216  ¦   ¦   ¦--Aubergine                                                       
    ## 217  ¦   ¦   ¦--Andenbeere                                                      
    ## 218  ¦   ¦   ¦--Tomaten                                                         
    ## 219  ¦   ¦   ¦   ¦--Tomaten Spezialitäten                                       
    ## 220  ¦   ¦   ¦   ¦--Cherrytomaten                                               
    ## 221  ¦   ¦   ¦   °--Rispentomaten                                               
    ## 222  ¦   ¦   °--Pepino                                                          
    ## 223  ¦   ¦--Doldenblütler (Apiaceae)                                            
    ## 224  ¦   ¦   ¦--Knollenfenchel                                                  
    ## 225  ¦   ¦   ¦--Wurzelpetersilie                                                
    ## 226  ¦   ¦   ¦--Karotten                                                        
    ## 227  ¦   ¦   ¦--Sellerie                                                        
    ## 228  ¦   ¦   ¦   ¦--Suppensellerie                                              
    ## 229  ¦   ¦   ¦   ¦--Stangensellerie                                             
    ## 230  ¦   ¦   ¦   °--Knollensellerie                                             
    ## 231  ¦   ¦   °--Pastinake                                                       
    ## 232  ¦   ¦--Kürbisgewächse (Cucurbitaceae)                                      
    ## 233  ¦   ¦   ¦--Wassermelonen                                                   
    ## 234  ¦   ¦   ¦--Gurken                                                          
    ## 235  ¦   ¦   ¦   ¦--Einlegegurken                                               
    ## 236  ¦   ¦   ¦   ¦--Nostranogurken                                              
    ## 237  ¦   ¦   ¦   °--Gewächshausgurken                                           
    ## 238  ¦   ¦   ¦--Melonen                                                         
    ## 239  ¦   ¦   ¦--Speisekürbisse (ungeniessbare Schale)                           
    ## 240  ¦   ¦   ¦--Ölkürbisse                                                      
    ## 241  ¦   ¦   °--Kürbisse mit geniessbarer Schale                                
    ## 242  ¦   ¦       ¦--Patisson                                                    
    ## 243  ¦   ¦       ¦--Zucchetti                                                   
    ## 244  ¦   ¦       °--Rondini                                                     
    ## 245  ¦   ¦--Windengewächse (Convolvulaceae)                                     
    ## 246  ¦   ¦   °--Süsskartoffel                                                   
    ## 247  ¦   ¦--Korbblütler (Asteraceae)                                            
    ## 248  ¦   ¦   ¦--Artischocken                                                    
    ## 249  ¦   ¦   ¦--Kardy                                                           
    ## 250  ¦   ¦   ¦--Schwarzwurzel                                                   
    ## 251  ¦   ¦   ¦--Topinambur                                                      
    ## 252  ¦   ¦   ¦--Chicorée                                                        
    ## 253  ¦   ¦   °--Salate (Asteraceae)                                             
    ## 254  ¦   ¦       ¦--Löwenzahn                                                   
    ## 255  ¦   ¦       ¦--Lactuca-Salate                                              
    ## 256  ¦   ¦       ¦   ¦--Kopfsalate                                              
    ## 257  ¦   ¦       ¦   ¦   °--Kopfsalat                                           
    ## 258  ¦   ¦       ¦   °--Blattsalate (Asteraceae)                                
    ## 259  ¦   ¦       ¦       °--Schnittsalat                                        
    ## 260  ¦   ¦       °--Endivien und Blattzichorien                                 
    ## 261  ¦   ¦           ¦--Endivien                                                
    ## 262  ¦   ¦           °--Radicchio- und Cicorino-Typen                           
    ## 263  ¦   ¦--Lippenblütler (Labiatae)                                            
    ## 264  ¦   ¦   °--Stachys                                                         
    ## 265  ¦   ¦--Süssgräser (Poaceae)                                                
    ## 266  ¦   ¦   °--Zuckermais                                                      
    ## 267  ¦   ¦--Kräuter                                                             
    ## 268  ¦   ¦--Küchenkräuter                                                       
    ## 269  ¦   ¦   ¦--Liebstöckel                                                     
    ## 270  ¦   ¦   ¦--Ysop                                                            
    ## 271  ¦   ¦   ¦--Koriander                                                       
    ## 272  ¦   ¦   ¦--Oregano                                                         
    ## 273  ¦   ¦   ¦--Rosmarin                                                        
    ## 274  ¦   ¦   ¦--Petersilie                                                      
    ## 275  ¦   ¦   ¦--Römische Kamille                                                
    ## 276  ¦   ¦   ¦--Kerbel                                                          
    ## 277  ¦   ¦   ¦--Minze                                                           
    ## 278  ¦   ¦   ¦--Basilikum                                                       
    ## 279  ¦   ¦   ¦--Bohnenkraut                                                     
    ## 280  ¦   ¦   ¦--Majoran                                                         
    ## 281  ¦   ¦   ¦--Thymian                                                         
    ## 282  ¦   ¦   ¦--Kümmel                                                          
    ## 283  ¦   ¦   ¦--Gewürzfenchel                                                   
    ## 284  ¦   ¦   ¦--Dill                                                            
    ## 285  ¦   ¦   ¦--Salbei                                                          
    ## 286  ¦   ¦   ¦--Süssdolde                                                       
    ## 287  ¦   ¦   ¦--Estragon                                                        
    ## 288  ¦   ¦   ¦--Melisse                                                         
    ## 289  ¦   ¦   °--Schnittlauch                                                    
    ## 290  ¦   ¦--Hülsenfrüchtler (Fabaceae)                                          
    ## 291  ¦   ¦   ¦--Kichererbse                                                     
    ## 292  ¦   ¦   ¦--Linse                                                           
    ## 293  ¦   ¦   ¦--Puffbohne                                                       
    ## 294  ¦   ¦   ¦--Erbsen                                                          
    ## 295  ¦   ¦   ¦   ¦--Erbsen mit Hülsen                                           
    ## 296  ¦   ¦   ¦   °--Erbsen ohne Hülsen                                          
    ## 297  ¦   ¦   °--Bohnen                                                          
    ## 298  ¦   ¦       ¦--Bohnen ohne Hülsen                                          
    ## 299  ¦   ¦       °--Bohnen mit Hülsen                                           
    ## 300  ¦   ¦           ¦--Stangenbohne                                            
    ## 301  ¦   ¦           °--Buschbohne                                              
    ## 302  ¦   ¦--Kreuzblütler (Brassicaceae)                                         
    ## 303  ¦   ¦   ¦--Brunnenkresse                                                   
    ## 304  ¦   ¦   ¦--Kohlarten                                                       
    ## 305  ¦   ¦   ¦   ¦--Blumenkohle                                                 
    ## 306  ¦   ¦   ¦   ¦   ¦--Blumenkohl                                              
    ## 307  ¦   ¦   ¦   ¦   ¦--Romanesco                                               
    ## 308  ¦   ¦   ¦   ¦   °--Broccoli                                                
    ## 309  ¦   ¦   ¦   ¦--Blattkohle                                                  
    ## 310  ¦   ¦   ¦   ¦   ¦--Pak-Choi                                                
    ## 311  ¦   ¦   ¦   ¦   ¦--Markstammkohl                                           
    ## 312  ¦   ¦   ¦   ¦   ¦--Chinakohl                                               
    ## 313  ¦   ¦   ¦   ¦   ¦--Stielmus                                                
    ## 314  ¦   ¦   ¦   ¦   °--Federkohl                                               
    ## 315  ¦   ¦   ¦   ¦--Rosenkohl                                                   
    ## 316  ¦   ¦   ¦   ¦--Kopfkohle                                                   
    ## 317  ¦   ¦   ¦   °--Kohlrabi                                                    
    ## 318  ¦   ¦   ¦--Kresse                                                          
    ## 319  ¦   ¦   ¦--Blattsalate (Brassicaceae)                                      
    ## 320  ¦   ¦   ¦--Radies                                                          
    ## 321  ¦   ¦   ¦--Speisekohlrüben                                                 
    ## 322  ¦   ¦   ¦   ¦--Brassica napus-Rüben                                        
    ## 323  ¦   ¦   ¦   ¦   °--Bodenkohlrabi                                           
    ## 324  ¦   ¦   ¦   °--Brassica rapa-Rüben                                         
    ## 325  ¦   ¦   ¦--Barbarakraut                                                    
    ## 326  ¦   ¦   ¦--Rettich                                                         
    ## 327  ¦   ¦   ¦--Asia-Salate (Brassicaceae)                                      
    ## 328  ¦   ¦   ¦--Cima di Rapa                                                    
    ## 329  ¦   ¦   ¦--Rucola                                                          
    ## 330  ¦   ¦   °--Meerrettich                                                     
    ## 331  ¦   °--Kohlgemüse                                                          
    ## 332  ¦--Brache                                                                  
    ## 333  ¦--Traubensilberkerze                                                      
    ## 334  ¦--Obstbau allg.                                                           
    ## 335  ¦   ¦--Steinobst                                                           
    ## 336  ¦   ¦   ¦--Zwetschge / Pflaume                                             
    ## 337  ¦   ¦   ¦   ¦--Zwetschge                                                   
    ## 338  ¦   ¦   ¦   °--Pflaume                                                     
    ## 339  ¦   ¦   ¦--Pfirsich / Nektarine                                            
    ## 340  ¦   ¦   ¦--Kirsche                                                         
    ## 341  ¦   ¦   °--Aprikose                                                        
    ## 342  ¦   ¦--Kernobst                                                            
    ## 343  ¦   ¦   ¦--Birne / Nashi                                                   
    ## 344  ¦   ¦   ¦   °--Birne                                                       
    ## 345  ¦   ¦   ¦--Quitte                                                          
    ## 346  ¦   ¦   °--Apfel                                                           
    ## 347  ¦   ¦--Hartschalenobst                                                     
    ## 348  ¦   ¦   °--Nüsse                                                           
    ## 349  ¦   ¦       °--Walnuss                                                     
    ## 350  ¦   °--Olive                                                               
    ## 351  ¦--Biodiversitätforderflächen allg.                                        
    ## 352  ¦   ¦--Grünfläche                                                          
    ## 353  ¦   °--Offene Ackerfläche                                                  
    ## 354  °--allg. Wiesen und Weiden                                                 
    ##                               culture_id
    ## 1                                       
    ## 2   0FC26BDD-5CD1-4321-93D0-6AB24FA678B5
    ## 3   17B69B05-E650-4A6F-815A-D6DA55A92CDB
    ## 4   28ECDBFE-F44F-44C6-BF06-9B7E6EBFC1F6
    ## 5   465E7118-95AB-46A2-9A85-7A0B9070E63A
    ## 6   4B6DC713-3B11-42C5-92A8-E504D594E978
    ## 7   75047A9C-12E2-4BAC-89D8-B14BC4C6B100
    ## 8   7D23702C-980B-4B90-A86B-70013806D3EA
    ## 9   CC08E1E6-655D-4FAA-B0E8-AD968A68A536
    ## 10  3783A322-9E9C-44F6-B683-FE35221CA6AC
    ## 11  01AFF6EB-9C8D-4D0D-B225-0BA07B59A72F
    ## 12  086E34F3-82E5-4F92-9224-41C9F7529E70
    ## 13  B542EC7D-B423-43B4-9010-82A6889BB3B4
    ## 14  C763D817-B4AC-43DB-9C6E-A262CC32F400
    ## 15  095E9650-A880-4BD2-A1BB-39297582BCE6
    ## 16  27FBFA25-5091-4D7E-9C96-3C0BC05B6474
    ## 17  404C1D02-5666-4AA3-8487-65A9EEE0B53D
    ## 18  49F7DA15-E241-4080-9D42-1523ECA834B5
    ## 19  4A386AE2-A36F-4A55-8668-7B896A1E8092
    ## 20  575A1469-EF59-4B4E-96C3-38FC0CAEF637
    ## 21  4FC4A2B5-73DC-4C30-940C-813BBB4DFD10
    ## 22  B9DC95B4-DD22-49F9-9048-4B37F8DD8F8F
    ## 23  6388D9E7-CD0D-4823-80DD-E6FA472AF12C
    ## 24  657E4B0A-50BD-424B-9DB4-1B84582AD3D7
    ## 25  6D06A7F9-DF91-4BB5-84B8-FB877C211E66
    ## 26  7D52C099-7C6F-453C-8513-4BBFB94EE66A
    ## 27  8262D735-4D45-4499-AE0B-497FF4C0C4AA
    ## 28  8B5A3E2B-2534-4FC0-84C5-685915165A77
    ## 29  048FDB44-710A-4801-849C-72F1A458DB82
    ## 30  CEC488FC-D9AD-4515-A28E-DEEC6C807926
    ## 31  287584B7-E43E-494B-84C2-D13B2C9C3736
    ## 32  7AB6690B-B2B9-4F12-AFAE-A9B0222C2637
    ## 33  7D65DFD2-C26E-4CAB-9E2C-66A6C7CBA641
    ## 34  B74E61A6-30BD-4A63-8A24-94FC0A54D489
    ## 35  CEC488FC-D9AD-4515-A28E-DEEC6C807926
    ## 36  D3D49C53-8EBC-4DAC-9C4C-B988AA162F7D
    ## 37  F730D531-B0C8-4A20-AC4B-4F86445E2491
    ## 38  449A5380-96E3-4C3F-AB31-7CB3D0579561
    ## 39  B6669854-1833-4BBC-A931-E67505848EA7
    ## 40  C026CB2D-39B4-4FDF-AD04-FBA22AD2B4F1
    ## 41  C9DB1105-33C7-44E8-92BA-9BBE5BA2BB3F
    ## 42  7D76F5F6-5810-4556-A7D5-84C91FDE3FF2
    ## 43  B74E61A6-30BD-4A63-8A24-94FC0A54D489
    ## 44  82376115-14E2-449A-8DFA-F8119476FE3F
    ## 45  7870FD70-C44A-4788-ABEA-FB673A5FD106
    ## 46  D3D49C53-8EBC-4DAC-9C4C-B988AA162F7D
    ## 47  D3D90BE6-0924-4844-98FB-52C4D7F21A38
    ## 48  7AB6690B-B2B9-4F12-AFAE-A9B0222C2637
    ## 49  B6669854-1833-4BBC-A931-E67505848EA7
    ## 50  F730D531-B0C8-4A20-AC4B-4F86445E2491
    ## 51  F4273CE5-EC2B-42A3-89FC-C5F63EF425D2
    ## 52  7D65DFD2-C26E-4CAB-9E2C-66A6C7CBA641
    ## 53  C026CB2D-39B4-4FDF-AD04-FBA22AD2B4F1
    ## 54  F8A8C1D8-E2C7-4230-8435-4D5AEE69813E
    ## 55  C9DB1105-33C7-44E8-92BA-9BBE5BA2BB3F
    ## 56  99379C08-8682-4628-BD67-6E566F5130FA
    ## 57  9B8F475B-C6FA-4642-9CD8-89A98A293D50
    ## 58  9BA6BDE9-AD45-4F91-A190-708D39AD5B63
    ## 59  9F6AE17C-0BE1-457A-B780-D408BCD333BF
    ## 60  BC86A080-EDBD-4BBC-A36A-BE41037227C4
    ## 61  BD424265-B4C9-4410-AB7E-982930129FAE
    ## 62  5755AD92-721E-431E-8473-6FA2F340532F
    ## 63  C27B142E-1F10-46E0-A1CA-2ACCDA029027
    ## 64  CDF1E5BC-0740-4214-8912-870CC2BB37F4
    ## 65  D3CD23DC-4C49-4EE5-8BF8-6B074E74352A
    ## 66  E107FECF-24B6-43D7-B3E6-05C5C239EFBB
    ## 67  52019F0F-3BAF-4161-A223-62EECBA47871
    ## 68  5C0E6310-52CD-4368-9057-135822C019E6
    ## 69  E77825CE-5021-479E-B6C1-8F55766E497B
    ## 70  4E1ACD79-F162-4EBB-93CB-C6857A811E9C
    ## 71  EA82A16B-4A8C-4917-A08F-C2AD3B266640
    ## 72  38A60506-8FFA-4E1C-92AD-70A25987C64C
    ## 73  3FEAB48F-0D66-4814-B3E3-C4BC0AB749B3
    ## 74  13BB4B9E-6CEE-4729-AE29-8A4380EB33B0
    ## 75  19CC4F57-CB08-4970-BEDB-3DB2B2CB1034
    ## 76  43FC7C18-BDA5-4364-B4CA-74EA37B7B8DC
    ## 77  43FC7C18-BDA5-4364-B4CA-74EA37B7B8DC
    ## 78  43ED81C2-40E7-4A22-9114-3E623BE1B14C
    ## 79  2314EB9F-7207-409F-A0D4-89B6A1177363
    ## 80  293D431D-8501-4D41-A0E5-F1A5AD59C8B6
    ## 81  516862FD-DCB0-42BF-8E18-ADA820B1DB90
    ## 82  79A5CFAD-0AB3-41EB-8C69-E260DCD2DEE6
    ## 83  6C44D265-956D-457C-B395-71C81B327416
    ## 84  C38D7DE4-C804-4F7C-AA2F-A536D03E0DFC
    ## 85  7F20F06C-C950-49B9-A78F-9E2F696B079E
    ## 86  A22521E4-7D71-40C2-9FDF-B1230008D934
    ## 87  AE465EA2-A950-4661-B631-D5A267B2F076
    ## 88  BAE217C2-8C72-4706-8A0E-911FB18FC723
    ## 89  C3E12AAE-119E-47CF-9B8A-6F1CA657CF6B
    ## 90  8774F019-8BB4-409D-ADA9-B565ECA1A6A9
    ## 91  3E4AFACC-03CA-4CEC-8392-520B07DDC604
    ## 92  AC0240B5-B610-4D7C-8704-AA8E182821AC
    ## 93  F171615D-81A1-4654-BF30-BF51620DFFB9
    ## 94  890D8A5E-BF86-4B2D-9B98-45B779D80F7F
    ## 95  00D94F57-BA6F-4BA0-8F68-26D4C497539A
    ## 96  C69EBD93-43E5-457F-9CBE-EE1C04791274
    ## 97  10642620-4F7B-4E5E-8F38-D73914354014
    ## 98  34753E17-C34D-4D0B-88A0-91143DADABB2
    ## 99  83A9CEC5-FC31-421C-A3B8-CA219AF649CF
    ## 100 9C6CEE37-8105-4E48-9CA4-11BA3AB556FB
    ## 101 DAF00AE7-5272-4E07-9A66-E9F9BD8FEE43
    ## 102 E2A335E5-D797-46E7-9CE4-9CB3F301AAA2
    ## 103 1B9B39A9-D742-4E8D-A88E-280B65C4B913
    ## 104 AEC07D17-6D8B-4180-A368-056A187DE2F8
    ## 105 2A05DA01-5722-46A2-BCCF-3B75C6D17BB6
    ## 106 2E38C972-4160-4D2B-8ED2-3B48FC781EF0
    ## 107 9A9A2586-34FF-4256-8FA4-BA9F2FA38CAE
    ## 108 B75AC4CC-6BB7-4A99-808A-9F7BDFCF8E6A
    ## 109 E8B23A5E-B65E-4DC8-977D-BD84F143A442
    ## 110 3BEFA6F7-0D34-4E29-8207-85E9D5783ECC
    ## 111 4D46051A-2DE7-42B1-8FB9-5DC0B007A26E
    ## 112 2F7BD13A-BAA5-4708-83C6-17D44E57EA4D
    ## 113 3A53A166-7559-4E75-BDED-F65CA6FDFDE1
    ## 114 33097BFE-2487-46DB-85A0-A8A4E06030AF
    ## 115 5B651459-FC70-4D22-9469-4991F847EA89
    ## 116 79C28385-E183-4661-AAC0-80E82C67089C
    ## 117 A21391C3-A1A3-4472-8AA1-56449FB56B36
    ## 118 DF455946-B2AB-45D2-9780-4A45A98D72D6
    ## 119 ED17FD35-4C96-4D28-902B-ACEA3F4950D6
    ## 120 5C610428-6087-4A2E-B977-3E83EDBB19F0
    ## 121 75317E57-B194-4B3D-8FF2-3489A39AC177
    ## 122 230F7417-5500-4124-B273-95AA1FFB940B
    ## 123 2E38C972-4160-4D2B-8ED2-3B48FC781EF0
    ## 124 302E5676-26A3-41EB-980F-2B6BDE117D3A
    ## 125 34753E17-C34D-4D0B-88A0-91143DADABB2
    ## 126 36EC3084-D6AE-494D-A5B2-EC39DCC4F412
    ## 127 61D9C648-0736-43D4-BF04-B8643B1D74E0
    ## 128 83A9CEC5-FC31-421C-A3B8-CA219AF649CF
    ## 129 9A9A2586-34FF-4256-8FA4-BA9F2FA38CAE
    ## 130 9C6CEE37-8105-4E48-9CA4-11BA3AB556FB
    ## 131 A8647F38-2A16-46AB-8B0E-2257EBF53C63
    ## 132 B75AC4CC-6BB7-4A99-808A-9F7BDFCF8E6A
    ## 133 B82B5C60-02CB-4B7A-B3D3-A4CA34A809C3
    ## 134 DAF00AE7-5272-4E07-9A66-E9F9BD8FEE43
    ## 135 E2A335E5-D797-46E7-9CE4-9CB3F301AAA2
    ## 136 E8B23A5E-B65E-4DC8-977D-BD84F143A442
    ## 137 FF0DF95C-A3A9-47EE-95FA-00FCB428A4ED
    ## 138 7B3C8CEE-526F-4381-A757-669C1864291A
    ## 139 0A5F3E91-96B9-4C6D-B99C-2E6E4835F6D5
    ## 140 5B651459-FC70-4D22-9469-4991F847EA89
    ## 141 79C28385-E183-4661-AAC0-80E82C67089C
    ## 142 D95CD842-A5BC-4DAA-935D-F009DA7BA748
    ## 143 ED17FD35-4C96-4D28-902B-ACEA3F4950D6
    ## 144 7971013B-801D-4595-8208-782446A6C7E0
    ## 145 2F7BD13A-BAA5-4708-83C6-17D44E57EA4D
    ## 146 3A53A166-7559-4E75-BDED-F65CA6FDFDE1
    ## 147 A21391C3-A1A3-4472-8AA1-56449FB56B36
    ## 148 DF455946-B2AB-45D2-9780-4A45A98D72D6
    ## 149 A0012475-8478-4CA9-A18A-DC1CB96D788B
    ## 150 A024CDFC-A05D-46B8-B08A-221C26BDF5DE
    ## 151 B85EF4C2-C22E-4A5A-A431-98DC8F621D92
    ## 152 61D9C648-0736-43D4-BF04-B8643B1D74E0
    ## 153 CB7061F0-B1D8-4AC0-9C50-A596763B68CF
    ## 154 F4479311-1516-49F1-95BA-E232030F9AAC
    ## 155 FCF24426-CAB8-43C8-9E42-B09581420287
    ## 156 8E6C3D3A-6D7A-4D82-94CC-E4F227CC1EB2
    ## 157 9DE574C1-EE11-42BC-9C05-930BCAE13A44
    ## 158 122B909A-CE9C-47BC-B5CA-DCF523646D38
    ## 159 36D9AFE2-7506-48CE-BA39-EFD54535294A
    ## 160 42D50BC4-0019-4B55-9CB5-6C3E86C9D112
    ## 161 43F8091A-A333-40F5-8845-FF83398B9AC3
    ## 162 8621CDCC-EE8A-4188-9F2C-14C9497FBED3
    ## 163 D63D73AC-87B1-41F7-82AC-D1DFF12F6704
    ## 164 9230C798-B1D0-4342-947C-C7A0988F416E
    ## 165 A3E943A5-C6D8-4CB0-A069-85BFC48E8B8A
    ## 166 A9F01BDE-468A-477A-8ED5-704359B663F6
    ## 167 B92BA12C-EA9D-4EA8-ADEE-A4547872DD58
    ## 168 BE3C6915-B28E-4CC8-980E-7F243F14F519
    ## 169 3A522DC8-E6D3-426D-AA99-65C148ED1A84
    ## 170 4E8A4BB8-3B5D-4695-B17C-F4C1202D5138
    ## 171 91406007-35B9-49E2-A62F-04BDE262366F
    ## 172 FFDDDA7D-B340-473C-94F4-841272B602FA
    ## 173 D18572C7-A270-4AA7-B766-48D62C5E9AB7
    ## 174 D1E8D0D6-BD3C-4C47-9017-DBEADC9215A9
    ## 175 D605CAA5-9199-4739-8C9C-343C74DABAEB
    ## 176 DDAE7B47-8561-44B4-BA3A-F9855E30BB54
    ## 177 EC349B29-6A2B-4E43-990F-C553D278DC0E
    ## 178 A707FD99-918E-49B2-ACA2-0393372D8C7C
    ## 179 AB4A906B-73C5-4D7D-AA74-EC42983BE679
    ## 180 B03E1EE3-18EE-4DC9-A98F-D528894885EB
    ## 181 B4368C0E-9129-4C6C-A752-747D00073ADF
    ## 182 B4CA8F81-4A66-4880-98AB-C7760AECCDA6
    ## 183 0106A8DF-6CDF-4E18-8F46-3D9E1D52D0E5
    ## 184 6C3D663E-442F-4783-87A2-A46806E119E5
    ## 185 9BD6A435-E370-4DFE-82E5-7E7813B4D193
    ## 186 DB0DCB7D-CA9F-454A-8398-606F066FBF4F
    ## 187 0A3519B1-A42F-43EE-AF82-6DCF17EA8DA6
    ## 188 27ACD8EA-49E8-4C99-84D4-53E2E605390E
    ## 189 0FEBE55E-236F-483E-AE05-88A35B181A55
    ## 190 037E11B2-128A-4194-9A5B-A3E980AE4113
    ## 191 8DFDE2D1-C004-4C25-BF54-21CF7C815232
    ## 192 DB98FC8E-5AFA-4434-9478-960124F960CA
    ## 193 83C510D2-293A-4E1B-B691-06B1F02149B4
    ## 194 874850AA-2F48-47B6-A789-C67D6DEE97DA
    ## 195 C883F887-6B72-4917-9385-7A757E5FD8D6
    ## 196 F718EA3C-F363-4DB2-BDF6-2D6236706822
    ## 197 17CE2494-D0C9-484B-A91E-15B7B04733FD
    ## 198 8A00630A-32FC-4B5A-8171-EC0F41D39F48
    ## 199 77267F83-907F-4537-98A8-7B9C1E4714F0
    ## 200 2D7D1AE2-E685-4C6B-B8EE-DC5C6391EC76
    ## 201 C96EE4F4-12EA-49DE-9BEF-21EA73B52760
    ## 202 2FAEBED2-193A-460C-A538-9B5C78024D98
    ## 203 707A99EF-0290-4CA9-9D90-8ADFDAA43330
    ## 204 31A0539F-1D4C-4BCF-876F-215CEBC4C864
    ## 205 AE97719E-9D0F-425C-BCD7-0F5D84092113
    ## 206 39D599AA-B93E-4AC2-970E-5A99A3113572
    ## 207 7A993953-3C2F-4BC3-98EE-2EE5E83C6E77
    ## 208 93A2DA1B-F920-461B-A9C9-BA9981CDB278
    ## 209 AB0798FE-64B8-49A2-8E75-14467EB7AB58
    ## 210 915B2192-1651-4B8A-B2D8-C162A5D27211
    ## 211 B7DE9539-35FD-4172-B72D-488EA12F2DF7
    ## 212 46901564-D096-4323-AE81-C93831AFEC64
    ## 213 096444CD-43E6-41F9-8914-2E7DADA4C801
    ## 214 46D3C073-CBD8-4B3A-A9AA-21785BA911CA
    ## 215 68688AEC-44E2-490B-AC80-E8DEDCC82B8F
    ## 216 6CC3F1FF-84DF-4E4A-A91E-57C5ECB82F61
    ## 217 74C47437-5700-45F5-86E2-D410DACD39B6
    ## 218 E9E3C127-33C1-40D9-8552-3CBE45E8E4C4
    ## 219 07A12E5B-DB0B-4421-A215-E306768AC0BE
    ## 220 1D9F568C-5170-43A1-86B9-B25808DD6A43
    ## 221 D100976A-2598-4614-AB7A-61436FF2B053
    ## 222 F512809F-5CC7-44A2-A378-8FDAFA67CFEA
    ## 223 5276BCA7-CEA5-4B6D-90E3-52F3A0532490
    ## 224 0D20E815-633E-4F38-AC93-7B6578B0483E
    ## 225 21228D46-5B00-4CDD-9C71-48C0A0B21C78
    ## 226 2AB457D1-DB9D-4545-92FF-04A6BD2CEC08
    ## 227 D36B92CB-136F-46C3-8217-10C3F86ECA12
    ## 228 18C6314C-C067-4E7F-AAB6-2DEF3F01DF9D
    ## 229 3702313F-95C6-4FE9-8B6B-C7CE3987CD18
    ## 230 56884AC3-B629-440D-8E82-05075A18697F
    ## 231 EE7EE009-EBD4-471D-AE85-1A98130F6119
    ## 232 8303C191-3315-4942-91DF-668C019850D7
    ## 233 09269926-BA07-42DC-BE9D-5B34658BDBF0
    ## 234 30F9F737-0A18-43EC-AF88-F28940E567F1
    ## 235 238AB652-AD62-4703-A74B-7550C693ED6E
    ## 236 AED83C4B-0546-4C91-B370-4AB5B425942F
    ## 237 CE13A930-22B8-44D6-98E4-97707B0F7F6C
    ## 238 399AC89E-29BB-44AD-8B1F-0B2F327D5230
    ## 239 573B50E9-ED1D-4999-B4FD-4537CA2A6306
    ## 240 BBD16782-6EB3-4923-9DBB-CC7D97EBCB0E
    ## 241 FE69D926-4BE1-4C67-840E-30C3D299442E
    ## 242 3447F4C9-2E90-437F-A240-0462AFEDF2B5
    ## 243 C1A1842A-37E5-46D3-9646-9ECC15BAEE99
    ## 244 F6A02973-2AF5-47AF-B99D-FFAD9A24BCB4
    ## 245 855980B6-D3CA-46B5-86C5-12E9847344B5
    ## 246 EF29B430-95C5-45D4-A812-DCCE046E1B8E
    ## 247 B05127D4-FF0A-4F36-AFDD-0D487043122A
    ## 248 1BFC9694-C7DC-4D74-84B2-1418AB94A8BA
    ## 249 3346CB25-6DC9-42AF-8BA2-F725BD92304A
    ## 250 9A9333CA-AD6C-459D-9AFF-B8E8FB2FF8D4
    ## 251 BDB73EC5-46E5-413B-85B5-78D3801F4E7E
    ## 252 E5B9C6F0-5C57-4A12-8ED9-D65B669B8243
    ## 253 E786D43D-444B-49D6-B0D0-294265F91403
    ## 254 25DA6F5A-1BD0-4040-A210-BB05CCB66AE4
    ## 255 33686F38-1E1A-4698-81E4-C40EE4494EF3
    ## 256 4DD550C5-15BB-4D52-98BD-6770972575F0
    ## 257 B02E0EFA-B8AF-425A-A779-6A4DFE8D4172
    ## 258 9CA61204-7EA7-4F2F-BAD3-BD02EDD6A829
    ## 259 BC3BA289-5090-487A-A2FE-3B0A0FDE4A1B
    ## 260 8DB1A579-6BAC-4DCB-8026-E79B65D3BD3A
    ## 261 62BF86AE-FD69-4F95-A72C-1D57AF1DCD99
    ## 262 B535B6DD-517D-4A62-ACC7-2948B15175ED
    ## 263 BA6FCA8F-68B8-4408-A267-2546B1FA5764
    ## 264 1F0B6451-EC2C-4647-A53A-23B0EAE626B1
    ## 265 BF77A7F8-C4C5-43AF-9BCD-B7F904506E7A
    ## 266 5433C814-C0CD-4815-B236-2D02E1C66F3D
    ## 267 C3F940E4-D07C-4F4D-851C-D1024F8A6A62
    ## 268 D541F2F5-8BA6-4E26-AA66-9CF469648AFF
    ## 269 068FF636-982B-4F95-A1C1-93E3DC0B7162
    ## 270 0A88EFE2-B85E-4BF7-9C38-AEE8CB2BFE42
    ## 271 0DAB25B6-C3AA-430B-BF83-05FA66D889A4
    ## 272 0E2847EB-CEFD-4640-82EB-F09F3F1A5E13
    ## 273 14B19DFD-331F-4C30-8724-8EDDF8E2D0D4
    ## 274 1A1D511B-4ABD-44F2-8BB5-55192F5310D2
    ## 275 25DC9B01-CA06-426A-B743-C0D293447898
    ## 276 2C8A4414-AD7F-4708-9C58-BF1969131693
    ## 277 37059300-8031-4A64-B75C-7490288E32BA
    ## 278 3C2F424F-DFA0-4A59-A3DF-6E33A6B0B97E
    ## 279 4D799EC6-1483-4D65-90EA-8DDB6A4166CA
    ## 280 710CC0C8-B138-4B31-9975-4DA04AF67792
    ## 281 730AACDC-B956-493D-8148-7520019CE0BC
    ## 282 807F5A2C-7904-456D-BBC7-A80A4B207964
    ## 283 8512D352-73CC-4535-9469-965AAF1FD0B1
    ## 284 91522E50-F1AC-42B1-870B-68218110C235
    ## 285 A067CC81-6A5D-4684-BE95-7941A51B9EF2
    ## 286 A2D2B4EC-D7D6-4A30-BEE9-0A8F907A874A
    ## 287 ABF54D5D-620B-4A08-A37D-416C1AD8D1BF
    ## 288 D51188F1-9F8F-46E6-8F5B-550A7D45A4BE
    ## 289 FA8C26CF-E3B4-456D-AA4E-94D21AEADA1A
    ## 290 DB4E4C8B-016C-4C31-8DC5-587A9F1F8FFD
    ## 291 2260B6A9-FC51-4F50-8E8F-D39BC6D5DA3A
    ## 292 54C75B64-57C4-46E2-BCEA-741EBC10FDDF
    ## 293 56AF3EA3-01F4-4F10-B240-7EF4BE1C1CCE
    ## 294 5DF3AB4D-7CAC-4112-90D9-67BD80EC5E96
    ## 295 02BF379A-E526-422A-952B-3B0CD995F8C1
    ## 296 C5188A42-9C79-4110-B1E8-AEE9D6078BEA
    ## 297 A8BAC5BB-239F-4EE0-8CE2-F55590DA3FC0
    ## 298 102C28F6-4AFB-4079-909B-ACE8E0819A77
    ## 299 F7BB2F1C-EDE5-4C95-931E-0B2C973F5A29
    ## 300 4465118D-78E7-4748-A47A-7F39E593771A
    ## 301 930524FB-BD0A-4CA9-A89D-4FEEE1F9174F
    ## 302 E55D75D3-B805-4BFD-B2B0-D02368BD32AC
    ## 303 19C5BA72-A0D5-4409-8D05-0A7C9D821E20
    ## 304 4380EC0F-E195-4783-8BB7-F6B0464B37D6
    ## 305 4A22B9D3-747C-4323-A852-1CB1F6ADB680
    ## 306 1E129025-DFD8-42D1-8A86-D90485B282A1
    ## 307 8AFA14F8-CCE3-4012-BD12-9D690EBAE1AD
    ## 308 B9323B4D-249D-4CF3-A5DF-4FDA2E66532F
    ## 309 6F26F4E0-401C-4B16-A28B-4CC889907361
    ## 310 394AE687-29A0-4BA6-B0B9-D7DFB0C08FCE
    ## 311 80395E92-C39B-45D9-91AC-AB7E6DCAC3DB
    ## 312 C37A7EE2-D06B-4204-809A-F50A934F79E3
    ## 313 DA5835F6-C295-4A4F-829D-007B1FA50A6D
    ## 314 DF4B3775-8361-41CE-9843-AC953197403D
    ## 315 7B90BAC4-B80F-4039-ADC3-ADF9225CCBB7
    ## 316 CA58ABAE-E494-4608-BE51-5FF49D853A03
    ## 317 D8A50212-BD15-456A-9D2E-2A401C2EF21D
    ## 318 7CE53BA0-097D-44FB-82FF-C30DFD3769DD
    ## 319 85BB3788-27A8-4E73-800A-0E8F154EC0BE
    ## 320 8FF3D364-2BA6-40AA-A370-4B72E3CAC8DF
    ## 321 A0C29069-5DBA-4E89-B7F9-4C556C272821
    ## 322 1F004DAA-89AD-4A9D-A172-95D24B8A45FA
    ## 323 EB820B26-DE4E-4AF4-8BA3-46844F045306
    ## 324 BFD1B79E-ABD1-4A44-8E61-891FF97960A1
    ## 325 BA2DECCF-5987-4987-B56E-C5EC6E5D19C0
    ## 326 BB923645-6E65-48EE-9C64-DA2232EEE7EF
    ## 327 BFDDCB65-6E46-47E1-90B1-A998D5BD0546
    ## 328 C264982A-CA81-4311-9E38-67D2D956BC78
    ## 329 CC9D982D-A99F-4143-8298-BC029BD1D1AD
    ## 330 EACDD832-D1CD-479C-973F-CD0DB6A9FBC3
    ## 331 EB0C465C-50B7-4DC0-914B-ABE4C284A907
    ## 332 C8AB8319-939E-4CF3-B78E-549A85DEF756
    ## 333 D1C8A572-3D39-46F7-BEAC-10B485FE4FC3
    ## 334 DA71526F-AC1D-40F1-8EF5-109E3F3FFD76
    ## 335 01D7815D-B309-4ECF-B172-DA38B80C8732
    ## 336 24A364B9-6BD7-42A6-A9EC-AB9E94E010FF
    ## 337 66B27CD1-032A-456E-99C4-28F6E989CC14
    ## 338 9C38BA77-FDC8-461A-800A-9E2467C52105
    ## 339 307A62EA-67D6-4D28-9CF7-F1218C9BE2CD
    ## 340 ABA3C163-EFDF-4B91-9F61-8380B6DDE0A6
    ## 341 EEC471CB-C715-489D-B3E5-2A0D37DC2A90
    ## 342 0F5F1FEE-084C-4961-A76F-82F9B17B2635
    ## 343 9CBD7DB6-38F5-4C41-952D-72F253C88809
    ## 344 42466A90-AFCD-4DA6-8769-99C4BC5BE217
    ## 345 FD180555-9DEF-42BA-86E0-EBD31AB8FABB
    ## 346 FD18F42C-C390-4701-B07B-B8108B33320B
    ## 347 6EDA1989-51C8-490E-90FD-974CE3E8FF03
    ## 348 77462EAB-3BD3-4EAC-B740-F95597FFAE35
    ## 349 6D45EAF5-D29C-48AB-A212-91C67357E898
    ## 350 9BCEB85B-1578-4001-839D-68BFB9CE4CD8
    ## 351 E798A7B8-F618-42EE-88F4-289B1283C7B3
    ## 352 24EA0CC6-D1D5-4BB4-981C-A836E3D7125D
    ## 353 8BDDCACC-13C1-4676-9322-402ECF20BE85
    ## 354 FD7AB34C-F432-445D-9440-F44FDAB8422C
    ##                                                                       name_fr
    ## 1                                                                            
    ## 2                                           Lager- und Produktionsräume allg.
    ## 3                                                 Les exploitations tabacoles
    ## 4                                                  Locaux de production vides
    ## 5                                                     installations et outils
    ## 6                                              Locaux de transformation vides
    ## 7                          Palette en bois, bois d'emballage, bois en général
    ## 8                                                             Êntrepôts vides
    ## 9                                                              denrée stockée
    ## 10                                                  grande culture en général
    ## 11                                                                    Houblon
    ## 12                                           betteraves à sucre et fourragère
    ## 13                                                          Betterave à sucre
    ## 14                                                       Betterave fourragère
    ## 15                                                                  Tournesol
    ## 16                                                              Sorgho commun
    ## 17                                                                      Lupin
    ## 18                                                                   Carthame
    ## 19                                                            Roseau de Chine
    ## 20                                                            pommes de terre
    ## 21                              pommes de terre de consommation et fourragère
    ## 22                               pommes de terre pour la production de plants
    ## 23                                     Trèfles pour la production de semences
    ## 24                                                                   féverole
    ## 25                                                                      Kenaf
    ## 26                                                          pois protéagineux
    ## 27                                                                      Tabac
    ## 28                                                                   Céréales
    ## 29                                                                  Triticale
    ## 30                                                        Triticale d'automne
    ## 31                                                         Céréales d'automne
    ## 32                                                              Blé d'automne
    ## 33                                                             Orge d'automne
    ## 34                                                           Seigle d'automne
    ## 35                                                        Triticale d'automne
    ## 36                                                                   Épeautre
    ## 37                                                                 Amidonnier
    ## 38                                                      Céréales de printemps
    ## 39                                                           Blé de printemps
    ## 40                                                          orge de printemps
    ## 41                                                        Avoine de printemps
    ## 42                                                                     Seigle
    ## 43                                                           Seigle d'automne
    ## 44                                                                        Blé
    ## 45                                                                    Blé dur
    ## 46                                                                   Épeautre
    ## 47                                                                 Blé tendre
    ## 48                                                              Blé d'automne
    ## 49                                                           Blé de printemps
    ## 50                                                                 Amidonnier
    ## 51                                                                       Orge
    ## 52                                                             Orge d'automne
    ## 53                                                          orge de printemps
    ## 54                                                                     Avoine
    ## 55                                                        Avoine de printemps
    ## 56                                                  Riz semis sur terrain sec
    ## 57                                                                      pavot
    ## 58                                                                        Lin
    ## 59                                                                       Soja
    ## 60                                                                       maïs
    ## 61                                                                      Colza
    ## 62                                                            Colza d'automne
    ## 63                                                                     millet
    ## 64                                   Graminées pour la production de semences
    ## 65                                                                    Luzerne
    ## 66                                                      techniques culturales
    ## 67                                                         semis sous litière
    ## 68                                            semis après travail superficiel
    ## 69                                                      Prairies et pâturages
    ## 70                            mélange trèfles-graminées (prairie arificielle)
    ## 71                                                                    Chanvre
    ## 72                                                                 Orpin rose
    ## 73                                                    sylviculture en général
    ## 74                              grumes en forêt et sur les places de stockage
    ## 75                                                                      forêt
    ## 76                                                     pépinières forestières
    ## 77                                                     pépinières forestières
    ## 78                                                        domaine app. vignes
    ## 79                                                                      vigne
    ## 80                                                        vigne en production
    ## 81                                                                jeune vigne
    ## 82                                                        plantes médicinales
    ## 83                                                                  valériane
    ## 84                                                          digitale lanifère
    ## 85                                            domaine non agricole en général
    ## 86  talus et bandes vertes le long des voies de communication (selon ORRChim)
    ## 87                                                                     friche
    ## 88                                                    dépôt de terre végétale
    ## 89               le long des routes nationales et cantonales  (selon ORRChim)
    ## 90                                                    protection des récoltes
    ## 91                                                   locaux de transformation
    ## 92                                                  entrepôts, moulins, silos
    ## 93                                                                  entrepôts
    ## 94                                             culture ornementale en général
    ## 95                             plantes ornementales annuelles et bisannuelles
    ## 96                                                           fleurs estivales
    ## 97                                                             fleurs coupées
    ## 98                                                               chrysanthème
    ## 99                                                                    oeillet
    ## 100                                                                   gerbera
    ## 101                                                              chardon bleu
    ## 102                                                                   glaïeul
    ## 103                                                      tubercules de fleurs
    ## 104                                                                    dahlia
    ## 105                                            plantes en pot et en container
    ## 106                                                                   bégonia
    ## 107                                                                  cyclamen
    ## 108                                                                  géranium
    ## 109                                                                primevères
    ## 110                                                                 pépinière
    ## 111                                           arbres et arbustes (hors fôret)
    ## 112                                                         marronnier d'Inde
    ## 113                                                              rhododendron
    ## 114                                                                    azalée
    ## 115                                                                sapin bleu
    ## 116                                                            arbres de Noël
    ## 117                                                            laurier-cerise
    ## 118                                                              buis (Buxus)
    ## 119                                                              cupressacées
    ## 120                                     gazon d'ornement et terrains de sport
    ## 121                                       cultures florales et plantes vertes
    ## 122                                                                ranunculus
    ## 123                                                                   bégonia
    ## 124                                                         courge d'ornement
    ## 125                                                              chrysanthème
    ## 126                                                                   anémone
    ## 127                                                                  jacinthe
    ## 128                                                                   oeillet
    ## 129                                                                  cyclamen
    ## 130                                                                   gerbera
    ## 131                                                                      iris
    ## 132                                                                  géranium
    ## 133                                          liliacées (plantes ornementales)
    ## 134                                                              chardon bleu
    ## 135                                                                   glaïeul
    ## 136                                                                primevères
    ## 137                                                                    tulipe
    ## 138                                            plantes ligneuses (hors forêt)
    ## 139                                                                 conifères
    ## 140                                                                sapin bleu
    ## 141                                                            arbres de Noël
    ## 142                                                                    épicéa
    ## 143                                                              cupressacées
    ## 144                                                                  feuillus
    ## 145                                                         marronnier d'Inde
    ## 146                                                              rhododendron
    ## 147                                                            laurier-cerise
    ## 148                                                              buis (Buxus)
    ## 149                                                        bulbes ornementaux
    ## 150                                                                    rosier
    ## 151                                                         bulbes des fleurs
    ## 152                                                                  jacinthe
    ## 153                                                                  euphorbe
    ## 154                                          arbustes d'ornement (hors forêt)
    ## 155                                                           plantes vivaces
    ## 156                                                                   plantes
    ## 157                                              culture des baies en général
    ## 158                                                     sorbier des oiseleurs
    ## 159                                                              aronie noire
    ## 160                                                              grand sureau
    ## 161                                                          espèces de Rubus
    ## 162                                                                      mûre
    ## 163                                                                 framboise
    ## 164                                                                    fraise
    ## 165                                                             Baies de Goji
    ## 166                                                                  myrtille
    ## 167                                                           camérisier bleu
    ## 168                                                          espèces de Ribes
    ## 169                                                    groseilles à maquereau
    ## 170                                                                    cassis
    ## 171                                                      groseilles à grappes
    ## 172                                                                     josta
    ## 173                                                               mûrier noir
    ## 174                                                                 argousier
    ## 175                                                          amélavier commun
    ## 176                                                         mini-Kiwi (Kiwaï)
    ## 177                                                                cynorhodon
    ## 178                                                         plantain lancéolé
    ## 179                                                                   Laurier
    ## 180                                                   champignons comestibles
    ## 181                                                         Cerfeuil tubéreux
    ## 182                                             culture maraîchère en général
    ## 183                                                                 Baby-Leaf
    ## 184                                                  Baby-Leaf (Brassicaceae)
    ## 185                                                Baby-Leaf (Chenopodiaceae)
    ## 186                                                    Baby-Leaf (Asteraceae)
    ## 187                                                              polygonacées
    ## 188                                                                  rhubarbe
    ## 189                                                            amaryllidaceae
    ## 190                                                                       ail
    ## 191                                                                   poireau
    ## 192                                                                    oignon
    ## 193                                                            oignon potager
    ## 194                                                          oignons en botte
    ## 195                                                        oignon (condiment)
    ## 196                                                                  échalote
    ## 197                                             portulacacées (Portulacaceae)
    ## 198                                                                  pourpier
    ## 199                                                           pourpier commun
    ## 200                                               asparagacées (Asparagaceae)
    ## 201                                                                   asperge
    ## 202                                                             valérianacées
    ## 203                                                             mâche, rampon
    ## 204                                         herbes aromatiques et médicinales
    ## 205                                                              millepertuis
    ## 206                                                            chénopodiacées
    ## 207                                                        betterave à salade
    ## 208                                                                   épinard
    ## 209                                                                     bette
    ## 210                                                              bette à côte
    ## 211                                                            bette à tondre
    ## 212                                                                solanacées
    ## 213                                                                   poivron
    ## 214                                                                   poivron
    ## 215                                                              poivron doux
    ## 216                                                                 aubergine
    ## 217                                                         coqueret du Pérou
    ## 218                                                                    tomate
    ## 219                                                      tomates, spécialités
    ## 220                                                             tomate-cerise
    ## 221                                                           tomate à grappe
    ## 222                                                               poire melon
    ## 223                                                   ombellifères (Apiaceae)
    ## 224                                                           fenouil bulbeux
    ## 225                                                    persil à grosse racine
    ## 226                                                                   carotte
    ## 227                                                                    céleri
    ## 228                                                céleri-pomme pour bouillon
    ## 229                                                            céleri-branche
    ## 230                                                              céleri-pomme
    ## 231                                                                    Panais
    ## 232                                                             cucurbitacées
    ## 233                                                                  pastèque
    ## 234                                                                 concombre
    ## 235                                                                cornichons
    ## 236                                                        concombre nostrano
    ## 237                                                        concombre de serre
    ## 238                                                                    melons
    ## 239                                           courges (écorce non comestible)
    ## 240                                                      courges oléagineuses
    ## 241                                                 courges à peau comestible
    ## 242                                                                  pâtisson
    ## 243                                                                 courgette
    ## 244                                                                   rondini
    ## 245                                           convolvulacées (Convolvulaceae)
    ## 246                                                              Patate douce
    ## 247                                                     composées (Asteracea)
    ## 248                                                                 artichaut
    ## 249                                                                    cardon
    ## 250                                                                scorsonère
    ## 251                                                               topinambour
    ## 252                                        chicorée witloof (chicorée-endive)
    ## 253                                                      salades (Asteraceae)
    ## 254                                                              dent-de-lion
    ## 255                                                           salades lactuca
    ## 256                                                           laitues pommées
    ## 257                                                             laitue pommée
    ## 258                                             laitues à tondre (Asteraceae)
    ## 259                                                           laitue à tondre
    ## 260                                    chicorée pommée et chicorée à feuilles
    ## 261                                         chicorée scarole, chicorée frisée
    ## 262                                   types de radicchio/trévises et cicorino
    ## 263                                                      lamiacées (Labiatae)
    ## 264                                                          crosnes du japon
    ## 265                                                       poacées (Gramineae)
    ## 266                                                                maïs sucré
    ## 267                                                                    herbes
    ## 268                                                              fines herbes
    ## 269                                                                   livèche
    ## 270                                                                    Hysope
    ## 271                                                                 coriandre
    ## 272                                                                    origan
    ## 273                                                                   romarin
    ## 274                                                                    persil
    ## 275                                                         Camomille romaine
    ## 276                                                                  cerfeuil
    ## 277                                                                    menthe
    ## 278                                                                   basilic
    ## 279                                                                 sarriette
    ## 280                                                                marjolaine
    ## 281                                                                      thym
    ## 282                                                                     carvi
    ## 283                                                        fenouil aromatique
    ## 284                                                                     aneth
    ## 285                                                                     sauge
    ## 286                                                           Cerfeuil musqué
    ## 287                                                                  estragon
    ## 288                                                                   mélisse
    ## 289                                                                ciboulette
    ## 290                                                   fabacées (légumineuses)
    ## 291                                                               pois chiche
    ## 292                                                                  lentille
    ## 293                                                                      fève
    ## 294                                                                      pois
    ## 295                                                          pois non écossés
    ## 296                                                              pois écossés
    ## 297                                                                  haricots
    ## 298                                                          haricots écossés
    ## 299                                                      haricots non écossés
    ## 300                                                           haricot à rames
    ## 301                                                              haricot nain
    ## 302                                                 crucifères (Brassicaceae)
    ## 303                                                       cresson de fontaine
    ## 304                                                                     choux
    ## 305                                  choux (développement de l'inflorescence)
    ## 306                                                                chou-fleur
    ## 307                                                                 romanesco
    ## 308                                                                   brocoli
    ## 309                                                          choux à feuilles
    ## 310                                                                   pakchoi
    ## 311                                                             chou moellier
    ## 312                                                             chou de Chine
    ## 313                                                            navet à tondre
    ## 314                                                      chou frisé non pommé
    ## 315                                                         chou de Bruxelles
    ## 316                                                              choux pommés
    ## 317                                                                   colrave
    ## 318                                                         cresson de jardin
    ## 319                                          laitues à tondre  (Brassicaceae)
    ## 320                                                    radis de tous les mois
    ## 321                                         rave de Brassica rapa et B. napus
    ## 322                                                    rave de Brassica napus
    ## 323                                                                  rutabaga
    ## 324                                                     rave de Brassica rapa
    ## 325                                                     Barbarée du printemps
    ## 326                                                                radis long
    ## 327                                               salades Asia (Brassicaceae)
    ## 328                                                              cima di rapa
    ## 329                                                                  roquette
    ## 330                                                                   raifort
    ## 331                                                                     choux
    ## 332                                                                   jachère
    ## 333                                                            actée à grappe
    ## 334                                                  arboriculture en général
    ## 335                                                           fruits à noyaux
    ## 336                                                   prunier (pruneau/prune)
    ## 337                                                         prunier (pruneau)
    ## 338                                                           prunier (prune)
    ## 339                                                        pêcher / nectarine
    ## 340                                                                  cerisier
    ## 341                                                                abricotier
    ## 342                                                           fruits à pépins
    ## 343                                                           poirier / nashi
    ## 344                                                                   poirier
    ## 345                                                                cognassier
    ## 346                                                                   pommier
    ## 347                                                           noix en général
    ## 348                                                                      noix
    ## 349                                                                     noyer
    ## 350                                                                   olivier
    ## 351                       Surfaces de promotion de la biodiversité en général
    ## 352                                                       surfaces herbagères
    ## 353                                                           terres ouvertes
    ## 354                                        domaine app. prairies et paturages
    ##                                                                             name_it
    ## 1                                                                                  
    ## 2                                                 Lager- und Produktionsräume allg.
    ## 3                                                    Aziende produttrici di tabacco
    ## 4                                                        Locali di produzione vuoti
    ## 5                                                        Installazioni e apparecchi
    ## 6                                                   Locali per la lavorazione vuoti
    ## 7                        Palette in legno, legno da imballaggio, legno non lavorato
    ## 8                                                        Locali di stoccaggio vuoti
    ## 9                                                                 Raccolto stoccato
    ## 10                                                         Campicoltura in generale
    ## 11                                                                          Luppolo
    ## 12                                           Barbabietole da foraggio e da zucchero
    ## 13                                                         Barbabietola da zucchero
    ## 14                                                         Barbabietola da foraggio
    ## 15                                                                         Girasole
    ## 16                                                                            Sorgo
    ## 17                                                                           Lupini
    ## 18                                                                          Cartamo
    ## 19                                                                         Miscanto
    ## 20                                                                           Patate
    ## 21                                                   Patate da tavola e da foraggio
    ## 22                                          Patate per la produzione di tuberi-seme
    ## 23                                           Trifoglio per la produzione di sementi
    ## 24                                                                             Fava
    ## 25                                                                            Kenaf
    ## 26                                                                 Pisello proteico
    ## 27                                                                          Tabacco
    ## 28                                                                          Cereali
    ## 29                                                                        Triticale
    ## 30                                                              Triticale autunnale
    ## 31                                                                Cereali autunnali
    ## 32                                                               Frumento autunnale
    ## 33                                                                   Orzo autunnale
    ## 34                                                                 Segale autunnale
    ## 35                                                              Triticale autunnale
    ## 36                                                                           Spelta
    ## 37                                                                            Farro
    ## 38                                                              Cereali primaverili
    ## 39                                                             Frumento primaverile
    ## 40                                                                 Orzo primaverile
    ## 41                                                                Avena primaverile
    ## 42                                                                           Segale
    ## 43                                                                 Segale autunnale
    ## 44                                                                         Frumento
    ## 45                                                                       Grano duro
    ## 46                                                                           Spelta
    ## 47                                                                     Grano tenero
    ## 48                                                               Frumento autunnale
    ## 49                                                             Frumento primaverile
    ## 50                                                                            Farro
    ## 51                                                                             Orzo
    ## 52                                                                   Orzo autunnale
    ## 53                                                                 Orzo primaverile
    ## 54                                                                            Avena
    ## 55                                                                Avena primaverile
    ## 56                                                Riso seminato su terreno asciutto
    ## 57                                                                         Papavero
    ## 58                                                                             Lino
    ## 59                                                                             Soia
    ## 60                                                                             Mais
    ## 61                                                                            colza
    ## 62                                                                  Colza autunnale
    ## 63                                                                           Miglio
    ## 64                                          Graminacee per la produzione di sementi
    ## 65                                                                      Erba medica
    ## 66                                                          Tecnica di coltivazione
    ## 67                                                                Semine a lattiera
    ## 68                                                         Semine dopo la fresatura
    ## 69                                                                  Prati e pascoli
    ## 70                                 Miscela trifoglio-graminacee (prati artificiali)
    ## 71                                                                           Canapa
    ## 72                                                                   Rhodiola rosea
    ## 73                                                         Selvicoltura in generale
    ## 74                    Tronchi abbattuti nella foresta e presso piazzali di deposito
    ## 75                                                                            Bosco
    ## 76                                                                  Vivai forestali
    ## 77                                                                  Vivai forestali
    ## 78                                                                                 
    ## 79                                                                             Vite
    ## 80                                                               Vite in produzione
    ## 81                                                                    Ceppi giovani
    ## 82                                                                  erbe medicinali
    ## 83                                                                        Valeriana
    ## 84                                                                  Digitale lanata
    ## 85                                                Superfici non coltive in generale
    ## 86  Scarpate e strisce verdi lungo le vie di comunicazione (conformemente ORRPChim)
    ## 87                                                                  Terreno incolto
    ## 88                                                     Deposito di terreno vegetale
    ## 89                   Lungo le strade nazionali e cantonali (conformemente ORRPChim)
    ## 90                                            Protezione delle scorte (in generale)
    ## 91                                                        Locali per la lavorazione
    ## 92                                                           Depositi, mulini, sili
    ## 93                                                                         Depositi
    ## 94                                           Coltivazione piante ornam. in generale
    ## 95                                            Piante ornamentali annuali e biennali
    ## 96                                                                     Fiori estivi
    ## 97                                                                     Fiori recisi
    ## 98                                                                       Crisantemo
    ## 99                                                                         Garofani
    ## 100                                                                         Gerbera
    ## 101                                                                   Cardo azzurro
    ## 102                                                                        Gladiolo
    ## 103                                                        Radici tuberose floreali
    ## 104                                                                           Dalie
    ## 105                                                   Pianta in vaso e in container
    ## 106                                                                         Begonia
    ## 107                                                                       Ciclamino
    ## 108                                                                         Geranio
    ## 109                                                                         Primule
    ## 110                                                                          Vivaio
    ## 111                                    Alberi e arbusti (al di fuori della foresta)
    ## 112                                                                     Ippocastano
    ## 113                                                                      Rododendro
    ## 114                                                                          Azalee
    ## 115                                                              Abete del Colorado
    ## 116                                                                Alberi di Natale
    ## 117                                                                    Lauro ceraso
    ## 118                                                                   Bosso (Buxus)
    ## 119                                                                    Cupressaceae
    ## 120                                               Tappeti erbosi e terreni sportivi
    ## 121                                                 Colture da fiore e piante verdi
    ## 122                                                                       ranuncolo
    ## 123                                                                         Begonia
    ## 124                                                               Zucca ornamentale
    ## 125                                                                      Crisantemo
    ## 126                                                                         Anemone
    ## 127                                                                        Giacinto
    ## 128                                                                        Garofani
    ## 129                                                                       Ciclamino
    ## 130                                                                         Gerbera
    ## 131                                                                            Iris
    ## 132                                                                         Geranio
    ## 133                                                   Liliacee (pianti ornamentali)
    ## 134                                                                   Cardo azzurro
    ## 135                                                                        Gladiolo
    ## 136                                                                         Primule
    ## 137                                                                        Tulipano
    ## 138                                               Boschetti (al di fuori del bosco)
    ## 139                                                                        Conifere
    ## 140                                                              Abete del Colorado
    ## 141                                                                Alberi di Natale
    ## 142                                                                     Abete rosso
    ## 143                                                                    Cupressaceae
    ## 144                                                                      Latifoglie
    ## 145                                                                     Ippocastano
    ## 146                                                                      Rododendro
    ## 147                                                                    Lauro ceraso
    ## 148                                                                   Bosso (Buxus)
    ## 149                                                               Bulbi ornamentali
    ## 150                                                                            Rose
    ## 151                                                                  Bulbi di fiori
    ## 152                                                                        Giacinto
    ## 153                                                                        Euforbia
    ## 154                                 Arbusti ornamentali (al di fuori della foresta)
    ## 155                                                                         Arbusti
    ## 156                                                                          Piante
    ## 157                                              Coltivazione di bacche in generale
    ## 158                                                          Sorbo degli ucellatori
    ## 159                                                                     Aronia nera
    ## 160                                                                    Sambuco nero
    ## 161                                                                 Specie di rubus
    ## 162                                                                            Mora
    ## 163                                                                         Lampone
    ## 164                                                                         Fragola
    ## 165                                                                  Bacche di Goji
    ## 166                                                                        Mirtillo
    ## 167                                                            Caprifoglio turchino
    ## 168                                                                 Specie di ribes
    ## 169                                                                       Uva spina
    ## 170                                                                      Ribes nero
    ## 171                                                                     Ribes rosso
    ## 172                                                                           Josta
    ## 173                                                                       Moro nero
    ## 174                                                                Olivello spinoso
    ## 175                                                                    Pero corvino
    ## 176                                                                       Mini-Kiwi
    ## 177                                                                     rosa canina
    ## 178                                                           piantaggine lanciuola
    ## 179                                                                          Alloro
    ## 180                                                             Funghi commestibili
    ## 181                                                               Cerfoglio bulboso
    ## 182                                                         Orticoltura in generale
    ## 183                                                                       Baby-Leaf
    ## 184                                                        Baby-Leaf (Brassicaceae)
    ## 185                                                      Baby-Leaf (Chenopodiaceae)
    ## 186                                                          Baby-Leaf (Asteraceae)
    ## 187                                                                     Poligonacee
    ## 188                                                                       Rabarbaro
    ## 189                                                                  Amaryllidaceae
    ## 190                                                                           Aglio
    ## 191                                                                           Porro
    ## 192                                                                         Cipolle
    ## 193                                                                   Cipolle dolci
    ## 194                                                              Cipollotti a mazzi
    ## 195                                                               Cipolle da tavola
    ## 196                                                                        Scalogni
    ## 197                                                      Portulacee (Portulacaceae)
    ## 198                                                                       Portulaca
    ## 199                                                                Portulaca estiva
    ## 200                                                      Asparagacee (Asparagaceae)
    ## 201                                                                        Asparagi
    ## 202                                                                    Valerianacee
    ## 203                                                                    Valerianella
    ## 204                                                    Erbe aromatiche e medicinali
    ## 205                                                                         Iperico
    ## 206                                                                   Chenopodiacee
    ## 207                                                                    Barbabietola
    ## 208                                                                         Spinaci
    ## 209                                                                         Bietola
    ## 210                                                                           Costa
    ## 211                                                               Bietola da taglio
    ## 212                                                                       Solanacee
    ## 213                                                                        Peperone
    ## 214                                                                        Peperone
    ## 215                                                                  Peperone dolce
    ## 216                                                                       Melanzana
    ## 217                                                                    Alchechengio
    ## 218                                                                        Pomodori
    ## 219                                                 Varietà particolari di pomodoro
    ## 220                                                               Pomodoro ciliegia
    ## 221                                                                 Pomodoro ramato
    ## 222                                                                          Pepino
    ## 223                                                          Ombrellifere (Apiacee)
    ## 224                                                                 Finocchio dolce
    ## 225                                                             Prezzemolo tuberoso
    ## 226                                                                          Carote
    ## 227                                                                          Sedano
    ## 228                                                            Sedano da condimento
    ## 229                                                                 Sedano da coste
    ## 230                                                                     Sedano rapa
    ## 231                                                                       Pastinaca
    ## 232                                                                    Cucurbitacee
    ## 233                                                                         Angurie
    ## 234                                                                        Cetrioli
    ## 235                                                           cetrioli per conserva
    ## 236                                                               Cetriolo nostrano
    ## 237                                                               Cetriolo olandese
    ## 238                                                                          Meloni
    ## 239                                                Zucche (buccia non commestibile)
    ## 240                                                                   Zucca da olio
    ## 241                                                  Zucche con buccia commestibile
    ## 242                                                                        Patisson
    ## 243                                                                        Zucchine
    ## 244                                                                         Rondini
    ## 245                                                                  Convolvulaceae
    ## 246                                                                    Patata dolce
    ## 247                                                           Composite (Asteracee)
    ## 248                                                                        Carciofi
    ## 249                                                                           Cardo
    ## 250                                                                      Scorzonera
    ## 251                                                                      Topinambur
    ## 252                                                                   Cicoria belga
    ## 253                                                            Insalate (Asteracee)
    ## 254                                                                  Dente di leone
    ## 255                                                     Insalate del genere Lactuca
    ## 256                                                              Insalate cappuccio
    ## 257                                                               Lattuga cappuccio
    ## 258                                                   Insalate a foglie (Asteracee)
    ## 259                                                               Lattuga da taglio
    ## 260                                                     Indivia e cicoria da foglia
    ## 261                                                                         Indivia
    ## 262                                                    Tipi di radicchio e cicorino
    ## 263                                                             Lamiacee (Labiatae)
    ## 264                                                                        Tuberina
    ## 265                                                            Poacee (Graminaceae)
    ## 266                                                                      Mais dolce
    ## 267                                                                            Erbe
    ## 268                                                               Erbette da cucina
    ## 269                                                                       Levistico
    ## 270                                                                          Issopo
    ## 271                                                                      Coriandolo
    ## 272                                                                         origano
    ## 273                                                                       Rosmarino
    ## 274                                                                      Prezzemolo
    ## 275                                                                Camomilla romana
    ## 276                                                                       Cerfoglio
    ## 277                                                                           Menta
    ## 278                                                                        Basilico
    ## 279                                                                     Santoreggia
    ## 280                                                                      maggiorana
    ## 281                                                                            Timo
    ## 282                                                                           Carvi
    ## 283                                                             Finocchio aromatico
    ## 284                                                                           Aneto
    ## 285                                                                          Salvia
    ## 286                                                                    finocchiella
    ## 287                                                                     Dragoncello
    ## 288                                                                         Melissa
    ## 289                                                                  Erba cipollina
    ## 290                                                            Fabacee (Leguminose)
    ## 291                                                                            cece
    ## 292                                                                      Lenticchia
    ## 293                                                                            Fave
    ## 294                                                                         Piselli
    ## 295                                                            Piselli con baccello
    ## 296                                                          Piselli senza baccello
    ## 297                                                                         Fagioli
    ## 298                                                          Fagioli senza baccello
    ## 299                                                            Fagioli con baccello
    ## 300                                                              Fagiolo rampicante
    ## 301                                                                    Fagiolo nano
    ## 302                                                         Crocifere (Brassicacee)
    ## 303                                                             Crescione acquatico
    ## 304                                                                Specie di cavoli
    ## 305                                                          Cavoli a infiorescenza
    ## 306                                                                      Cavolfiore
    ## 307                                                                       Romanesco
    ## 308                                                                        Broccoli
    ## 309                                                                Cavoli fogliacei
    ## 310                                                                        Pak-Choi
    ## 311                                                                  Cavolo fustoso
    ## 312                                                                   Cavolo cinese
    ## 313                                                         Cavoli / rape da taglio
    ## 314                                                                    Cavolo piuma
    ## 315                                                             Cavoli di Bruxelles
    ## 316                                                                  Cavoli a testa
    ## 317                                                                     Cavolo rapa
    ## 318                                                                       Crescione
    ## 319                                                 Insalate a foglie (Brassicacee)
    ## 320                                                                       Ravanello
    ## 321                                                Rapa di Brassica rapa e B. napus
    ## 322                                                          Rapa di Brassica napus
    ## 323                                                                   Cavolo navone
    ## 324                                                           Rapa di Brassica rapa
    ## 325                                                   Erba di Santa Barbara vernale
    ## 326                                                                      Ramolaccio
    ## 327                                                Insalate asiatiche (Brassicacee)
    ## 328                                                                    Cima di rapa
    ## 329                                                                          Rucola
    ## 330                                                   Rafano rusticana / Ramolaccio
    ## 331                                                                          Cavoli
    ## 332                                                                         Maggese
    ## 333                                                                 actaea racemosa
    ## 334                                                       Frutticoltura in generale
    ## 335                                                               Frutta a nocciolo
    ## 336                                                                   Prugno/Susino
    ## 337                                                                          Prugno
    ## 338                                                                        Prugnolo
    ## 339                                                                Pesco/pesco noce
    ## 340                                                                        Ciliegio
    ## 341                                                                       Albicocco
    ## 342                                                               Frutta a granelli
    ## 343                                                                    Pero / Nashi
    ## 344                                                                            Pero
    ## 345                                                                         Cotogno
    ## 346                                                                            Melo
    ## 347                                                               Frutta con guscio
    ## 348                                                                            Noci
    ## 349                                                                     Noce comune
    ## 350                                                                           Olivo
    ## 351                      Superfici per la promozione della biodiversità in generale
    ## 352                                                             Superficie inerbita
    ## 353                                                       Superficie coltiva aperta
    ## 354
