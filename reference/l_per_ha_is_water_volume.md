# Use definitions where the rate in l/ha refers to the volume of the spraying solution

This information is used in the functions
[product_rates](https://agroscope-ch.github.io/srppp/reference/product_rates.md)
and
[application_rate_g_per_ha](https://agroscope-ch.github.io/srppp/reference/application_rate_g_per_ha.md)
in cases where a rate in l/ha exceeds 100 l/ha. It only affects older
XML files, in current versions of the XML files, rate specifications
always refer to the product.

## Usage

``` r
l_per_ha_is_water_volume
```

## Format

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with 2
rows and 5 columns.

## Details

Currently, the affected products are Dormex (P-Nr. 5151) and Karate with
Zeon technology (P-Nr. 3756).

## See also

[product_rates](https://agroscope-ch.github.io/srppp/reference/product_rates.md)

## Examples

``` r
library(srppp)
l_per_ha_is_water_volume
#> # A tibble: 2 × 5
#>    pNbr use_nr source                                   url                file 
#>   <int>  <int> <chr>                                    <chr>              <chr>
#> 1  5151      1 EFSA conclusion on cyanamide 2010, p. 17 https://doi.org/1… NA   
#> 2  3756     14 Verzeichnis 2009 Pflanzenschutzmittel    NA                 Grün…
```
