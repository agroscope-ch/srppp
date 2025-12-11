# Get Products from an XML version of the Swiss Register of Plant Protection Products

Get Products from an XML version of the Swiss Register of Plant
Protection Products

## Usage

``` r
srppp_xml_get_products(
  srppp_xml = srppp_xml_get(),
  verbose = TRUE,
  remove_duplicates = TRUE
)
```

## Arguments

- srppp_xml:

  An object as returned by 'srppp_xml_get'

- verbose:

  Should we give some feedback?

- remove_duplicates:

  Should duplicates based on wNbrs be removed? If set to 'TRUE', one of
  the two entries with identical wNbrs is removed, based on an
  investigation of background information carried out by the package
  authors. In all cases except for one, one of the product sections with
  duplicate wNbrs has information about an expiry of the registration,
  and the other doesn't. In these cases the registration without expiry
  is kept, and the expiring registration is discarded. In the remaining
  case (wNbr 5945), the second entry is selected, as it contains more
  indications which were apparently intended to be published as well.

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
with a row for each product section in the XML file. An attribute
'duplicated_wNbrs' is also returned, containing duplicated W-Numbers, if
applicable, or NULL.

## Examples

``` r
# Try to get current list of products
# \donttest{
try(srppp_xml_get_products())
#> Warning: URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip': status was 'Failure when receiving data from the peer'
#> Error in download.file(from, path) : 
#>   cannot open URL 'https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip.download.zip/Daten%20Pflanzenschutzmittelverzeichnis.zip'
# }
```
