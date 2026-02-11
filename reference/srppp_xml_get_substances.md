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
#> # A tibble: 442 × 6
#>    pk                  iupac substance_de substance_fr substance_it substance_en
#>    <chr>               <chr> <chr>        <chr>        <chr>        <chr>       
#>  1 0A7BFE30-AC31-4326… (E)-… (E)-8-Dodec… (E)-8-dodec… (E)-8-dodec… (E)-8-Dodec…
#>  2 96054844-EF1E-4817… (E,Z… (E,Z)-2,13-… (E,Z)-2,13-… (E,Z)-2,13-… (E,Z)-2,13-…
#>  3 CC42B743-0C24-4493… (E,Z… (E,Z)-3,13-… (E,Z)-3,13-… (E,Z)-3,13-… (E,Z)-3,13-…
#>  4 DC2C6844-BE99-4B8A… (E,Z… (E,Z)-3,8-T… (E,Z)-3,8-T… (E,Z)-3,8-T… (E,Z)-3,8-T…
#>  5 332FDA27-923A-41C7… (7E,… (E,Z)-7,9-D… (E,Z)-7,9-D… (E,Z)-7,9-D… (E,Z)-7,9-d…
#>  6 BEB1622C-583D-4BA0… (E,Z… (E,Z,Z)-3,8… (E,Z,Z)-3,8… (E,Z,Z)-3,8… (E,Z,Z)-3,8…
#>  7 7CC210AC-D72E-4B30… [S-(… (S)-cis-Ver… (S)-cis-Ver… (S)-cis-Ver… (S)-cis-Ver…
#>  8 F2EC442B-C581-45A1… (Z)-… (Z)-11-Tetr… (Z)-11-Tetr… (Z)-11-Tetr… (Z)-11-Tetr…
#>  9 738E64D8-6E48-415F… (Z)-… (Z)-8-Dodec… (Z)-8-Dodec… (Z)-8-Dodec… (Z)-8-Dodec…
#> 10 37FEF947-0B44-4DDF… (Z)-… (Z)-8-dodec… (Z)-8-Dodéc… (Z)-8-dodec… (Z)-8-Dodec…
#> # ℹ 432 more rows
# }
```
