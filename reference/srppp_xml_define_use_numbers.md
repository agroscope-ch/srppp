# Define use identification numbers in an SRPPP read in from an XML file

Define use identification numbers in an SRPPP read in from an XML file

## Usage

``` r
srppp_xml_define_use_numbers(srppp_xml = srppp_xml_get())
```

## Arguments

- srppp_xml:

  An object as returned by
  [srppp_xml_get](https://agroscope-ch.github.io/srppp/reference/srppp_xml_get.md)

## Value

An object of the same class, with 'use_nr' added as an attribute of
'Indication' nodes.

## Examples

``` r
# \donttest{
try(srppp_xml_define_use_numbers())
#> Warning: downloaded length 0 != reported length 16
#> Warning: cannot open URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip': HTTP status was '502 Bad Gateway'
#> Error in download.file(from, path, quiet = TRUE) : 
#>   cannot open URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip'
# }
```
