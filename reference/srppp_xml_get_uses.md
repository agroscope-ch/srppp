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
#> Warning: downloaded length 0 != reported length 16
#> Warning: cannot open URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip': HTTP status was '502 Bad Gateway'
#> Error in download.file(from, path, quiet = TRUE) : 
#>   cannot open URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip'
if (!inherits(srppp_xml, "try-error")) {
  srppp_xml <- srppp_xml_define_use_numbers(srppp_xml)
  srppp_xml_get_uses(srppp_xml)
}
# }
```
