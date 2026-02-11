# Get ingredients for all registered products described in an XML version of the Swiss Register of Plant Protection Products

Get ingredients for all registered products described in an XML version
of the Swiss Register of Plant Protection Products

## Usage

``` r
srppp_xml_get_ingredients(srppp_xml = srppp_xml_get())
```

## Arguments

- srppp_xml:

  An object as returned by 'srppp_xml_get'

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
containing a line for each ingredient of each W-Number

## Examples

``` r
# \donttest{
try(srppp_xml_get_ingredients())
#> # A tibble: 1,835 × 9
#>    wNbr  pk      type  percent g_per_L ingredient_de ingredient_fr ingredient_it
#>    <chr> <chr>   <chr>   <dbl>   <dbl> <chr>         <chr>         <chr>        
#>  1 1454  1D7FC7… ACTI…    99.2    830  NA            NA            NA           
#>  2 1526  F976B5… ACTI…    99.1    830  NA            NA            NA           
#>  3 1529  1D7FC7… ACTI…    99.2    830  NA            NA            NA           
#>  4 1698  AEE4CE… ACTI…    33.2    400  NA            NA            NA           
#>  5 18    D95F01… ACTI…    80       NA  NA            NA            NA           
#>  6 1840  F976B5… ACTI…    99.1    830  NA            NA            NA           
#>  7 1896  1D7FC7… ACTI…   100      864. NA            NA            NA           
#>  8 1899  A2DD53… ACTI…    50       NA  NA            NA            NA           
#>  9 193   9B6470… ACTI…    84       NA  entspricht 5… correspond à… pari al 50 %…
#> 10 2008  1D7FC7… ACTI…    99.2    830  NA            NA            NA           
#> # ℹ 1,825 more rows
#> # ℹ 1 more variable: ingredient_en <chr>
# }
```
