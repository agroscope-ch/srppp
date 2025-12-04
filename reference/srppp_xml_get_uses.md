# Get uses ('indications') for all products described in an XML version of the Swiss Register of Plant Protection Products

Get uses ('indications') for all products described in an XML version of
the Swiss Register of Plant Protection Products

## Usage

``` r
srppp_xml_get_uses(srppp_xml = srppp_xml_get())
```

## Arguments

- srppp_xml:

  An object as returned by
  [srppp_xml_get](https://agroscope-ch.github.io/srppp/reference/srppp_xml_get.md)
  with use numbers defined by
  [srppp_xml_define_use_numbers](https://agroscope-ch.github.io/srppp/reference/srppp_xml_define_use_numbers.md)

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
of use definitions

## Examples

``` r
# \donttest{
srppp_xml <- try(srppp_xml_get())
if (!inherits(srppp_xml, "try-error")) {
  srppp_xml <- srppp_xml_define_use_numbers(srppp_xml)
  srppp_xml_get_uses(srppp_xml)
}
#> # A tibble: 7,855 × 15
#>    wNbr  use_nr min_dosage max_dosage min_rate max_rate units_de units_fr
#>    <chr>  <int>      <dbl>      <dbl>    <dbl>    <dbl> <chr>    <chr>   
#>  1 1454       1        3.5         NA       35       NA l/ha     l/ha    
#>  2 1454       2        2           NA       32       NA l/ha     l/ha    
#>  3 1454       3        3.5         NA       NA       NA NA       NA      
#>  4 1454       4        1           NA       16       NA l/ha     l/ha    
#>  5 1454       5        3.5         NA       56       NA l/ha     l/ha    
#>  6 1454       6        3.5         NA       35       NA l/ha     l/ha    
#>  7 1454       7        1           NA        6       NA l/ha     l/ha    
#>  8 1454       8        3.5         NA       35       NA l/ha     l/ha    
#>  9 1454       9        2           NA       16       NA l/ha     l/ha    
#> 10 1454      10        2           NA       32       NA l/ha     l/ha    
#> # ℹ 7,845 more rows
#> # ℹ 7 more variables: units_it <chr>, units_en <chr>, waiting_period <int>,
#> #   time_units_de <chr>, time_units_fr <chr>, time_units_it <chr>,
#> #   time_units_en <chr>
# }
```
