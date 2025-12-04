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
The first four entries out of 443 are shown below.

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
| 332FDA27-923A-41C7-9DE5-2154B959ED7E | (7E,9Z)-dodeca-7,9-dien-1-yl acetate | (E,Z)-7,9-Dodecadien-1-yl acetat    | (E,Z)-7,9-Dodecadien-1-yl acetate    | (E,Z)-7,9-Dodecadien-1-yl acetate    |

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

| pNbr | pk                                   | type | percent | g_per_L | ingredient_de                    | ingredient_fr                         |
|-----:|:-------------------------------------|:-----|--------:|--------:|:---------------------------------|:--------------------------------------|
|   38 | D95F01F3-9ED2-4D08-92FD-A58AF1B5F49F |      |   80.00 |         |                                  |                                       |
| 1182 | 057FC3E0-B59E-45EB-8CCB-B2EA4527E479 |      |   38.00 |   438.5 | entspricht 34.7 % MCPB (400g/L)  | correspond à 34.7 % de MCPB (400 g/L) |
| 1192 | 057FC3E0-B59E-45EB-8CCB-B2EA4527E479 |      |   38.00 |   438.5 | entspricht 34.7 % MCPB (400 g/L) | correspond à 34,7 % de MCPB (400 g/L) |
| 1263 | D95F01F3-9ED2-4D08-92FD-A58AF1B5F49F |      |   80.00 |         |                                  |                                       |
| 1865 | 1D7FC783-1AA4-47FD-B973-83867751B87B |      |   99.16 |   830.0 |                                  |                                       |

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

| type |   n |
|:-----|----:|
|      | 442 |

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

| type | substance_de | n   |
|------|--------------|-----|

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
|   38 | 18-3 | Sanoplant Schwefel         |                    |                 | TRUE             | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
|   38 | 18-5 | Gesal Schrotschuss Spezial |                    |                 | TRUE             | A128E9C6-FBC1-4649-8E3C-92073B82925B |
| 1182 | 923  | Divopan                    |                    |                 | FALSE            | 018C0DAB-6CB8-4F46-B684-4F59117A4F6A |
| 1192 | 934  | Trifolin                   |                    |                 | FALSE            | 15BAC516-7F05-4353-82D7-A2BA41438215 |
| 1263 | 986  | Elosal Supra               |                    |                 | FALSE            | 84E721E7-7A4F-4F80-B06A-A49B17EB0311 |

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

At the build time of this vignette, there were 1740 product
registrations for 1123 P-Numbers in the Swiss Register of Plant
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
| 6521 |      1 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      2 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      3 |            |            |      1.5 |          | l/ha     |                |               | Feldbau             |
| 6521 |      4 |            |            |      1.0 |          | l/ha     |              3 | Week(s)       | Feldbau             |
| 6521 |      5 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      6 |            |            |      1.0 |          | l/ha     |              3 | Week(s)       | Feldbau             |
| 6521 |      7 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
| 6521 |      8 |            |            |      1.0 |          | l/ha     |              3 | Week(s)       | Feldbau             |
| 6521 |      9 |            |            |      1.0 |          | l/ha     |                |               | Feldbau             |
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

    ##                                              levelName
    ## 1  Cultures                                           
    ## 2   ¦--Baby-Leaf                                      
    ## 3   ¦   ¦--Baby-Leaf (Brassicaceae)                   
    ## 4   ¦   ¦--Baby-Leaf (Chenopodiaceae)                 
    ## 5   ¦   °--Baby-Leaf (Asteraceae)                     
    ## 6   ¦--Hopfen                                         
    ## 7   ¦--Knoblauch                                      
    ## 8   ¦--Futter- und Zuckerrüben                        
    ## 9   ¦   ¦--Zuckerrübe                                 
    ## 10  ¦   °--Futterrübe                                 
    ## 11  ¦--Sonnenblume                                    
    ## 12  ¦--Knollenfenchel                                 
    ## 13  ¦--Oregano                                        
    ## 14  ¦--Kernobst                                       
    ## 15  ¦   ¦--Birne / Nashi                              
    ## 16  ¦   ¦   °--Birne                                  
    ## 17  ¦   ¦--Quitte                                     
    ## 18  ¦   °--Apfel                                      
    ## 19  ¦--Eberesche                                      
    ## 20  ¦--Liegendes Rundholz im Wald und auf Lagerplätzen
    ## 21  ¦--Tabak produzierende Betriebe                   
    ## 22  ¦--Brunnenkresse                                  
    ## 23  ¦--Artischocken                                   
    ## 24  ¦--Wiesen und Weiden                              
    ## 25  ¦   °--Kleegrasmischung (Kunstwiese)              
    ## 26  ¦--Stachys                                        
    ## 27  ¦--Wurzelpetersilie                               
    ## 28  ¦--Kichererbse                                    
    ## 29  ¦--Ranunkel                                       
    ## 30  °--... 128 nodes w/ 139 sub                       
    ##                              culture_id
    ## 1                                      
    ## 2  0106A8DF-6CDF-4E18-8F46-3D9E1D52D0E5
    ## 3  6C3D663E-442F-4783-87A2-A46806E119E5
    ## 4  9BD6A435-E370-4DFE-82E5-7E7813B4D193
    ## 5  DB0DCB7D-CA9F-454A-8398-606F066FBF4F
    ## 6  01AFF6EB-9C8D-4D0D-B225-0BA07B59A72F
    ## 7  037E11B2-128A-4194-9A5B-A3E980AE4113
    ## 8  086E34F3-82E5-4F92-9224-41C9F7529E70
    ## 9  B542EC7D-B423-43B4-9010-82A6889BB3B4
    ## 10 C763D817-B4AC-43DB-9C6E-A262CC32F400
    ## 11 095E9650-A880-4BD2-A1BB-39297582BCE6
    ## 12 0D20E815-633E-4F38-AC93-7B6578B0483E
    ## 13 0E2847EB-CEFD-4640-82EB-F09F3F1A5E13
    ## 14 0F5F1FEE-084C-4961-A76F-82F9B17B2635
    ## 15 FA0F7C48-BF78-49B0-9046-FBB5ABB4BF75
    ## 16 42466A90-AFCD-4DA6-8769-99C4BC5BE217
    ## 17 FD180555-9DEF-42BA-86E0-EBD31AB8FABB
    ## 18 FD18F42C-C390-4701-B07B-B8108B33320B
    ## 19 122B909A-CE9C-47BC-B5CA-DCF523646D38
    ## 20 13BB4B9E-6CEE-4729-AE29-8A4380EB33B0
    ## 21 17B69B05-E650-4A6F-815A-D6DA55A92CDB
    ## 22 19C5BA72-A0D5-4409-8D05-0A7C9D821E20
    ## 23 1BFC9694-C7DC-4D74-84B2-1418AB94A8BA
    ## 24 1F03DDC0-19CF-48F1-BAB8-61CA4CEF24CF
    ## 25 4E1ACD79-F162-4EBB-93CB-C6857A811E9C
    ## 26 1F0B6451-EC2C-4647-A53A-23B0EAE626B1
    ## 27 21228D46-5B00-4CDD-9C71-48C0A0B21C78
    ## 28 2260B6A9-FC51-4F50-8E8F-D39BC6D5DA3A
    ## 29 230F7417-5500-4124-B273-95AA1FFB940B
    ## 30

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
| 6521 |      1 | Feldbau             | Weizen                             | Septoria-Spelzenbräune (S. nodorum) |
| 6521 |      2 | Feldbau             | Winterroggen                       | Braunrost                           |
| 6521 |      3 | Feldbau             | Raps                               | Wurzelhals- und Stengelfäule        |
| 6521 |      4 | Feldbau             | Lupinen                            | Anthraknose                         |
| 6521 |      5 | Feldbau             | Weizen                             | Echter Mehltau des Getreides        |
| 6521 |      6 | Feldbau             | Eiweisserbse                       | Graufäule (Botrytis cinerea)        |
| 6521 |      6 | Feldbau             | Eiweisserbse                       | Rost der Erbse                      |
| 6521 |      6 | Feldbau             | Eiweisserbse                       | Brennfleckenkrankheit der Erbse     |
| 6521 |      7 | Feldbau             | Weizen                             | Ährenfusariosen                     |
| 6521 |      8 | Feldbau             | Ackerbohne                         | Rost der Ackerbohne                 |
| 6521 |      8 | Feldbau             | Ackerbohne                         | Braunfleckenkrankheit               |
| 6521 |      9 | Feldbau             | Lein                               | Stängelbräune des Leins             |
| 6521 |      9 | Feldbau             | Lein                               | Pasmokrankheit                      |
| 6521 |      9 | Feldbau             | Lein                               | Echter Mehltau des Leins            |
| 6521 |     10 | Gemüsebau           | Spargel                            | Blattschwärze der Spargel           |
| 6521 |     10 | Gemüsebau           | Spargel                            | Spargelrost                         |
| 6521 |     11 | Feldbau             | Grasbestände zur Saatgutproduktion | Rost der Gräser                     |
| 6521 |     11 | Feldbau             | Grasbestände zur Saatgutproduktion | Blattfleckenpilze                   |
| 6521 |     12 | Gemüsebau           | Erbsen                             | Graufäule (Botrytis cinerea)        |
| 6521 |     12 | Gemüsebau           | Erbsen                             | Rost der Erbse                      |
| 6521 |     12 | Gemüsebau           | Erbsen                             | Brennfleckenkrankheit der Erbse     |
| 6521 |     13 | Feldbau             | Raps                               | Sclerotinia-Fäule                   |
| 6521 |     14 | Feldbau             | Raps                               | Wurzelhals- und Stengelfäule        |
| 6521 |     14 | Feldbau             | Raps                               | Erhöhung der Standfestigkeit        |
| 6521 |     15 | Feldbau             | Weizen                             | Gelbrost                            |

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

| pNbr | use_nr | code | obligation_de                                                                                                                                                                                                                                                                                                                                                                               | sw_runoff_points |
|-----:|-------:|:-----|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------:|
| 7105 |      1 |      | Behandlung von im Herbst gesäten Kulturen.                                                                                                                                                                                                                                                                                                                                                  |                  |
| 7105 |      1 |      | Maximal 1 Behandlung pro Kultur.                                                                                                                                                                                                                                                                                                                                                            |                  |
| 7105 |      1 |      | SPe 3: Zum Schutz von Gewässerorganismen muss das Abschwemmungsrisiko gemäss den Weisungen der Zulassungsstelle um 1 Punkt reduziert werden.                                                                                                                                                                                                                                                |                1 |
| 7105 |      1 |      | Niedrige Aufwandmenge nur in Tankmischung gemäss den Angaben der Bewilligungsinhaberin.                                                                                                                                                                                                                                                                                                     |                  |
| 7105 |      1 |      | Nachfolgearbeiten in behandelten Kulturen: bis 48 Stunden nach Ausbringung des Mittels Schutzhandschuhe + Schutzanzug tragen.                                                                                                                                                                                                                                                               |                  |
| 7105 |      1 |      | Ansetzen der Spritzbrühe: Schutzhandschuhe tragen. Ausbringen der Spritzbrühe: Schutzhandschuhe + Schutzanzug + Visier + Kopfbedeckung tragen. Technische Schutzvorrichtungen während des Ausbringens (z.B. geschlossene Traktorkabine) können die vorgeschriebene persönliche Schutzausrüstung ersetzen, wenn gewährleistet ist, dass sie einen vergleichbaren oder höheren Schutz bieten. |                  |
| 7105 |      2 |      | Phytotoxschäden bei empfindlichen Arten oder Sorten möglich; vor allgemeiner Anwendung Versuchspritzung durchführen.                                                                                                                                                                                                                                                                        |                  |
| 7105 |      2 |      | Maximal 1 Behandlung pro Kultur.                                                                                                                                                                                                                                                                                                                                                            |                  |
| 7105 |      2 |      | SPe 3: Zum Schutz von Gewässerorganismen muss das Abschwemmungsrisiko gemäss den Weisungen der Zulassungsstelle um 1 Punkt reduziert werden.                                                                                                                                                                                                                                                |                1 |
| 7105 |      2 |      | Nachbau anderer Kulturen: 16 Wochen Wartefrist.                                                                                                                                                                                                                                                                                                                                             |                  |
| 7105 |      2 |      | Nachfolgearbeiten in behandelten Kulturen: bis 48 Stunden nach Ausbringung des Mittels Schutzhandschuhe + Schutzanzug tragen.                                                                                                                                                                                                                                                               |                  |
| 7105 |      2 |      | Ansetzen der Spritzbrühe: Schutzhandschuhe tragen. Ausbringen der Spritzbrühe: Schutzhandschuhe + Schutzanzug + Visier + Kopfbedeckung tragen. Technische Schutzvorrichtungen während des Ausbringens (z.B. geschlossene Traktorkabine) können die vorgeschriebene persönliche Schutzausrüstung ersetzen, wenn gewährleistet ist, dass sie einen vergleichbaren oder höheren Schutz bieten. |                  |

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
    ## 6    ¦--Hopfen                                                                  
    ## 7    ¦--Knoblauch                                                               
    ## 8    ¦--Futter- und Zuckerrüben                                                 
    ## 9    ¦   ¦--Zuckerrübe                                                          
    ## 10   ¦   °--Futterrübe                                                          
    ## 11   ¦--Sonnenblume                                                             
    ## 12   ¦--Knollenfenchel                                                          
    ## 13   ¦--Oregano                                                                 
    ## 14   ¦--Kernobst                                                                
    ## 15   ¦   ¦--Birne / Nashi                                                       
    ## 16   ¦   ¦   °--Birne                                                           
    ## 17   ¦   ¦--Quitte                                                              
    ## 18   ¦   °--Apfel                                                               
    ## 19   ¦--Eberesche                                                               
    ## 20   ¦--Liegendes Rundholz im Wald und auf Lagerplätzen                         
    ## 21   ¦--Tabak produzierende Betriebe                                            
    ## 22   ¦--Brunnenkresse                                                           
    ## 23   ¦--Artischocken                                                            
    ## 24   ¦--Wiesen und Weiden                                                       
    ## 25   ¦   °--Kleegrasmischung (Kunstwiese)                                       
    ## 26   ¦--Stachys                                                                 
    ## 27   ¦--Wurzelpetersilie                                                        
    ## 28   ¦--Kichererbse                                                             
    ## 29   ¦--Ranunkel                                                                
    ## 30   ¦--Reben                                                                   
    ## 31   ¦   ¦--Ertragsreben                                                        
    ## 32   ¦   °--Jungreben                                                           
    ## 33   ¦--Grünfläche                                                              
    ## 34   ¦--Spitzwegerich                                                           
    ## 35   ¦--Rhabarber                                                               
    ## 36   ¦--Sorghum                                                                 
    ## 37   ¦--Leere Produktionsräume                                                  
    ## 38   ¦--Karotten                                                                
    ## 39   ¦--Rosskastanie                                                            
    ## 40   ¦--Baldrian                                                                
    ## 41   ¦--Kardy                                                                   
    ## 42   ¦--Chrysantheme                                                            
    ## 43   ¦--Schwarze Apfelbeere                                                     
    ## 44   ¦--Anemone                                                                 
    ## 45   ¦--Feldbau allg.                                                           
    ## 46   ¦   ¦--Kartoffeln                                                          
    ## 47   ¦   ¦   ¦--Kartoffeln zur Pflanzgutproduktion                              
    ## 48   ¦   ¦   °--Speise- und Futterkartoffeln                                    
    ## 49   ¦   °--Hanf                                                                
    ## 50   ¦--Rhododendron                                                            
    ## 51   ¦   °--Azaleen                                                             
    ## 52   ¦--Verarbeitungsräume                                                      
    ## 53   ¦--Forstwirtschaft allg.                                                   
    ## 54   ¦   ¦--Wald                                                                
    ## 55   ¦   °--Forstliche Pflanzgärten                                             
    ## 56   ¦--Lupinen                                                                 
    ## 57   ¦--Schwarzer Holunder                                                      
    ## 58   ¦--Kohlarten                                                               
    ## 59   ¦   ¦--Blumenkohle                                                         
    ## 60   ¦   ¦   ¦--Blumenkohl                                                      
    ## 61   ¦   ¦   ¦--Romanesco                                                       
    ## 62   ¦   ¦   °--Broccoli                                                        
    ## 63   ¦   ¦--Blattkohle                                                          
    ## 64   ¦   ¦   ¦--Pak-Choi                                                        
    ## 65   ¦   ¦   ¦--Markstammkohl                                                   
    ## 66   ¦   ¦   ¦--Chinakohl                                                       
    ## 67   ¦   ¦   °--Federkohl                                                       
    ## 68   ¦   ¦--Rosenkohl                                                           
    ## 69   ¦   ¦--Kopfkohle                                                           
    ## 70   ¦   °--Kohlrabi                                                            
    ## 71   ¦--Rubus Arten                                                             
    ## 72   ¦   ¦--Brombeere                                                           
    ## 73   ¦   °--Himbeere                                                            
    ## 74   ¦--Einrichtungen und Geräte                                                
    ## 75   ¦--Nachtschattengewächse (Solanaceae)                                      
    ## 76   ¦   ¦--Paprika                                                             
    ## 77   ¦   ¦   ¦--Peperoni                                                        
    ## 78   ¦   ¦   °--Gemüsepaprika                                                   
    ## 79   ¦   ¦--Aubergine                                                           
    ## 80   ¦   ¦--Andenbeere                                                          
    ## 81   ¦   ¦--Tomaten                                                             
    ## 82   ¦   ¦   ¦--Tomaten Spezialitäten                                           
    ## 83   ¦   ¦   ¦--Cherrytomaten                                                   
    ## 84   ¦   ¦   °--Rispentomaten                                                   
    ## 85   ¦   °--Pepino                                                              
    ## 86   ¦--Färberdistel (Saflor)                                                   
    ## 87   ¦--Chinaschilf                                                             
    ## 88   ¦--leere Verarbeitungsräume                                                
    ## 89   ¦--Lorbeer                                                                 
    ## 90   ¦--Lager- und Produktionsräume allg.                                       
    ## 91   ¦--Mulchsaaten                                                             
    ## 92   ¦--Zuckermais                                                              
    ## 93   ¦--Linse                                                                   
    ## 94   ¦--Puffbohne                                                               
    ## 95   ¦--Blautanne                                                               
    ## 96   ¦--Erbsen                                                                  
    ## 97   ¦   ¦--Erbsen mit Hülsen                                                   
    ## 98   ¦   °--Erbsen ohne Hülsen                                                  
    ## 99   ¦--Klee zur Saatgutproduktion                                              
    ## 100  ¦--Ackerbohne                                                              
    ## 101  ¦--Kenaf                                                                   
    ## 102  ¦--Walnuss                                                                 
    ## 103  ¦--Hartschalenobst                                                         
    ## 104  ¦--Majoran                                                                 
    ## 105  ¦--Kerbelrübe                                                              
    ## 106  ¦--Holzpaletten, Packholz, Stammholz                                       
    ## 107  ¦--Weihnachtsbäume                                                         
    ## 108  ¦--Rande                                                                   
    ## 109  ¦--Kresse                                                                  
    ## 110  ¦--leere Lagerräume                                                        
    ## 111  ¦--Eiweisserbse                                                            
    ## 112  ¦--Nichtkulturland allg.                                                   
    ## 113  ¦   ¦--Böschungen und Grünstreifen entlang von Verkehrswegen (gem. ChemRRV)
    ## 114  ¦   °--Auf und an National- und Kantonsstrassen (gem. ChemRRV)             
    ## 115  ¦--Tabak                                                                   
    ## 116  ¦--Kürbisgewächse (Cucurbitaceae)                                          
    ## 117  ¦   ¦--Wassermelonen                                                       
    ## 118  ¦   ¦--Gurken                                                              
    ## 119  ¦   ¦   ¦--Einlegegurken                                                   
    ## 120  ¦   ¦   ¦--Nostranogurken                                                  
    ## 121  ¦   ¦   °--Gewächshausgurken                                               
    ## 122  ¦   ¦--Melonen                                                             
    ## 123  ¦   ¦--Speisekürbisse (ungeniessbare Schale)                               
    ## 124  ¦   ¦--Ölkürbisse                                                          
    ## 125  ¦   °--Kürbisse mit geniessbarer Schale                                    
    ## 126  ¦       ¦--Patisson                                                        
    ## 127  ¦       ¦--Zucchetti                                                       
    ## 128  ¦       °--Rondini                                                         
    ## 129  ¦--Nelken                                                                  
    ## 130  ¦--Gewürzfenchel                                                           
    ## 131  ¦--Zierpflanzen allg.                                                      
    ## 132  ¦   ¦--Ein- und zweijährige Zierpflanzen                                   
    ## 133  ¦   ¦   °--Sommerflor                                                      
    ## 134  ¦   ¦--Topf- und Kontainerpflanzen                                         
    ## 135  ¦   ¦   ¦--Begonia                                                         
    ## 136  ¦   ¦   ¦--Cyclame                                                         
    ## 137  ¦   ¦   ¦--Pelargonien                                                     
    ## 138  ¦   ¦   °--Primeln                                                         
    ## 139  ¦   ¦--Baumschule                                                          
    ## 140  ¦   ¦--Zier- und Sportrasen                                                
    ## 141  ¦   ¦--Blumenkulturen und Grünpflanzen                                     
    ## 142  ¦   ¦   ¦--Zierkürbis                                                      
    ## 143  ¦   ¦   ¦--Hyazinthe                                                       
    ## 144  ¦   ¦   ¦--Iris                                                            
    ## 145  ¦   ¦   ¦--Liliengewächse (Zierpflanzen)                                   
    ## 146  ¦   ¦   °--Tulpe                                                           
    ## 147  ¦   ¦--Gehölze (ausserhalb Forst)                                          
    ## 148  ¦   ¦--Rosen                                                               
    ## 149  ¦   ¦--Bäume und Sträucher (ausserhalb Forst)                              
    ## 150  ¦   ¦--Ziergehölze (ausserhalb Forst)                                      
    ## 151  ¦   °--Stauden                                                             
    ## 152  ¦--Portulak                                                                
    ## 153  ¦   °--Gemüseportulak                                                      
    ## 154  ¦--Getreide                                                                
    ## 155  ¦   ¦--Triticale                                                           
    ## 156  ¦   ¦   °--Wintertriticale                                                 
    ## 157  ¦   ¦--Wintergetreide                                                      
    ## 158  ¦   ¦   ¦--Winterweizen                                                    
    ## 159  ¦   ¦   ¦--Winterroggen                                                    
    ## 160  ¦   ¦   ¦--Korn (Dinkel)                                                   
    ## 161  ¦   ¦   °--Emmer                                                           
    ## 162  ¦   ¦--Sommergetreide                                                      
    ## 163  ¦   ¦   ¦--Sommerweizen                                                    
    ## 164  ¦   ¦   ¦--Sommergerste                                                    
    ## 165  ¦   ¦   °--Sommerhafer                                                     
    ## 166  ¦   ¦--Gerste                                                              
    ## 167  ¦   ¦   °--Wintergerste                                                    
    ## 168  ¦   ¦--Roggen                                                              
    ## 169  ¦   ¦--Weizen                                                              
    ## 170  ¦   ¦   ¦--Hartweizen                                                      
    ## 171  ¦   ¦   °--Weichweizen                                                     
    ## 172  ¦   °--Hafer                                                               
    ## 173  ¦--Offene Ackerfläche                                                      
    ## 174  ¦--Lauch                                                                   
    ## 175  ¦--Pflanzen                                                                
    ## 176  ¦--Radies                                                                  
    ## 177  ¦--Spinat                                                                  
    ## 178  ¦--Traubensilberkerze                                                      
    ## 179  ¦--Trockenreis                                                             
    ## 180  ¦--Schwarzwurzel                                                           
    ## 181  ¦--Nüsslisalat                                                             
    ## 182  ¦--Mohn                                                                    
    ## 183  ¦--Lein                                                                    
    ## 184  ¦--Olive                                                                   
    ## 185  ¦--Gerbera                                                                 
    ## 186  ¦--Beerenbau allg.                                                         
    ## 187  ¦--Sojabohne                                                               
    ## 188  ¦--Blumenzwiebeln und Blumenknollen                                        
    ## 189  ¦--Speisekohlrüben                                                         
    ## 190  ¦   °--Brassica rapa-Rüben                                                 
    ## 191  ¦--Rosenwurz                                                               
    ## 192  ¦--Kirschlorbeer                                                           
    ## 193  ¦--Speisepilze                                                             
    ## 194  ¦--Süssdolde                                                               
    ## 195  ¦--Gojibeere                                                               
    ## 196  ¦--Bohnen                                                                  
    ## 197  ¦   ¦--Bohnen ohne Hülsen                                                  
    ## 198  ¦   °--Bohnen mit Hülsen                                                   
    ## 199  ¦       ¦--Stangenbohne                                                    
    ## 200  ¦       °--Buschbohne                                                      
    ## 201  ¦--Heidelbeere                                                             
    ## 202  ¦--Mangold                                                                 
    ## 203  ¦   ¦--Krautstiel                                                          
    ## 204  ¦   °--Schnittmangold                                                      
    ## 205  ¦--Lagerhallen, Mühlen, Silogebäude                                        
    ## 206  ¦--Brachland                                                               
    ## 207  ¦--Johanniskraut                                                           
    ## 208  ¦--Dahlien                                                                 
    ## 209  ¦--Gemüsebau allg.                                                         
    ## 210  ¦--Asia-Salate (Brassicaceae)                                              
    ## 211  ¦--Blaue Heckenkirsche                                                     
    ## 212  ¦--Barbarakraut                                                            
    ## 213  ¦--Humusdeponie                                                            
    ## 214  ¦--Rettich                                                                 
    ## 215  ¦--Topinambur                                                              
    ## 216  ¦--Ribes Arten                                                             
    ## 217  ¦   ¦--Stachelbeere                                                        
    ## 218  ¦   ¦--Schwarze Johannisbeere                                              
    ## 219  ¦   ¦--Rote Johannisbeere                                                  
    ## 220  ¦   °--Jostabeere                                                          
    ## 221  ¦--Cima di Rapa                                                            
    ## 222  ¦--Brache                                                                  
    ## 223  ¦--Spargel                                                                 
    ## 224  ¦--Steinobst                                                               
    ## 225  ¦   ¦--Zwetschge / Pflaume                                                 
    ## 226  ¦   ¦   ¦--Zwetschge                                                       
    ## 227  ¦   ¦   °--Pflaume                                                         
    ## 228  ¦   ¦--Pfirsich / Nektarine                                                
    ## 229  ¦   ¦--Aprikose                                                            
    ## 230  ¦   °--Kirsche                                                             
    ## 231  ¦--Mini-Kiwi                                                               
    ## 232  ¦--Erntegut                                                                
    ## 233  ¦--Rucola                                                                  
    ## 234  ¦--Erdbeere                                                                
    ## 235  ¦--Grasbestände zur Saatgutproduktion                                      
    ## 236  ¦--Schwarze Maulbeere                                                      
    ## 237  ¦--Sanddorn                                                                
    ## 238  ¦--Sellerie                                                                
    ## 239  ¦   ¦--Suppensellerie                                                      
    ## 240  ¦   ¦--Stangensellerie                                                     
    ## 241  ¦   °--Knollensellerie                                                     
    ## 242  ¦--Luzerne                                                                 
    ## 243  ¦--Melisse                                                                 
    ## 244  ¦--Küchenkräuter                                                           
    ## 245  ¦   ¦--Ysop                                                                
    ## 246  ¦   ¦--Koriander                                                           
    ## 247  ¦   ¦--Rosmarin                                                            
    ## 248  ¦   ¦--Petersilie                                                          
    ## 249  ¦   ¦--Römische Kamille                                                    
    ## 250  ¦   ¦--Kerbel                                                              
    ## 251  ¦   ¦--Minze                                                               
    ## 252  ¦   ¦--Basilikum                                                           
    ## 253  ¦   ¦--Bohnenkraut                                                         
    ## 254  ¦   ¦--Thymian                                                             
    ## 255  ¦   ¦--Kümmel                                                              
    ## 256  ¦   ¦--Dill                                                                
    ## 257  ¦   ¦--Salbei                                                              
    ## 258  ¦   ¦--Liebstöckel                                                         
    ## 259  ¦   ¦--Estragon                                                            
    ## 260  ¦   °--Schnittlauch                                                        
    ## 261  ¦--Gemeine Felsenbirne                                                     
    ## 262  ¦--Fichte                                                                  
    ## 263  ¦--Stielmus                                                                
    ## 264  ¦--Obstbau allg.                                                           
    ## 265  ¦--Blaudistel                                                              
    ## 266  ¦--Zwiebeln                                                                
    ## 267  ¦   ¦--Gemüsezwiebel                                                       
    ## 268  ¦   ¦--Bundzwiebeln                                                        
    ## 269  ¦   °--Speisezwiebel                                                       
    ## 270  ¦--Buchsbäume (Buxus)                                                      
    ## 271  ¦--Gladiole                                                                
    ## 272  ¦--Frässaaten                                                              
    ## 273  ¦--Raps                                                                    
    ## 274  ¦   °--Winterraps                                                          
    ## 275  ¦--Chicorée                                                                
    ## 276  ¦--Salate (Asteraceae)                                                     
    ## 277  ¦   ¦--Löwenzahn                                                           
    ## 278  ¦   ¦--Lactuca-Salate                                                      
    ## 279  ¦   ¦   ¦--Kopfsalate                                                      
    ## 280  ¦   ¦   ¦   °--Kopfsalat                                                   
    ## 281  ¦   ¦   °--Blattsalate (Asteraceae)                                        
    ## 282  ¦   ¦       °--Schnittsalat                                                
    ## 283  ¦   °--Endivien und Blattzichorien                                         
    ## 284  ¦       ¦--Endivien                                                        
    ## 285  ¦       ¦--Zuckerhut                                                       
    ## 286  ¦       °--Radicchio- und Cicorino-Typen                                   
    ## 287  ¦--Medizinalkräuter                                                        
    ## 288  ¦   °--Wolliger Fingerhut                                                  
    ## 289  ¦--Meerrettich                                                             
    ## 290  ¦--Bodenkohlrabi                                                           
    ## 291  ¦--Hagebutten                                                              
    ## 292  ¦--Pastinake                                                               
    ## 293  ¦--Süsskartoffel                                                           
    ## 294  ¦--Lagerräume                                                              
    ## 295  ¦--Schalotten                                                              
    ## 296  °--Mais                                                                    
    ##                               culture_id
    ## 1                                       
    ## 2   0106A8DF-6CDF-4E18-8F46-3D9E1D52D0E5
    ## 3   6C3D663E-442F-4783-87A2-A46806E119E5
    ## 4   9BD6A435-E370-4DFE-82E5-7E7813B4D193
    ## 5   DB0DCB7D-CA9F-454A-8398-606F066FBF4F
    ## 6   01AFF6EB-9C8D-4D0D-B225-0BA07B59A72F
    ## 7   037E11B2-128A-4194-9A5B-A3E980AE4113
    ## 8   086E34F3-82E5-4F92-9224-41C9F7529E70
    ## 9   B542EC7D-B423-43B4-9010-82A6889BB3B4
    ## 10  C763D817-B4AC-43DB-9C6E-A262CC32F400
    ## 11  095E9650-A880-4BD2-A1BB-39297582BCE6
    ## 12  0D20E815-633E-4F38-AC93-7B6578B0483E
    ## 13  0E2847EB-CEFD-4640-82EB-F09F3F1A5E13
    ## 14  0F5F1FEE-084C-4961-A76F-82F9B17B2635
    ## 15  FA0F7C48-BF78-49B0-9046-FBB5ABB4BF75
    ## 16  42466A90-AFCD-4DA6-8769-99C4BC5BE217
    ## 17  FD180555-9DEF-42BA-86E0-EBD31AB8FABB
    ## 18  FD18F42C-C390-4701-B07B-B8108B33320B
    ## 19  122B909A-CE9C-47BC-B5CA-DCF523646D38
    ## 20  13BB4B9E-6CEE-4729-AE29-8A4380EB33B0
    ## 21  17B69B05-E650-4A6F-815A-D6DA55A92CDB
    ## 22  19C5BA72-A0D5-4409-8D05-0A7C9D821E20
    ## 23  1BFC9694-C7DC-4D74-84B2-1418AB94A8BA
    ## 24  1F03DDC0-19CF-48F1-BAB8-61CA4CEF24CF
    ## 25  4E1ACD79-F162-4EBB-93CB-C6857A811E9C
    ## 26  1F0B6451-EC2C-4647-A53A-23B0EAE626B1
    ## 27  21228D46-5B00-4CDD-9C71-48C0A0B21C78
    ## 28  2260B6A9-FC51-4F50-8E8F-D39BC6D5DA3A
    ## 29  230F7417-5500-4124-B273-95AA1FFB940B
    ## 30  2314EB9F-7207-409F-A0D4-89B6A1177363
    ## 31  293D431D-8501-4D41-A0E5-F1A5AD59C8B6
    ## 32  516862FD-DCB0-42BF-8E18-ADA820B1DB90
    ## 33  24EA0CC6-D1D5-4BB4-981C-A836E3D7125D
    ## 34  269900C0-F407-4AFA-B3F2-D857EDACB733
    ## 35  27ACD8EA-49E8-4C99-84D4-53E2E605390E
    ## 36  27FBFA25-5091-4D7E-9C96-3C0BC05B6474
    ## 37  28ECDBFE-F44F-44C6-BF06-9B7E6EBFC1F6
    ## 38  2AB457D1-DB9D-4545-92FF-04A6BD2CEC08
    ## 39  2F7BD13A-BAA5-4708-83C6-17D44E57EA4D
    ## 40  309E5D09-3084-40C6-88F2-D4A14345136C
    ## 41  3346CB25-6DC9-42AF-8BA2-F725BD92304A
    ## 42  34753E17-C34D-4D0B-88A0-91143DADABB2
    ## 43  36D9AFE2-7506-48CE-BA39-EFD54535294A
    ## 44  36EC3084-D6AE-494D-A5B2-EC39DCC4F412
    ## 45  3783A322-9E9C-44F6-B683-FE35221CA6AC
    ## 46  B4D50F5E-6028-493D-9B95-85CAE5DADF06
    ## 47  689F7BE7-DA1E-49B6-95D5-E002E210E7B9
    ## 48  92CAB39E-ACC3-44DC-9EF3-0D27B8600E83
    ## 49  EA82A16B-4A8C-4917-A08F-C2AD3B266640
    ## 50  3A53A166-7559-4E75-BDED-F65CA6FDFDE1
    ## 51  33097BFE-2487-46DB-85A0-A8A4E06030AF
    ## 52  3E4AFACC-03CA-4CEC-8392-520B07DDC604
    ## 53  3FEAB48F-0D66-4814-B3E3-C4BC0AB749B3
    ## 54  19CC4F57-CB08-4970-BEDB-3DB2B2CB1034
    ## 55  43FC7C18-BDA5-4364-B4CA-74EA37B7B8DC
    ## 56  404C1D02-5666-4AA3-8487-65A9EEE0B53D
    ## 57  42D50BC4-0019-4B55-9CB5-6C3E86C9D112
    ## 58  4380EC0F-E195-4783-8BB7-F6B0464B37D6
    ## 59  4A22B9D3-747C-4323-A852-1CB1F6ADB680
    ## 60  1E129025-DFD8-42D1-8A86-D90485B282A1
    ## 61  8AFA14F8-CCE3-4012-BD12-9D690EBAE1AD
    ## 62  B9323B4D-249D-4CF3-A5DF-4FDA2E66532F
    ## 63  6F26F4E0-401C-4B16-A28B-4CC889907361
    ## 64  394AE687-29A0-4BA6-B0B9-D7DFB0C08FCE
    ## 65  80395E92-C39B-45D9-91AC-AB7E6DCAC3DB
    ## 66  C37A7EE2-D06B-4204-809A-F50A934F79E3
    ## 67  DF4B3775-8361-41CE-9843-AC953197403D
    ## 68  7B90BAC4-B80F-4039-ADC3-ADF9225CCBB7
    ## 69  CA58ABAE-E494-4608-BE51-5FF49D853A03
    ## 70  D8A50212-BD15-456A-9D2E-2A401C2EF21D
    ## 71  43F8091A-A333-40F5-8845-FF83398B9AC3
    ## 72  8621CDCC-EE8A-4188-9F2C-14C9497FBED3
    ## 73  D63D73AC-87B1-41F7-82AC-D1DFF12F6704
    ## 74  465E7118-95AB-46A2-9A85-7A0B9070E63A
    ## 75  46901564-D096-4323-AE81-C93831AFEC64
    ## 76  096444CD-43E6-41F9-8914-2E7DADA4C801
    ## 77  46D3C073-CBD8-4B3A-A9AA-21785BA911CA
    ## 78  68688AEC-44E2-490B-AC80-E8DEDCC82B8F
    ## 79  6CC3F1FF-84DF-4E4A-A91E-57C5ECB82F61
    ## 80  74C47437-5700-45F5-86E2-D410DACD39B6
    ## 81  E9E3C127-33C1-40D9-8552-3CBE45E8E4C4
    ## 82  07A12E5B-DB0B-4421-A215-E306768AC0BE
    ## 83  1D9F568C-5170-43A1-86B9-B25808DD6A43
    ## 84  D100976A-2598-4614-AB7A-61436FF2B053
    ## 85  F512809F-5CC7-44A2-A378-8FDAFA67CFEA
    ## 86  49F7DA15-E241-4080-9D42-1523ECA834B5
    ## 87  4A386AE2-A36F-4A55-8668-7B896A1E8092
    ## 88  4B6DC713-3B11-42C5-92A8-E504D594E978
    ## 89  4C8B56DD-9606-453C-9B14-C9C6309E87FA
    ## 90  4D5AF334-29F4-4854-A14F-4457A8A87D97
    ## 91  52019F0F-3BAF-4161-A223-62EECBA47871
    ## 92  5433C814-C0CD-4815-B236-2D02E1C66F3D
    ## 93  54C75B64-57C4-46E2-BCEA-741EBC10FDDF
    ## 94  56AF3EA3-01F4-4F10-B240-7EF4BE1C1CCE
    ## 95  5B651459-FC70-4D22-9469-4991F847EA89
    ## 96  5DF3AB4D-7CAC-4112-90D9-67BD80EC5E96
    ## 97  02BF379A-E526-422A-952B-3B0CD995F8C1
    ## 98  C5188A42-9C79-4110-B1E8-AEE9D6078BEA
    ## 99  6388D9E7-CD0D-4823-80DD-E6FA472AF12C
    ## 100 657E4B0A-50BD-424B-9DB4-1B84582AD3D7
    ## 101 6D06A7F9-DF91-4BB5-84B8-FB877C211E66
    ## 102 6D45EAF5-D29C-48AB-A212-91C67357E898
    ## 103 6EDA1989-51C8-490E-90FD-974CE3E8FF03
    ## 104 710CC0C8-B138-4B31-9975-4DA04AF67792
    ## 105 71D9FB13-5AE4-42C3-9F84-956B16C379C1
    ## 106 75047A9C-12E2-4BAC-89D8-B14BC4C6B100
    ## 107 79C28385-E183-4661-AAC0-80E82C67089C
    ## 108 7A993953-3C2F-4BC3-98EE-2EE5E83C6E77
    ## 109 7CE53BA0-097D-44FB-82FF-C30DFD3769DD
    ## 110 7D23702C-980B-4B90-A86B-70013806D3EA
    ## 111 7D52C099-7C6F-453C-8513-4BBFB94EE66A
    ## 112 7F20F06C-C950-49B9-A78F-9E2F696B079E
    ## 113 A22521E4-7D71-40C2-9FDF-B1230008D934
    ## 114 C3E12AAE-119E-47CF-9B8A-6F1CA657CF6B
    ## 115 8262D735-4D45-4499-AE0B-497FF4C0C4AA
    ## 116 8303C191-3315-4942-91DF-668C019850D7
    ## 117 09269926-BA07-42DC-BE9D-5B34658BDBF0
    ## 118 30F9F737-0A18-43EC-AF88-F28940E567F1
    ## 119 238AB652-AD62-4703-A74B-7550C693ED6E
    ## 120 AED83C4B-0546-4C91-B370-4AB5B425942F
    ## 121 CE13A930-22B8-44D6-98E4-97707B0F7F6C
    ## 122 399AC89E-29BB-44AD-8B1F-0B2F327D5230
    ## 123 573B50E9-ED1D-4999-B4FD-4537CA2A6306
    ## 124 BBD16782-6EB3-4923-9DBB-CC7D97EBCB0E
    ## 125 FE69D926-4BE1-4C67-840E-30C3D299442E
    ## 126 3447F4C9-2E90-437F-A240-0462AFEDF2B5
    ## 127 C1A1842A-37E5-46D3-9646-9ECC15BAEE99
    ## 128 F6A02973-2AF5-47AF-B99D-FFAD9A24BCB4
    ## 129 83A9CEC5-FC31-421C-A3B8-CA219AF649CF
    ## 130 8512D352-73CC-4535-9469-965AAF1FD0B1
    ## 131 890D8A5E-BF86-4B2D-9B98-45B779D80F7F
    ## 132 00D94F57-BA6F-4BA0-8F68-26D4C497539A
    ## 133 C69EBD93-43E5-457F-9CBE-EE1C04791274
    ## 134 2A05DA01-5722-46A2-BCCF-3B75C6D17BB6
    ## 135 2E38C972-4160-4D2B-8ED2-3B48FC781EF0
    ## 136 9A9A2586-34FF-4256-8FA4-BA9F2FA38CAE
    ## 137 B75AC4CC-6BB7-4A99-808A-9F7BDFCF8E6A
    ## 138 E8B23A5E-B65E-4DC8-977D-BD84F143A442
    ## 139 3BEFA6F7-0D34-4E29-8207-85E9D5783ECC
    ## 140 5C610428-6087-4A2E-B977-3E83EDBB19F0
    ## 141 75317E57-B194-4B3D-8FF2-3489A39AC177
    ## 142 302E5676-26A3-41EB-980F-2B6BDE117D3A
    ## 143 61D9C648-0736-43D4-BF04-B8643B1D74E0
    ## 144 A8647F38-2A16-46AB-8B0E-2257EBF53C63
    ## 145 B82B5C60-02CB-4B7A-B3D3-A4CA34A809C3
    ## 146 FF0DF95C-A3A9-47EE-95FA-00FCB428A4ED
    ## 147 7B3C8CEE-526F-4381-A757-669C1864291A
    ## 148 A024CDFC-A05D-46B8-B08A-221C26BDF5DE
    ## 149 D40E1405-757C-4E3D-B26F-07D5F2251565
    ## 150 F4479311-1516-49F1-95BA-E232030F9AAC
    ## 151 FCF24426-CAB8-43C8-9E42-B09581420287
    ## 152 8A00630A-32FC-4B5A-8171-EC0F41D39F48
    ## 153 77267F83-907F-4537-98A8-7B9C1E4714F0
    ## 154 8B5A3E2B-2534-4FC0-84C5-685915165A77
    ## 155 048FDB44-710A-4801-849C-72F1A458DB82
    ## 156 CEC488FC-D9AD-4515-A28E-DEEC6C807926
    ## 157 287584B7-E43E-494B-84C2-D13B2C9C3736
    ## 158 7AB6690B-B2B9-4F12-AFAE-A9B0222C2637
    ## 159 B74E61A6-30BD-4A63-8A24-94FC0A54D489
    ## 160 D3D49C53-8EBC-4DAC-9C4C-B988AA162F7D
    ## 161 F730D531-B0C8-4A20-AC4B-4F86445E2491
    ## 162 449A5380-96E3-4C3F-AB31-7CB3D0579561
    ## 163 B6669854-1833-4BBC-A931-E67505848EA7
    ## 164 C026CB2D-39B4-4FDF-AD04-FBA22AD2B4F1
    ## 165 C9DB1105-33C7-44E8-92BA-9BBE5BA2BB3F
    ## 166 625EA905-7C3D-4BCC-8551-BC1CB14FF647
    ## 167 7D65DFD2-C26E-4CAB-9E2C-66A6C7CBA641
    ## 168 7D76F5F6-5810-4556-A7D5-84C91FDE3FF2
    ## 169 82376115-14E2-449A-8DFA-F8119476FE3F
    ## 170 7870FD70-C44A-4788-ABEA-FB673A5FD106
    ## 171 D3D90BE6-0924-4844-98FB-52C4D7F21A38
    ## 172 F8A8C1D8-E2C7-4230-8435-4D5AEE69813E
    ## 173 8BDDCACC-13C1-4676-9322-402ECF20BE85
    ## 174 8DFDE2D1-C004-4C25-BF54-21CF7C815232
    ## 175 8E6C3D3A-6D7A-4D82-94CC-E4F227CC1EB2
    ## 176 8FF3D364-2BA6-40AA-A370-4B72E3CAC8DF
    ## 177 93A2DA1B-F920-461B-A9C9-BA9981CDB278
    ## 178 9650E36A-38F4-4375-9594-25785BACE1DC
    ## 179 99379C08-8682-4628-BD67-6E566F5130FA
    ## 180 9A9333CA-AD6C-459D-9AFF-B8E8FB2FF8D4
    ## 181 9AA59D6B-D6AA-49BE-8BF8-A7A53BE54759
    ## 182 9B8F475B-C6FA-4642-9CD8-89A98A293D50
    ## 183 9BA6BDE9-AD45-4F91-A190-708D39AD5B63
    ## 184 9BCEB85B-1578-4001-839D-68BFB9CE4CD8
    ## 185 9C6CEE37-8105-4E48-9CA4-11BA3AB556FB
    ## 186 9DE574C1-EE11-42BC-9C05-930BCAE13A44
    ## 187 9F6AE17C-0BE1-457A-B780-D408BCD333BF
    ## 188 A0012475-8478-4CA9-A18A-DC1CB96D788B
    ## 189 A0C29069-5DBA-4E89-B7F9-4C556C272821
    ## 190 BFD1B79E-ABD1-4A44-8E61-891FF97960A1
    ## 191 A1B43C0A-8077-47D4-9171-8E6B2C9A95C4
    ## 192 A21391C3-A1A3-4472-8AA1-56449FB56B36
    ## 193 A2D0B83F-9BB5-477C-AD44-24B31F2EF276
    ## 194 A2D2B4EC-D7D6-4A30-BEE9-0A8F907A874A
    ## 195 A3E943A5-C6D8-4CB0-A069-85BFC48E8B8A
    ## 196 A8BAC5BB-239F-4EE0-8CE2-F55590DA3FC0
    ## 197 102C28F6-4AFB-4079-909B-ACE8E0819A77
    ## 198 F7BB2F1C-EDE5-4C95-931E-0B2C973F5A29
    ## 199 4465118D-78E7-4748-A47A-7F39E593771A
    ## 200 930524FB-BD0A-4CA9-A89D-4FEEE1F9174F
    ## 201 A9F01BDE-468A-477A-8ED5-704359B663F6
    ## 202 AB0798FE-64B8-49A2-8E75-14467EB7AB58
    ## 203 915B2192-1651-4B8A-B2D8-C162A5D27211
    ## 204 B7DE9539-35FD-4172-B72D-488EA12F2DF7
    ## 205 AC0240B5-B610-4D7C-8704-AA8E182821AC
    ## 206 AE465EA2-A950-4661-B631-D5A267B2F076
    ## 207 AE97719E-9D0F-425C-BCD7-0F5D84092113
    ## 208 AEC07D17-6D8B-4180-A368-056A187DE2F8
    ## 209 B4CA8F81-4A66-4880-98AB-C7760AECCDA6
    ## 210 B5FFA375-D9A5-4FD1-9DCF-76F230FEA725
    ## 211 B92BA12C-EA9D-4EA8-ADEE-A4547872DD58
    ## 212 BA2DECCF-5987-4987-B56E-C5EC6E5D19C0
    ## 213 BAE217C2-8C72-4706-8A0E-911FB18FC723
    ## 214 BB923645-6E65-48EE-9C64-DA2232EEE7EF
    ## 215 BDB73EC5-46E5-413B-85B5-78D3801F4E7E
    ## 216 BE3C6915-B28E-4CC8-980E-7F243F14F519
    ## 217 3A522DC8-E6D3-426D-AA99-65C148ED1A84
    ## 218 4E8A4BB8-3B5D-4695-B17C-F4C1202D5138
    ## 219 91406007-35B9-49E2-A62F-04BDE262366F
    ## 220 FFDDDA7D-B340-473C-94F4-841272B602FA
    ## 221 C264982A-CA81-4311-9E38-67D2D956BC78
    ## 222 C8AB8319-939E-4CF3-B78E-549A85DEF756
    ## 223 C96EE4F4-12EA-49DE-9BEF-21EA73B52760
    ## 224 CA722B7E-8F16-4502-8139-C33F749545D4
    ## 225 24A364B9-6BD7-42A6-A9EC-AB9E94E010FF
    ## 226 66B27CD1-032A-456E-99C4-28F6E989CC14
    ## 227 9C38BA77-FDC8-461A-800A-9E2467C52105
    ## 228 307A62EA-67D6-4D28-9CF7-F1218C9BE2CD
    ## 229 9BB00FC5-181F-4F3F-94C8-E4141143F44A
    ## 230 CF9B4B3C-DCDC-4E2E-A613-D784936842D2
    ## 231 CA9B7EDC-8626-4E01-B979-4856CFA9893E
    ## 232 CC08E1E6-655D-4FAA-B0E8-AD968A68A536
    ## 233 CC9D982D-A99F-4143-8298-BC029BD1D1AD
    ## 234 CCCD6417-ED96-4A46-82EF-2EC848F719A7
    ## 235 CDF1E5BC-0740-4214-8912-870CC2BB37F4
    ## 236 D18572C7-A270-4AA7-B766-48D62C5E9AB7
    ## 237 D1E8D0D6-BD3C-4C47-9017-DBEADC9215A9
    ## 238 D36B92CB-136F-46C3-8217-10C3F86ECA12
    ## 239 18C6314C-C067-4E7F-AAB6-2DEF3F01DF9D
    ## 240 3702313F-95C6-4FE9-8B6B-C7CE3987CD18
    ## 241 56884AC3-B629-440D-8E82-05075A18697F
    ## 242 D3CD23DC-4C49-4EE5-8BF8-6B074E74352A
    ## 243 D51188F1-9F8F-46E6-8F5B-550A7D45A4BE
    ## 244 D541F2F5-8BA6-4E26-AA66-9CF469648AFF
    ## 245 0A88EFE2-B85E-4BF7-9C38-AEE8CB2BFE42
    ## 246 0DAB25B6-C3AA-430B-BF83-05FA66D889A4
    ## 247 14B19DFD-331F-4C30-8724-8EDDF8E2D0D4
    ## 248 1A1D511B-4ABD-44F2-8BB5-55192F5310D2
    ## 249 25DC9B01-CA06-426A-B743-C0D293447898
    ## 250 2C8A4414-AD7F-4708-9C58-BF1969131693
    ## 251 37059300-8031-4A64-B75C-7490288E32BA
    ## 252 3C2F424F-DFA0-4A59-A3DF-6E33A6B0B97E
    ## 253 4D799EC6-1483-4D65-90EA-8DDB6A4166CA
    ## 254 730AACDC-B956-493D-8148-7520019CE0BC
    ## 255 807F5A2C-7904-456D-BBC7-A80A4B207964
    ## 256 91522E50-F1AC-42B1-870B-68218110C235
    ## 257 A067CC81-6A5D-4684-BE95-7941A51B9EF2
    ## 258 A519A894-B754-44D1-A032-155F57B0CBFE
    ## 259 ABF54D5D-620B-4A08-A37D-416C1AD8D1BF
    ## 260 FA8C26CF-E3B4-456D-AA4E-94D21AEADA1A
    ## 261 D605CAA5-9199-4739-8C9C-343C74DABAEB
    ## 262 D95CD842-A5BC-4DAA-935D-F009DA7BA748
    ## 263 DA5835F6-C295-4A4F-829D-007B1FA50A6D
    ## 264 DA71526F-AC1D-40F1-8EF5-109E3F3FFD76
    ## 265 DAF00AE7-5272-4E07-9A66-E9F9BD8FEE43
    ## 266 DB98FC8E-5AFA-4434-9478-960124F960CA
    ## 267 83C510D2-293A-4E1B-B691-06B1F02149B4
    ## 268 874850AA-2F48-47B6-A789-C67D6DEE97DA
    ## 269 C883F887-6B72-4917-9385-7A757E5FD8D6
    ## 270 DF455946-B2AB-45D2-9780-4A45A98D72D6
    ## 271 E2A335E5-D797-46E7-9CE4-9CB3F301AAA2
    ## 272 E36FADB4-A022-42A0-81CF-F041CABB93A4
    ## 273 E58E502E-BECD-44CB-96A2-3A6771D8A7B7
    ## 274 5755AD92-721E-431E-8473-6FA2F340532F
    ## 275 E5B9C6F0-5C57-4A12-8ED9-D65B669B8243
    ## 276 E786D43D-444B-49D6-B0D0-294265F91403
    ## 277 25DA6F5A-1BD0-4040-A210-BB05CCB66AE4
    ## 278 33686F38-1E1A-4698-81E4-C40EE4494EF3
    ## 279 4DD550C5-15BB-4D52-98BD-6770972575F0
    ## 280 B02E0EFA-B8AF-425A-A779-6A4DFE8D4172
    ## 281 9CA61204-7EA7-4F2F-BAD3-BD02EDD6A829
    ## 282 A4BC1F92-959A-4449-A039-B98E3ABCD9B1
    ## 283 8DB1A579-6BAC-4DCB-8026-E79B65D3BD3A
    ## 284 62BF86AE-FD69-4F95-A72C-1D57AF1DCD99
    ## 285 94589F70-1F3A-4AEF-A26A-2267EB5BDA4B
    ## 286 B535B6DD-517D-4A62-ACC7-2948B15175ED
    ## 287 E981BFA6-288D-4EA6-B81B-4F610611EB36
    ## 288 C38D7DE4-C804-4F7C-AA2F-A536D03E0DFC
    ## 289 EACDD832-D1CD-479C-973F-CD0DB6A9FBC3
    ## 290 EB820B26-DE4E-4AF4-8BA3-46844F045306
    ## 291 EC349B29-6A2B-4E43-990F-C553D278DC0E
    ## 292 EE7EE009-EBD4-471D-AE85-1A98130F6119
    ## 293 EF29B430-95C5-45D4-A812-DCCE046E1B8E
    ## 294 F171615D-81A1-4654-BF30-BF51620DFFB9
    ## 295 F718EA3C-F363-4DB2-BDF6-2D6236706822
    ## 296 F9426E5C-7D4D-45E5-80DA-64BB12336CA4
    ##                                                                       name_fr
    ## 1                                                                            
    ## 2                                                                   Baby-Leaf
    ## 3                                                    Baby-Leaf (Brassicaceae)
    ## 4                                                  Baby-Leaf (Chenopodiaceae)
    ## 5                                                      Baby-Leaf (Asteraceae)
    ## 6                                                                     Houblon
    ## 7                                                                         ail
    ## 8                                            betteraves à sucre et fourragère
    ## 9                                                           Betterave à sucre
    ## 10                                                       Betterave fourragère
    ## 11                                                                  Tournesol
    ## 12                                                            fenouil bulbeux
    ## 13                                                                     origan
    ## 14                                                            fruits à pépins
    ## 15                                                            poirier / nashi
    ## 16                                                                    poirier
    ## 17                                                                 cognassier
    ## 18                                                                    pommier
    ## 19                                                      sorbier des oiseleurs
    ## 20                              grumes en forêt et sur les places de stockage
    ## 21                                                Les exploitations tabacoles
    ## 22                                                        cresson de fontaine
    ## 23                                                                  artichaut
    ## 24                                                      Prairies et pâturages
    ## 25                            mélange trèfles-graminées (prairie arificielle)
    ## 26                                                           crosnes du japon
    ## 27                                                     persil à grosse racine
    ## 28                                                                pois chiche
    ## 29                                                                 ranunculus
    ## 30                                                                      vigne
    ## 31                                                        vigne en production
    ## 32                                                                jeune vigne
    ## 33                                                        surfaces herbagères
    ## 34                                                          plantain lancéolé
    ## 35                                                                   rhubarbe
    ## 36                                                              Sorgho commun
    ## 37                                                 Locaux de production vides
    ## 38                                                                    carotte
    ## 39                                                          marronnier d'Inde
    ## 40                                                                  valériane
    ## 41                                                                     cardon
    ## 42                                                               chrysanthème
    ## 43                                                               aronie noire
    ## 44                                                                    anémone
    ## 45                                                  grande culture en général
    ## 46                                                            pommes de terre
    ## 47                               pommes de terre pour la production de plants
    ## 48                              pommes de terre de consommation et fourragère
    ## 49                                                                    Chanvre
    ## 50                                                               rhododendron
    ## 51                                                                     azalée
    ## 52                                                   locaux de transformation
    ## 53                                                    sylviculture en général
    ## 54                                                                      forêt
    ## 55                                                     pépinières forestières
    ## 56                                                                      Lupin
    ## 57                                                               grand sureau
    ## 58                                                                      choux
    ## 59                                   choux (développement de l'inflorescence)
    ## 60                                                                 chou-fleur
    ## 61                                                                  romanesco
    ## 62                                                                    brocoli
    ## 63                                                           choux à feuilles
    ## 64                                                                    pakchoi
    ## 65                                                              chou moellier
    ## 66                                                              chou de Chine
    ## 67                                                       chou frisé non pommé
    ## 68                                                          chou de Bruxelles
    ## 69                                                               choux pommés
    ## 70                                                                    colrave
    ## 71                                                           espèces de Rubus
    ## 72                                                                       mûre
    ## 73                                                                  framboise
    ## 74                                                    installations et outils
    ## 75                                                                 solanacées
    ## 76                                                                    poivron
    ## 77                                                                    poivron
    ## 78                                                               poivron doux
    ## 79                                                                  aubergine
    ## 80                                                          coqueret du Pérou
    ## 81                                                                     tomate
    ## 82                                                       tomates, spécialités
    ## 83                                                              tomate-cerise
    ## 84                                                            tomate à grappe
    ## 85                                                                poire melon
    ## 86                                                                   Carthame
    ## 87                                                            Roseau de Chine
    ## 88                                             Locaux de transformation vides
    ## 89                                                                    Laurier
    ## 90                                          Lager- und Produktionsräume allg.
    ## 91                                                         semis sous litière
    ## 92                                                                 maïs sucré
    ## 93                                                                   lentille
    ## 94                                                                       fève
    ## 95                                                                 sapin bleu
    ## 96                                                                       pois
    ## 97                                                           pois non écossés
    ## 98                                                               pois écossés
    ## 99                                     Trèfles pour la production de semences
    ## 100                                                                  féverole
    ## 101                                                                     Kenaf
    ## 102                                                                     noyer
    ## 103                                                           noix en général
    ## 104                                                                marjolaine
    ## 105                                                         Cerfeuil tubéreux
    ## 106                        Palette en bois, bois d'emballage, bois en général
    ## 107                                                            arbres de Noël
    ## 108                                                        betterave à salade
    ## 109                                                         cresson de jardin
    ## 110                                                           Êntrepôts vides
    ## 111                                                         pois protéagineux
    ## 112                                           domaine non agricole en général
    ## 113 talus et bandes vertes le long des voies de communication (selon ORRChim)
    ## 114              le long des routes nationales et cantonales  (selon ORRChim)
    ## 115                                                                     Tabac
    ## 116                                                             cucurbitacées
    ## 117                                                                  pastèque
    ## 118                                                                 concombre
    ## 119                                                                cornichons
    ## 120                                                        concombre nostrano
    ## 121                                                        concombre de serre
    ## 122                                                                    melons
    ## 123                                           courges (écorce non comestible)
    ## 124                                                      courges oléagineuses
    ## 125                                                 courges à peau comestible
    ## 126                                                                  pâtisson
    ## 127                                                                 courgette
    ## 128                                                                   rondini
    ## 129                                                                   oeillet
    ## 130                                                        fenouil aromatique
    ## 131                                            culture ornementale en général
    ## 132                            plantes ornementales annuelles et bisannuelles
    ## 133                                                          fleurs estivales
    ## 134                                            plantes en pot et en container
    ## 135                                                                   bégonia
    ## 136                                                                  cyclamen
    ## 137                                                                  géranium
    ## 138                                                                primevères
    ## 139                                                                 pépinière
    ## 140                                     gazon d'ornement et terrains de sport
    ## 141                                       cultures florales et plantes vertes
    ## 142                                                         courge d'ornement
    ## 143                                                                  jacinthe
    ## 144                                                                      iris
    ## 145                                          liliacées (plantes ornementales)
    ## 146                                                                    tulipe
    ## 147                                            plantes ligneuses (hors forêt)
    ## 148                                                                    rosier
    ## 149                                           arbres et arbustes (hors fôret)
    ## 150                                          arbustes d'ornement (hors forêt)
    ## 151                                                           plantes vivaces
    ## 152                                                                  pourpier
    ## 153                                                           pourpier commun
    ## 154                                                                  Céréales
    ## 155                                                                 Triticale
    ## 156                                                       Triticale d'automne
    ## 157                                                        Céréales d'automne
    ## 158                                                             Blé d'automne
    ## 159                                                          Seigle d'automne
    ## 160                                                                  Épeautre
    ## 161                                                                Amidonnier
    ## 162                                                     Céréales de printemps
    ## 163                                                          Blé de printemps
    ## 164                                                         orge de printemps
    ## 165                                                       Avoine de printemps
    ## 166                                                                      Orge
    ## 167                                                            Orge d'automne
    ## 168                                                                    Seigle
    ## 169                                                                       Blé
    ## 170                                                                   Blé dur
    ## 171                                                                Blé tendre
    ## 172                                                                    Avoine
    ## 173                                                           terres ouvertes
    ## 174                                                                   poireau
    ## 175                                                                   plantes
    ## 176                                                    radis de tous les mois
    ## 177                                                                   épinard
    ## 178                                                            actée à grappe
    ## 179                                                 Riz semis sur terrain sec
    ## 180                                                                scorsonère
    ## 181                                                             mâche, rampon
    ## 182                                                                     pavot
    ## 183                                                                       Lin
    ## 184                                                                   olivier
    ## 185                                                                   gerbera
    ## 186                                              culture des baies en général
    ## 187                                                                      Soja
    ## 188                                                        bulbes ornementaux
    ## 189                                         rave de Brassica rapa et B. napus
    ## 190                                                     rave de Brassica rapa
    ## 191                                                                Orpin rose
    ## 192                                                            laurier-cerise
    ## 193                                                   champignons comestibles
    ## 194                                                           Cerfeuil musqué
    ## 195                                                             Baies de Goji
    ## 196                                                                  haricots
    ## 197                                                          haricots écossés
    ## 198                                                      haricots non écossés
    ## 199                                                           haricot à rames
    ## 200                                                              haricot nain
    ## 201                                                                  myrtille
    ## 202                                                                     bette
    ## 203                                                              bette à côte
    ## 204                                                            bette à tondre
    ## 205                                                 entrepôts, moulins, silos
    ## 206                                                                    friche
    ## 207                                                              millepertuis
    ## 208                                                                    dahlia
    ## 209                                             culture maraîchère en général
    ## 210                                               salades Asia (Brassicaceae)
    ## 211                                                           camérisier bleu
    ## 212                                                     Barbarée du printemps
    ## 213                                                   dépôt de terre végétale
    ## 214                                                                radis long
    ## 215                                                               topinambour
    ## 216                                                          espèces de Ribes
    ## 217                                                    groseilles à maquereau
    ## 218                                                                    cassis
    ## 219                                                      groseilles à grappes
    ## 220                                                                     josta
    ## 221                                                              cima di rapa
    ## 222                                                                   jachère
    ## 223                                                                   asperge
    ## 224                                                           fruits à noyaux
    ## 225                                                   prunier (pruneau/prune)
    ## 226                                                         prunier (pruneau)
    ## 227                                                           prunier (prune)
    ## 228                                                        pêcher / nectarine
    ## 229                                                                abricotier
    ## 230                                                                  cerisier
    ## 231                                                         mini-Kiwi (Kiwaï)
    ## 232                                                            denrée stockée
    ## 233                                                                  roquette
    ## 234                                                                    fraise
    ## 235                                  Graminées pour la production de semences
    ## 236                                                               mûrier noir
    ## 237                                                                 argousier
    ## 238                                                                    céleri
    ## 239                                                céleri-pomme pour bouillon
    ## 240                                                            céleri-branche
    ## 241                                                              céleri-pomme
    ## 242                                                                   Luzerne
    ## 243                                                                   mélisse
    ## 244                                                              fines herbes
    ## 245                                                                    Hysope
    ## 246                                                                 coriandre
    ## 247                                                                   romarin
    ## 248                                                                    persil
    ## 249                                                         Camomille romaine
    ## 250                                                                  cerfeuil
    ## 251                                                                    menthe
    ## 252                                                                   basilic
    ## 253                                                                 sarriette
    ## 254                                                                      thym
    ## 255                                                                     carvi
    ## 256                                                                     aneth
    ## 257                                                                     sauge
    ## 258                                                                   livèche
    ## 259                                                                  estragon
    ## 260                                                                ciboulette
    ## 261                                                          amélavier commun
    ## 262                                                                    épicéa
    ## 263                                                            navet à tondre
    ## 264                                                  arboriculture en général
    ## 265                                                              chardon bleu
    ## 266                                                                    oignon
    ## 267                                                            oignon potager
    ## 268                                                          oignons en botte
    ## 269                                                        oignon (condiment)
    ## 270                                                              buis (Buxus)
    ## 271                                                                   glaïeul
    ## 272                                           semis après travail superficiel
    ## 273                                                                     Colza
    ## 274                                                           Colza d'automne
    ## 275                                        chicorée witloof (chicorée-endive)
    ## 276                                                      salades (Asteraceae)
    ## 277                                                              dent-de-lion
    ## 278                                                           salades lactuca
    ## 279                                                           laitues pommées
    ## 280                                                             laitue pommée
    ## 281                                             laitues à tondre (Asteraceae)
    ## 282                                                           laitue à tondre
    ## 283                                    chicorée pommée et chicorée à feuilles
    ## 284                                         chicorée scarole, chicorée frisée
    ## 285                                                    chicorée pain de sucre
    ## 286                                   types de radicchio/trévises et cicorino
    ## 287                                                       plantes médicinales
    ## 288                                                         digitale lanifère
    ## 289                                                                   raifort
    ## 290                                                                  rutabaga
    ## 291                                                                cynorhodon
    ## 292                                                                    Panais
    ## 293                                                              Patate douce
    ## 294                                                                 entrepôts
    ## 295                                                                  échalote
    ## 296                                                                      Maïs
    ##                                                                             name_it
    ## 1                                                                                  
    ## 2                                                                         Baby-Leaf
    ## 3                                                          Baby-Leaf (Brassicaceae)
    ## 4                                                        Baby-Leaf (Chenopodiaceae)
    ## 5                                                            Baby-Leaf (Asteraceae)
    ## 6                                                                           Luppolo
    ## 7                                                                             Aglio
    ## 8                                            Barbabietole da foraggio e da zucchero
    ## 9                                                          Barbabietola da zucchero
    ## 10                                                         Barbabietola da foraggio
    ## 11                                                                         Girasole
    ## 12                                                                  Finocchio dolce
    ## 13                                                                          origano
    ## 14                                                                Frutta a granelli
    ## 15                                                                     Pero / Nashi
    ## 16                                                                             Pero
    ## 17                                                                          Cotogno
    ## 18                                                                             Melo
    ## 19                                                           Sorbo degli ucellatori
    ## 20                    Tronchi abbattuti nella foresta e presso piazzali di deposito
    ## 21                                                   Aziende produttrici di tabacco
    ## 22                                                              Crescione acquatico
    ## 23                                                                         Carciofi
    ## 24                                                                  Prati e pascoli
    ## 25                                 Miscela trifoglio-graminacee (prati artificiali)
    ## 26                                                                         Tuberina
    ## 27                                                              Prezzemolo tuberoso
    ## 28                                                                             cece
    ## 29                                                                        ranuncolo
    ## 30                                                                             Vite
    ## 31                                                               Vite in produzione
    ## 32                                                                    Ceppi giovani
    ## 33                                                              Superficie inerbita
    ## 34                                                            piantaggine lanciuola
    ## 35                                                                        Rabarbaro
    ## 36                                                                            Sorgo
    ## 37                                                       Locali di produzione vuoti
    ## 38                                                                           Carote
    ## 39                                                                      Ippocastano
    ## 40                                                                        Valeriana
    ## 41                                                                            Cardo
    ## 42                                                                       Crisantemo
    ## 43                                                                      Aronia nera
    ## 44                                                                          Anemone
    ## 45                                                         Campicoltura in generale
    ## 46                                                                           Patate
    ## 47                                          Patate per la produzione di tuberi-seme
    ## 48                                                   Patate da tavola e da foraggio
    ## 49                                                                           Canapa
    ## 50                                                                       Rododendro
    ## 51                                                                           Azalee
    ## 52                                                        Locali per la lavorazione
    ## 53                                                         Selvicoltura in generale
    ## 54                                                                            Bosco
    ## 55                                                                  Vivai forestali
    ## 56                                                                           Lupini
    ## 57                                                                     Sambuco nero
    ## 58                                                                 Specie di cavoli
    ## 59                                                           Cavoli a infiorescenza
    ## 60                                                                       Cavolfiore
    ## 61                                                                        Romanesco
    ## 62                                                                         Broccoli
    ## 63                                                                 Cavoli fogliacei
    ## 64                                                                         Pak-Choi
    ## 65                                                                   Cavolo fustoso
    ## 66                                                                    Cavolo cinese
    ## 67                                                                     Cavolo piuma
    ## 68                                                              Cavoli di Bruxelles
    ## 69                                                                   Cavoli a testa
    ## 70                                                                      Cavolo rapa
    ## 71                                                                  Specie di rubus
    ## 72                                                                             Mora
    ## 73                                                                          Lampone
    ## 74                                                       Installazioni e apparecchi
    ## 75                                                                        Solanacee
    ## 76                                                                         Peperone
    ## 77                                                                         Peperone
    ## 78                                                                   Peperone dolce
    ## 79                                                                        Melanzana
    ## 80                                                                     Alchechengio
    ## 81                                                                         Pomodori
    ## 82                                                  Varietà particolari di pomodoro
    ## 83                                                                Pomodoro ciliegia
    ## 84                                                                  Pomodoro ramato
    ## 85                                                                           Pepino
    ## 86                                                                          Cartamo
    ## 87                                                                         Miscanto
    ## 88                                                  Locali per la lavorazione vuoti
    ## 89                                                                           Alloro
    ## 90                                                Lager- und Produktionsräume allg.
    ## 91                                                                Semine a lattiera
    ## 92                                                                       Mais dolce
    ## 93                                                                       Lenticchia
    ## 94                                                                             Fave
    ## 95                                                               Abete del Colorado
    ## 96                                                                          Piselli
    ## 97                                                             Piselli con baccello
    ## 98                                                           Piselli senza baccello
    ## 99                                           Trifoglio per la produzione di sementi
    ## 100                                                                            Fava
    ## 101                                                                           Kenaf
    ## 102                                                                     Noce comune
    ## 103                                                               Frutta con guscio
    ## 104                                                                      maggiorana
    ## 105                                                               Cerfoglio bulboso
    ## 106                      Palette in legno, legno da imballaggio, legno non lavorato
    ## 107                                                                Alberi di Natale
    ## 108                                                                    Barbabietola
    ## 109                                                                       Crescione
    ## 110                                                      Locali di stoccaggio vuoti
    ## 111                                                                Pisello proteico
    ## 112                                               Superfici non coltive in generale
    ## 113 Scarpate e strisce verdi lungo le vie di comunicazione (conformemente ORRPChim)
    ## 114                  Lungo le strade nazionali e cantonali (conformemente ORRPChim)
    ## 115                                                                         Tabacco
    ## 116                                                                    Cucurbitacee
    ## 117                                                                         Angurie
    ## 118                                                                        Cetrioli
    ## 119                                                           cetrioli per conserva
    ## 120                                                               Cetriolo nostrano
    ## 121                                                               Cetriolo olandese
    ## 122                                                                          Meloni
    ## 123                                                Zucche (buccia non commestibile)
    ## 124                                                                   Zucca da olio
    ## 125                                                  Zucche con buccia commestibile
    ## 126                                                                        Patisson
    ## 127                                                                        Zucchine
    ## 128                                                                         Rondini
    ## 129                                                                        Garofani
    ## 130                                                             Finocchio aromatico
    ## 131                                          Coltivazione piante ornam. in generale
    ## 132                                           Piante ornamentali annuali e biennali
    ## 133                                                                    Fiori estivi
    ## 134                                                   Pianta in vaso e in container
    ## 135                                                                         Begonia
    ## 136                                                                       Ciclamino
    ## 137                                                                         Geranio
    ## 138                                                                         Primule
    ## 139                                                                          Vivaio
    ## 140                                               Tappeti erbosi e terreni sportivi
    ## 141                                                 Colture da fiore e piante verdi
    ## 142                                                               Zucca ornamentale
    ## 143                                                                        Giacinto
    ## 144                                                                            Iris
    ## 145                                                   Liliacee (pianti ornamentali)
    ## 146                                                                        Tulipano
    ## 147                                               Boschetti (al di fuori del bosco)
    ## 148                                                                            Rose
    ## 149                                    Alberi e arbusti (al di fuori della foresta)
    ## 150                                 Arbusti ornamentali (al di fuori della foresta)
    ## 151                                                                         Arbusti
    ## 152                                                                       Portulaca
    ## 153                                                                Portulaca estiva
    ## 154                                                                         Cereali
    ## 155                                                                       Triticale
    ## 156                                                             Triticale autunnale
    ## 157                                                               Cereali autunnali
    ## 158                                                              Frumento autunnale
    ## 159                                                                Segale autunnale
    ## 160                                                                          Spelta
    ## 161                                                                           Farro
    ## 162                                                             Cereali primaverili
    ## 163                                                            Frumento primaverile
    ## 164                                                                Orzo primaverile
    ## 165                                                               Avena primaverile
    ## 166                                                                            Orzo
    ## 167                                                                  Orzo autunnale
    ## 168                                                                          Segale
    ## 169                                                                        Frumento
    ## 170                                                                      Grano duro
    ## 171                                                                    Grano tenero
    ## 172                                                                           Avena
    ## 173                                                       Superficie coltiva aperta
    ## 174                                                                           Porro
    ## 175                                                                          Piante
    ## 176                                                                       Ravanello
    ## 177                                                                         Spinaci
    ## 178                                                                 actaea racemosa
    ## 179                                               Riso seminato su terreno asciutto
    ## 180                                                                      Scorzonera
    ## 181                                                                    Valerianella
    ## 182                                                                        Papavero
    ## 183                                                                            Lino
    ## 184                                                                           Olivo
    ## 185                                                                         Gerbera
    ## 186                                              Coltivazione di bacche in generale
    ## 187                                                                            Soia
    ## 188                                                               Bulbi ornamentali
    ## 189                                                Rapa di Brassica rapa e B. napus
    ## 190                                                           Rapa di Brassica rapa
    ## 191                                                                  Rhodiola rosea
    ## 192                                                                    Lauro ceraso
    ## 193                                                             Funghi commestibili
    ## 194                                                                    finocchiella
    ## 195                                                                  Bacche di Goji
    ## 196                                                                         Fagioli
    ## 197                                                          Fagioli senza baccello
    ## 198                                                            Fagioli con baccello
    ## 199                                                              Fagiolo rampicante
    ## 200                                                                    Fagiolo nano
    ## 201                                                                        Mirtillo
    ## 202                                                                         Bietola
    ## 203                                                                           Costa
    ## 204                                                               Bietola da taglio
    ## 205                                                          Depositi, mulini, sili
    ## 206                                                                 Terreno incolto
    ## 207                                                                         Iperico
    ## 208                                                                           Dalie
    ## 209                                                         Orticoltura in generale
    ## 210                                                Insalate asiatiche (Brassicacee)
    ## 211                                                            Caprifoglio turchino
    ## 212                                                   Erba di Santa Barbara vernale
    ## 213                                                    Deposito di terreno vegetale
    ## 214                                                                      Ramolaccio
    ## 215                                                                      Topinambur
    ## 216                                                                 Specie di ribes
    ## 217                                                                       Uva spina
    ## 218                                                                      Ribes nero
    ## 219                                                                     Ribes rosso
    ## 220                                                                           Josta
    ## 221                                                                    Cima di rapa
    ## 222                                                                         Maggese
    ## 223                                                                        Asparagi
    ## 224                                                               Frutta a nocciolo
    ## 225                                                                   Prugno/Susino
    ## 226                                                                          Prugno
    ## 227                                                                        Prugnolo
    ## 228                                                                Pesco/pesco noce
    ## 229                                                                       Albicocco
    ## 230                                                                        Ciliegio
    ## 231                                                                       Mini-Kiwi
    ## 232                                                               Raccolto stoccato
    ## 233                                                                          Rucola
    ## 234                                                                         Fragola
    ## 235                                         Graminacee per la produzione di sementi
    ## 236                                                                       Moro nero
    ## 237                                                                Olivello spinoso
    ## 238                                                                          Sedano
    ## 239                                                            Sedano da condimento
    ## 240                                                                 Sedano da coste
    ## 241                                                                     Sedano rapa
    ## 242                                                                     Erba medica
    ## 243                                                                         Melissa
    ## 244                                                               Erbette da cucina
    ## 245                                                                          Issopo
    ## 246                                                                      Coriandolo
    ## 247                                                                       Rosmarino
    ## 248                                                                      Prezzemolo
    ## 249                                                                Camomilla romana
    ## 250                                                                       Cerfoglio
    ## 251                                                                           Menta
    ## 252                                                                        Basilico
    ## 253                                                                     Santoreggia
    ## 254                                                                            Timo
    ## 255                                                                           Carvi
    ## 256                                                                           Aneto
    ## 257                                                                          Salvia
    ## 258                                                                       Levistico
    ## 259                                                                     Dragoncello
    ## 260                                                                  Erba cipollina
    ## 261                                                                    Pero corvino
    ## 262                                                                     Abete rosso
    ## 263                                                         Cavoli / rape da taglio
    ## 264                                                       Frutticoltura in generale
    ## 265                                                                   Cardo azzurro
    ## 266                                                                         Cipolle
    ## 267                                                                   Cipolle dolci
    ## 268                                                              Cipollotti a mazzi
    ## 269                                                               Cipolle da tavola
    ## 270                                                                   Bosso (Buxus)
    ## 271                                                                        Gladiolo
    ## 272                                                        Semine dopo la fresatura
    ## 273                                                                           Colza
    ## 274                                                                 Colza autunnale
    ## 275                                                                   Cicoria belga
    ## 276                                                            Insalate (Asteracee)
    ## 277                                                                  Dente di leone
    ## 278                                                     Insalate del genere Lactuca
    ## 279                                                              Insalate cappuccio
    ## 280                                                               Lattuga cappuccio
    ## 281                                                   Insalate a foglie (Asteracee)
    ## 282                                                               Lattuga da taglio
    ## 283                                                     Indivia e cicoria da foglia
    ## 284                                                                         Indivia
    ## 285                                                         Cicoria pan di zucchero
    ## 286                                                    Tipi di radicchio e cicorino
    ## 287                                                                 erbe medicinali
    ## 288                                                                 Digitale lanata
    ## 289                                                   Rafano rusticana / Ramolaccio
    ## 290                                                                   Cavolo navone
    ## 291                                                                     rosa canina
    ## 292                                                                       Pastinaca
    ## 293                                                                    Patata dolce
    ## 294                                                                        Depositi
    ## 295                                                                        Scalogni
    ## 296                                                                            Mais
