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
#> Error in read_html(base_url) : could not find function "read_html"

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
#> # A tibble: 924 × 5
#>    application_area_de culture_de   pest_de                        n_wNbr n_pNbr
#>    <chr>               <chr>        <chr>                           <int>  <int>
#>  1 Beerenbau           Erdbeere     Erdbeer- oder Himbeerblütenst…     18      7
#>  2 Beerenbau           Erdbeere     Thripse                            38     21
#>  3 Beerenbau           Himbeere     Erdbeer- oder Himbeerblütenst…     12      3
#>  4 Beerenbau           Himbeere     Himbeerkäfer                       12      3
#>  5 Feldbau             Ackerbohne   Erdraupen                           6      4
#>  6 Feldbau             Eiweisserbse Erbsenblattrandkäfer                0      0
#>  7 Feldbau             Eiweisserbse Erbsenwickler                       4      1
#>  8 Feldbau             Eiweisserbse Erdraupen                           6      4
#>  9 Feldbau             Emmer        Erdraupen                           6      4
#> 10 Feldbau             Emmer        Gelbe Getreidehalmfliege            6      4
#> # ℹ 914 more rows
alternative_products(sr, actives_de, resolve_cultures = FALSE)
#> # A tibble: 484 × 5
#>    application_area_de culture_de              pest_de             n_wNbr n_pNbr
#>    <chr>               <chr>                   <chr>                <int>  <int>
#>  1 Beerenbau           Erdbeere                Erdbeer- oder Himb…     18      7
#>  2 Beerenbau           Erdbeere                Thripse                 33     16
#>  3 Beerenbau           Himbeere                Erdbeer- oder Himb…     12      3
#>  4 Beerenbau           Himbeere                Himbeerkäfer            12      3
#>  5 Feldbau             Ackerbohne              Erdraupen                6      4
#>  6 Feldbau             Eiweisserbse            Erbsenblattrandkäf…      0      0
#>  7 Feldbau             Eiweisserbse            Erbsenwickler            4      1
#>  8 Feldbau             Eiweisserbse            Erdraupen                6      4
#>  9 Feldbau             Futter- und Zuckerrüben Blattläuse (Röhren…      6      2
#> 10 Feldbau             Futter- und Zuckerrüben Erdraupen                6      4
#> # ℹ 474 more rows
alternative_products(sr, actives_de, missing = TRUE)
#> # A tibble: 110 × 3
#>    application_area_de culture_de                       pest_de              
#>    <chr>               <chr>                            <chr>                
#>  1 Feldbau             Eiweisserbse                     Erbsenblattrandkäfer 
#>  2 Feldbau             Futterrübe                       Rübenfliege          
#>  3 Feldbau             Zuckerrübe                       Rübenfliege          
#>  4 Feldbau             Lagerhallen, Mühlen, Silogebäude Vorratsschädlinge    
#>  5 Feldbau             Mais                             Fritfliege           
#>  6 Feldbau             Sojabohne                        Distelfalter         
#>  7 Gemüsebau           Asia-Salate (Brassicaceae)       Kohldrehherzgallmücke
#>  8 Gemüsebau           Asia-Salate (Brassicaceae)       Kohlschabe           
#>  9 Gemüsebau           Baby-Leaf (Asteraceae)           Minierfliegen        
#> 10 Gemüsebau           Baby-Leaf (Brassicaceae)         Kohldrehherzgallmücke
#> # ℹ 100 more rows
alternative_products(sr, actives_de, details = TRUE)
#> # A tibble: 37,713 × 7
#>    application_area_de culture_de pest_de                pNbr wNbr  use_nr type 
#>    <chr>               <chr>      <chr>                 <int> <chr>  <int> <chr>
#>  1 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4426 4343      17 PEST…
#>  2 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4568 4491      12 PEST…
#>  3 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4568 4491…     12 PEST…
#>  4 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020      37 PEST…
#>  5 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020…     37 PEST…
#>  6 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020…     37 PEST…
#>  7 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133       7 PEST…
#>  8 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133…      7 PEST…
#>  9 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133…      7 PEST…
#> 10 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133…      7 PEST…
#> # ℹ 37,703 more rows
alternative_products(sr, actives_de, list = TRUE)
#> $`No alternative`
#> # A tibble: 110 × 3
#>    application_area_de culture_de                       pest_de              
#>    <chr>               <chr>                            <chr>                
#>  1 Feldbau             Eiweisserbse                     Erbsenblattrandkäfer 
#>  2 Feldbau             Futterrübe                       Rübenfliege          
#>  3 Feldbau             Zuckerrübe                       Rübenfliege          
#>  4 Feldbau             Lagerhallen, Mühlen, Silogebäude Vorratsschädlinge    
#>  5 Feldbau             Mais                             Fritfliege           
#>  6 Feldbau             Sojabohne                        Distelfalter         
#>  7 Gemüsebau           Asia-Salate (Brassicaceae)       Kohldrehherzgallmücke
#>  8 Gemüsebau           Asia-Salate (Brassicaceae)       Kohlschabe           
#>  9 Gemüsebau           Baby-Leaf (Asteraceae)           Minierfliegen        
#> 10 Gemüsebau           Baby-Leaf (Brassicaceae)         Kohldrehherzgallmücke
#> # ℹ 100 more rows
#> 
#> $`Number of alternatives`
#> # A tibble: 924 × 5
#>    application_area_de culture_de   pest_de                        n_wNbr n_pNbr
#>    <chr>               <chr>        <chr>                           <int>  <int>
#>  1 Beerenbau           Erdbeere     Erdbeer- oder Himbeerblütenst…     18      7
#>  2 Beerenbau           Erdbeere     Thripse                            38     21
#>  3 Beerenbau           Himbeere     Erdbeer- oder Himbeerblütenst…     12      3
#>  4 Beerenbau           Himbeere     Himbeerkäfer                       12      3
#>  5 Feldbau             Ackerbohne   Erdraupen                           6      4
#>  6 Feldbau             Eiweisserbse Erbsenblattrandkäfer                0      0
#>  7 Feldbau             Eiweisserbse Erbsenwickler                       4      1
#>  8 Feldbau             Eiweisserbse Erdraupen                           6      4
#>  9 Feldbau             Emmer        Erdraupen                           6      4
#> 10 Feldbau             Emmer        Gelbe Getreidehalmfliege            6      4
#> # ℹ 914 more rows
#> 
#> $`Alternative uses`
#> # A tibble: 37,713 × 7
#>    application_area_de culture_de pest_de                pNbr wNbr  use_nr type 
#>    <chr>               <chr>      <chr>                 <int> <chr>  <int> <chr>
#>  1 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4426 4343      17 PEST…
#>  2 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4568 4491      12 PEST…
#>  3 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4568 4491…     12 PEST…
#>  4 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020      37 PEST…
#>  5 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020…     37 PEST…
#>  6 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020…     37 PEST…
#>  7 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133       7 PEST…
#>  8 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133…      7 PEST…
#>  9 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133…      7 PEST…
#> 10 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133…      7 PEST…
#> # ℹ 37,703 more rows
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
#> 1 Obstbau             Birne / Nashi Birnblattsauger                 35     22
#> 2 Obstbau             Kernobst      Apfelwickler                    15     12
#> 3 Obstbau             Kernobst      Eulenraupen (blattfressend)      0      0
#> 4 Obstbau             Kernobst      Frostspanner                    36     16
#> 5 Obstbau             Kernobst      Schalenwickler                  16      9
#> 
#> $`Alternative uses`
#> # A tibble: 107 × 7
#>    application_area_de culture_de    pest_de          pNbr wNbr   use_nr type   
#>    <chr>               <chr>         <chr>           <int> <chr>   <int> <chr>  
#>  1 Obstbau             Birne / Nashi Birnblattsauger  7051 6098       16 PEST_F…
#>  2 Obstbau             Birne / Nashi Birnblattsauger  7051 6098-1     16 PEST_F…
#>  3 Obstbau             Birne / Nashi Birnblattsauger  7051 6098-2     16 PEST_F…
#>  4 Obstbau             Birne / Nashi Birnblattsauger  7169 6148        1 PEST_P…
#>  5 Obstbau             Birne / Nashi Birnblattsauger  7291 6107        1 PEST_F…
#>  6 Obstbau             Birne / Nashi Birnblattsauger  7291 6107-1      1 PEST_F…
#>  7 Obstbau             Birne / Nashi Birnblattsauger  7291 6107-2      1 PEST_F…
#>  8 Obstbau             Birne / Nashi Birnblattsauger  7441 6382        5 PEST_F…
#>  9 Obstbau             Birne / Nashi Birnblattsauger  7511 6432       22 PEST_F…
#> 10 Obstbau             Birne / Nashi Birnblattsauger  7511 6432-1     22 PEST_F…
#> # ℹ 97 more rows
#> 
alternative_products(sr, actives_de, resolve_cultures = TRUE, list = TRUE)
#> $`No alternative`
#> # A tibble: 3 × 3
#>   application_area_de culture_de pest_de                    
#>   <chr>               <chr>      <chr>                      
#> 1 Obstbau             Apfel      Eulenraupen (blattfressend)
#> 2 Obstbau             Quitte     Eulenraupen (blattfressend)
#> 3 Obstbau             Birne      Eulenraupen (blattfressend)
#> 
#> $`Number of alternatives`
#> # A tibble: 13 × 5
#>    application_area_de culture_de pest_de                     n_wNbr n_pNbr
#>    <chr>               <chr>      <chr>                        <int>  <int>
#>  1 Obstbau             Apfel      Apfelwickler                    39     26
#>  2 Obstbau             Apfel      Eulenraupen (blattfressend)      0      0
#>  3 Obstbau             Apfel      Frostspanner                    60     26
#>  4 Obstbau             Apfel      Schalenwickler                  25     13
#>  5 Obstbau             Birne      Apfelwickler                    38     25
#>  6 Obstbau             Birne      Birnblattsauger                 36     23
#>  7 Obstbau             Birne      Eulenraupen (blattfressend)      0      0
#>  8 Obstbau             Birne      Frostspanner                    60     26
#>  9 Obstbau             Birne      Schalenwickler                  25     13
#> 10 Obstbau             Quitte     Apfelwickler                    29     21
#> 11 Obstbau             Quitte     Eulenraupen (blattfressend)      0      0
#> 12 Obstbau             Quitte     Frostspanner                    53     24
#> 13 Obstbau             Quitte     Schalenwickler                  18     11
#> 
#> $`Alternative uses`
#> # A tibble: 405 × 7
#>    application_area_de culture_de pest_de          pNbr wNbr   use_nr type      
#>    <chr>               <chr>      <chr>           <int> <chr>   <int> <chr>     
#>  1 Obstbau             Birne      Birnblattsauger  7051 6098       16 PEST_FULL…
#>  2 Obstbau             Birne      Birnblattsauger  7051 6098-1     16 PEST_FULL…
#>  3 Obstbau             Birne      Birnblattsauger  7051 6098-2     16 PEST_FULL…
#>  4 Obstbau             Birne      Birnblattsauger  7169 6148        1 PEST_PART…
#>  5 Obstbau             Birne      Birnblattsauger  7291 6107        1 PEST_FULL…
#>  6 Obstbau             Birne      Birnblattsauger  7291 6107-1      1 PEST_FULL…
#>  7 Obstbau             Birne      Birnblattsauger  7291 6107-2      1 PEST_FULL…
#>  8 Obstbau             Birne      Birnblattsauger  7441 6382        5 PEST_FULL…
#>  9 Obstbau             Birne      Birnblattsauger  7511 6432       22 PEST_FULL…
#> 10 Obstbau             Birne      Birnblattsauger  7511 6432-1     22 PEST_FULL…
#> # ℹ 395 more rows
#> 

actives_de <- c("Schalenwicklergranulose-Virus")
alternative_products(sr, actives_de, resolve_cultures = FALSE, list = TRUE)
#> $`No alternative`
#> # A tibble: 0 × 3
#> # ℹ 3 variables: application_area_de <chr>, culture_de <chr>, pest_de <chr>
#> 
#> $`Number of alternatives`
#> # A tibble: 1 × 5
#>   application_area_de culture_de    pest_de        n_wNbr n_pNbr
#>   <chr>               <chr>         <chr>           <int>  <int>
#> 1 Obstbau             Obstbau allg. Schalenwickler      1      1
#> 
#> $`Alternative uses`
#> # A tibble: 1 × 7
#>   application_area_de culture_de    pest_de         pNbr wNbr  use_nr type      
#>   <chr>               <chr>         <chr>          <int> <chr>  <int> <chr>     
#> 1 Obstbau             Obstbau allg. Schalenwickler  7545 6362       1 PEST_FULL…
#> 
alternative_products(sr, actives_de, resolve_cultures = TRUE, list = TRUE)
#> $`No alternative`
#> # A tibble: 0 × 3
#> # ℹ 3 variables: application_area_de <chr>, culture_de <chr>, pest_de <chr>
#> 
#> $`Number of alternatives`
#> # A tibble: 10 × 5
#>    application_area_de culture_de           pest_de        n_wNbr n_pNbr
#>    <chr>               <chr>                <chr>           <int>  <int>
#>  1 Obstbau             Apfel                Schalenwickler     25     13
#>  2 Obstbau             Aprikose             Schalenwickler     13      9
#>  3 Obstbau             Birne                Schalenwickler     25     13
#>  4 Obstbau             Kirsche              Schalenwickler     20     11
#>  5 Obstbau             Olive                Schalenwickler      1      1
#>  6 Obstbau             Pfirsich / Nektarine Schalenwickler     13      9
#>  7 Obstbau             Pflaume              Schalenwickler     20     11
#>  8 Obstbau             Quitte               Schalenwickler     18     11
#>  9 Obstbau             Walnuss              Schalenwickler      3      3
#> 10 Obstbau             Zwetschge            Schalenwickler     20     11
#> 
#> $`Alternative uses`
#> # A tibble: 179 × 7
#>    application_area_de culture_de pest_de         pNbr wNbr   use_nr type       
#>    <chr>               <chr>      <chr>          <int> <chr>   <int> <chr>      
#>  1 Obstbau             Olive      Schalenwickler  7545 6362        1 PEST_FULL_…
#>  2 Obstbau             Apfel      Schalenwickler  7036 6020       57 PEST_FULL_…
#>  3 Obstbau             Apfel      Schalenwickler  7036 6020       58 PEST_FULL_…
#>  4 Obstbau             Apfel      Schalenwickler  7036 6020-1     57 PEST_FULL_…
#>  5 Obstbau             Apfel      Schalenwickler  7036 6020-1     58 PEST_FULL_…
#>  6 Obstbau             Apfel      Schalenwickler  7036 6020-2     57 PEST_FULL_…
#>  7 Obstbau             Apfel      Schalenwickler  7036 6020-2     58 PEST_FULL_…
#>  8 Obstbau             Apfel      Schalenwickler  7074 6144        2 PEST_FULL_…
#>  9 Obstbau             Apfel      Schalenwickler  7545 6362        1 PEST_FULL_…
#> 10 Obstbau             Apfel      Schalenwickler  7808 6748        1 PEST_FULL_…
#> # ℹ 169 more rows
#> 

actives_de <- c("Emamectinbenzoat")
alternative_products(sr, actives_de, resolve_cultures = FALSE, list = TRUE)
#> $`No alternative`
#> # A tibble: 4 × 3
#>   application_area_de culture_de           pest_de                    
#>   <chr>               <chr>                <chr>                      
#> 1 Feldbau             Eiweisserbse         Eulenraupen (blattfressend)
#> 2 Obstbau             Aprikose             Pfirsichmotte              
#> 3 Obstbau             Aprikose             Pfirsichwickler            
#> 4 Obstbau             Pfirsich / Nektarine Pfirsichmotte              
#> 
#> $`Number of alternatives`
#> # A tibble: 30 × 5
#>    application_area_de culture_de   pest_de                     n_wNbr n_pNbr
#>    <chr>               <chr>        <chr>                        <int>  <int>
#>  1 Feldbau             Eiweisserbse Erbsenwickler                   13      7
#>  2 Feldbau             Eiweisserbse Eulenraupen (blattfressend)      0      0
#>  3 Gemüsebau           Blattkohle   Eulenraupen (blattfressend)      8      6
#>  4 Gemüsebau           Blattkohle   Kohlschabe                       8      6
#>  5 Gemüsebau           Blattkohle   Weisslinge                       8      6
#>  6 Gemüsebau           Blumenkohle  Eulenraupen (blattfressend)      8      6
#>  7 Gemüsebau           Blumenkohle  Kohlschabe                       8      6
#>  8 Gemüsebau           Blumenkohle  Weisslinge                       8      6
#>  9 Gemüsebau           Kopfkohle    Eulenraupen (blattfressend)     11      8
#> 10 Gemüsebau           Kopfkohle    Kohlschabe                      11      8
#> # ℹ 20 more rows
#> 
#> $`Alternative uses`
#> # A tibble: 293 × 7
#>    application_area_de culture_de   pest_de        pNbr wNbr   use_nr type      
#>    <chr>               <chr>        <chr>         <int> <chr>   <int> <chr>     
#>  1 Feldbau             Eiweisserbse Erbsenwickler  7051 6098       42 PEST_FULL…
#>  2 Feldbau             Eiweisserbse Erbsenwickler  7051 6098-1     42 PEST_FULL…
#>  3 Feldbau             Eiweisserbse Erbsenwickler  7051 6098-2     42 PEST_FULL…
#>  4 Feldbau             Eiweisserbse Erbsenwickler  7441 6382       36 PEST_FULL…
#>  5 Feldbau             Eiweisserbse Erbsenwickler  7522 6381       13 PEST_FULL…
#>  6 Feldbau             Eiweisserbse Erbsenwickler  7522 6381-1     13 PEST_FULL…
#>  7 Feldbau             Eiweisserbse Erbsenwickler  8580 6998       30 PEST_FULL…
#>  8 Feldbau             Eiweisserbse Erbsenwickler  8711 7226        1 PEST_FULL…
#>  9 Feldbau             Eiweisserbse Erbsenwickler  9326 7410        1 PEST_FULL…
#> 10 Feldbau             Eiweisserbse Erbsenwickler  9326 7410-1      1 PEST_FULL…
#> # ℹ 283 more rows
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
#> # A tibble: 66 × 5
#>    application_area_de culture_de    pest_de                     n_wNbr n_pNbr
#>    <chr>               <chr>         <chr>                        <int>  <int>
#>  1 Feldbau             Eiweisserbse  Erbsenwickler                   13      7
#>  2 Feldbau             Eiweisserbse  Eulenraupen (blattfressend)      0      0
#>  3 Gemüsebau           Blumenkohl    Eulenraupen (blattfressend)     56     28
#>  4 Gemüsebau           Blumenkohl    Kohlschabe                      49     24
#>  5 Gemüsebau           Blumenkohl    Weisslinge                      69     30
#>  6 Gemüsebau           Broccoli      Eulenraupen (blattfressend)     56     28
#>  7 Gemüsebau           Broccoli      Kohlschabe                      49     24
#>  8 Gemüsebau           Broccoli      Weisslinge                      69     30
#>  9 Gemüsebau           Cherrytomaten Tomatenminiermotte              24     11
#> 10 Gemüsebau           Chinakohl     Eulenraupen (blattfressend)     56     28
#> # ℹ 56 more rows
#> 
#> $`Alternative uses`
#> # A tibble: 2,486 × 7
#>    application_area_de culture_de   pest_de        pNbr wNbr   use_nr type      
#>    <chr>               <chr>        <chr>         <int> <chr>   <int> <chr>     
#>  1 Feldbau             Eiweisserbse Erbsenwickler  7051 6098       42 PEST_FULL…
#>  2 Feldbau             Eiweisserbse Erbsenwickler  7051 6098-1     42 PEST_FULL…
#>  3 Feldbau             Eiweisserbse Erbsenwickler  7051 6098-2     42 PEST_FULL…
#>  4 Feldbau             Eiweisserbse Erbsenwickler  7441 6382       36 PEST_FULL…
#>  5 Feldbau             Eiweisserbse Erbsenwickler  7522 6381       13 PEST_FULL…
#>  6 Feldbau             Eiweisserbse Erbsenwickler  7522 6381-1     13 PEST_FULL…
#>  7 Feldbau             Eiweisserbse Erbsenwickler  8580 6998       30 PEST_FULL…
#>  8 Feldbau             Eiweisserbse Erbsenwickler  8711 7226        1 PEST_FULL…
#>  9 Feldbau             Eiweisserbse Erbsenwickler  9326 7410        1 PEST_FULL…
#> 10 Feldbau             Eiweisserbse Erbsenwickler  9326 7410-1      1 PEST_FULL…
#> # ℹ 2,476 more rows
#> 

# Example in Italian
actives_it <- c("Lambda-Cialotrina", "Deltametrina")
alternative_products(sr, actives_it, lang = "it", resolve_cultures = FALSE)
#> # A tibble: 484 × 5
#>    application_area_it culture_it                          pest_it n_wNbr n_pNbr
#>    <chr>               <chr>                               <chr>    <int>  <int>
#>  1 Campicoltura        Barbabietola da zucchero            Altich…      0      0
#>  2 Campicoltura        Barbabietola da zucchero            Nottue…      0      0
#>  3 Campicoltura        Barbabietole da foraggio e da zucc… Afidi        6      2
#>  4 Campicoltura        Barbabietole da foraggio e da zucc… Altich…      6      4
#>  5 Campicoltura        Barbabietole da foraggio e da zucc… Mosca …      0      0
#>  6 Campicoltura        Barbabietole da foraggio e da zucc… Nottue…      6      4
#>  7 Campicoltura        Barbabietole da foraggio e da zucc… tignol…      2      2
#>  8 Campicoltura        Cartamo                             Nottue…      6      4
#>  9 Campicoltura        Cereali                             Afidi …      0      0
#> 10 Campicoltura        Cereali                             Clorop…      6      4
#> # ℹ 474 more rows
# }
```
