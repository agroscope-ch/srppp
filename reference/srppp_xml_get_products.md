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
#> # A tibble: 1,740 × 8
#>     pNbr wNbr  name          exhaustionDeadline soldoutDeadline isSalePermission
#>    <int> <chr> <chr>         <chr>              <chr>           <lgl>           
#>  1    38 18    "Thiovit Jet" ""                 ""              FALSE           
#>  2    38 18-3  "Sanoplant S… ""                 ""              TRUE            
#>  3    38 18-5  "Gesal Schro… ""                 ""              TRUE            
#>  4  1182 923   "Divopan"     ""                 ""              FALSE           
#>  5  1192 934   "Trifolin"    ""                 ""              FALSE           
#>  6  1263 986   "Elosal Supr… ""                 ""              FALSE           
#>  7  1865 1454  "Misto 12"    ""                 ""              FALSE           
#>  8  1994 1526  "Zofal D"     ""                 ""              FALSE           
#>  9  2028 1529  "Oléoc "      ""                 ""              FALSE           
#> 10  2055 1840  "Misto 20"    ""                 ""              FALSE           
#> # ℹ 1,730 more rows
#> # ℹ 2 more variables: terminationReason <chr>, permission_holder <chr>
# }
```
