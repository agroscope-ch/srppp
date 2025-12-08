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
#> # A tibble: 443 × 6
#>    pk                  iupac substance_de substance_fr substance_it substance_en
#>    <chr>               <chr> <chr>        <chr>        <chr>        <chr>       
#>  1 0A7BFE30-AC31-4326… (E)-… (E)-8-Dodec… (E)-8-dodec… (E)-8-dodec… (E)-8-Dodec…
#>  2 96054844-EF1E-4817… (E,Z… (E,Z)-2,13-… (E,Z)-2,13-… (E,Z)-2,13-… (E,Z)-2,13-…
#>  3 CC42B743-0C24-4493… (E,Z… (E,Z)-3,13-… (E,Z)-3,13-… (E,Z)-3,13-… (E,Z)-3,13-…
#>  4 332FDA27-923A-41C7… (7E,… (E,Z)-7,9-D… (E,Z)-7,9-D… (E,Z)-7,9-D… (E,Z)-7,9-d…
#>  5 7CC210AC-D72E-4B30… [S-(… (S)-cis-Ver… (S)-cis-Ver… (S)-cis-Ver… (S)-cis-Ver…
#>  6 F2EC442B-C581-45A1… (Z)-… (Z)-11-Tetr… (Z)-11-Tetr… (Z)-11-Tetr… (Z)-11-Tetr…
#>  7 738E64D8-6E48-415F… (Z)-… (Z)-8-Dodec… (Z)-8-Dodec… (Z)-8-Dodec… (Z)-8-Dodec…
#>  8 37FEF947-0B44-4DDF… (Z)-… (Z)-8-dodec… (Z)-8-Dodéc… (Z)-8-dodec… (Z)-8-Dodec…
#>  9 028AA985-0DBA-4B99… (9Z)… (Z)-9-Dodec… (Z)-9-Dodec… (Z)-9-Dodec… (Z)-9-Dodec…
#> 10 1930                NA    (Z)-9-Octad… (Z)-9-Octad… (Z)-9-Octad… (Z)-9-Octad…
#> # ℹ 433 more rows
# }
```
