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
The first four entries out of 442 are shown below.

``` r
library(knitr)
example_register$substances |> 
  select(pk, iupac, substance_de, substance_fr, substance_it) |> 
  head(n = 4L) |> 
  kable()
```

| pk                                   | iupac                                | substance_de                        | substance_fr                         | substance_it                         |
|:-------------------------------------|:-------------------------------------|:------------------------------------|:-------------------------------------|:-------------------------------------|
| 0A7BFE30-AC31-4326-9CF4-8A93ED26D3AB | (E)-8-dodecen-1-yl acetate           | (E)-8-Dodecen-1-yl acetat           | (E)-8-dodecen-1-yl acetate           | (E)-8-dodecen-1-yl acetate           |
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

| pNbr | pk                                   | type              | percent | g_per_L | ingredient_de                    | ingredient_fr                         |
|-----:|:-------------------------------------|:------------------|--------:|--------:|:---------------------------------|:--------------------------------------|
|   38 | D95F01F3-9ED2-4D08-92FD-A58AF1B5F49F | ACTIVE_INGREDIENT |   80.00 |         |                                  |                                       |
| 1182 | 057FC3E0-B59E-45EB-8CCB-B2EA4527E479 | ACTIVE_INGREDIENT |   38.00 |   438.5 | entspricht 34.7 % MCPB (400g/L)  | correspond à 34.7 % de MCPB (400 g/L) |
| 1192 | 057FC3E0-B59E-45EB-8CCB-B2EA4527E479 | ACTIVE_INGREDIENT |   38.00 |   438.5 | entspricht 34.7 % MCPB (400 g/L) | correspond à 34,7 % de MCPB (400 g/L) |
| 1263 | D95F01F3-9ED2-4D08-92FD-A58AF1B5F49F | ACTIVE_INGREDIENT |   80.00 |         |                                  |                                       |
| 1865 | 1D7FC783-1AA4-47FD-B973-83867751B87B | ACTIVE_INGREDIENT |   99.16 |   830.0 |                                  |                                       |

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
| ACTIVE_INGREDIENT   | 324 |
| ADDITIVE_TO_DECLARE | 111 |
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
| SYNERGIST | Sesamöl raffiniert |   1 |

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

| pNbr | wNbr | name                       | exhaustionDeadline | soldoutDeadline | isSalePermission | permission_holder                    |
|-----:|:-----|:---------------------------|:-------------------|:----------------|:-----------------|:-------------------------------------|
|   38 | 18   | Thiovit Jet                |                    |                 | FALSE            | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
|   38 | 18-1 | Sufralo                    |                    |                 | TRUE             | 15BAC516-7F05-4353-82D7-A2BA41438215 |
|   38 | 18-2 | Capito Bio-Schwefel        |                    |                 | TRUE             | 15BAC516-7F05-4353-82D7-A2BA41438215 |
|   38 | 18-3 | Sanoplant Schwefel         |                    |                 | TRUE             | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
|   38 | 18-4 | Biorga Contra Schwefel     |                    |                 | TRUE             | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
|   38 | 18-5 | Gesal Schrotschuss Spezial |                    |                 | TRUE             | A128E9C6-FBC1-4649-8E3C-92073B82925B |

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

| pNbr | wNbr   | name                     | exhaustionDeadline          | soldoutDeadline             | isSalePermission | permission_holder                    |
|-----:|:-------|:-------------------------|:----------------------------|:----------------------------|:-----------------|:-------------------------------------|
| 2092 | 1698   | Asulox                   | 2026-07-01 00:00:00.0000000 | 2025-07-01 00:00:00.0000000 | FALSE            | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
| 3948 | 4034   | Asulam                   | 2026-07-01 00:00:00.0000000 | 2025-07-01 00:00:00.0000000 | FALSE            | 5E2915EB-369E-4C9C-B8B7-9FAAABF0E127 |
| 4163 | 4309   | Volpan                   | 2026-10-31 00:00:00.0000000 | 2025-10-31 00:00:00.0000000 | FALSE            | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
| 4163 | 4309-1 | MIOPLANT Windenvertilger | 2026-10-31 00:00:00.0000000 | 2025-10-31 00:00:00.0000000 | TRUE             | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
| 4251 | 4234   | Capex 2                  | 2026-07-01 00:00:00.0000000 | 2025-07-01 00:00:00.0000000 | FALSE            | F05FD7E3-EA3C-46CE-A537-B40375F273AA |
| 4426 | 4343   | Cypermethrin             | 2026-06-11 00:00:00.0000000 | 2025-06-11 00:00:00.0000000 | FALSE            | 5E2915EB-369E-4C9C-B8B7-9FAAABF0E127 |

At the build time of this vignette, there were 1731 product
registrations for 1114 P-Numbers in the Swiss Register of Plant
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
| 4077 | Plüsstar | 2,4-D        |   14.83 |     170 |
| 4077 | Plüsstar | Mecoprop-P   |   35.34 |     405 |

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
| 6521 |      1 |            |            |      0.5 |        1 | l/ha     |                |               | Feldbau             |
| 6521 |      2 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      3 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      4 |            |            |      1.5 |          | l/ha     |                |               | Feldbau             |
| 6521 |      5 |            |            |      1.0 |          | l/ha     |              3 | Week(s)       | Feldbau             |
| 6521 |      6 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      7 |            |            |      1.0 |          | l/ha     |              3 | Week(s)       | Feldbau             |
| 6521 |      8 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      9 |            |            |      1.0 |          | l/ha     |              3 | Week(s)       | Feldbau             |
| 7511 |      1 |        0.3 |            |          |          | kg/ha    |              3 | Days          | Gemüsebau           |
| 7511 |      2 |            |            |      5.0 |          | kg/ha    |                |               | Obstbau             |
| 7511 |      3 |        0.3 |            |      4.8 |          | kg/ha    |                |               | Obstbau             |
| 7511 |      4 |        0.3 |            |      4.8 |          | kg/ha    |              8 | Days          | Obstbau             |
| 7511 |      5 |            |            |      3.0 |          | kg/ha    |              1 | Days          | Gemüsebau           |
| 7511 |      6 |        0.3 |            |          |          |          |              3 | Days          | Beerenbau           |
| 7511 |      7 |            |            |      3.0 |          | kg/ha    |              1 | Days          | Gemüsebau           |
| 7511 |      8 |            |            |      3.0 |          | kg/ha    |              1 | Days          | Gemüsebau           |
| 7511 |      9 |            |            |      5.0 |          | kg/ha    |              3 | Days          | Gemüsebau           |

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
| 7105 | Boxer |      1 |            |            |      2.5 |        5 | l/ha     | Feldbau             | Prosulfocarb |   78.43 |     800 |
| 7105 | Boxer |      2 |            |            |      5.0 |          | l/ha     | Gemüsebau           | Prosulfocarb |   78.43 |     800 |
| 7105 | Boxer |      3 |            |            |      3.0 |          | l/ha     | Gemüsebau           | Prosulfocarb |   78.43 |     800 |
| 7105 | Boxer |      4 |            |            |      5.0 |          | l/ha     | Gemüsebau           | Prosulfocarb |   78.43 |     800 |
| 7105 | Boxer |      5 |            |            |      3.0 |        5 | l/ha     | Feldbau             | Prosulfocarb |   78.43 |     800 |
| 7105 | Boxer |     12 |            |            |      5.0 |          | l/ha     | Feldbau             | Prosulfocarb |   78.43 |     800 |
| 7105 | Boxer |     13 |            |            |      2.5 |        5 | l/ha     | Feldbau             | Prosulfocarb |   78.43 |     800 |
| 7105 | Boxer |     14 |            |            |      5.0 |          | l/ha     | Gemüsebau           | Prosulfocarb |   78.43 |     800 |
| 7105 | Boxer |     15 |            |            |      4.0 |          | l/ha     | Gemüsebau           | Prosulfocarb |   78.43 |     800 |
| 7105 | Boxer |     16 |            |            |      4.0 |          | l/ha     | Gemüsebau           | Prosulfocarb |   78.43 |     800 |
| 7105 | Boxer |     17 |            |            |      4.0 |          | l/ha     | Gemüsebau           | Prosulfocarb |   78.43 |     800 |

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
| Prosulfocarb | Gemüsebau |      5.0 |          | l/ha     | 4000 |
| Prosulfocarb | Gemüsebau |      3.0 |          | l/ha     | 2400 |
| Prosulfocarb | Gemüsebau |      5.0 |          | l/ha     | 4000 |
| Prosulfocarb | Feldbau   |      3.0 |        5 | l/ha     | 4000 |
| Prosulfocarb | Feldbau   |      5.0 |          | l/ha     | 4000 |
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

    ##                                                  levelName
    ## 1  Cultures                                               
    ## 2   ¦--Baby-Leaf                                          
    ## 3   ¦   ¦--Baby-Leaf (Brassicaceae)                       
    ## 4   ¦   ¦--Baby-Leaf (Chenopodiaceae)                     
    ## 5   ¦   °--Baby-Leaf (Asteraceae)                         
    ## 6   ¦--Oregano                                            
    ## 7   ¦--Eberesche                                          
    ## 8   ¦--allg. Forstwirtschaft                              
    ## 9   ¦   °--Liegendes Rundholz im Wald und auf Lagerplätzen
    ## 10  ¦--Tabak produzierende Betriebe                       
    ## 11  ¦--allg. Feldbau                                      
    ## 12  ¦   ¦--Hopfen                                         
    ## 13  ¦   ¦--Futter- und Zuckerrüben                        
    ## 14  ¦   ¦   ¦--Zuckerrübe                                 
    ## 15  ¦   ¦   °--Futterrübe                                 
    ## 16  ¦   ¦--Sonnenblume                                    
    ## 17  ¦   ¦--Wiesen und Weiden                              
    ## 18  ¦   ¦   °--Kleegrasmischung (Kunstwiese)              
    ## 19  ¦   ¦--Sorghum                                        
    ## 20  ¦   ¦--Lupinen                                        
    ## 21  ¦   ¦--Färberdistel (Saflor)                          
    ## 22  ¦   ¦--Chinaschilf                                    
    ## 23  ¦   ¦--Klee zur Saatgutproduktion                     
    ## 24  ¦   ¦--Ackerbohne                                     
    ## 25  ¦   ¦--Kenaf                                          
    ## 26  ¦   ¦--Eiweisserbse                                   
    ## 27  ¦   ¦--Tabak                                          
    ## 28  ¦   ¦--Getreide                                       
    ## 29  ¦   ¦   ¦--Triticale                                  
    ## 30  ¦   ¦   ¦   °--... 1 nodes w/ 0 sub                   
    ## 31  ¦   ¦   °--... 6 nodes w/ 20 sub                      
    ## 32  ¦   °--... 9 nodes w/ 31 sub                          
    ## 33  °--... 46 nodes w/ 290 sub                            
    ##                              culture_id
    ## 1                                      
    ## 2  0106A8DF-6CDF-4E18-8F46-3D9E1D52D0E5
    ## 3  6C3D663E-442F-4783-87A2-A46806E119E5
    ## 4  9BD6A435-E370-4DFE-82E5-7E7813B4D193
    ## 5  DB0DCB7D-CA9F-454A-8398-606F066FBF4F
    ## 6  0E2847EB-CEFD-4640-82EB-F09F3F1A5E13
    ## 7  122B909A-CE9C-47BC-B5CA-DCF523646D38
    ## 8  1575BC21-D089-4248-99A6-676F14E1309F
    ## 9  13BB4B9E-6CEE-4729-AE29-8A4380EB33B0
    ## 10 17B69B05-E650-4A6F-815A-D6DA55A92CDB
    ## 11 1DD3F253-4B23-4B69-BFB1-1C24CE7D5508
    ## 12 01AFF6EB-9C8D-4D0D-B225-0BA07B59A72F
    ## 13 086E34F3-82E5-4F92-9224-41C9F7529E70
    ## 14 B542EC7D-B423-43B4-9010-82A6889BB3B4
    ## 15 C763D817-B4AC-43DB-9C6E-A262CC32F400
    ## 16 095E9650-A880-4BD2-A1BB-39297582BCE6
    ## 17 1F03DDC0-19CF-48F1-BAB8-61CA4CEF24CF
    ## 18 4E1ACD79-F162-4EBB-93CB-C6857A811E9C
    ## 19 27FBFA25-5091-4D7E-9C96-3C0BC05B6474
    ## 20 404C1D02-5666-4AA3-8487-65A9EEE0B53D
    ## 21 49F7DA15-E241-4080-9D42-1523ECA834B5
    ## 22 4A386AE2-A36F-4A55-8668-7B896A1E8092
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

| use_nr | pest_de                               | pest_add_txt_de | pest_fr                   | pest_add_txt_fr |
|-------:|:--------------------------------------|:----------------|:--------------------------|:----------------|
|      1 | Einjährige Monocotyledonen (Ungräser) |                 | monocotylédones annuelles |                 |
|      1 | Einjährige Dicotyledonen (Unkräuter)  |                 | dicotylédones annuelles   |                 |
|      2 | Einjährige Monocotyledonen (Ungräser) |                 | monocotylédones annuelles |                 |
|      2 | Einjährige Dicotyledonen (Unkräuter)  |                 | dicotylédones annuelles   |                 |

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
| 6521 |      1 | Feldbau             | Weizen                             | Gelbrost                            |
| 6521 |      2 | Feldbau             | Weizen                             | Septoria-Spelzenbräune (S. nodorum) |
| 6521 |      3 | Feldbau             | Winterroggen                       | Braunrost                           |
| 6521 |      4 | Feldbau             | Raps                               | Wurzelhals- und Stengelfäule        |
| 6521 |      5 | Feldbau             | Lupinen                            | Anthraknose                         |
| 6521 |      6 | Feldbau             | Weizen                             | Echter Mehltau des Getreides        |
| 6521 |      7 | Feldbau             | Eiweisserbse                       | Graufäule (Botrytis cinerea)        |
| 6521 |      7 | Feldbau             | Eiweisserbse                       | Rost der Erbse                      |
| 6521 |      7 | Feldbau             | Eiweisserbse                       | Brennfleckenkrankheit der Erbse     |
| 6521 |      8 | Feldbau             | Weizen                             | Ährenfusariosen                     |
| 6521 |      9 | Feldbau             | Ackerbohne                         | Rost der Ackerbohne                 |
| 6521 |      9 | Feldbau             | Ackerbohne                         | Braunfleckenkrankheit               |
| 6521 |     10 | Feldbau             | Lein                               | Stängelbräune des Leins             |
| 6521 |     10 | Feldbau             | Lein                               | Pasmokrankheit                      |
| 6521 |     10 | Feldbau             | Lein                               | Echter Mehltau des Leins            |
| 6521 |     11 | Gemüsebau           | Spargel                            | Blattschwärze der Spargel           |
| 6521 |     11 | Gemüsebau           | Spargel                            | Spargelrost                         |
| 6521 |     12 | Feldbau             | Grasbestände zur Saatgutproduktion | Rost der Gräser                     |
| 6521 |     12 | Feldbau             | Grasbestände zur Saatgutproduktion | Blattfleckenpilze                   |
| 6521 |     13 | Gemüsebau           | Erbsen                             | Graufäule (Botrytis cinerea)        |
| 6521 |     13 | Gemüsebau           | Erbsen                             | Rost der Erbse                      |
| 6521 |     13 | Gemüsebau           | Erbsen                             | Brennfleckenkrankheit der Erbse     |
| 6521 |     14 | Feldbau             | Raps                               | Sclerotinia-Fäule                   |
| 6521 |     15 | Feldbau             | Raps                               | Wurzelhals- und Stengelfäule        |
| 6521 |     15 | Feldbau             | Raps                               | Erhöhung der Standfestigkeit        |

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

| pNbr | use_nr | application_comment_de                            | application_comment_fr                             |
|-----:|-------:|:--------------------------------------------------|:---------------------------------------------------|
| 7105 |      1 | Herbst, Frühjahr; Vorauflauf, früher Nachauflauf. | automne, printemps; pré-levée, post-levée précoce. |
| 7105 |      2 | Nachauflauf, Stadium 12-13.                       | post-levée, stade 12-13.                           |

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

| pNbr | use_nr | code  | obligation_de                                                                                                                                                                                                                                                                                                                                                                               | sw_runoff_points |
|-----:|-------:|:------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------:|
| 7105 |      1 | 13804 | Behandlung von im Herbst gesäten Kulturen.                                                                                                                                                                                                                                                                                                                                                  |                  |
| 7105 |      1 | 9457  | Maximal 1 Behandlung pro Kultur.                                                                                                                                                                                                                                                                                                                                                            |                  |
| 7105 |      1 | 14120 | SPe 3: Zum Schutz von Gewässerorganismen muss das Abschwemmungsrisiko gemäss den Weisungen der Zulassungsstelle um 1 Punkt reduziert werden.                                                                                                                                                                                                                                                |                1 |
| 7105 |      1 | 9824  | Niedrige Aufwandmenge nur in Tankmischung gemäss den Angaben der Bewilligungsinhaberin.                                                                                                                                                                                                                                                                                                     |                  |
| 7105 |      1 | 11380 | Nachfolgearbeiten in behandelten Kulturen: bis 48 Stunden nach Ausbringung des Mittels Schutzhandschuhe + Schutzanzug tragen.                                                                                                                                                                                                                                                               |                  |
| 7105 |      1 | 12827 | Ansetzen der Spritzbrühe: Schutzhandschuhe tragen. Ausbringen der Spritzbrühe: Schutzhandschuhe + Schutzanzug + Visier + Kopfbedeckung tragen. Technische Schutzvorrichtungen während des Ausbringens (z.B. geschlossene Traktorkabine) können die vorgeschriebene persönliche Schutzausrüstung ersetzen, wenn gewährleistet ist, dass sie einen vergleichbaren oder höheren Schutz bieten. |                  |
| 7105 |      2 | 9561  | Phytotoxschäden bei empfindlichen Arten oder Sorten möglich; vor allgemeiner Anwendung Versuchspritzung durchführen.                                                                                                                                                                                                                                                                        |                  |
| 7105 |      2 | 9457  | Maximal 1 Behandlung pro Kultur.                                                                                                                                                                                                                                                                                                                                                            |                  |
| 7105 |      2 | 14120 | SPe 3: Zum Schutz von Gewässerorganismen muss das Abschwemmungsrisiko gemäss den Weisungen der Zulassungsstelle um 1 Punkt reduziert werden.                                                                                                                                                                                                                                                |                1 |
| 7105 |      2 | 8614  | Nachbau anderer Kulturen: 16 Wochen Wartefrist.                                                                                                                                                                                                                                                                                                                                             |                  |
| 7105 |      2 | 11380 | Nachfolgearbeiten in behandelten Kulturen: bis 48 Stunden nach Ausbringung des Mittels Schutzhandschuhe + Schutzanzug tragen.                                                                                                                                                                                                                                                               |                  |
| 7105 |      2 | 12827 | Ansetzen der Spritzbrühe: Schutzhandschuhe tragen. Ausbringen der Spritzbrühe: Schutzhandschuhe + Schutzanzug + Visier + Kopfbedeckung tragen. Technische Schutzvorrichtungen während des Ausbringens (z.B. geschlossene Traktorkabine) können die vorgeschriebene persönliche Schutzausrüstung ersetzen, wenn gewährleistet ist, dass sie einen vergleichbaren oder höheren Schutz bieten. |                  |

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
    ## 2    ¦--Baby-Leaf                                                               
    ## 3    ¦   ¦--Baby-Leaf (Brassicaceae)                                            
    ## 4    ¦   ¦--Baby-Leaf (Chenopodiaceae)                                          
    ## 5    ¦   °--Baby-Leaf (Asteraceae)                                              
    ## 6    ¦--Oregano                                                                 
    ## 7    ¦--Eberesche                                                               
    ## 8    ¦--allg. Forstwirtschaft                                                   
    ## 9    ¦   °--Liegendes Rundholz im Wald und auf Lagerplätzen                     
    ## 10   ¦--Tabak produzierende Betriebe                                            
    ## 11   ¦--allg. Feldbau                                                           
    ## 12   ¦   ¦--Hopfen                                                              
    ## 13   ¦   ¦--Futter- und Zuckerrüben                                             
    ## 14   ¦   ¦   ¦--Zuckerrübe                                                      
    ## 15   ¦   ¦   °--Futterrübe                                                      
    ## 16   ¦   ¦--Sonnenblume                                                         
    ## 17   ¦   ¦--Wiesen und Weiden                                                   
    ## 18   ¦   ¦   °--Kleegrasmischung (Kunstwiese)                                   
    ## 19   ¦   ¦--Sorghum                                                             
    ## 20   ¦   ¦--Lupinen                                                             
    ## 21   ¦   ¦--Färberdistel (Saflor)                                               
    ## 22   ¦   ¦--Chinaschilf                                                         
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
    ## 42   ¦   ¦   ¦--Gerste                                                          
    ## 43   ¦   ¦   ¦   ¦--Wintergerste [dup]                                          
    ## 44   ¦   ¦   ¦   °--Sommergerste [dup]                                          
    ## 45   ¦   ¦   ¦--Roggen                                                          
    ## 46   ¦   ¦   ¦   °--Winterroggen [dup]                                          
    ## 47   ¦   ¦   ¦--Weizen                                                          
    ## 48   ¦   ¦   ¦   ¦--Hartweizen                                                  
    ## 49   ¦   ¦   ¦   ¦--Korn (Dinkel) [dup]                                         
    ## 50   ¦   ¦   ¦   ¦--Weichweizen                                                 
    ## 51   ¦   ¦   ¦   ¦   ¦--Winterweizen [dup]                                      
    ## 52   ¦   ¦   ¦   ¦   °--Sommerweizen [dup]                                      
    ## 53   ¦   ¦   ¦   °--Emmer [dup]                                                 
    ## 54   ¦   ¦   °--Hafer                                                           
    ## 55   ¦   ¦       °--Sommerhafer [dup]                                           
    ## 56   ¦   ¦--Trockenreis                                                         
    ## 57   ¦   ¦--Lein                                                                
    ## 58   ¦   ¦--Sojabohne                                                           
    ## 59   ¦   ¦--Kartoffeln                                                          
    ## 60   ¦   ¦   ¦--Kartoffeln zur Pflanzgutproduktion                              
    ## 61   ¦   ¦   °--Speise- und Futterkartoffeln                                    
    ## 62   ¦   ¦--Grasbestände zur Saatgutproduktion                                  
    ## 63   ¦   ¦--Luzerne                                                             
    ## 64   ¦   ¦--Anbautechnik                                                        
    ## 65   ¦   ¦   ¦--Mulchsaaten                                                     
    ## 66   ¦   ¦   °--Frässaaten                                                      
    ## 67   ¦   ¦--Raps                                                                
    ## 68   ¦   ¦   °--Winterraps                                                      
    ## 69   ¦   °--Mais                                                                
    ## 70   ¦--Kichererbse                                                             
    ## 71   ¦--Ranunkel                                                                
    ## 72   ¦--Grünfläche                                                              
    ## 73   ¦--Spitzwegerich                                                           
    ## 74   ¦--Leere Produktionsräume                                                  
    ## 75   ¦--Anemone                                                                 
    ## 76   ¦--Feldbau allg.                                                           
    ## 77   ¦   ¦--Getreide [dup]                                                      
    ## 78   ¦   ¦--Trockenreis [dup]                                                   
    ## 79   ¦   ¦--Kartoffeln [dup]                                                    
    ## 80   ¦   ¦--Rispenhirse                                                         
    ## 81   ¦   ¦--Hanf                                                                
    ## 82   ¦   °--Mais [dup]                                                          
    ## 83   ¦--allg. Beerenbau                                                         
    ## 84   ¦   ¦--Schwarze Apfelbeere                                                 
    ## 85   ¦   ¦--Schwarzer Holunder                                                  
    ## 86   ¦   ¦--Rubus Arten                                                         
    ## 87   ¦   ¦   ¦--Brombeere                                                       
    ## 88   ¦   ¦   °--Himbeere                                                        
    ## 89   ¦   ¦--Heidelbeere                                                         
    ## 90   ¦   ¦--Ribes Arten                                                         
    ## 91   ¦   ¦   ¦--Stachelbeere                                                    
    ## 92   ¦   ¦   ¦--Schwarze Johannisbeere                                          
    ## 93   ¦   ¦   ¦--Rote Johannisbeere                                              
    ## 94   ¦   ¦   °--Jostabeere                                                      
    ## 95   ¦   ¦--Mini-Kiwi                                                           
    ## 96   ¦   °--Erdbeere                                                            
    ## 97   ¦--Forstwirtschaft allg.                                                   
    ## 98   ¦   ¦--Wald                                                                
    ## 99   ¦   ¦   °--Forstliche Pflanzgärten                                         
    ## 100  ¦   °--Forstliche Pflanzgärten [dup]                                       
    ## 101  ¦--allg. Weinbau                                                           
    ## 102  ¦   °--Reben                                                               
    ## 103  ¦       ¦--Ertragsreben                                                    
    ## 104  ¦       °--Jungreben                                                       
    ## 105  ¦--leere Verarbeitungsräume                                                
    ## 106  ¦--Lorbeer                                                                 
    ## 107  ¦--Lager- und Produktionsräume allg.                                       
    ## 108  ¦--allg. Nichtkulturland                                                   
    ## 109  ¦   °--Allgemein Vorratsschutz                                             
    ## 110  ¦       ¦--Verarbeitungsräume                                              
    ## 111  ¦       ¦--Einrichtungen und Geräte                                        
    ## 112  ¦       ¦--Lagerhallen, Mühlen, Silogebäude                                
    ## 113  ¦       °--Lagerräume                                                      
    ## 114  ¦--Majoran                                                                 
    ## 115  ¦--Kerbelrübe                                                              
    ## 116  ¦--Holzpaletten, Packholz, Stammholz                                       
    ## 117  ¦--leere Lagerräume                                                        
    ## 118  ¦--Nichtkulturland allg.                                                   
    ## 119  ¦   ¦--Böschungen und Grünstreifen entlang von Verkehrswegen (gem. ChemRRV)
    ## 120  ¦   °--Auf und an National- und Kantonsstrassen (gem. ChemRRV)             
    ## 121  ¦--allg. Ökologische Ausgleichsflächen (gemäss DZV)                        
    ## 122  ¦   °--Offene Ackerfläche                                                  
    ## 123  ¦--Gewürzfenchel                                                           
    ## 124  ¦--Zierpflanzen allg.                                                      
    ## 125  ¦   ¦--Ein- und zweijährige Zierpflanzen                                   
    ## 126  ¦   ¦   °--Sommerflor                                                      
    ## 127  ¦   ¦--Schnittblumen                                                       
    ## 128  ¦   ¦   ¦--Chrysantheme                                                    
    ## 129  ¦   ¦   ¦--Nelken                                                          
    ## 130  ¦   ¦   ¦--Gerbera                                                         
    ## 131  ¦   ¦   ¦--Blaudistel                                                      
    ## 132  ¦   ¦   °--Gladiole                                                        
    ## 133  ¦   ¦--Blumenknollen                                                       
    ## 134  ¦   ¦   °--Dahlien                                                         
    ## 135  ¦   ¦--Topf- und Kontainerpflanzen                                         
    ## 136  ¦   ¦   ¦--Begonia                                                         
    ## 137  ¦   ¦   ¦--Cyclame                                                         
    ## 138  ¦   ¦   ¦--Pelargonien                                                     
    ## 139  ¦   ¦   °--Primeln                                                         
    ## 140  ¦   ¦--Baumschule                                                          
    ## 141  ¦   ¦--Zier- und Sportrasen                                                
    ## 142  ¦   ¦--Blumenkulturen und Grünpflanzen                                     
    ## 143  ¦   ¦   ¦--Begonia [dup]                                                   
    ## 144  ¦   ¦   ¦--Zierkürbis                                                      
    ## 145  ¦   ¦   ¦--Chrysantheme [dup]                                              
    ## 146  ¦   ¦   ¦--Hyazinthe                                                       
    ## 147  ¦   ¦   ¦--Nelken [dup]                                                    
    ## 148  ¦   ¦   ¦--Cyclame [dup]                                                   
    ## 149  ¦   ¦   ¦--Gerbera [dup]                                                   
    ## 150  ¦   ¦   ¦--Iris                                                            
    ## 151  ¦   ¦   ¦--Pelargonien [dup]                                               
    ## 152  ¦   ¦   ¦--Liliengewächse (Zierpflanzen)                                   
    ## 153  ¦   ¦   ¦--Blaudistel [dup]                                                
    ## 154  ¦   ¦   ¦--Gladiole [dup]                                                  
    ## 155  ¦   ¦   ¦--Primeln [dup]                                                   
    ## 156  ¦   ¦   °--Tulpe                                                           
    ## 157  ¦   ¦--Gehölze (ausserhalb Forst)                                          
    ## 158  ¦   ¦   ¦--Nadelgehölze (Koniferen)                                        
    ## 159  ¦   ¦   ¦   ¦--Blautanne                                                   
    ## 160  ¦   ¦   ¦   ¦--Weihnachtsbäume                                             
    ## 161  ¦   ¦   ¦   ¦--Fichte                                                      
    ## 162  ¦   ¦   ¦   °--Zypressengewächse                                           
    ## 163  ¦   ¦   °--Laubgehölze                                                     
    ## 164  ¦   ¦       ¦--Rosskastanie                                                
    ## 165  ¦   ¦       ¦--Rhododendron                                                
    ## 166  ¦   ¦       ¦   °--Azaleen                                                 
    ## 167  ¦   ¦       ¦--Kirschlorbeer                                               
    ## 168  ¦   ¦       °--Buchsbäume (Buxus)                                          
    ## 169  ¦   ¦--Rosen                                                               
    ## 170  ¦   ¦--Blumenzwiebeln                                                      
    ## 171  ¦   ¦   °--Hyazinthe [dup]                                                 
    ## 172  ¦   ¦--Euphorbia                                                           
    ## 173  ¦   ¦--Bäume und Sträucher (ausserhalb Forst)                              
    ## 174  ¦   ¦   ¦--Rosskastanie [dup]                                              
    ## 175  ¦   ¦   ¦--Rhododendron [dup]                                              
    ## 176  ¦   ¦   ¦--Blautanne [dup]                                                 
    ## 177  ¦   ¦   ¦--Weihnachtsbäume [dup]                                           
    ## 178  ¦   ¦   ¦--Kirschlorbeer [dup]                                             
    ## 179  ¦   ¦   ¦--Buchsbäume (Buxus) [dup]                                        
    ## 180  ¦   ¦   °--Zypressengewächse [dup]                                         
    ## 181  ¦   ¦--Ziergehölze (ausserhalb Forst)                                      
    ## 182  ¦   °--Stauden                                                             
    ## 183  ¦--Pflanzen                                                                
    ## 184  ¦--Traubensilberkerze                                                      
    ## 185  ¦--Mohn                                                                    
    ## 186  ¦--Beerenbau allg.                                                         
    ## 187  ¦--Blumenzwiebeln und Blumenknollen                                        
    ## 188  ¦--Rosenwurz                                                               
    ## 189  ¦--Süssdolde                                                               
    ## 190  ¦--Gojibeere                                                               
    ## 191  ¦--Brachland                                                               
    ## 192  ¦--Gemüsebau allg.                                                         
    ## 193  ¦   °--Windengewächse (Convolvulaceae)                                     
    ## 194  ¦       °--Süsskartoffel                                                   
    ## 195  ¦--Blaue Heckenkirsche                                                     
    ## 196  ¦--Humusdeponie                                                            
    ## 197  ¦--allg. Obstbau                                                           
    ## 198  ¦   ¦--Kernobst                                                            
    ## 199  ¦   ¦   ¦--Birne / Nashi                                                   
    ## 200  ¦   ¦   ¦   °--Birne                                                       
    ## 201  ¦   ¦   ¦--Quitte                                                          
    ## 202  ¦   ¦   °--Apfel                                                           
    ## 203  ¦   ¦--Hartschalenobst                                                     
    ## 204  ¦   ¦   °--Nüsse                                                           
    ## 205  ¦   ¦       °--Walnuss                                                     
    ## 206  ¦   ¦--Olive                                                               
    ## 207  ¦   °--Steinobst                                                           
    ## 208  ¦       ¦--Zwetschge / Pflaume                                             
    ## 209  ¦       ¦   ¦--Zwetschge                                                   
    ## 210  ¦       ¦   °--Pflaume                                                     
    ## 211  ¦       ¦--Pfirsich / Nektarine                                            
    ## 212  ¦       ¦--Aprikose                                                        
    ## 213  ¦       °--Kirsche                                                         
    ## 214  ¦--Brache                                                                  
    ## 215  ¦--Erntegut                                                                
    ## 216  ¦--Schwarze Maulbeere                                                      
    ## 217  ¦--Sanddorn                                                                
    ## 218  ¦--Melisse                                                                 
    ## 219  ¦--Gemeine Felsenbirne                                                     
    ## 220  ¦--Obstbau allg.                                                           
    ## 221  ¦--allg. Gemüsebau                                                         
    ## 222  ¦   ¦--Knöterichgewächse (Polygonaceae)                                    
    ## 223  ¦   ¦   °--Rhabarber                                                       
    ## 224  ¦   ¦--Portulakgewächse (Portulacaceae)                                    
    ## 225  ¦   ¦   °--Portulak                                                        
    ## 226  ¦   ¦       °--Gemüseportulak                                              
    ## 227  ¦   ¦--Spargelgewächse (Asparagaceae)                                      
    ## 228  ¦   ¦   °--Spargel                                                         
    ## 229  ¦   ¦--Baldriangewächse (Valerianaceae)                                    
    ## 230  ¦   ¦   °--Nüsslisalat                                                     
    ## 231  ¦   ¦--Baldrian                                                            
    ## 232  ¦   ¦--Gewürz- und Medizinalkräuter                                        
    ## 233  ¦   ¦   °--Johanniskraut                                                   
    ## 234  ¦   ¦--Gänsefussgewächse (Chenopodiaceae)                                  
    ## 235  ¦   ¦   ¦--Rande                                                           
    ## 236  ¦   ¦   ¦--Spinat                                                          
    ## 237  ¦   ¦   °--Mangold                                                         
    ## 238  ¦   ¦       ¦--Krautstiel                                                  
    ## 239  ¦   ¦       °--Schnittmangold                                              
    ## 240  ¦   ¦--Nachtschattengewächse (Solanaceae)                                  
    ## 241  ¦   ¦   ¦--Paprika                                                         
    ## 242  ¦   ¦   ¦   ¦--Peperoni                                                    
    ## 243  ¦   ¦   ¦   °--Gemüsepaprika                                               
    ## 244  ¦   ¦   ¦--Aubergine                                                       
    ## 245  ¦   ¦   ¦--Andenbeere                                                      
    ## 246  ¦   ¦   ¦--Tomaten                                                         
    ## 247  ¦   ¦   ¦   ¦--Tomaten Spezialitäten                                       
    ## 248  ¦   ¦   ¦   ¦--Cherrytomaten                                               
    ## 249  ¦   ¦   ¦   °--Rispentomaten                                               
    ## 250  ¦   ¦   °--Pepino                                                          
    ## 251  ¦   ¦--Doldenblütler (Apiaceae)                                            
    ## 252  ¦   ¦   ¦--Knollenfenchel                                                  
    ## 253  ¦   ¦   ¦--Wurzelpetersilie                                                
    ## 254  ¦   ¦   ¦--Karotten                                                        
    ## 255  ¦   ¦   ¦--Sellerie                                                        
    ## 256  ¦   ¦   ¦   ¦--Suppensellerie                                              
    ## 257  ¦   ¦   ¦   ¦--Stangensellerie                                             
    ## 258  ¦   ¦   ¦   °--Knollensellerie                                             
    ## 259  ¦   ¦   °--Pastinake                                                       
    ## 260  ¦   ¦--Liliengewächse (Liliaceae)                                          
    ## 261  ¦   ¦   ¦--Knoblauch                                                       
    ## 262  ¦   ¦   ¦--Lauch                                                           
    ## 263  ¦   ¦   ¦--Zwiebeln                                                        
    ## 264  ¦   ¦   ¦   ¦--Gemüsezwiebel                                               
    ## 265  ¦   ¦   ¦   ¦--Bundzwiebeln                                                
    ## 266  ¦   ¦   ¦   °--Speisezwiebel                                               
    ## 267  ¦   ¦   °--Schalotten                                                      
    ## 268  ¦   ¦--Kürbisgewächse (Cucurbitaceae)                                      
    ## 269  ¦   ¦   ¦--Wassermelonen                                                   
    ## 270  ¦   ¦   ¦--Gurken                                                          
    ## 271  ¦   ¦   ¦   ¦--Einlegegurken                                               
    ## 272  ¦   ¦   ¦   ¦--Nostranogurken                                              
    ## 273  ¦   ¦   ¦   °--Gewächshausgurken                                           
    ## 274  ¦   ¦   ¦--Melonen                                                         
    ## 275  ¦   ¦   ¦--Speisekürbisse (ungeniessbare Schale)                           
    ## 276  ¦   ¦   ¦--Ölkürbisse                                                      
    ## 277  ¦   ¦   °--Kürbisse mit geniessbarer Schale                                
    ## 278  ¦   ¦       ¦--Patisson                                                    
    ## 279  ¦   ¦       ¦--Zucchetti                                                   
    ## 280  ¦   ¦       °--Rondini                                                     
    ## 281  ¦   ¦--Speisepilze                                                         
    ## 282  ¦   ¦--Korbblütler (Asteraceae)                                            
    ## 283  ¦   ¦   ¦--Artischocken                                                    
    ## 284  ¦   ¦   ¦--Kardy                                                           
    ## 285  ¦   ¦   ¦--Schwarzwurzel                                                   
    ## 286  ¦   ¦   ¦--Topinambur                                                      
    ## 287  ¦   ¦   ¦--Chicorée                                                        
    ## 288  ¦   ¦   °--Salate (Asteraceae)                                             
    ## 289  ¦   ¦       ¦--Löwenzahn                                                   
    ## 290  ¦   ¦       ¦--Lactuca-Salate                                              
    ## 291  ¦   ¦       ¦   ¦--Kopfsalate                                              
    ## 292  ¦   ¦       ¦   ¦   °--Kopfsalat                                           
    ## 293  ¦   ¦       ¦   °--Blattsalate (Asteraceae)                                
    ## 294  ¦   ¦       ¦       °--Schnittsalat                                        
    ## 295  ¦   ¦       °--Endivien und Blattzichorien                                 
    ## 296  ¦   ¦           ¦--Endivien                                                
    ## 297  ¦   ¦           ¦--Zuckerhut                                               
    ## 298  ¦   ¦           °--Radicchio- und Cicorino-Typen                           
    ## 299  ¦   ¦--Lippenblütler (Labiatae)                                            
    ## 300  ¦   ¦   °--Stachys                                                         
    ## 301  ¦   ¦--Süssgräser (Poaceae)                                                
    ## 302  ¦   ¦   °--Zuckermais                                                      
    ## 303  ¦   ¦--Kräuter                                                             
    ## 304  ¦   ¦--Küchenkräuter                                                       
    ## 305  ¦   ¦   ¦--Ysop                                                            
    ## 306  ¦   ¦   ¦--Koriander                                                       
    ## 307  ¦   ¦   ¦--Rosmarin                                                        
    ## 308  ¦   ¦   ¦--Petersilie                                                      
    ## 309  ¦   ¦   ¦--Römische Kamille                                                
    ## 310  ¦   ¦   ¦--Kerbel                                                          
    ## 311  ¦   ¦   ¦--Minze                                                           
    ## 312  ¦   ¦   ¦--Basilikum                                                       
    ## 313  ¦   ¦   ¦--Bohnenkraut                                                     
    ## 314  ¦   ¦   ¦--Thymian                                                         
    ## 315  ¦   ¦   ¦--Kümmel                                                          
    ## 316  ¦   ¦   ¦--Dill                                                            
    ## 317  ¦   ¦   ¦--Salbei                                                          
    ## 318  ¦   ¦   ¦--Liebstöckel                                                     
    ## 319  ¦   ¦   ¦--Estragon                                                        
    ## 320  ¦   ¦   °--Schnittlauch                                                    
    ## 321  ¦   ¦--Hülsenfrüchtler (Fabaceae)                                          
    ## 322  ¦   ¦   ¦--Linse                                                           
    ## 323  ¦   ¦   ¦--Puffbohne                                                       
    ## 324  ¦   ¦   ¦--Erbsen                                                          
    ## 325  ¦   ¦   ¦   ¦--Erbsen mit Hülsen                                           
    ## 326  ¦   ¦   ¦   °--Erbsen ohne Hülsen                                          
    ## 327  ¦   ¦   °--Bohnen                                                          
    ## 328  ¦   ¦       ¦--Bohnen ohne Hülsen                                          
    ## 329  ¦   ¦       °--Bohnen mit Hülsen                                           
    ## 330  ¦   ¦           ¦--Stangenbohne                                            
    ## 331  ¦   ¦           °--Buschbohne                                              
    ## 332  ¦   ¦--Kreuzblütler (Brassicaceae)                                         
    ## 333  ¦   ¦   ¦--Brunnenkresse                                                   
    ## 334  ¦   ¦   ¦--Kohlarten                                                       
    ## 335  ¦   ¦   ¦   ¦--Blumenkohle                                                 
    ## 336  ¦   ¦   ¦   ¦   ¦--Blumenkohl                                              
    ## 337  ¦   ¦   ¦   ¦   ¦--Romanesco                                               
    ## 338  ¦   ¦   ¦   ¦   °--Broccoli                                                
    ## 339  ¦   ¦   ¦   ¦--Blattkohle                                                  
    ## 340  ¦   ¦   ¦   ¦   ¦--Pak-Choi                                                
    ## 341  ¦   ¦   ¦   ¦   ¦--Markstammkohl                                           
    ## 342  ¦   ¦   ¦   ¦   ¦--Chinakohl                                               
    ## 343  ¦   ¦   ¦   ¦   ¦--Stielmus                                                
    ## 344  ¦   ¦   ¦   ¦   °--Federkohl                                               
    ## 345  ¦   ¦   ¦   ¦--Rosenkohl                                                   
    ## 346  ¦   ¦   ¦   ¦--Kopfkohle                                                   
    ## 347  ¦   ¦   ¦   °--Kohlrabi                                                    
    ## 348  ¦   ¦   ¦--Kresse                                                          
    ## 349  ¦   ¦   ¦--Blattsalate (Brassicaceae)                                      
    ## 350  ¦   ¦   ¦--Radies                                                          
    ## 351  ¦   ¦   ¦--Speisekohlrüben                                                 
    ## 352  ¦   ¦   ¦   ¦--Brassica napus-Rüben                                        
    ## 353  ¦   ¦   ¦   ¦   °--Bodenkohlrabi                                           
    ## 354  ¦   ¦   ¦   °--Brassica rapa-Rüben                                         
    ## 355  ¦   ¦   ¦--Barbarakraut                                                    
    ## 356  ¦   ¦   ¦--Rettich                                                         
    ## 357  ¦   ¦   ¦--Asia-Salate (Brassicaceae)                                      
    ## 358  ¦   ¦   ¦--Cima di Rapa                                                    
    ## 359  ¦   ¦   ¦--Rucola                                                          
    ## 360  ¦   ¦   °--Meerrettich                                                     
    ## 361  ¦   °--Kohlgemüse                                                          
    ## 362  ¦--Medizinalkräuter                                                        
    ## 363  ¦   °--Wolliger Fingerhut                                                  
    ## 364  ¦--Hagebutten                                                              
    ## 365  °--allg. Wiesen und Weiden                                                 
    ##                               culture_id
    ## 1                                       
    ## 2   0106A8DF-6CDF-4E18-8F46-3D9E1D52D0E5
    ## 3   6C3D663E-442F-4783-87A2-A46806E119E5
    ## 4   9BD6A435-E370-4DFE-82E5-7E7813B4D193
    ## 5   DB0DCB7D-CA9F-454A-8398-606F066FBF4F
    ## 6   0E2847EB-CEFD-4640-82EB-F09F3F1A5E13
    ## 7   122B909A-CE9C-47BC-B5CA-DCF523646D38
    ## 8   1575BC21-D089-4248-99A6-676F14E1309F
    ## 9   13BB4B9E-6CEE-4729-AE29-8A4380EB33B0
    ## 10  17B69B05-E650-4A6F-815A-D6DA55A92CDB
    ## 11  1DD3F253-4B23-4B69-BFB1-1C24CE7D5508
    ## 12  01AFF6EB-9C8D-4D0D-B225-0BA07B59A72F
    ## 13  086E34F3-82E5-4F92-9224-41C9F7529E70
    ## 14  B542EC7D-B423-43B4-9010-82A6889BB3B4
    ## 15  C763D817-B4AC-43DB-9C6E-A262CC32F400
    ## 16  095E9650-A880-4BD2-A1BB-39297582BCE6
    ## 17  1F03DDC0-19CF-48F1-BAB8-61CA4CEF24CF
    ## 18  4E1ACD79-F162-4EBB-93CB-C6857A811E9C
    ## 19  27FBFA25-5091-4D7E-9C96-3C0BC05B6474
    ## 20  404C1D02-5666-4AA3-8487-65A9EEE0B53D
    ## 21  49F7DA15-E241-4080-9D42-1523ECA834B5
    ## 22  4A386AE2-A36F-4A55-8668-7B896A1E8092
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
    ## 42  625EA905-7C3D-4BCC-8551-BC1CB14FF647
    ## 43  7D65DFD2-C26E-4CAB-9E2C-66A6C7CBA641
    ## 44  C026CB2D-39B4-4FDF-AD04-FBA22AD2B4F1
    ## 45  7D76F5F6-5810-4556-A7D5-84C91FDE3FF2
    ## 46  B74E61A6-30BD-4A63-8A24-94FC0A54D489
    ## 47  82376115-14E2-449A-8DFA-F8119476FE3F
    ## 48  7870FD70-C44A-4788-ABEA-FB673A5FD106
    ## 49  D3D49C53-8EBC-4DAC-9C4C-B988AA162F7D
    ## 50  D3D90BE6-0924-4844-98FB-52C4D7F21A38
    ## 51  7AB6690B-B2B9-4F12-AFAE-A9B0222C2637
    ## 52  B6669854-1833-4BBC-A931-E67505848EA7
    ## 53  F730D531-B0C8-4A20-AC4B-4F86445E2491
    ## 54  F8A8C1D8-E2C7-4230-8435-4D5AEE69813E
    ## 55  C9DB1105-33C7-44E8-92BA-9BBE5BA2BB3F
    ## 56  99379C08-8682-4628-BD67-6E566F5130FA
    ## 57  9BA6BDE9-AD45-4F91-A190-708D39AD5B63
    ## 58  9F6AE17C-0BE1-457A-B780-D408BCD333BF
    ## 59  B4D50F5E-6028-493D-9B95-85CAE5DADF06
    ## 60  689F7BE7-DA1E-49B6-95D5-E002E210E7B9
    ## 61  92CAB39E-ACC3-44DC-9EF3-0D27B8600E83
    ## 62  CDF1E5BC-0740-4214-8912-870CC2BB37F4
    ## 63  D3CD23DC-4C49-4EE5-8BF8-6B074E74352A
    ## 64  E107FECF-24B6-43D7-B3E6-05C5C239EFBB
    ## 65  52019F0F-3BAF-4161-A223-62EECBA47871
    ## 66  E36FADB4-A022-42A0-81CF-F041CABB93A4
    ## 67  E58E502E-BECD-44CB-96A2-3A6771D8A7B7
    ## 68  5755AD92-721E-431E-8473-6FA2F340532F
    ## 69  F9426E5C-7D4D-45E5-80DA-64BB12336CA4
    ## 70  2260B6A9-FC51-4F50-8E8F-D39BC6D5DA3A
    ## 71  230F7417-5500-4124-B273-95AA1FFB940B
    ## 72  24EA0CC6-D1D5-4BB4-981C-A836E3D7125D
    ## 73  269900C0-F407-4AFA-B3F2-D857EDACB733
    ## 74  28ECDBFE-F44F-44C6-BF06-9B7E6EBFC1F6
    ## 75  36EC3084-D6AE-494D-A5B2-EC39DCC4F412
    ## 76  3783A322-9E9C-44F6-B683-FE35221CA6AC
    ## 77  8B5A3E2B-2534-4FC0-84C5-685915165A77
    ## 78  99379C08-8682-4628-BD67-6E566F5130FA
    ## 79  B4D50F5E-6028-493D-9B95-85CAE5DADF06
    ## 80  C27B142E-1F10-46E0-A1CA-2ACCDA029027
    ## 81  EA82A16B-4A8C-4917-A08F-C2AD3B266640
    ## 82  F9426E5C-7D4D-45E5-80DA-64BB12336CA4
    ## 83  3EAC5420-E234-4AA5-8B46-6F9E8542C7AF
    ## 84  36D9AFE2-7506-48CE-BA39-EFD54535294A
    ## 85  42D50BC4-0019-4B55-9CB5-6C3E86C9D112
    ## 86  43F8091A-A333-40F5-8845-FF83398B9AC3
    ## 87  8621CDCC-EE8A-4188-9F2C-14C9497FBED3
    ## 88  D63D73AC-87B1-41F7-82AC-D1DFF12F6704
    ## 89  A9F01BDE-468A-477A-8ED5-704359B663F6
    ## 90  BE3C6915-B28E-4CC8-980E-7F243F14F519
    ## 91  3A522DC8-E6D3-426D-AA99-65C148ED1A84
    ## 92  4E8A4BB8-3B5D-4695-B17C-F4C1202D5138
    ## 93  91406007-35B9-49E2-A62F-04BDE262366F
    ## 94  FFDDDA7D-B340-473C-94F4-841272B602FA
    ## 95  CA9B7EDC-8626-4E01-B979-4856CFA9893E
    ## 96  CCCD6417-ED96-4A46-82EF-2EC848F719A7
    ## 97  3FEAB48F-0D66-4814-B3E3-C4BC0AB749B3
    ## 98  19CC4F57-CB08-4970-BEDB-3DB2B2CB1034
    ## 99  43FC7C18-BDA5-4364-B4CA-74EA37B7B8DC
    ## 100 43FC7C18-BDA5-4364-B4CA-74EA37B7B8DC
    ## 101 43ED81C2-40E7-4A22-9114-3E623BE1B14C
    ## 102 2314EB9F-7207-409F-A0D4-89B6A1177363
    ## 103 293D431D-8501-4D41-A0E5-F1A5AD59C8B6
    ## 104 516862FD-DCB0-42BF-8E18-ADA820B1DB90
    ## 105 4B6DC713-3B11-42C5-92A8-E504D594E978
    ## 106 4C8B56DD-9606-453C-9B14-C9C6309E87FA
    ## 107 4D5AF334-29F4-4854-A14F-4457A8A87D97
    ## 108 4D6B9837-FA9A-4E8D-BAAB-A7249BD01F2D
    ## 109 8774F019-8BB4-409D-ADA9-B565ECA1A6A9
    ## 110 3E4AFACC-03CA-4CEC-8392-520B07DDC604
    ## 111 465E7118-95AB-46A2-9A85-7A0B9070E63A
    ## 112 AC0240B5-B610-4D7C-8704-AA8E182821AC
    ## 113 F171615D-81A1-4654-BF30-BF51620DFFB9
    ## 114 710CC0C8-B138-4B31-9975-4DA04AF67792
    ## 115 71D9FB13-5AE4-42C3-9F84-956B16C379C1
    ## 116 75047A9C-12E2-4BAC-89D8-B14BC4C6B100
    ## 117 7D23702C-980B-4B90-A86B-70013806D3EA
    ## 118 7F20F06C-C950-49B9-A78F-9E2F696B079E
    ## 119 A22521E4-7D71-40C2-9FDF-B1230008D934
    ## 120 C3E12AAE-119E-47CF-9B8A-6F1CA657CF6B
    ## 121 811C79DC-9182-4302-8AEC-AB12D5F69188
    ## 122 8BDDCACC-13C1-4676-9322-402ECF20BE85
    ## 123 8512D352-73CC-4535-9469-965AAF1FD0B1
    ## 124 890D8A5E-BF86-4B2D-9B98-45B779D80F7F
    ## 125 00D94F57-BA6F-4BA0-8F68-26D4C497539A
    ## 126 C69EBD93-43E5-457F-9CBE-EE1C04791274
    ## 127 10642620-4F7B-4E5E-8F38-D73914354014
    ## 128 34753E17-C34D-4D0B-88A0-91143DADABB2
    ## 129 83A9CEC5-FC31-421C-A3B8-CA219AF649CF
    ## 130 9C6CEE37-8105-4E48-9CA4-11BA3AB556FB
    ## 131 DAF00AE7-5272-4E07-9A66-E9F9BD8FEE43
    ## 132 E2A335E5-D797-46E7-9CE4-9CB3F301AAA2
    ## 133 1B9B39A9-D742-4E8D-A88E-280B65C4B913
    ## 134 AEC07D17-6D8B-4180-A368-056A187DE2F8
    ## 135 2A05DA01-5722-46A2-BCCF-3B75C6D17BB6
    ## 136 2E38C972-4160-4D2B-8ED2-3B48FC781EF0
    ## 137 9A9A2586-34FF-4256-8FA4-BA9F2FA38CAE
    ## 138 B75AC4CC-6BB7-4A99-808A-9F7BDFCF8E6A
    ## 139 E8B23A5E-B65E-4DC8-977D-BD84F143A442
    ## 140 3BEFA6F7-0D34-4E29-8207-85E9D5783ECC
    ## 141 5C610428-6087-4A2E-B977-3E83EDBB19F0
    ## 142 75317E57-B194-4B3D-8FF2-3489A39AC177
    ## 143 2E38C972-4160-4D2B-8ED2-3B48FC781EF0
    ## 144 302E5676-26A3-41EB-980F-2B6BDE117D3A
    ## 145 34753E17-C34D-4D0B-88A0-91143DADABB2
    ## 146 61D9C648-0736-43D4-BF04-B8643B1D74E0
    ## 147 83A9CEC5-FC31-421C-A3B8-CA219AF649CF
    ## 148 9A9A2586-34FF-4256-8FA4-BA9F2FA38CAE
    ## 149 9C6CEE37-8105-4E48-9CA4-11BA3AB556FB
    ## 150 A8647F38-2A16-46AB-8B0E-2257EBF53C63
    ## 151 B75AC4CC-6BB7-4A99-808A-9F7BDFCF8E6A
    ## 152 B82B5C60-02CB-4B7A-B3D3-A4CA34A809C3
    ## 153 DAF00AE7-5272-4E07-9A66-E9F9BD8FEE43
    ## 154 E2A335E5-D797-46E7-9CE4-9CB3F301AAA2
    ## 155 E8B23A5E-B65E-4DC8-977D-BD84F143A442
    ## 156 FF0DF95C-A3A9-47EE-95FA-00FCB428A4ED
    ## 157 7B3C8CEE-526F-4381-A757-669C1864291A
    ## 158 0A5F3E91-96B9-4C6D-B99C-2E6E4835F6D5
    ## 159 5B651459-FC70-4D22-9469-4991F847EA89
    ## 160 79C28385-E183-4661-AAC0-80E82C67089C
    ## 161 D95CD842-A5BC-4DAA-935D-F009DA7BA748
    ## 162 ED17FD35-4C96-4D28-902B-ACEA3F4950D6
    ## 163 7971013B-801D-4595-8208-782446A6C7E0
    ## 164 2F7BD13A-BAA5-4708-83C6-17D44E57EA4D
    ## 165 3A53A166-7559-4E75-BDED-F65CA6FDFDE1
    ## 166 33097BFE-2487-46DB-85A0-A8A4E06030AF
    ## 167 A21391C3-A1A3-4472-8AA1-56449FB56B36
    ## 168 DF455946-B2AB-45D2-9780-4A45A98D72D6
    ## 169 A024CDFC-A05D-46B8-B08A-221C26BDF5DE
    ## 170 B85EF4C2-C22E-4A5A-A431-98DC8F621D92
    ## 171 61D9C648-0736-43D4-BF04-B8643B1D74E0
    ## 172 CB7061F0-B1D8-4AC0-9C50-A596763B68CF
    ## 173 D40E1405-757C-4E3D-B26F-07D5F2251565
    ## 174 2F7BD13A-BAA5-4708-83C6-17D44E57EA4D
    ## 175 3A53A166-7559-4E75-BDED-F65CA6FDFDE1
    ## 176 5B651459-FC70-4D22-9469-4991F847EA89
    ## 177 79C28385-E183-4661-AAC0-80E82C67089C
    ## 178 A21391C3-A1A3-4472-8AA1-56449FB56B36
    ## 179 DF455946-B2AB-45D2-9780-4A45A98D72D6
    ## 180 ED17FD35-4C96-4D28-902B-ACEA3F4950D6
    ## 181 F4479311-1516-49F1-95BA-E232030F9AAC
    ## 182 FCF24426-CAB8-43C8-9E42-B09581420287
    ## 183 8E6C3D3A-6D7A-4D82-94CC-E4F227CC1EB2
    ## 184 9650E36A-38F4-4375-9594-25785BACE1DC
    ## 185 9B8F475B-C6FA-4642-9CD8-89A98A293D50
    ## 186 9DE574C1-EE11-42BC-9C05-930BCAE13A44
    ## 187 A0012475-8478-4CA9-A18A-DC1CB96D788B
    ## 188 A1B43C0A-8077-47D4-9171-8E6B2C9A95C4
    ## 189 A2D2B4EC-D7D6-4A30-BEE9-0A8F907A874A
    ## 190 A3E943A5-C6D8-4CB0-A069-85BFC48E8B8A
    ## 191 AE465EA2-A950-4661-B631-D5A267B2F076
    ## 192 B4CA8F81-4A66-4880-98AB-C7760AECCDA6
    ## 193 855980B6-D3CA-46B5-86C5-12E9847344B5
    ## 194 EF29B430-95C5-45D4-A812-DCCE046E1B8E
    ## 195 B92BA12C-EA9D-4EA8-ADEE-A4547872DD58
    ## 196 BAE217C2-8C72-4706-8A0E-911FB18FC723
    ## 197 C6EBB3D7-3050-4C36-BBC2-CBD20D6B9E56
    ## 198 0F5F1FEE-084C-4961-A76F-82F9B17B2635
    ## 199 FA0F7C48-BF78-49B0-9046-FBB5ABB4BF75
    ## 200 42466A90-AFCD-4DA6-8769-99C4BC5BE217
    ## 201 FD180555-9DEF-42BA-86E0-EBD31AB8FABB
    ## 202 FD18F42C-C390-4701-B07B-B8108B33320B
    ## 203 6EDA1989-51C8-490E-90FD-974CE3E8FF03
    ## 204 77462EAB-3BD3-4EAC-B740-F95597FFAE35
    ## 205 6D45EAF5-D29C-48AB-A212-91C67357E898
    ## 206 9BCEB85B-1578-4001-839D-68BFB9CE4CD8
    ## 207 CA722B7E-8F16-4502-8139-C33F749545D4
    ## 208 24A364B9-6BD7-42A6-A9EC-AB9E94E010FF
    ## 209 66B27CD1-032A-456E-99C4-28F6E989CC14
    ## 210 9C38BA77-FDC8-461A-800A-9E2467C52105
    ## 211 307A62EA-67D6-4D28-9CF7-F1218C9BE2CD
    ## 212 9BB00FC5-181F-4F3F-94C8-E4141143F44A
    ## 213 CF9B4B3C-DCDC-4E2E-A613-D784936842D2
    ## 214 C8AB8319-939E-4CF3-B78E-549A85DEF756
    ## 215 CC08E1E6-655D-4FAA-B0E8-AD968A68A536
    ## 216 D18572C7-A270-4AA7-B766-48D62C5E9AB7
    ## 217 D1E8D0D6-BD3C-4C47-9017-DBEADC9215A9
    ## 218 D51188F1-9F8F-46E6-8F5B-550A7D45A4BE
    ## 219 D605CAA5-9199-4739-8C9C-343C74DABAEB
    ## 220 DA71526F-AC1D-40F1-8EF5-109E3F3FFD76
    ## 221 E59545AD-3331-4E3D-B58D-9F67833C060B
    ## 222 0A3519B1-A42F-43EE-AF82-6DCF17EA8DA6
    ## 223 27ACD8EA-49E8-4C99-84D4-53E2E605390E
    ## 224 17CE2494-D0C9-484B-A91E-15B7B04733FD
    ## 225 8A00630A-32FC-4B5A-8171-EC0F41D39F48
    ## 226 77267F83-907F-4537-98A8-7B9C1E4714F0
    ## 227 2D7D1AE2-E685-4C6B-B8EE-DC5C6391EC76
    ## 228 C96EE4F4-12EA-49DE-9BEF-21EA73B52760
    ## 229 2FAEBED2-193A-460C-A538-9B5C78024D98
    ## 230 9AA59D6B-D6AA-49BE-8BF8-A7A53BE54759
    ## 231 309E5D09-3084-40C6-88F2-D4A14345136C
    ## 232 31A0539F-1D4C-4BCF-876F-215CEBC4C864
    ## 233 AE97719E-9D0F-425C-BCD7-0F5D84092113
    ## 234 39D599AA-B93E-4AC2-970E-5A99A3113572
    ## 235 7A993953-3C2F-4BC3-98EE-2EE5E83C6E77
    ## 236 93A2DA1B-F920-461B-A9C9-BA9981CDB278
    ## 237 AB0798FE-64B8-49A2-8E75-14467EB7AB58
    ## 238 915B2192-1651-4B8A-B2D8-C162A5D27211
    ## 239 B7DE9539-35FD-4172-B72D-488EA12F2DF7
    ## 240 46901564-D096-4323-AE81-C93831AFEC64
    ## 241 096444CD-43E6-41F9-8914-2E7DADA4C801
    ## 242 46D3C073-CBD8-4B3A-A9AA-21785BA911CA
    ## 243 68688AEC-44E2-490B-AC80-E8DEDCC82B8F
    ## 244 6CC3F1FF-84DF-4E4A-A91E-57C5ECB82F61
    ## 245 74C47437-5700-45F5-86E2-D410DACD39B6
    ## 246 E9E3C127-33C1-40D9-8552-3CBE45E8E4C4
    ## 247 07A12E5B-DB0B-4421-A215-E306768AC0BE
    ## 248 1D9F568C-5170-43A1-86B9-B25808DD6A43
    ## 249 D100976A-2598-4614-AB7A-61436FF2B053
    ## 250 F512809F-5CC7-44A2-A378-8FDAFA67CFEA
    ## 251 5276BCA7-CEA5-4B6D-90E3-52F3A0532490
    ## 252 0D20E815-633E-4F38-AC93-7B6578B0483E
    ## 253 21228D46-5B00-4CDD-9C71-48C0A0B21C78
    ## 254 2AB457D1-DB9D-4545-92FF-04A6BD2CEC08
    ## 255 D36B92CB-136F-46C3-8217-10C3F86ECA12
    ## 256 18C6314C-C067-4E7F-AAB6-2DEF3F01DF9D
    ## 257 3702313F-95C6-4FE9-8B6B-C7CE3987CD18
    ## 258 56884AC3-B629-440D-8E82-05075A18697F
    ## 259 EE7EE009-EBD4-471D-AE85-1A98130F6119
    ## 260 5AC11C43-B41E-4823-8515-E991D4EA1B3C
    ## 261 037E11B2-128A-4194-9A5B-A3E980AE4113
    ## 262 8DFDE2D1-C004-4C25-BF54-21CF7C815232
    ## 263 DB98FC8E-5AFA-4434-9478-960124F960CA
    ## 264 83C510D2-293A-4E1B-B691-06B1F02149B4
    ## 265 874850AA-2F48-47B6-A789-C67D6DEE97DA
    ## 266 C883F887-6B72-4917-9385-7A757E5FD8D6
    ## 267 F718EA3C-F363-4DB2-BDF6-2D6236706822
    ## 268 8303C191-3315-4942-91DF-668C019850D7
    ## 269 09269926-BA07-42DC-BE9D-5B34658BDBF0
    ## 270 30F9F737-0A18-43EC-AF88-F28940E567F1
    ## 271 238AB652-AD62-4703-A74B-7550C693ED6E
    ## 272 AED83C4B-0546-4C91-B370-4AB5B425942F
    ## 273 CE13A930-22B8-44D6-98E4-97707B0F7F6C
    ## 274 399AC89E-29BB-44AD-8B1F-0B2F327D5230
    ## 275 573B50E9-ED1D-4999-B4FD-4537CA2A6306
    ## 276 BBD16782-6EB3-4923-9DBB-CC7D97EBCB0E
    ## 277 FE69D926-4BE1-4C67-840E-30C3D299442E
    ## 278 3447F4C9-2E90-437F-A240-0462AFEDF2B5
    ## 279 C1A1842A-37E5-46D3-9646-9ECC15BAEE99
    ## 280 F6A02973-2AF5-47AF-B99D-FFAD9A24BCB4
    ## 281 A2D0B83F-9BB5-477C-AD44-24B31F2EF276
    ## 282 B05127D4-FF0A-4F36-AFDD-0D487043122A
    ## 283 1BFC9694-C7DC-4D74-84B2-1418AB94A8BA
    ## 284 3346CB25-6DC9-42AF-8BA2-F725BD92304A
    ## 285 9A9333CA-AD6C-459D-9AFF-B8E8FB2FF8D4
    ## 286 BDB73EC5-46E5-413B-85B5-78D3801F4E7E
    ## 287 E5B9C6F0-5C57-4A12-8ED9-D65B669B8243
    ## 288 E786D43D-444B-49D6-B0D0-294265F91403
    ## 289 25DA6F5A-1BD0-4040-A210-BB05CCB66AE4
    ## 290 33686F38-1E1A-4698-81E4-C40EE4494EF3
    ## 291 4DD550C5-15BB-4D52-98BD-6770972575F0
    ## 292 B02E0EFA-B8AF-425A-A779-6A4DFE8D4172
    ## 293 9CA61204-7EA7-4F2F-BAD3-BD02EDD6A829
    ## 294 A4BC1F92-959A-4449-A039-B98E3ABCD9B1
    ## 295 8DB1A579-6BAC-4DCB-8026-E79B65D3BD3A
    ## 296 62BF86AE-FD69-4F95-A72C-1D57AF1DCD99
    ## 297 94589F70-1F3A-4AEF-A26A-2267EB5BDA4B
    ## 298 B535B6DD-517D-4A62-ACC7-2948B15175ED
    ## 299 BA6FCA8F-68B8-4408-A267-2546B1FA5764
    ## 300 1F0B6451-EC2C-4647-A53A-23B0EAE626B1
    ## 301 BF77A7F8-C4C5-43AF-9BCD-B7F904506E7A
    ## 302 5433C814-C0CD-4815-B236-2D02E1C66F3D
    ## 303 C3F940E4-D07C-4F4D-851C-D1024F8A6A62
    ## 304 D541F2F5-8BA6-4E26-AA66-9CF469648AFF
    ## 305 0A88EFE2-B85E-4BF7-9C38-AEE8CB2BFE42
    ## 306 0DAB25B6-C3AA-430B-BF83-05FA66D889A4
    ## 307 14B19DFD-331F-4C30-8724-8EDDF8E2D0D4
    ## 308 1A1D511B-4ABD-44F2-8BB5-55192F5310D2
    ## 309 25DC9B01-CA06-426A-B743-C0D293447898
    ## 310 2C8A4414-AD7F-4708-9C58-BF1969131693
    ## 311 37059300-8031-4A64-B75C-7490288E32BA
    ## 312 3C2F424F-DFA0-4A59-A3DF-6E33A6B0B97E
    ## 313 4D799EC6-1483-4D65-90EA-8DDB6A4166CA
    ## 314 730AACDC-B956-493D-8148-7520019CE0BC
    ## 315 807F5A2C-7904-456D-BBC7-A80A4B207964
    ## 316 91522E50-F1AC-42B1-870B-68218110C235
    ## 317 A067CC81-6A5D-4684-BE95-7941A51B9EF2
    ## 318 A519A894-B754-44D1-A032-155F57B0CBFE
    ## 319 ABF54D5D-620B-4A08-A37D-416C1AD8D1BF
    ## 320 FA8C26CF-E3B4-456D-AA4E-94D21AEADA1A
    ## 321 DB4E4C8B-016C-4C31-8DC5-587A9F1F8FFD
    ## 322 54C75B64-57C4-46E2-BCEA-741EBC10FDDF
    ## 323 56AF3EA3-01F4-4F10-B240-7EF4BE1C1CCE
    ## 324 5DF3AB4D-7CAC-4112-90D9-67BD80EC5E96
    ## 325 02BF379A-E526-422A-952B-3B0CD995F8C1
    ## 326 C5188A42-9C79-4110-B1E8-AEE9D6078BEA
    ## 327 A8BAC5BB-239F-4EE0-8CE2-F55590DA3FC0
    ## 328 102C28F6-4AFB-4079-909B-ACE8E0819A77
    ## 329 F7BB2F1C-EDE5-4C95-931E-0B2C973F5A29
    ## 330 4465118D-78E7-4748-A47A-7F39E593771A
    ## 331 930524FB-BD0A-4CA9-A89D-4FEEE1F9174F
    ## 332 E55D75D3-B805-4BFD-B2B0-D02368BD32AC
    ## 333 19C5BA72-A0D5-4409-8D05-0A7C9D821E20
    ## 334 4380EC0F-E195-4783-8BB7-F6B0464B37D6
    ## 335 4A22B9D3-747C-4323-A852-1CB1F6ADB680
    ## 336 1E129025-DFD8-42D1-8A86-D90485B282A1
    ## 337 8AFA14F8-CCE3-4012-BD12-9D690EBAE1AD
    ## 338 B9323B4D-249D-4CF3-A5DF-4FDA2E66532F
    ## 339 6F26F4E0-401C-4B16-A28B-4CC889907361
    ## 340 394AE687-29A0-4BA6-B0B9-D7DFB0C08FCE
    ## 341 80395E92-C39B-45D9-91AC-AB7E6DCAC3DB
    ## 342 C37A7EE2-D06B-4204-809A-F50A934F79E3
    ## 343 DA5835F6-C295-4A4F-829D-007B1FA50A6D
    ## 344 DF4B3775-8361-41CE-9843-AC953197403D
    ## 345 7B90BAC4-B80F-4039-ADC3-ADF9225CCBB7
    ## 346 CA58ABAE-E494-4608-BE51-5FF49D853A03
    ## 347 D8A50212-BD15-456A-9D2E-2A401C2EF21D
    ## 348 7CE53BA0-097D-44FB-82FF-C30DFD3769DD
    ## 349 85BB3788-27A8-4E73-800A-0E8F154EC0BE
    ## 350 8FF3D364-2BA6-40AA-A370-4B72E3CAC8DF
    ## 351 A0C29069-5DBA-4E89-B7F9-4C556C272821
    ## 352 1F004DAA-89AD-4A9D-A172-95D24B8A45FA
    ## 353 EB820B26-DE4E-4AF4-8BA3-46844F045306
    ## 354 BFD1B79E-ABD1-4A44-8E61-891FF97960A1
    ## 355 BA2DECCF-5987-4987-B56E-C5EC6E5D19C0
    ## 356 BB923645-6E65-48EE-9C64-DA2232EEE7EF
    ## 357 BFDDCB65-6E46-47E1-90B1-A998D5BD0546
    ## 358 C264982A-CA81-4311-9E38-67D2D956BC78
    ## 359 CC9D982D-A99F-4143-8298-BC029BD1D1AD
    ## 360 EACDD832-D1CD-479C-973F-CD0DB6A9FBC3
    ## 361 EB0C465C-50B7-4DC0-914B-ABE4C284A907
    ## 362 E981BFA6-288D-4EA6-B81B-4F610611EB36
    ## 363 C38D7DE4-C804-4F7C-AA2F-A536D03E0DFC
    ## 364 EC349B29-6A2B-4E43-990F-C553D278DC0E
    ## 365 FD7AB34C-F432-445D-9440-F44FDAB8422C
    ##                                                                       name_fr
    ## 1                                                                            
    ## 2                                                                   Baby-Leaf
    ## 3                                                    Baby-Leaf (Brassicaceae)
    ## 4                                                  Baby-Leaf (Chenopodiaceae)
    ## 5                                                      Baby-Leaf (Asteraceae)
    ## 6                                                                      origan
    ## 7                                                       sorbier des oiseleurs
    ## 8                                                   domaine app. sylviculture
    ## 9                               grumes en forêt et sur les places de stockage
    ## 10                                                Les exploitations tabacoles
    ## 11                                                domaine app. grande culture
    ## 12                                                                    Houblon
    ## 13                                           betteraves à sucre et fourragère
    ## 14                                                          Betterave à sucre
    ## 15                                                       Betterave fourragère
    ## 16                                                                  Tournesol
    ## 17                                                      Prairies et pâturages
    ## 18                            mélange trèfles-graminées (prairie arificielle)
    ## 19                                                              Sorgho commun
    ## 20                                                                      Lupin
    ## 21                                                                   Carthame
    ## 22                                                            Roseau de Chine
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
    ## 42                                                                       Orge
    ## 43                                                             Orge d'automne
    ## 44                                                          orge de printemps
    ## 45                                                                     Seigle
    ## 46                                                           Seigle d'automne
    ## 47                                                                        Blé
    ## 48                                                                    Blé dur
    ## 49                                                                   Épeautre
    ## 50                                                                 Blé tendre
    ## 51                                                              Blé d'automne
    ## 52                                                           Blé de printemps
    ## 53                                                                 Amidonnier
    ## 54                                                                     Avoine
    ## 55                                                        Avoine de printemps
    ## 56                                                  Riz semis sur terrain sec
    ## 57                                                                        Lin
    ## 58                                                                       Soja
    ## 59                                                            pommes de terre
    ## 60                               pommes de terre pour la production de plants
    ## 61                              pommes de terre de consommation et fourragère
    ## 62                                   Graminées pour la production de semences
    ## 63                                                                    Luzerne
    ## 64                                                      techniques culturales
    ## 65                                                         semis sous litière
    ## 66                                            semis après travail superficiel
    ## 67                                                                      Colza
    ## 68                                                            Colza d'automne
    ## 69                                                                       Maïs
    ## 70                                                                pois chiche
    ## 71                                                                 ranunculus
    ## 72                                                        surfaces herbagères
    ## 73                                                          plantain lancéolé
    ## 74                                                 Locaux de production vides
    ## 75                                                                    anémone
    ## 76                                                  grande culture en général
    ## 77                                                                   Céréales
    ## 78                                                  Riz semis sur terrain sec
    ## 79                                                            pommes de terre
    ## 80                                                                     millet
    ## 81                                                                    Chanvre
    ## 82                                                                       Maïs
    ## 83                                                         domaine app. baies
    ## 84                                                               aronie noire
    ## 85                                                               grand sureau
    ## 86                                                           espèces de Rubus
    ## 87                                                                       mûre
    ## 88                                                                  framboise
    ## 89                                                                   myrtille
    ## 90                                                           espèces de Ribes
    ## 91                                                     groseilles à maquereau
    ## 92                                                                     cassis
    ## 93                                                       groseilles à grappes
    ## 94                                                                      josta
    ## 95                                                          mini-Kiwi (Kiwaï)
    ## 96                                                                     fraise
    ## 97                                                    sylviculture en général
    ## 98                                                                      forêt
    ## 99                                                     pépinières forestières
    ## 100                                                    pépinières forestières
    ## 101                                                       domaine app. vignes
    ## 102                                                                     vigne
    ## 103                                                       vigne en production
    ## 104                                                               jeune vigne
    ## 105                                            Locaux de transformation vides
    ## 106                                                                   Laurier
    ## 107                                         Lager- und Produktionsräume allg.
    ## 108                                                 domaine app. non agricole
    ## 109                                                   protection des récoltes
    ## 110                                                  locaux de transformation
    ## 111                                                   installations et outils
    ## 112                                                 entrepôts, moulins, silos
    ## 113                                                                 entrepôts
    ## 114                                                                marjolaine
    ## 115                                                         Cerfeuil tubéreux
    ## 116                        Palette en bois, bois d'emballage, bois en général
    ## 117                                                           Êntrepôts vides
    ## 118                                           domaine non agricole en général
    ## 119 talus et bandes vertes le long des voies de communication (selon ORRChim)
    ## 120              le long des routes nationales et cantonales  (selon ORRChim)
    ## 121                   domaine surfaces de compensation écologique (selon OPD)
    ## 122                                                           terres ouvertes
    ## 123                                                        fenouil aromatique
    ## 124                                            culture ornementale en général
    ## 125                            plantes ornementales annuelles et bisannuelles
    ## 126                                                          fleurs estivales
    ## 127                                                            fleurs coupées
    ## 128                                                              chrysanthème
    ## 129                                                                   oeillet
    ## 130                                                                   gerbera
    ## 131                                                              chardon bleu
    ## 132                                                                   glaïeul
    ## 133                                                      tubercules de fleurs
    ## 134                                                                    dahlia
    ## 135                                            plantes en pot et en container
    ## 136                                                                   bégonia
    ## 137                                                                  cyclamen
    ## 138                                                                  géranium
    ## 139                                                                primevères
    ## 140                                                                 pépinière
    ## 141                                     gazon d'ornement et terrains de sport
    ## 142                                       cultures florales et plantes vertes
    ## 143                                                                   bégonia
    ## 144                                                         courge d'ornement
    ## 145                                                              chrysanthème
    ## 146                                                                  jacinthe
    ## 147                                                                   oeillet
    ## 148                                                                  cyclamen
    ## 149                                                                   gerbera
    ## 150                                                                      iris
    ## 151                                                                  géranium
    ## 152                                          liliacées (plantes ornementales)
    ## 153                                                              chardon bleu
    ## 154                                                                   glaïeul
    ## 155                                                                primevères
    ## 156                                                                    tulipe
    ## 157                                            plantes ligneuses (hors forêt)
    ## 158                                                                 conifères
    ## 159                                                                sapin bleu
    ## 160                                                            arbres de Noël
    ## 161                                                                    épicéa
    ## 162                                                              cupressacées
    ## 163                                                                  feuillus
    ## 164                                                         marronnier d'Inde
    ## 165                                                              rhododendron
    ## 166                                                                    azalée
    ## 167                                                            laurier-cerise
    ## 168                                                              buis (Buxus)
    ## 169                                                                    rosier
    ## 170                                                         bulbes des fleurs
    ## 171                                                                  jacinthe
    ## 172                                                                  euphorbe
    ## 173                                           arbres et arbustes (hors fôret)
    ## 174                                                         marronnier d'Inde
    ## 175                                                              rhododendron
    ## 176                                                                sapin bleu
    ## 177                                                            arbres de Noël
    ## 178                                                            laurier-cerise
    ## 179                                                              buis (Buxus)
    ## 180                                                              cupressacées
    ## 181                                          arbustes d'ornement (hors forêt)
    ## 182                                                           plantes vivaces
    ## 183                                                                   plantes
    ## 184                                                            actée à grappe
    ## 185                                                                     pavot
    ## 186                                              culture des baies en général
    ## 187                                                        bulbes ornementaux
    ## 188                                                                Orpin rose
    ## 189                                                           Cerfeuil musqué
    ## 190                                                             Baies de Goji
    ## 191                                                                    friche
    ## 192                                             culture maraîchère en général
    ## 193                                           convolvulacées (Convolvulaceae)
    ## 194                                                              Patate douce
    ## 195                                                           camérisier bleu
    ## 196                                                   dépôt de terre végétale
    ## 197                                                domaine app. arboriculture
    ## 198                                                           fruits à pépins
    ## 199                                                           poirier / nashi
    ## 200                                                                   poirier
    ## 201                                                                cognassier
    ## 202                                                                   pommier
    ## 203                                                           noix en général
    ## 204                                                                      noix
    ## 205                                                                     noyer
    ## 206                                                                   olivier
    ## 207                                                           fruits à noyaux
    ## 208                                                   prunier (pruneau/prune)
    ## 209                                                         prunier (pruneau)
    ## 210                                                           prunier (prune)
    ## 211                                                        pêcher / nectarine
    ## 212                                                                abricotier
    ## 213                                                                  cerisier
    ## 214                                                                   jachère
    ## 215                                                            denrée stockée
    ## 216                                                               mûrier noir
    ## 217                                                                 argousier
    ## 218                                                                   mélisse
    ## 219                                                          amélavier commun
    ## 220                                                  arboriculture en général
    ## 221                                                   domaine app. maraîchère
    ## 222                                                              polygonacées
    ## 223                                                                  rhubarbe
    ## 224                                             portulacacées (Portulacaceae)
    ## 225                                                                  pourpier
    ## 226                                                           pourpier commun
    ## 227                                               asparagacées (Asparagaceae)
    ## 228                                                                   asperge
    ## 229                                                             valérianacées
    ## 230                                                             mâche, rampon
    ## 231                                                                 valériane
    ## 232                                         herbes aromatiques et médicinales
    ## 233                                                              millepertuis
    ## 234                                                            chénopodiacées
    ## 235                                                        betterave à salade
    ## 236                                                                   épinard
    ## 237                                                                     bette
    ## 238                                                              bette à côte
    ## 239                                                            bette à tondre
    ## 240                                                                solanacées
    ## 241                                                                   poivron
    ## 242                                                                   poivron
    ## 243                                                              poivron doux
    ## 244                                                                 aubergine
    ## 245                                                         coqueret du Pérou
    ## 246                                                                    tomate
    ## 247                                                      tomates, spécialités
    ## 248                                                             tomate-cerise
    ## 249                                                           tomate à grappe
    ## 250                                                               poire melon
    ## 251                                                   ombellifères (Apiaceae)
    ## 252                                                           fenouil bulbeux
    ## 253                                                    persil à grosse racine
    ## 254                                                                   carotte
    ## 255                                                                    céleri
    ## 256                                                céleri-pomme pour bouillon
    ## 257                                                            céleri-branche
    ## 258                                                              céleri-pomme
    ## 259                                                                    Panais
    ## 260                                                                 liliacées
    ## 261                                                                       ail
    ## 262                                                                   poireau
    ## 263                                                                    oignon
    ## 264                                                            oignon potager
    ## 265                                                          oignons en botte
    ## 266                                                        oignon (condiment)
    ## 267                                                                  échalote
    ## 268                                                             cucurbitacées
    ## 269                                                                  pastèque
    ## 270                                                                 concombre
    ## 271                                                                cornichons
    ## 272                                                        concombre nostrano
    ## 273                                                        concombre de serre
    ## 274                                                                    melons
    ## 275                                           courges (écorce non comestible)
    ## 276                                                      courges oléagineuses
    ## 277                                                 courges à peau comestible
    ## 278                                                                  pâtisson
    ## 279                                                                 courgette
    ## 280                                                                   rondini
    ## 281                                                   champignons comestibles
    ## 282                                                     composées (Asteracea)
    ## 283                                                                 artichaut
    ## 284                                                                    cardon
    ## 285                                                                scorsonère
    ## 286                                                               topinambour
    ## 287                                        chicorée witloof (chicorée-endive)
    ## 288                                                      salades (Asteraceae)
    ## 289                                                              dent-de-lion
    ## 290                                                           salades lactuca
    ## 291                                                           laitues pommées
    ## 292                                                             laitue pommée
    ## 293                                             laitues à tondre (Asteraceae)
    ## 294                                                           laitue à tondre
    ## 295                                    chicorée pommée et chicorée à feuilles
    ## 296                                         chicorée scarole, chicorée frisée
    ## 297                                                    chicorée pain de sucre
    ## 298                                   types de radicchio/trévises et cicorino
    ## 299                                                      lamiacées (Labiatae)
    ## 300                                                          crosnes du japon
    ## 301                                                       poacées (Gramineae)
    ## 302                                                                maïs sucré
    ## 303                                                                    herbes
    ## 304                                                              fines herbes
    ## 305                                                                    Hysope
    ## 306                                                                 coriandre
    ## 307                                                                   romarin
    ## 308                                                                    persil
    ## 309                                                         Camomille romaine
    ## 310                                                                  cerfeuil
    ## 311                                                                    menthe
    ## 312                                                                   basilic
    ## 313                                                                 sarriette
    ## 314                                                                      thym
    ## 315                                                                     carvi
    ## 316                                                                     aneth
    ## 317                                                                     sauge
    ## 318                                                                   livèche
    ## 319                                                                  estragon
    ## 320                                                                ciboulette
    ## 321                                                   fabacées (légumineuses)
    ## 322                                                                  lentille
    ## 323                                                                      fève
    ## 324                                                                      pois
    ## 325                                                          pois non écossés
    ## 326                                                              pois écossés
    ## 327                                                                  haricots
    ## 328                                                          haricots écossés
    ## 329                                                      haricots non écossés
    ## 330                                                           haricot à rames
    ## 331                                                              haricot nain
    ## 332                                                 crucifères (Brassicaceae)
    ## 333                                                       cresson de fontaine
    ## 334                                                                     choux
    ## 335                                  choux (développement de l'inflorescence)
    ## 336                                                                chou-fleur
    ## 337                                                                 romanesco
    ## 338                                                                   brocoli
    ## 339                                                          choux à feuilles
    ## 340                                                                   pakchoi
    ## 341                                                             chou moellier
    ## 342                                                             chou de Chine
    ## 343                                                            navet à tondre
    ## 344                                                      chou frisé non pommé
    ## 345                                                         chou de Bruxelles
    ## 346                                                              choux pommés
    ## 347                                                                   colrave
    ## 348                                                         cresson de jardin
    ## 349                                          laitues à tondre  (Brassicaceae)
    ## 350                                                    radis de tous les mois
    ## 351                                         rave de Brassica rapa et B. napus
    ## 352                                                    rave de Brassica napus
    ## 353                                                                  rutabaga
    ## 354                                                     rave de Brassica rapa
    ## 355                                                     Barbarée du printemps
    ## 356                                                                radis long
    ## 357                                               salades Asia (Brassicaceae)
    ## 358                                                              cima di rapa
    ## 359                                                                  roquette
    ## 360                                                                   raifort
    ## 361                                                                     choux
    ## 362                                                       plantes médicinales
    ## 363                                                         digitale lanifère
    ## 364                                                                cynorhodon
    ## 365                                        domaine app. prairies et paturages
    ##                                                                             name_it
    ## 1                                                                                  
    ## 2                                                                         Baby-Leaf
    ## 3                                                          Baby-Leaf (Brassicaceae)
    ## 4                                                        Baby-Leaf (Chenopodiaceae)
    ## 5                                                            Baby-Leaf (Asteraceae)
    ## 6                                                                           origano
    ## 7                                                            Sorbo degli ucellatori
    ## 8                                                                                  
    ## 9                     Tronchi abbattuti nella foresta e presso piazzali di deposito
    ## 10                                                   Aziende produttrici di tabacco
    ## 11                                                                                 
    ## 12                                                                          Luppolo
    ## 13                                           Barbabietole da foraggio e da zucchero
    ## 14                                                         Barbabietola da zucchero
    ## 15                                                         Barbabietola da foraggio
    ## 16                                                                         Girasole
    ## 17                                                                  Prati e pascoli
    ## 18                                 Miscela trifoglio-graminacee (prati artificiali)
    ## 19                                                                            Sorgo
    ## 20                                                                           Lupini
    ## 21                                                                          Cartamo
    ## 22                                                                         Miscanto
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
    ## 42                                                                             Orzo
    ## 43                                                                   Orzo autunnale
    ## 44                                                                 Orzo primaverile
    ## 45                                                                           Segale
    ## 46                                                                 Segale autunnale
    ## 47                                                                         Frumento
    ## 48                                                                       Grano duro
    ## 49                                                                           Spelta
    ## 50                                                                     Grano tenero
    ## 51                                                               Frumento autunnale
    ## 52                                                             Frumento primaverile
    ## 53                                                                            Farro
    ## 54                                                                            Avena
    ## 55                                                                Avena primaverile
    ## 56                                                Riso seminato su terreno asciutto
    ## 57                                                                             Lino
    ## 58                                                                             Soia
    ## 59                                                                           Patate
    ## 60                                          Patate per la produzione di tuberi-seme
    ## 61                                                   Patate da tavola e da foraggio
    ## 62                                          Graminacee per la produzione di sementi
    ## 63                                                                      Erba medica
    ## 64                                                          Tecnica di coltivazione
    ## 65                                                                Semine a lattiera
    ## 66                                                         Semine dopo la fresatura
    ## 67                                                                            Colza
    ## 68                                                                  Colza autunnale
    ## 69                                                                             Mais
    ## 70                                                                             cece
    ## 71                                                                        ranuncolo
    ## 72                                                              Superficie inerbita
    ## 73                                                            piantaggine lanciuola
    ## 74                                                       Locali di produzione vuoti
    ## 75                                                                          Anemone
    ## 76                                                         Campicoltura in generale
    ## 77                                                                          Cereali
    ## 78                                                Riso seminato su terreno asciutto
    ## 79                                                                           Patate
    ## 80                                                                           Miglio
    ## 81                                                                           Canapa
    ## 82                                                                             Mais
    ## 83                                                                                 
    ## 84                                                                      Aronia nera
    ## 85                                                                     Sambuco nero
    ## 86                                                                  Specie di rubus
    ## 87                                                                             Mora
    ## 88                                                                          Lampone
    ## 89                                                                         Mirtillo
    ## 90                                                                  Specie di ribes
    ## 91                                                                        Uva spina
    ## 92                                                                       Ribes nero
    ## 93                                                                      Ribes rosso
    ## 94                                                                            Josta
    ## 95                                                                        Mini-Kiwi
    ## 96                                                                          Fragola
    ## 97                                                         Selvicoltura in generale
    ## 98                                                                            Bosco
    ## 99                                                                  Vivai forestali
    ## 100                                                                 Vivai forestali
    ## 101                                                                                
    ## 102                                                                            Vite
    ## 103                                                              Vite in produzione
    ## 104                                                                   Ceppi giovani
    ## 105                                                 Locali per la lavorazione vuoti
    ## 106                                                                          Alloro
    ## 107                                               Lager- und Produktionsräume allg.
    ## 108                                                                                
    ## 109                                           Protezione delle scorte (in generale)
    ## 110                                                       Locali per la lavorazione
    ## 111                                                      Installazioni e apparecchi
    ## 112                                                          Depositi, mulini, sili
    ## 113                                                                        Depositi
    ## 114                                                                      maggiorana
    ## 115                                                               Cerfoglio bulboso
    ## 116                      Palette in legno, legno da imballaggio, legno non lavorato
    ## 117                                                      Locali di stoccaggio vuoti
    ## 118                                               Superfici non coltive in generale
    ## 119 Scarpate e strisce verdi lungo le vie di comunicazione (conformemente ORRPChim)
    ## 120                  Lungo le strade nazionali e cantonali (conformemente ORRPChim)
    ## 121            Superfici di compensazione ecologica in generale (conformemente OPD)
    ## 122                                                       Superficie coltiva aperta
    ## 123                                                             Finocchio aromatico
    ## 124                                          Coltivazione piante ornam. in generale
    ## 125                                           Piante ornamentali annuali e biennali
    ## 126                                                                    Fiori estivi
    ## 127                                                                    Fiori recisi
    ## 128                                                                      Crisantemo
    ## 129                                                                        Garofani
    ## 130                                                                         Gerbera
    ## 131                                                                   Cardo azzurro
    ## 132                                                                        Gladiolo
    ## 133                                                        Radici tuberose floreali
    ## 134                                                                           Dalie
    ## 135                                                   Pianta in vaso e in container
    ## 136                                                                         Begonia
    ## 137                                                                       Ciclamino
    ## 138                                                                         Geranio
    ## 139                                                                         Primule
    ## 140                                                                          Vivaio
    ## 141                                               Tappeti erbosi e terreni sportivi
    ## 142                                                 Colture da fiore e piante verdi
    ## 143                                                                         Begonia
    ## 144                                                               Zucca ornamentale
    ## 145                                                                      Crisantemo
    ## 146                                                                        Giacinto
    ## 147                                                                        Garofani
    ## 148                                                                       Ciclamino
    ## 149                                                                         Gerbera
    ## 150                                                                            Iris
    ## 151                                                                         Geranio
    ## 152                                                   Liliacee (pianti ornamentali)
    ## 153                                                                   Cardo azzurro
    ## 154                                                                        Gladiolo
    ## 155                                                                         Primule
    ## 156                                                                        Tulipano
    ## 157                                               Boschetti (al di fuori del bosco)
    ## 158                                                                        Conifere
    ## 159                                                              Abete del Colorado
    ## 160                                                                Alberi di Natale
    ## 161                                                                     Abete rosso
    ## 162                                                                    Cupressaceae
    ## 163                                                                      Latifoglie
    ## 164                                                                     Ippocastano
    ## 165                                                                      Rododendro
    ## 166                                                                          Azalee
    ## 167                                                                    Lauro ceraso
    ## 168                                                                   Bosso (Buxus)
    ## 169                                                                            Rose
    ## 170                                                                  Bulbi di fiori
    ## 171                                                                        Giacinto
    ## 172                                                                        Euforbia
    ## 173                                    Alberi e arbusti (al di fuori della foresta)
    ## 174                                                                     Ippocastano
    ## 175                                                                      Rododendro
    ## 176                                                              Abete del Colorado
    ## 177                                                                Alberi di Natale
    ## 178                                                                    Lauro ceraso
    ## 179                                                                   Bosso (Buxus)
    ## 180                                                                    Cupressaceae
    ## 181                                 Arbusti ornamentali (al di fuori della foresta)
    ## 182                                                                         Arbusti
    ## 183                                                                          Piante
    ## 184                                                                 actaea racemosa
    ## 185                                                                        Papavero
    ## 186                                              Coltivazione di bacche in generale
    ## 187                                                               Bulbi ornamentali
    ## 188                                                                  Rhodiola rosea
    ## 189                                                                    finocchiella
    ## 190                                                                  Bacche di Goji
    ## 191                                                                 Terreno incolto
    ## 192                                                         Orticoltura in generale
    ## 193                                                                  Convolvulaceae
    ## 194                                                                    Patata dolce
    ## 195                                                            Caprifoglio turchino
    ## 196                                                    Deposito di terreno vegetale
    ## 197                                                                                
    ## 198                                                               Frutta a granelli
    ## 199                                                                    Pero / Nashi
    ## 200                                                                            Pero
    ## 201                                                                         Cotogno
    ## 202                                                                            Melo
    ## 203                                                               Frutta con guscio
    ## 204                                                                            Noci
    ## 205                                                                     Noce comune
    ## 206                                                                           Olivo
    ## 207                                                               Frutta a nocciolo
    ## 208                                                                   Prugno/Susino
    ## 209                                                                          Prugno
    ## 210                                                                        Prugnolo
    ## 211                                                                Pesco/pesco noce
    ## 212                                                                       Albicocco
    ## 213                                                                        Ciliegio
    ## 214                                                                         Maggese
    ## 215                                                               Raccolto stoccato
    ## 216                                                                       Moro nero
    ## 217                                                                Olivello spinoso
    ## 218                                                                         Melissa
    ## 219                                                                    Pero corvino
    ## 220                                                       Frutticoltura in generale
    ## 221                                                                                
    ## 222                                                                     Poligonacee
    ## 223                                                                       Rabarbaro
    ## 224                                                      Portulacee (Portulacaceae)
    ## 225                                                                       Portulaca
    ## 226                                                                Portulaca estiva
    ## 227                                                      Asparagacee (Asparagaceae)
    ## 228                                                                        Asparagi
    ## 229                                                                    Valerianacee
    ## 230                                                                    Valerianella
    ## 231                                                                       Valeriana
    ## 232                                                    Erbe aromatiche e medicinali
    ## 233                                                                         Iperico
    ## 234                                                                   Chenopodiacee
    ## 235                                                                    Barbabietola
    ## 236                                                                         Spinaci
    ## 237                                                                         Bietola
    ## 238                                                                           Costa
    ## 239                                                               Bietola da taglio
    ## 240                                                                       Solanacee
    ## 241                                                                        Peperone
    ## 242                                                                        Peperone
    ## 243                                                                  Peperone dolce
    ## 244                                                                       Melanzana
    ## 245                                                                    Alchechengio
    ## 246                                                                        Pomodori
    ## 247                                                 Varietà particolari di pomodoro
    ## 248                                                               Pomodoro ciliegia
    ## 249                                                                 Pomodoro ramato
    ## 250                                                                          Pepino
    ## 251                                                          Ombrellifere (Apiacee)
    ## 252                                                                 Finocchio dolce
    ## 253                                                             Prezzemolo tuberoso
    ## 254                                                                          Carote
    ## 255                                                                          Sedano
    ## 256                                                            Sedano da condimento
    ## 257                                                                 Sedano da coste
    ## 258                                                                     Sedano rapa
    ## 259                                                                       Pastinaca
    ## 260                                                                        Liliacee
    ## 261                                                                           Aglio
    ## 262                                                                           Porro
    ## 263                                                                         Cipolle
    ## 264                                                                   Cipolle dolci
    ## 265                                                              Cipollotti a mazzi
    ## 266                                                               Cipolle da tavola
    ## 267                                                                        Scalogni
    ## 268                                                                    Cucurbitacee
    ## 269                                                                         Angurie
    ## 270                                                                        Cetrioli
    ## 271                                                           cetrioli per conserva
    ## 272                                                               Cetriolo nostrano
    ## 273                                                               Cetriolo olandese
    ## 274                                                                          Meloni
    ## 275                                                Zucche (buccia non commestibile)
    ## 276                                                                   Zucca da olio
    ## 277                                                  Zucche con buccia commestibile
    ## 278                                                                        Patisson
    ## 279                                                                        Zucchine
    ## 280                                                                         Rondini
    ## 281                                                             Funghi commestibili
    ## 282                                                           Composite (Asteracee)
    ## 283                                                                        Carciofi
    ## 284                                                                           Cardo
    ## 285                                                                      Scorzonera
    ## 286                                                                      Topinambur
    ## 287                                                                   Cicoria belga
    ## 288                                                            Insalate (Asteracee)
    ## 289                                                                  Dente di leone
    ## 290                                                     Insalate del genere Lactuca
    ## 291                                                              Insalate cappuccio
    ## 292                                                               Lattuga cappuccio
    ## 293                                                   Insalate a foglie (Asteracee)
    ## 294                                                               Lattuga da taglio
    ## 295                                                     Indivia e cicoria da foglia
    ## 296                                                                         Indivia
    ## 297                                                         Cicoria pan di zucchero
    ## 298                                                    Tipi di radicchio e cicorino
    ## 299                                                             Lamiacee (Labiatae)
    ## 300                                                                        Tuberina
    ## 301                                                            Poacee (Graminaceae)
    ## 302                                                                      Mais dolce
    ## 303                                                                            Erbe
    ## 304                                                               Erbette da cucina
    ## 305                                                                          Issopo
    ## 306                                                                      Coriandolo
    ## 307                                                                       Rosmarino
    ## 308                                                                      Prezzemolo
    ## 309                                                                Camomilla romana
    ## 310                                                                       Cerfoglio
    ## 311                                                                           Menta
    ## 312                                                                        Basilico
    ## 313                                                                     Santoreggia
    ## 314                                                                            Timo
    ## 315                                                                           Carvi
    ## 316                                                                           Aneto
    ## 317                                                                          Salvia
    ## 318                                                                       Levistico
    ## 319                                                                     Dragoncello
    ## 320                                                                  Erba cipollina
    ## 321                                                            Fabacee (Leguminose)
    ## 322                                                                      Lenticchia
    ## 323                                                                            Fave
    ## 324                                                                         Piselli
    ## 325                                                            Piselli con baccello
    ## 326                                                          Piselli senza baccello
    ## 327                                                                         Fagioli
    ## 328                                                          Fagioli senza baccello
    ## 329                                                            Fagioli con baccello
    ## 330                                                              Fagiolo rampicante
    ## 331                                                                    Fagiolo nano
    ## 332                                                         Crocifere (Brassicacee)
    ## 333                                                             Crescione acquatico
    ## 334                                                                Specie di cavoli
    ## 335                                                          Cavoli a infiorescenza
    ## 336                                                                      Cavolfiore
    ## 337                                                                       Romanesco
    ## 338                                                                        Broccoli
    ## 339                                                                Cavoli fogliacei
    ## 340                                                                        Pak-Choi
    ## 341                                                                  Cavolo fustoso
    ## 342                                                                   Cavolo cinese
    ## 343                                                         Cavoli / rape da taglio
    ## 344                                                                    Cavolo piuma
    ## 345                                                             Cavoli di Bruxelles
    ## 346                                                                  Cavoli a testa
    ## 347                                                                     Cavolo rapa
    ## 348                                                                       Crescione
    ## 349                                                 Insalate a foglie (Brassicacee)
    ## 350                                                                       Ravanello
    ## 351                                                Rapa di Brassica rapa e B. napus
    ## 352                                                          Rapa di Brassica napus
    ## 353                                                                   Cavolo navone
    ## 354                                                           Rapa di Brassica rapa
    ## 355                                                   Erba di Santa Barbara vernale
    ## 356                                                                      Ramolaccio
    ## 357                                                Insalate asiatiche (Brassicacee)
    ## 358                                                                    Cima di rapa
    ## 359                                                                          Rucola
    ## 360                                                   Rafano rusticana / Ramolaccio
    ## 361                                                                          Cavoli
    ## 362                                                                 erbe medicinali
    ## 363                                                                 Digitale lanata
    ## 364                                                                     rosa canina
    ## 365
