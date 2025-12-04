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

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
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
#> # A tibble: 841 × 5
#>    application_area_de culture_de   pest_de                        n_wNbr n_pNbr
#>    <chr>               <chr>        <chr>                           <int>  <int>
#>  1 Beerenbau           Erdbeere     Erdbeer- oder Himbeerblütenst…      9      7
#>  2 Beerenbau           Erdbeere     Thripse                            19     17
#>  3 Beerenbau           Himbeere     Erdbeer- oder Himbeerblütenst…      5      3
#>  4 Beerenbau           Himbeere     Himbeerkäfer                        5      3
#>  5 Feldbau             Ackerbohne   Erdraupen                           4      4
#>  6 Feldbau             Eiweisserbse Erbsenblattrandkäfer                0      0
#>  7 Feldbau             Eiweisserbse Erbsenwickler                       1      1
#>  8 Feldbau             Eiweisserbse Erdraupen                           4      4
#>  9 Feldbau             Emmer        Erdraupen                           4      4
#> 10 Feldbau             Emmer        Gelbe Getreidehalmfliege            4      4
#> # ℹ 831 more rows
alternative_products(sr, actives_de, resolve_cultures = FALSE)
#> # A tibble: 527 × 5
#>    application_area_de culture_de              pest_de             n_wNbr n_pNbr
#>    <chr>               <chr>                   <chr>                <int>  <int>
#>  1 Beerenbau           Erdbeere                Erdbeer- oder Himb…      9      7
#>  2 Beerenbau           Erdbeere                Thripse                 19     17
#>  3 Beerenbau           Himbeere                Erdbeer- oder Himb…      5      3
#>  4 Beerenbau           Himbeere                Himbeerkäfer             5      3
#>  5 Feldbau             Ackerbohne              Erdraupen                4      4
#>  6 Feldbau             Eiweisserbse            Erbsenblattrandkäf…      0      0
#>  7 Feldbau             Eiweisserbse            Erbsenwickler            1      1
#>  8 Feldbau             Eiweisserbse            Erdraupen                4      4
#>  9 Feldbau             Futter- und Zuckerrüben Blattläuse (Röhren…      5      2
#> 10 Feldbau             Futter- und Zuckerrüben Erdraupen                4      4
#> # ℹ 517 more rows
alternative_products(sr, actives_de, missing = TRUE)
#> # A tibble: 165 × 3
#>    application_area_de culture_de                       pest_de                 
#>    <chr>               <chr>                            <chr>                   
#>  1 Feldbau             Eiweisserbse                     Erbsenblattrandkäfer    
#>  2 Feldbau             Zuckerrübe                       Rübenfliege             
#>  3 Feldbau             Futterrübe                       Rübenfliege             
#>  4 Feldbau             Roggen                           Virusübertragende Blatt…
#>  5 Feldbau             Winterweizen                     Virusübertragende Blatt…
#>  6 Feldbau             Emmer                            Virusübertragende Blatt…
#>  7 Feldbau             Sommerweizen                     Virusübertragende Blatt…
#>  8 Feldbau             Sommergerste                     Virusübertragende Blatt…
#>  9 Feldbau             Sommerhafer                      Virusübertragende Blatt…
#> 10 Feldbau             Lagerhallen, Mühlen, Silogebäude Vorratsschädlinge       
#> # ℹ 155 more rows
alternative_products(sr, actives_de, details = TRUE)
#> # A tibble: 13,576 × 7
#>    application_area_de culture_de pest_de                pNbr wNbr  use_nr type 
#>    <chr>               <chr>      <chr>                 <int> <chr>  <int> <chr>
#>  1 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4426 4343       5 PEST…
#>  2 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4568 4491      18 PEST…
#>  3 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020      71 PEST…
#>  4 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133      35 PEST…
#>  5 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8800 7106       7 PEST…
#>  6 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  9058 7333      15 PEST…
#>  7 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  9058 7333…     15 PEST…
#>  8 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  9058 7333…     15 PEST…
#>  9 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  9680 7609      17 PEST…
#> 10 Beerenbau           Erdbeere   Thripse                4426 4343       5 PEST…
#> # ℹ 13,566 more rows
alternative_products(sr, actives_de, list = TRUE)
#> $`No alternative`
#> # A tibble: 165 × 3
#>    application_area_de culture_de                       pest_de                 
#>    <chr>               <chr>                            <chr>                   
#>  1 Feldbau             Eiweisserbse                     Erbsenblattrandkäfer    
#>  2 Feldbau             Zuckerrübe                       Rübenfliege             
#>  3 Feldbau             Futterrübe                       Rübenfliege             
#>  4 Feldbau             Roggen                           Virusübertragende Blatt…
#>  5 Feldbau             Winterweizen                     Virusübertragende Blatt…
#>  6 Feldbau             Emmer                            Virusübertragende Blatt…
#>  7 Feldbau             Sommerweizen                     Virusübertragende Blatt…
#>  8 Feldbau             Sommergerste                     Virusübertragende Blatt…
#>  9 Feldbau             Sommerhafer                      Virusübertragende Blatt…
#> 10 Feldbau             Lagerhallen, Mühlen, Silogebäude Vorratsschädlinge       
#> # ℹ 155 more rows
#> 
#> $`Number of alternatives`
#> # A tibble: 841 × 5
#>    application_area_de culture_de   pest_de                        n_wNbr n_pNbr
#>    <chr>               <chr>        <chr>                           <int>  <int>
#>  1 Beerenbau           Erdbeere     Erdbeer- oder Himbeerblütenst…      9      7
#>  2 Beerenbau           Erdbeere     Thripse                            19     17
#>  3 Beerenbau           Himbeere     Erdbeer- oder Himbeerblütenst…      5      3
#>  4 Beerenbau           Himbeere     Himbeerkäfer                        5      3
#>  5 Feldbau             Ackerbohne   Erdraupen                           4      4
#>  6 Feldbau             Eiweisserbse Erbsenblattrandkäfer                0      0
#>  7 Feldbau             Eiweisserbse Erbsenwickler                       1      1
#>  8 Feldbau             Eiweisserbse Erdraupen                           4      4
#>  9 Feldbau             Emmer        Erdraupen                           4      4
#> 10 Feldbau             Emmer        Gelbe Getreidehalmfliege            4      4
#> # ℹ 831 more rows
#> 
#> $`Alternative uses`
#> # A tibble: 13,576 × 7
#>    application_area_de culture_de pest_de                pNbr wNbr  use_nr type 
#>    <chr>               <chr>      <chr>                 <int> <chr>  <int> <chr>
#>  1 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4426 4343       5 PEST…
#>  2 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  4568 4491      18 PEST…
#>  3 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  7036 6020      71 PEST…
#>  4 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8464 7133      35 PEST…
#>  5 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  8800 7106       7 PEST…
#>  6 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  9058 7333      15 PEST…
#>  7 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  9058 7333…     15 PEST…
#>  8 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  9058 7333…     15 PEST…
#>  9 Beerenbau           Erdbeere   Erdbeer- oder Himbee…  9680 7609      17 PEST…
#> 10 Beerenbau           Erdbeere   Thripse                4426 4343       5 PEST…
#> # ℹ 13,566 more rows
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
#> 1 Obstbau             Birne / Nashi Birnblattsauger                 33     23
#> 2 Obstbau             Kernobst      Apfelwickler                    13     13
#> 3 Obstbau             Kernobst      Eulenraupen (blattfressend)      0      0
#> 4 Obstbau             Kernobst      Frostspanner                    26     16
#> 5 Obstbau             Kernobst      Schalenwickler                  16     10
#> 
#> $`Alternative uses`
#> # A tibble: 90 × 7
#>    application_area_de culture_de    pest_de          pNbr wNbr   use_nr type   
#>    <chr>               <chr>         <chr>           <int> <chr>   <int> <chr>  
#>  1 Obstbau             Birne / Nashi Birnblattsauger  7051 6098        6 PEST_F…
#>  2 Obstbau             Birne / Nashi Birnblattsauger  7051 6098-1      6 PEST_F…
#>  3 Obstbau             Birne / Nashi Birnblattsauger  7169 6148        1 PEST_P…
#>  4 Obstbau             Birne / Nashi Birnblattsauger  7291 6107        4 PEST_F…
#>  5 Obstbau             Birne / Nashi Birnblattsauger  7291 6107-1      4 PEST_F…
#>  6 Obstbau             Birne / Nashi Birnblattsauger  7291 6107-2      4 PEST_F…
#>  7 Obstbau             Birne / Nashi Birnblattsauger  7291 6107-3      4 PEST_F…
#>  8 Obstbau             Birne / Nashi Birnblattsauger  7441 6382       10 PEST_F…
#>  9 Obstbau             Birne / Nashi Birnblattsauger  7511 6432        2 PEST_F…
#> 10 Obstbau             Birne / Nashi Birnblattsauger  7511 6432-1      2 PEST_F…
#> # ℹ 80 more rows
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
#>  1 Obstbau             Apfel      Apfelwickler                    19     19
#>  2 Obstbau             Apfel      Eulenraupen (blattfressend)      0      0
#>  3 Obstbau             Apfel      Frostspanner                    28     18
#>  4 Obstbau             Apfel      Schalenwickler                  18     12
#>  5 Obstbau             Birne      Apfelwickler                    18     18
#>  6 Obstbau             Birne      Birnblattsauger                 34     24
#>  7 Obstbau             Birne      Eulenraupen (blattfressend)      0      0
#>  8 Obstbau             Birne      Frostspanner                    28     18
#>  9 Obstbau             Birne      Schalenwickler                  18     12
#> 10 Obstbau             Quitte     Apfelwickler                    14     14
#> 11 Obstbau             Quitte     Eulenraupen (blattfressend)      0      0
#> 12 Obstbau             Quitte     Frostspanner                    26     16
#> 13 Obstbau             Quitte     Schalenwickler                  16     10
#> 
#> $`Alternative uses`
#> # A tibble: 228 × 7
#>    application_area_de culture_de pest_de          pNbr wNbr   use_nr type      
#>    <chr>               <chr>      <chr>           <int> <chr>   <int> <chr>     
#>  1 Obstbau             Birne      Birnblattsauger  7051 6098        6 PEST_FULL…
#>  2 Obstbau             Birne      Birnblattsauger  7051 6098-1      6 PEST_FULL…
#>  3 Obstbau             Birne      Birnblattsauger  7169 6148        1 PEST_PART…
#>  4 Obstbau             Birne      Birnblattsauger  7291 6107        4 PEST_FULL…
#>  5 Obstbau             Birne      Birnblattsauger  7291 6107-1      4 PEST_FULL…
#>  6 Obstbau             Birne      Birnblattsauger  7291 6107-2      4 PEST_FULL…
#>  7 Obstbau             Birne      Birnblattsauger  7291 6107-3      4 PEST_FULL…
#>  8 Obstbau             Birne      Birnblattsauger  7441 6382       10 PEST_FULL…
#>  9 Obstbau             Birne      Birnblattsauger  7511 6432        2 PEST_FULL…
#> 10 Obstbau             Birne      Birnblattsauger  7511 6432-1      2 PEST_FULL…
#> # ℹ 218 more rows
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
#> # A tibble: 1 × 5
#>   application_area_de culture_de pest_de        n_wNbr n_pNbr
#>   <chr>               <chr>      <chr>           <int>  <int>
#> 1 Obstbau             NA         Schalenwickler      1      1
#> 
#> $`Alternative uses`
#> # A tibble: 1 × 7
#>   application_area_de culture_de pest_de         pNbr wNbr  use_nr type         
#>   <chr>               <chr>      <chr>          <int> <chr>  <int> <chr>        
#> 1 Obstbau             NA         Schalenwickler  7545 6362       1 PEST_FULL_EF…
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
#>  1 Feldbau             Eiweisserbse Erbsenwickler                   10      7
#>  2 Feldbau             Eiweisserbse Eulenraupen (blattfressend)      0      0
#>  3 Gemüsebau           Blattkohle   Eulenraupen (blattfressend)      0      0
#>  4 Gemüsebau           Blattkohle   Kohlschabe                       0      0
#>  5 Gemüsebau           Blattkohle   Weisslinge                       0      0
#>  6 Gemüsebau           Blumenkohle  Eulenraupen (blattfressend)      7      6
#>  7 Gemüsebau           Blumenkohle  Kohlschabe                       7      6
#>  8 Gemüsebau           Blumenkohle  Weisslinge                       7      6
#>  9 Gemüsebau           Kopfkohle    Eulenraupen (blattfressend)      8      7
#> 10 Gemüsebau           Kopfkohle    Kohlschabe                       8      7
#> # ℹ 20 more rows
#> 
#> $`Alternative uses`
#> # A tibble: 214 × 7
#>    application_area_de culture_de   pest_de        pNbr wNbr   use_nr type      
#>    <chr>               <chr>        <chr>         <int> <chr>   <int> <chr>     
#>  1 Feldbau             Eiweisserbse Erbsenwickler  7051 6098       13 PEST_FULL…
#>  2 Feldbau             Eiweisserbse Erbsenwickler  7051 6098-1     13 PEST_FULL…
#>  3 Feldbau             Eiweisserbse Erbsenwickler  7441 6382        1 PEST_FULL…
#>  4 Feldbau             Eiweisserbse Erbsenwickler  7522 6381       16 PEST_FULL…
#>  5 Feldbau             Eiweisserbse Erbsenwickler  8580 6998       28 PEST_FULL…
#>  6 Feldbau             Eiweisserbse Erbsenwickler  8711 7226        8 PEST_FULL…
#>  7 Feldbau             Eiweisserbse Erbsenwickler  9326 7410       14 PEST_FULL…
#>  8 Feldbau             Eiweisserbse Erbsenwickler  9326 7410-2     14 PEST_FULL…
#>  9 Feldbau             Eiweisserbse Erbsenwickler  9326 7410-3     14 PEST_FULL…
#> 10 Feldbau             Eiweisserbse Erbsenwickler  9382 7465        7 PEST_FULL…
#> # ℹ 204 more rows
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
#> # A tibble: 65 × 5
#>    application_area_de culture_de    pest_de                     n_wNbr n_pNbr
#>    <chr>               <chr>         <chr>                        <int>  <int>
#>  1 Feldbau             Eiweisserbse  Erbsenwickler                   10      7
#>  2 Feldbau             Eiweisserbse  Eulenraupen (blattfressend)      0      0
#>  3 Gemüsebau           Blumenkohl    Eulenraupen (blattfressend)     38     27
#>  4 Gemüsebau           Blumenkohl    Kohlschabe                      33     24
#>  5 Gemüsebau           Blumenkohl    Weisslinge                      45     30
#>  6 Gemüsebau           Broccoli      Eulenraupen (blattfressend)     38     27
#>  7 Gemüsebau           Broccoli      Kohlschabe                      33     24
#>  8 Gemüsebau           Broccoli      Weisslinge                      45     30
#>  9 Gemüsebau           Cherrytomaten Tomatenminiermotte              20     12
#> 10 Gemüsebau           Chinakohl     Eulenraupen (blattfressend)     38     27
#> # ℹ 55 more rows
#> 
#> $`Alternative uses`
#> # A tibble: 1,510 × 7
#>    application_area_de culture_de   pest_de        pNbr wNbr   use_nr type      
#>    <chr>               <chr>        <chr>         <int> <chr>   <int> <chr>     
#>  1 Feldbau             Eiweisserbse Erbsenwickler  7051 6098       13 PEST_FULL…
#>  2 Feldbau             Eiweisserbse Erbsenwickler  7051 6098-1     13 PEST_FULL…
#>  3 Feldbau             Eiweisserbse Erbsenwickler  7441 6382        1 PEST_FULL…
#>  4 Feldbau             Eiweisserbse Erbsenwickler  7522 6381       16 PEST_FULL…
#>  5 Feldbau             Eiweisserbse Erbsenwickler  8580 6998       28 PEST_FULL…
#>  6 Feldbau             Eiweisserbse Erbsenwickler  8711 7226        8 PEST_FULL…
#>  7 Feldbau             Eiweisserbse Erbsenwickler  9326 7410       14 PEST_FULL…
#>  8 Feldbau             Eiweisserbse Erbsenwickler  9326 7410-2     14 PEST_FULL…
#>  9 Feldbau             Eiweisserbse Erbsenwickler  9326 7410-3     14 PEST_FULL…
#> 10 Feldbau             Eiweisserbse Erbsenwickler  9382 7465        7 PEST_FULL…
#> # ℹ 1,500 more rows
#> 

# Example in Italian
actives_it <- c("Lambda-Cialotrina", "Deltametrina")
alternative_products(sr, actives_it, lang = "it", resolve_cultures = FALSE)
#> # A tibble: 527 × 5
#>    application_area_it culture_it                          pest_it n_wNbr n_pNbr
#>    <chr>               <chr>                               <chr>    <int>  <int>
#>  1 Campicoltura        Barbabietola da zucchero            Altich…      0      0
#>  2 Campicoltura        Barbabietola da zucchero            Nottue…      0      0
#>  3 Campicoltura        Barbabietole da foraggio e da zucc… Afidi        5      2
#>  4 Campicoltura        Barbabietole da foraggio e da zucc… Altich…      4      4
#>  5 Campicoltura        Barbabietole da foraggio e da zucc… Mosca …      0      0
#>  6 Campicoltura        Barbabietole da foraggio e da zucc… Nottue…      4      4
#>  7 Campicoltura        Barbabietole da foraggio e da zucc… tignol…      2      2
#>  8 Campicoltura        Cartamo                             Nottue…      4      4
#>  9 Campicoltura        Cereali                             Afidi …      0      0
#> 10 Campicoltura        Cereali                             Clorop…      4      4
#> # ℹ 517 more rows
# }
```
