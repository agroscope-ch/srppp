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
#> Error in read_html(base_url) : could not find function "read_html"
# }
```
