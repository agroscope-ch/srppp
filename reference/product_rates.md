# Calculate product application rates

An application rate in l/ha or kg/ha is calculated from information on
dosage (product concentration in the application solution), application
volume, or directly from the product application rate. This is
complicated by the fact that a rate ("expenditure" in the XML file) with
units l/ha can refer to the application solution or to the liquid
product.

## Usage

``` r
product_rates(
  product_uses,
  aggregation = c("max", "mean", "min"),
  skip_l_per_ha_without_g_per_L = FALSE,
  fix_l_per_ha = TRUE
)
```

## Arguments

- product_uses:

  A tibble containing the columns 'pNbr', 'use_nr',
  'application_area_de', 'min_dosage', 'max_dosage', 'min_rate',
  'max_rate', from the 'uses' table in a
  [srppp_dm](https://agroscope-ch.github.io/srppp/reference/srppp_dm.md)
  object, as well as the columns 'percent' and 'g_per_L' from the
  'ingredients' table in a
  [srppp_dm](https://agroscope-ch.github.io/srppp/reference/srppp_dm.md)
  object and 'culture_de' from the 'cultures' table in
  [srppp_dm](https://agroscope-ch.github.io/srppp/reference/srppp_dm.md)
  object.

- aggregation:

  How to represent a range if present, e.g. "max" (default) or "mean".

- skip_l_per_ha_without_g_per_L:

  Passed on to `application_rate_g_per_ha`, but here, the default is
  FALSE, there it is TRUE.

- fix_l_per_ha:

  During the review of the 2023 indicator project calculations, a number
  of cases were identified where the unit l/ha specifies a water volume,
  and not a product volume. If TRUE (default), these cases are
  corrected, if FALSE, these cases are discarded.

## Value

A tibble containing one additional column 'rate_g_per_ha'

## Details

In some cases (currently one), external information was found,
indicating that the "expenditure" is an application volume
[l_per_ha_is_water_volume](https://agroscope-ch.github.io/srppp/reference/l_per_ha_is_water_volume.md).

## Note

A reference application volume is used if there is no 'expenditure'. It
is selected only based on the product application area and culture.

## Examples

``` r
# \dontrun{
library(srppp)
library(dplyr, warn.conflicts = FALSE)
library(dm, warn.conflicts = FALSE)
sr <- srppp_dm()
#> Warning: downloaded length 0 != reported length 16
#> Warning: cannot open URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip': HTTP status was '502 Bad Gateway'
#> Error in download.file(from, path, quiet = TRUE): cannot open URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip'

product_uses <- sr$products |>
  filter(name == "BIOHOP AudiENZ") |>
  left_join(sr$uses, by = "pNbr",
            relationship = "many-to-many") |>
  left_join(sr$cultures, by = c("pNbr", "use_nr"),
            relationship = "many-to-many") |>
  left_join(sr$ingredients, by = c("pNbr"),
            relationship = "many-to-many") |>
  select(name, pNbr, use_nr,
    min_dosage, max_dosage, min_rate, max_rate, units_de,
    application_area_de, culture_de, pk, percent, g_per_L)
#> Error: object 'sr' not found

product_rates(product_uses, aggregation = "max") |>
  select(pNbr, name, culture_de, application_area_de,
  max_prod_rate=prod_rate, prod_unit) |>
  print(n = 10)
#> Error: object 'product_uses' not found
# }
```
