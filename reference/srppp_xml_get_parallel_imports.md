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
#> # A tibble: 778 × 9
#>    id     wNbr  name   admissionnumber producingCountryPrim…¹ exhaustionDeadline
#>    <chr>  <chr> <chr>  <chr>           <chr>                  <chr>             
#>  1 D-7492 1526  Proma… 008719-60       56cce907-f002-4b0c-b9… ""                
#>  2 I-2789 1899  Pirim… 4701            be1d323d-29e4-4570-86… ""                
#>  3 F-7056 1899  Life … 2159999         c3ffe09f-f38f-42b3-86… ""                
#>  4 F-3632 2054  Basam… 6800403         c3ffe09f-f38f-42b3-86… ""                
#>  5 B-5440 2054  Basam… 5675P/B         9e495cc6-2d2c-4e76-b1… ""                
#>  6 I-6151 2054  Basam… 1573            be1d323d-29e4-4570-86… ""                
#>  7 D-7450 2592  Metaza 006179-00/078   56cce907-f002-4b0c-b9… ""                
#>  8 F-2010 2671  Fluid… 5100219         c3ffe09f-f38f-42b3-86… ""                
#>  9 I-5565 3002  Dazid… 012455          be1d323d-29e4-4570-86… ""                
#> 10 F-7416 3003  Rhodo… 7400755         c3ffe09f-f38f-42b3-86… ""                
#> # ℹ 768 more rows
#> # ℹ abbreviated name: ¹​producingCountryPrimaryKey
#> # ℹ 3 more variables: soldoutDeadline <chr>, pNbr <int>,
#> #   permission_holder <chr>
# }
```
