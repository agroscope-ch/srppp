# Calculate application rates for active ingredients

An application rate in g active substance/ha is calculated from
information on dosage (product concentration in the application
solution) and application volume, or directly from the product
application rate. This is complicated by the fact that a rate
("expenditure" in the XML file) with units l/ha can refer to the
application solution or to the liquid product.

## Usage

``` r
application_rate_g_per_ha(
  product_uses,
  aggregation = c("max", "mean", "min"),
  skip_l_per_ha_without_g_per_L = TRUE,
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

  Per default, uses where the use rate has units of l/ha are skipped, if
  there is not product concentration in g/L. This was also done in the
  2023 indicator project.

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
# \donttest{
library(srppp)
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

product_uses_with_ingredients <- sr$substances |>
  filter(
    grepl("Halauxifen-methyl", substance_de) |
    grepl("Kupfer.*Bordeaux", substance_de))  |> 
  left_join(sr$ingredients, by = "pk") |> # Add P-numbers
  left_join(sr$products, by = "pNbr") |>  # Add product names (may multiply P-numbers)
  left_join(sr$uses, by = "pNbr",       # Add use definitions
    relationship = "many-to-many") |>
  left_join(sr$cultures, by = c("pNbr", "use_nr"),
    relationship = "many-to-many") |> 
  select(pNbr, name, use_nr,
    min_dosage, max_dosage, min_rate, max_rate, units_de,
    application_area_de, culture_de,
    substance_de, percent, g_per_L)

# Note that since 2026, active ingredients containing copper
# are not expressed in terms of copper any more, but in terms
# of the salt, respectively in terms of the Bordeaux mixture
application_rate_g_per_ha(product_uses_with_ingredients) |>
  filter(name %in% c("Cerelex", "Pixxaro EC", "Bordeaux S")) |>
  select(ai = substance_de, app_area = application_area_de,
    min_d = min_dosage,  max_d = max_dosage,
    min_r = min_rate, max_r = max_rate,
    units_de, rate = rate_g_per_ha) |>
  distinct() |> 
  print(n = Inf)
#> # A tibble: 17 × 8
#>    ai                          app_area  min_d max_d min_r max_r units_de   rate
#>    <chr>                       <chr>     <dbl> <dbl> <dbl> <dbl> <chr>     <dbl>
#>  1 Halauxifen-methyl           Feldbau  NA     NA     1     NA   l/ha     6.25e0
#>  2 Halauxifen-methyl           Feldbau  NA     NA     0.75  NA   l/ha     4.69e0
#>  3 Halauxifen-methyl           Feldbau  NA     NA     0.5   NA   l/ha     6.25e0
#>  4 Kupfer (als Kalkpräparat, … Weinbau   0.25  NA     4     NA   kg/ha    2.91e3
#>  5 Kupfer (als Kalkpräparat, … Obstbau   0.125  0.25  2      4   kg/ha    2.91e3
#>  6 Kupfer (als Kalkpräparat, … Obstbau   0.5    0.75  8     12   kg/ha    8.72e3
#>  7 Kupfer (als Kalkpräparat, … Gemüseb… NA     NA    13     18   kg/ha    1.31e4
#>  8 Kupfer (als Kalkpräparat, … Weinbau   0.75  NA    12     NA   kg/ha    8.72e3
#>  9 Kupfer (als Kalkpräparat, … Beerenb…  0.25   0.75  2.5    7.5 kg/ha    5.45e3
#> 10 Kupfer (als Kalkpräparat, … Feldbau  NA     NA     4     NA   kg/ha    2.91e3
#> 11 Kupfer (als Kalkpräparat, … Gemüseb…  1.3    1.8  NA     NA   NA       1.31e4
#> 12 Kupfer (als Kalkpräparat, … Gemüseb…  0.5   NA     5     NA   kg/ha    3.63e3
#> 13 Kupfer (als Kalkpräparat, … Gemüseb… NA     NA    13     NA   kg/ha    9.45e3
#> 14 Kupfer (als Kalkpräparat, … Obstbau   0.25   0.5   4      8   kg/ha    5.82e3
#> 15 Kupfer (als Kalkpräparat, … Gemüseb… NA     NA     5     NA   kg/ha    3.63e3
#> 16 Kupfer (als Kalkpräparat, … Beerenb…  0.5    1.3   5     13   kg/ha    9.45e3
#> 17 Kupfer (als Kalkpräparat, … Feldbau  NA     NA    17.5   NA   kg/ha    1.27e4
# }
```
