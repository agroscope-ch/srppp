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
#> Warning: downloaded length 0 != reported length 16
#> Warning: cannot open URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip': HTTP status was '502 Bad Gateway'
#> Error in download.file(from, path, quiet = TRUE) : 
#>   cannot open URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip'
# }
```
