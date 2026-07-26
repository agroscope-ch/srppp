# Find alternative products for all products containing certain active substances

This function searches for uses of a given list of active substances and
reports either a table of uses with the number of available alternative
products for each use, a detailed table of the alternative product uses,
a table of uses without alternatives, or a list containing these three
tables.

## Usage

``` r
alternative_products(
  srppp,
  active_ingredients,
  details = FALSE,
  missing = FALSE,
  list = FALSE,
  lang = c("de", "fr", "it"),
  resolve_cultures = TRUE
)
```

## Arguments

- srppp:

  A
  [srppp_dm](https://agroscope-ch.github.io/srppp/reference/srppp_dm.md)
  object.

- active_ingredients:

  Character vector of active ingredient names that will be matched
  against the column 'substances_de' in the srppp table 'substances'.

- details:

  Should a table of alternative uses with 'wNbr' and 'use_nr' be
  returned?

- missing:

  If this is set to TRUE, uses without alternative product registrations
  are listed.

- list:

  If TRUE, a list of three tables is returned, a table of uses without
  alternative products ("Lückenindikationen"), a table of the number of
  alternative products for each use, if any, and a detailed table of all
  the alternative uses. This argument overrides the arguments 'details'
  and 'missing'.

- lang:

  The language used for the active ingredient names and the returned
  tables.

- resolve_cultures:

  Logical. Specifies whether to resolve culture levels to their most
  specific hierarchical level (leaf nodes) using a parent-child
  relationship dataset derived from a culture tree.

  - If `TRUE` (default), the function maps culture levels to their
    corresponding leaf nodes. This enables precise identification of
    alternative products at the most specific culture level. This
    resolves the problem that products are sometimes authorised for
    different cultural groups. This means that actual
    "Lückenindikationen" can be identified. Only supported in German,
    i.e. if `lang = "de"`.

  - If `FALSE`, the function retains the original culture levels without
    hierarchical resolution. This option is useful when the original
    structure of the culture data needs to be preserved. **Note**: This
    argument is only applicable when the language is set to German
    (`de`). For other languages, the `resolve_cultures` functionality is
    not implemented and must be set to `FALSE`.

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble.html)
containing use definitions as defined above, i.e. containing columns
with the application area, crop and pathogen. Depending on the
arguments, columns summarizing or listing the alternative products
and/or uses are also contained.

## Details

A use is defined here as a combination of an application area, a crop
('culture') and a pathogen ('pest'). This means, that for an alternative
product to be found, there has to be an exact match of application area,
crop an pathogen.

## Examples

``` r
# \donttest{
sr <- try(srppp_dm())

# Fall back to internal test data if downloading or reading fails
if (inherits(sr, "try-error")) {
  sr <- system.file("testdata/Daten_Pflanzenschutzmittelverzeichnis_2024-12-16.zip",
      package = "srppp") |>
    srppp_xml_get_from_path(from = "2024-12-16") |>
    srppp_dm()
}

# Examples with two active substances
actives_de <- c("Lambda-Cyhalothrin", "Deltamethrin")
alternative_products(sr, actives_de)
#> # A tibble: 989 × 5
#>    application_area_de culture_de   pest_de                        n_wNbr n_pNbr
#>    <chr>               <chr>        <chr>                           <int>  <int>
#>  1 Beerenbau           Erdbeere     Erdbeer- oder Himbeerblütenst…     16      6
#>  2 Beerenbau           Erdbeere     Thripse                            37     21
#>  3 Beerenbau           Himbeere     Erdbeer- oder Himbeerblütenst…     11      3
#>  4 Beerenbau           Himbeere     Himbeerkäfer                       11      3
#>  5 Feldbau             Ackerbohne   Erdraupen                           5      3
#>  6 Feldbau             Eiweisserbse Erbsenblattrandkäfer                0      0
#>  7 Feldbau             Eiweisserbse Erbsenwickler                       4      1
#>  8 Feldbau             Eiweisserbse Erdraupen                           5      3
#>  9 Feldbau             Emmer        Erdraupen                           5      3
#> 10 Feldbau             Emmer        Gelbe Getreidehalmfliege            5      3
#> # ℹ 979 more rows
alternative_products(sr, actives_de, resolve_cultures = FALSE)
#> # A tibble: 527 × 5
#>    application_area_de culture_de              pest_de             n_wNbr n_pNbr
#>    <chr>               <chr>                   <chr>                <int>  <int>
#>  1 Beerenbau           Erdbeere                Erdbeer- oder Himb…     16      6
#>  2 Beerenbau           Erdbeere                Thripse                 32     16
#>  3 Beerenbau           Himbeere                Erdbeer- oder Himb…     11      3
#>  4 Beerenbau           Himbeere                Himbeerkäfer            11      3
#>  5 Feldbau             Ackerbohne              Erdraupen                5      3
#>  6 Feldbau             Eiweisserbse            Erbsenblattrandkäf…      0      0
#>  7 Feldbau             Eiweisserbse            Erbsenwickler            4      1
#>  8 Feldbau             Eiweisserbse            Erdraupen                5      3
#>  9 Feldbau             Futter- und Zuckerrüben Blattläuse (Röhren…      6      2
#> 10 Feldbau             Futter- und Zuckerrüben Erdraupen                5      3
#> # ℹ 517 more rows
alternative_products(sr, actives_de, missing = TRUE)
#> # A tibble: 123 × 3
#>    application_area_de culture_de                       pest_de              
#>    <chr>               <chr>                            <chr>                
#>  1 Feldbau             Eiweisserbse                     Erbsenblattrandkäfer 
#>  2 Feldbau             Zuckerrübe                       Rübenfliege          
#>  3 Feldbau             Futterrübe                       Rübenfliege          
#>  4 Feldbau             Lagerhallen, Mühlen, Silogebäude Vorratsschädlinge    
#>  5 Feldbau             Mais                             Fritfliege           
#>  6 Feldbau             Sojabohne                        Distelfalter         
#>  7 Gemüsebau           Asia-Salate (Brassicaceae)       Kohldrehherzgallmücke
#>  8 Gemüsebau           Asia-Salate (Brassicaceae)       Kohlschabe           
#>  9 Gemüsebau           Baby-Leaf (Brassicaceae)         Kohldrehherzgallmücke
#> 10 Gemüsebau           Baby-Leaf (Brassicaceae)         Kohlschabe           
#> # ℹ 113 more rows
alternative_products(sr, actives_de, details = TRUE)
#> # A tibble: 42,079 × 7
#>    application_area_de culture_de pest_de                pNbr wNbr  use_nr type 
#>    <chr>               <chr>      <chr>                 <int> <chr>  <int> <chr>
#>  1 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4568 4491       2 PEST…
#>  2 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4568 4491…      2 PEST…
#>  3 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020      71 PEST…
#>  4 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020…     71 PEST…
#>  5 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020…     71 PEST…
#>  6 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133      30 PEST…
#>  7 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133…     30 PEST…
#>  8 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133…     30 PEST…
#>  9 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8800 7106       7 PEST…
#> 10 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  9058 7333      15 PEST…
#> # ℹ 42,069 more rows
alternative_products(sr, actives_de, list = TRUE)
#> $`No alternative`
#> # A tibble: 123 × 3
#>    application_area_de culture_de                       pest_de              
#>    <chr>               <chr>                            <chr>                
#>  1 Feldbau             Eiweisserbse                     Erbsenblattrandkäfer 
#>  2 Feldbau             Zuckerrübe                       Rübenfliege          
#>  3 Feldbau             Futterrübe                       Rübenfliege          
#>  4 Feldbau             Lagerhallen, Mühlen, Silogebäude Vorratsschädlinge    
#>  5 Feldbau             Mais                             Fritfliege           
#>  6 Feldbau             Sojabohne                        Distelfalter         
#>  7 Gemüsebau           Asia-Salate (Brassicaceae)       Kohldrehherzgallmücke
#>  8 Gemüsebau           Asia-Salate (Brassicaceae)       Kohlschabe           
#>  9 Gemüsebau           Baby-Leaf (Brassicaceae)         Kohldrehherzgallmücke
#> 10 Gemüsebau           Baby-Leaf (Brassicaceae)         Kohlschabe           
#> # ℹ 113 more rows
#> 
#> $`Number of alternatives`
#> # A tibble: 989 × 5
#>    application_area_de culture_de   pest_de                        n_wNbr n_pNbr
#>    <chr>               <chr>        <chr>                           <int>  <int>
#>  1 Beerenbau           Erdbeere     Erdbeer- oder Himbeerblütenst…     16      6
#>  2 Beerenbau           Erdbeere     Thripse                            37     21
#>  3 Beerenbau           Himbeere     Erdbeer- oder Himbeerblütenst…     11      3
#>  4 Beerenbau           Himbeere     Himbeerkäfer                       11      3
#>  5 Feldbau             Ackerbohne   Erdraupen                           5      3
#>  6 Feldbau             Eiweisserbse Erbsenblattrandkäfer                0      0
#>  7 Feldbau             Eiweisserbse Erbsenwickler                       4      1
#>  8 Feldbau             Eiweisserbse Erdraupen                           5      3
#>  9 Feldbau             Emmer        Erdraupen                           5      3
#> 10 Feldbau             Emmer        Gelbe Getreidehalmfliege            5      3
#> # ℹ 979 more rows
#> 
#> $`Alternative uses`
#> # A tibble: 42,079 × 7
#>    application_area_de culture_de pest_de                pNbr wNbr  use_nr type 
#>    <chr>               <chr>      <chr>                 <int> <chr>  <int> <chr>
#>  1 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4568 4491       2 PEST…
#>  2 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4568 4491…      2 PEST…
#>  3 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020      71 PEST…
#>  4 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020…     71 PEST…
#>  5 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020…     71 PEST…
#>  6 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133      30 PEST…
#>  7 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133…     30 PEST…
#>  8 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133…     30 PEST…
#>  9 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8800 7106       7 PEST…
#> 10 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  9058 7333      15 PEST…
#> # ℹ 42,069 more rows
#> 

# Examples resolving cultures
actives_de <- c("Spinetoram")
alternative_products(sr, actives_de, resolve_cultures = FALSE, list = TRUE)
#> $`No alternative`
#> # A tibble: 1 × 3
#>   application_area_de culture_de pest_de                    
#>   <chr>               <chr>      <chr>                      
#> 1 Obstbau             Kernobst   Eulenraupen (blattfressend)
#> 
#> $`Number of alternatives`
#> # A tibble: 5 × 5
#>   application_area_de culture_de    pest_de                     n_wNbr n_pNbr
#>   <chr>               <chr>         <chr>                        <int>  <int>
#> 1 Obstbau             Birne / Nashi Birnblattsauger                 38     23
#> 2 Obstbau             Kernobst      Apfelwickler                    16     13
#> 3 Obstbau             Kernobst      Eulenraupen (blattfressend)      0      0
#> 4 Obstbau             Kernobst      Frostspanner                    38     16
#> 5 Obstbau             Kernobst      Schalenwickler                  22     10
#> 
#> $`Alternative uses`
#> # A tibble: 119 × 7
#>    application_area_de culture_de    pest_de          pNbr wNbr   use_nr type   
#>    <chr>               <chr>         <chr>           <int> <chr>   <int> <chr>  
#>  1 Obstbau             Birne / Nashi Birnblattsauger  7051 6098       45 PEST_F…
#>  2 Obstbau             Birne / Nashi Birnblattsauger  7051 6098-1     45 PEST_F…
#>  3 Obstbau             Birne / Nashi Birnblattsauger  7051 6098-2     45 PEST_F…
#>  4 Obstbau             Birne / Nashi Birnblattsauger  7169 6148        1 PEST_P…
#>  5 Obstbau             Birne / Nashi Birnblattsauger  7291 6107        4 PEST_F…
#>  6 Obstbau             Birne / Nashi Birnblattsauger  7291 6107-1      4 PEST_F…
#>  7 Obstbau             Birne / Nashi Birnblattsauger  7291 6107-2      4 PEST_F…
#>  8 Obstbau             Birne / Nashi Birnblattsauger  7291 6107-3      4 PEST_F…
#>  9 Obstbau             Birne / Nashi Birnblattsauger  7441 6382       10 PEST_F…
#> 10 Obstbau             Birne / Nashi Birnblattsauger  7511 6432       31 PEST_F…
#> # ℹ 109 more rows
#> 
alternative_products(sr, actives_de, resolve_cultures = TRUE, list = TRUE)
#> $`No alternative`
#> # A tibble: 3 × 3
#>   application_area_de culture_de pest_de                    
#>   <chr>               <chr>      <chr>                      
#> 1 Obstbau             Quitte     Eulenraupen (blattfressend)
#> 2 Obstbau             Apfel      Eulenraupen (blattfressend)
#> 3 Obstbau             Birne      Eulenraupen (blattfressend)
#> 
#> $`Number of alternatives`
#> # A tibble: 13 × 5
#>    application_area_de culture_de pest_de                     n_wNbr n_pNbr
#>    <chr>               <chr>      <chr>                        <int>  <int>
#>  1 Obstbau             Apfel      Apfelwickler                    39     27
#>  2 Obstbau             Apfel      Eulenraupen (blattfressend)      0      0
#>  3 Obstbau             Apfel      Frostspanner                    60     26
#>  4 Obstbau             Apfel      Schalenwickler                  29     13
#>  5 Obstbau             Birne      Apfelwickler                    38     26
#>  6 Obstbau             Birne      Birnblattsauger                 39     24
#>  7 Obstbau             Birne      Eulenraupen (blattfressend)      0      0
#>  8 Obstbau             Birne      Frostspanner                    60     26
#>  9 Obstbau             Birne      Schalenwickler                  29     13
#> 10 Obstbau             Quitte     Apfelwickler                    30     22
#> 11 Obstbau             Quitte     Eulenraupen (blattfressend)      0      0
#> 12 Obstbau             Quitte     Frostspanner                    54     24
#> 13 Obstbau             Quitte     Schalenwickler                  23     11
#> 
#> $`Alternative uses`
#> # A tibble: 423 × 7
#>    application_area_de culture_de pest_de          pNbr wNbr   use_nr type      
#>    <chr>               <chr>      <chr>           <int> <chr>   <int> <chr>     
#>  1 Obstbau             Birne      Birnblattsauger  7051 6098       45 PEST_FULL…
#>  2 Obstbau             Birne      Birnblattsauger  7051 6098-1     45 PEST_FULL…
#>  3 Obstbau             Birne      Birnblattsauger  7051 6098-2     45 PEST_FULL…
#>  4 Obstbau             Birne      Birnblattsauger  7169 6148        1 PEST_PART…
#>  5 Obstbau             Birne      Birnblattsauger  7291 6107        4 PEST_FULL…
#>  6 Obstbau             Birne      Birnblattsauger  7291 6107-1      4 PEST_FULL…
#>  7 Obstbau             Birne      Birnblattsauger  7291 6107-2      4 PEST_FULL…
#>  8 Obstbau             Birne      Birnblattsauger  7291 6107-3      4 PEST_FULL…
#>  9 Obstbau             Birne      Birnblattsauger  7441 6382       10 PEST_FULL…
#> 10 Obstbau             Birne      Birnblattsauger  7511 6432       31 PEST_FULL…
#> # ℹ 413 more rows
#> 

actives_de <- c("Schalenwicklergranulose-Virus")
alternative_products(sr, actives_de, resolve_cultures = FALSE, list = TRUE)
#> $`No alternative`
#> # A tibble: 0 × 3
#> # ℹ 3 variables: application_area_de <chr>, culture_de <chr>, pest_de <chr>
#> 
#> $`Number of alternatives`
#> # A tibble: 0 × 5
#> # ℹ 5 variables: application_area_de <chr>, culture_de <chr>, pest_de <chr>,
#> #   n_wNbr <int>, n_pNbr <int>
#> 
#> $`Alternative uses`
#> # A tibble: 0 × 7
#> # ℹ 7 variables: application_area_de <chr>, culture_de <chr>, pest_de <chr>,
#> #   pNbr <int>, wNbr <chr>, use_nr <int>, type <chr>
#> 
alternative_products(sr, actives_de, resolve_cultures = TRUE, list = TRUE)
#> $`No alternative`
#> # A tibble: 0 × 3
#> # ℹ 3 variables: application_area_de <chr>, culture_de <chr>, pest_de <chr>
#> 
#> $`Number of alternatives`
#> # A tibble: 0 × 5
#> # ℹ 5 variables: application_area_de <chr>, culture_de <chr>, pest_de <chr>,
#> #   n_wNbr <int>, n_pNbr <int>
#> 
#> $`Alternative uses`
#> # A tibble: 0 × 7
#> # ℹ 7 variables: application_area_de <chr>, culture_de <chr>, pest_de <chr>,
#> #   pNbr <int>, wNbr <chr>, use_nr <int>, type <chr>
#> 

actives_de <- c("Emamectinbenzoat")
alternative_products(sr, actives_de, resolve_cultures = FALSE, list = TRUE)
#> $`No alternative`
#> # A tibble: 7 × 3
#>   application_area_de culture_de           pest_de                    
#>   <chr>               <chr>                <chr>                      
#> 1 Feldbau             Eiweisserbse         Eulenraupen (blattfressend)
#> 2 Gemüsebau           Blattkohle           Eulenraupen (blattfressend)
#> 3 Gemüsebau           Blattkohle           Kohlschabe                 
#> 4 Gemüsebau           Blattkohle           Weisslinge                 
#> 5 Obstbau             Aprikose             Pfirsichmotte              
#> 6 Obstbau             Aprikose             Pfirsichwickler            
#> 7 Obstbau             Pfirsich / Nektarine Pfirsichmotte              
#> 
#> $`Number of alternatives`
#> # A tibble: 30 × 5
#>    application_area_de culture_de   pest_de                     n_wNbr n_pNbr
#>    <chr>               <chr>        <chr>                        <int>  <int>
#>  1 Feldbau             Eiweisserbse Erbsenwickler                   13      7
#>  2 Feldbau             Eiweisserbse Eulenraupen (blattfressend)      0      0
#>  3 Gemüsebau           Blattkohle   Eulenraupen (blattfressend)      0      0
#>  4 Gemüsebau           Blattkohle   Kohlschabe                       0      0
#>  5 Gemüsebau           Blattkohle   Weisslinge                       0      0
#>  6 Gemüsebau           Blumenkohle  Eulenraupen (blattfressend)      8      6
#>  7 Gemüsebau           Blumenkohle  Kohlschabe                       8      6
#>  8 Gemüsebau           Blumenkohle  Weisslinge                       8      6
#>  9 Gemüsebau           Kopfkohle    Eulenraupen (blattfressend)      9      7
#> 10 Gemüsebau           Kopfkohle    Kohlschabe                       9      7
#> # ℹ 20 more rows
#> 
#> $`Alternative uses`
#> # A tibble: 289 × 7
#>    application_area_de culture_de   pest_de        pNbr wNbr   use_nr type      
#>    <chr>               <chr>        <chr>         <int> <chr>   <int> <chr>     
#>  1 Feldbau             Eiweisserbse Erbsenwickler  7051 6098       52 PEST_FULL…
#>  2 Feldbau             Eiweisserbse Erbsenwickler  7051 6098-1     52 PEST_FULL…
#>  3 Feldbau             Eiweisserbse Erbsenwickler  7051 6098-2     52 PEST_FULL…
#>  4 Feldbau             Eiweisserbse Erbsenwickler  7441 6382        1 PEST_FULL…
#>  5 Feldbau             Eiweisserbse Erbsenwickler  7522 6381       16 PEST_FULL…
#>  6 Feldbau             Eiweisserbse Erbsenwickler  7522 6381-1     16 PEST_FULL…
#>  7 Feldbau             Eiweisserbse Erbsenwickler  8580 6998       27 PEST_FULL…
#>  8 Feldbau             Eiweisserbse Erbsenwickler  8711 7226        8 PEST_FULL…
#>  9 Feldbau             Eiweisserbse Erbsenwickler  9326 7410       14 PEST_FULL…
#> 10 Feldbau             Eiweisserbse Erbsenwickler  9326 7410-1     14 PEST_FULL…
#> # ℹ 279 more rows
#> 
alternative_products(sr, actives_de, resolve_cultures = TRUE, list = TRUE)
#> $`No alternative`
#> # A tibble: 3 × 3
#>   application_area_de culture_de           pest_de                    
#>   <chr>               <chr>                <chr>                      
#> 1 Feldbau             Eiweisserbse         Eulenraupen (blattfressend)
#> 2 Obstbau             Aprikose             Pfirsichmotte              
#> 3 Obstbau             Pfirsich / Nektarine Pfirsichmotte              
#> 
#> $`Number of alternatives`
#> # A tibble: 68 × 5
#>    application_area_de culture_de    pest_de                     n_wNbr n_pNbr
#>    <chr>               <chr>         <chr>                        <int>  <int>
#>  1 Feldbau             Eiweisserbse  Erbsenwickler                   13      7
#>  2 Feldbau             Eiweisserbse  Eulenraupen (blattfressend)      0      0
#>  3 Gemüsebau           Blumenkohl    Eulenraupen (blattfressend)     56     27
#>  4 Gemüsebau           Blumenkohl    Kohlschabe                      49     24
#>  5 Gemüsebau           Blumenkohl    Weisslinge                      69     30
#>  6 Gemüsebau           Broccoli      Eulenraupen (blattfressend)     56     27
#>  7 Gemüsebau           Broccoli      Kohlschabe                      49     24
#>  8 Gemüsebau           Broccoli      Weisslinge                      69     30
#>  9 Gemüsebau           Cherrytomaten Tomatenminiermotte              34     13
#> 10 Gemüsebau           Chinakohl     Eulenraupen (blattfressend)     56     27
#> # ℹ 58 more rows
#> 
#> $`Alternative uses`
#> # A tibble: 2,578 × 7
#>    application_area_de culture_de   pest_de        pNbr wNbr   use_nr type      
#>    <chr>               <chr>        <chr>         <int> <chr>   <int> <chr>     
#>  1 Feldbau             Eiweisserbse Erbsenwickler  7051 6098       52 PEST_FULL…
#>  2 Feldbau             Eiweisserbse Erbsenwickler  7051 6098-1     52 PEST_FULL…
#>  3 Feldbau             Eiweisserbse Erbsenwickler  7051 6098-2     52 PEST_FULL…
#>  4 Feldbau             Eiweisserbse Erbsenwickler  7441 6382        1 PEST_FULL…
#>  5 Feldbau             Eiweisserbse Erbsenwickler  7522 6381       16 PEST_FULL…
#>  6 Feldbau             Eiweisserbse Erbsenwickler  7522 6381-1     16 PEST_FULL…
#>  7 Feldbau             Eiweisserbse Erbsenwickler  8580 6998       27 PEST_FULL…
#>  8 Feldbau             Eiweisserbse Erbsenwickler  8711 7226        8 PEST_FULL…
#>  9 Feldbau             Eiweisserbse Erbsenwickler  9326 7410       14 PEST_FULL…
#> 10 Feldbau             Eiweisserbse Erbsenwickler  9326 7410-1     14 PEST_FULL…
#> # ℹ 2,568 more rows
#> 

# Example in Italian
actives_it <- c("Lambda-Cialotrina", "Deltametrina")
alternative_products(sr, actives_it, lang = "it", resolve_cultures = FALSE)
#> # A tibble: 527 × 5
#>    application_area_it culture_it                          pest_it n_wNbr n_pNbr
#>    <chr>               <chr>                               <chr>    <int>  <int>
#>  1 Campicoltura        Barbabietola da zucchero            Altich…      0      0
#>  2 Campicoltura        Barbabietola da zucchero            Nottue…      0      0
#>  3 Campicoltura        Barbabietole da foraggio e da zucc… Afidi        6      2
#>  4 Campicoltura        Barbabietole da foraggio e da zucc… Altich…      5      3
#>  5 Campicoltura        Barbabietole da foraggio e da zucc… Mosca …      0      0
#>  6 Campicoltura        Barbabietole da foraggio e da zucc… Nottue…      5      3
#>  7 Campicoltura        Barbabietole da foraggio e da zucc… tignol…      2      2
#>  8 Campicoltura        Cartamo                             Nottue…      5      3
#>  9 Campicoltura        Cereali                             Afidi …      0      0
#> 10 Campicoltura        Cereali                             Clorop…      5      3
#> # ℹ 517 more rows
# }
```
