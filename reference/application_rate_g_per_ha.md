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
  dosage_units = c("percent_ww", "percent_vv", "state_of_matter"),
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
  object.

- aggregation:

  How to represent a range if present, e.g. "max" (default) or "mean".

- dosage_units:

  If no units are given, or units are "%", then the applied amount in
  g/ha is calculated using a reference application volume and the
  dosage. As the dosage units are not explicitly given, we can specify
  our assumptions about these using this argument (currently not
  implemented, i.e. specifying the argument has no effect).

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
is selected only based on the product application area. This is not
correct if hops ('Hopfen') is the culture, as it has a unique reference
application volume of 3000 L/ha.

Applications to hops were excluded for calculating mean use rates in the
indicator project (Korkaric 2023), arguing that it is not grown in large
areas in Switzerland.

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
  filter(substance_de %in% c("Halauxifen-methyl", "Kupfer (als Kalkpr\u00E4parat)")) |>
  left_join(sr$ingredients, by = "pk") |>
  left_join(sr$uses, by = "pNbr") |>
  left_join(sr$products, by = "pNbr") |>
  select(pNbr, name, use_nr,
    min_dosage, max_dosage, min_rate, max_rate, units_de,
    application_area_de,
    substance_de, percent, g_per_L)

application_rate_g_per_ha(product_uses_with_ingredients) |>
  filter(name %in% c("Cerelex", "Pixxaro EC", "Bordeaux S")) |>
  select(ai = substance_de, app_area = application_area_de,
    min_d = min_dosage,  max_d = max_dosage,
    min_r = min_rate, max_r = max_rate,
    units_de, rate = rate_g_per_ha) |>
  print(n = Inf)
#> # A tibble: 5 × 8
#>   ai                app_area min_d max_d min_r max_r units_de  rate
#>   <chr>             <chr>    <dbl> <dbl> <dbl> <dbl> <chr>    <dbl>
#> 1 Halauxifen-methyl Feldbau     NA    NA  1       NA l/ha      6.25
#> 2 Halauxifen-methyl Feldbau     NA    NA  0.75    NA l/ha      4.69
#> 3 Halauxifen-methyl Feldbau     NA    NA  1       NA l/ha      6.25
#> 4 Halauxifen-methyl Feldbau     NA    NA  0.5     NA l/ha      6.25
#> 5 Halauxifen-methyl Feldbau     NA    NA  0.5     NA l/ha      6.25
# }
```
