# Get substances from an XML version of the Swiss Register of Plant Protection Products

Get substances from an XML version of the Swiss Register of Plant
Protection Products

## Usage

``` r
srppp_xml_get_substances(srppp_xml = srppp_xml_get())
```

## Arguments

- srppp_xml:

  An object as returned by 'srppp_xml_get'

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
containing primary keys, IUPAC names and substance names in German,
French and Italian.

## Examples

``` r
# \donttest{
try(srppp_xml_get_substances())
#> Error in read_html(base_url) : could not find function "read_html"
# }
```
