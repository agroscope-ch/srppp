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
#> Warning: URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip': status was 'Failure when receiving data from the peer'
#> Error in download.file(from, path) : 
#>   cannot open URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip'
if (!inherits(srppp_xml, "try-error")) {
  srppp_xml <- srppp_xml_define_use_numbers(srppp_xml)
  srppp_xml_get_uses(srppp_xml)
}
# }
```
