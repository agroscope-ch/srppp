# Get Parallel Imports from an XML version of the Swiss Register of Plant Protection Products

Get Parallel Imports from an XML version of the Swiss Register of Plant
Protection Products

## Usage

``` r
srppp_xml_get_parallel_imports(srppp_xml = srppp_xml_get())
```

## Arguments

- srppp_xml:

  An object as returned by 'srppp_xml_get'

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with a row for each parallel import section in the XML file.

## Examples

``` r
# Try to get current list of parallel_imports
# \donttest{
try(srppp_xml_get_parallel_imports())
#> Warning: URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip': status was 'Failure when receiving data from the peer'
#> Error in download.file(from, path) : 
#>   cannot open URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip'
# }
```
