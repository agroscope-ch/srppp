# Statistics on products containing microorganisms in the latest XML dump of the SRPPP

``` r
knitr::opts_chunk$set(tidy = FALSE, cache = FALSE)
options(knitr.kable.NA = '')
library(srppp)
library(dplyr)
library(knitr)
```

``` r
srppp <- try(srppp_dm(srppp_xml_url))

# Fall back to using the file distributed with the package
if (inherits(srppp, "try-error")) {
  test_data <- system.file("testdata/Daten_Pflanzenschutzmittelverzeichnis_2024-12-16.zip",
  package = "srppp")
  test_xml <- srppp_xml_get_from_path(test_data, from = "2024-12-16")
  srppp <- srppp_dm(test_xml)
}
```

## Products in microorganism categories

The following list was used to identify product categories containing
microorganisms.

``` r
srppp$categories |>
  group_by(category_de) |>
  summarise(n = n()) |>
  kable()
```

| category_de                             |   n |
|:----------------------------------------|----:|
| Akarizid                                | 120 |
| Andere                                  |   1 |
| Bakterizid                              |  25 |
| Desinfektionsmittel                     |   3 |
| Fungizid                                | 269 |
| Herbizid                                | 322 |
| Insektizid                              | 154 |
| Lebende Organismen (Bakterien)          |   2 |
| Lebende Organismen (Insekten)           | 115 |
| Lebende Organismen (Insektenviren)      |  11 |
| Lebende Organismen (Milben)             |  30 |
| Lebende Organismen (Nematoden)          |  23 |
| Lebende Organismen (Pilze)              |  14 |
| Lebende Organismen (gegen Pilze)        |   7 |
| Mittel zum Schutz von Erntegütern       |   5 |
| Molluskizid                             |  31 |
| Nematizid                               |   2 |
| Pheromon                                |  31 |
| Phytoregulator                          |  72 |
| Rodentizid                              |   8 |
| Saatbeizmittel                          |  27 |
| Stimulator der natürlichen Abwehrkräfte |   5 |
| Virizid                                 |   1 |
| Vorratsschutzmittel                     |  19 |
| Wildabhaltemittel                       |   5 |
| Wundverschlussmittel                    |   1 |
| Zusatzstoffe                            |  35 |

The resulting product categories containing microorganisms were defined
as follows:

``` r
microorganism_categories = c(
  "Lebende Organismen (Bakterien)",
  "Lebende Organismen (Pilze)",
  "Lebende Organismen (gegen Pilze)")
kable(data.frame(Category = microorganism_categories))
```

| Category                         |
|:---------------------------------|
| Lebende Organismen (Bakterien)   |
| Lebende Organismen (Pilze)       |
| Lebende Organismen (gegen Pilze) |

The corresponding products are shown below.

``` r
products_in_microorganism_categories <- srppp$products |>
  filter(!isSalePermission) |>
  left_join(srppp$categories, by = "pNbr") |>
  filter(category_de %in% microorganism_categories) |>
  select(pNbr, wNbr, name, category_de) |>
  arrange(pNbr)
n_in_categories <- nrow(products_in_microorganism_categories)
kable(products_in_microorganism_categories)
```

| pNbr | wNbr | name                         | category_de                      |
|-----:|:-----|:-----------------------------|:---------------------------------|
| 4594 | 4574 | Beauveria-Schweizer          | Lebende Organismen (Pilze)       |
| 7650 | 6423 | Metarhizium Schweizer        | Lebende Organismen (Pilze)       |
| 8025 | 6919 | Botector                     | Lebende Organismen (gegen Pilze) |
| 8029 | 6881 | BioAct WG                    | Lebende Organismen (Pilze)       |
| 8119 | 6872 | Prestop                      | Lebende Organismen (gegen Pilze) |
| 8258 | 7151 | Amylo-X                      | Lebende Organismen (gegen Pilze) |
| 8309 | 6847 | Lalstop K61 WP               | Lebende Organismen (gegen Pilze) |
| 8374 | 6912 | Deposan                      | Lebende Organismen (Bakterien)   |
| 8926 | 7580 | Wormox                       | Lebende Organismen (Bakterien)   |
| 8946 | 7504 | Taegro                       | Lebende Organismen (gegen Pilze) |
| 9014 | 7259 | AQ 10                        | Lebende Organismen (Pilze)       |
| 9049 | 7316 | Naturalis-L                  | Lebende Organismen (Pilze)       |
| 9052 | 7324 | Rotstop                      | Lebende Organismen (gegen Pilze) |
| 9173 | 7378 | Beauveria-Maschinenring      | Lebende Organismen (Pilze)       |
| 9174 | 7379 | Metarhizium-Maschinenring    | Lebende Organismen (Pilze)       |
| 9384 | 7528 | Beauveria FL-Maschinenring   | Lebende Organismen (Pilze)       |
| 9385 | 7529 | Metarhizium FL-Maschinenring | Lebende Organismen (Pilze)       |
| 9389 | 7477 | Melocont GR                  | Lebende Organismen (Pilze)       |
| 9390 | 7478 | GranMet GR                   | Lebende Organismen (Pilze)       |
| 9479 | 7498 | Lalstop Contans WG           | Lebende Organismen (gegen Pilze) |
| 9481 | 7500 | Lalguard M52 GR              | Lebende Organismen (Pilze)       |
| 9698 | 7632 | Metapro                      | Lebende Organismen (Pilze)       |
| 9699 | 7633 | Beaupro                      | Lebende Organismen (Pilze)       |

## Insecticides and fungicides containing microorganisms

The following lists of active substances in insecticides and fungicides
were used to establish filter criteria active substances that are
microorganisms.

``` r
srppp$products |>
  filter(!isSalePermission) |>
  left_join(srppp$categories, by = "pNbr") |>
  filter(category_de == "Insektizid") |>
  left_join(srppp$ingredients, by = "pNbr", relationship = "many-to-many") |>
  left_join(srppp$substances, by = "pk") |>
  select(substance_de) |>
  unique() |>
  arrange(substance_de) |>
  kable()
```

| substance_de                                                                 |
|:-----------------------------------------------------------------------------|
| 1,2-Benzisothiazol-3(2H)-on                                                  |
| 1,2-benzisothiazol-3(2H)-one; 1,2-benzisothiazolin-3-one                     |
| 3,6-Dimethyl-4-octin-3,6-diol                                                |
| Abamectin                                                                    |
| Acequinocyl                                                                  |
| Acetamiprid                                                                  |
| Alcohols, C12-15, ethoxylated                                                |
| Alkane C9-C12-Iso                                                            |
| Aluminiumphosphid                                                            |
| Anastatus bifasciatus                                                        |
| Azadirachtin A                                                               |
| Bacillus thuringiensis var. aizawai                                          |
| Bacillus thuringiensis var. israeliensis                                     |
| Bacillus thuringiensis var. kurstaki                                         |
| Bacillus thuringiensis var. tenebrionis                                      |
| Beauveria brongniartii                                                       |
| Benzolsulfonsäure                                                            |
| Benzolsulfonsäure, Mono-C11-13-verzweigte Alkylderivate, Calciumsalze        |
| Bifenazat                                                                    |
| Buprofezin                                                                   |
| C14-C16-Alkanehydroxysulfonic acids sodium salts                             |
| Calcium Dodecylbenzene Sulfonate                                             |
| Chlorantraniliprol                                                           |
| Cypermethrin                                                                 |
| Deltamethrin                                                                 |
| Emamectinbenzoat                                                             |
| Etofenprox                                                                   |
| Eupeodes corollae                                                            |
| Fenpyroximate                                                                |
| Fettsäuren                                                                   |
| Fettsäuren C7-C18                                                            |
| Fettsäuren, C7-C18-und C18 ungesättigt, Kaliumsalze                          |
| Flonicamid                                                                   |
| Gamma Butyrolacton                                                           |
| Glutaraldehyd                                                                |
| Heterorhabditis bacteriophora                                                |
| Heterorhabditis downesi                                                      |
| Hexythiazox                                                                  |
| Hydrocarbons, C10-C13, aromatics, \<1% naphthalene                           |
| Kaliumhydrogencarbonat                                                       |
| Kalkstein                                                                    |
| Kaolin                                                                       |
| Kieselgur (Diatomeenerde)                                                    |
| Lambda-Cyhalothrin                                                           |
| Lösungsmittelnaphtha (Erdöl), leichte aromatische                            |
| Maltodextrin                                                                 |
| Metarhizium anisopliae                                                       |
| Milbemectin                                                                  |
| Oleylamin ethoxyliert, Dodecylbenzensulfonsalz                               |
| Orangenöl                                                                    |
| Paraffinöl                                                                   |
| Piperonyl butoxid                                                            |
| Pirimicarb                                                                   |
| Pyrethrine                                                                   |
| Quassiaextrakt                                                               |
| Rapsöl                                                                       |
| Sesamöl raffiniert                                                           |
| Solvent Naphtha                                                              |
| Solvent naphtha (petroleum), heavy arom.; Kerosine - unspecified             |
| Sphaerophoria rueppellii                                                     |
| Spinetoram                                                                   |
| Spinosad                                                                     |
| Spirotetramat                                                                |
| Steinernema carpocapsae                                                      |
| Steinernema carpocapsae all strain                                           |
| Steinernema feltiae                                                          |
| Sulfurylfluorid                                                              |
| Tebufenozide                                                                 |
| Tebufenpyrad                                                                 |
| Tefluthrin                                                                   |
| Tetrahydrofurfuryl-Alkohol                                                   |
| Trichogramma brassicae Bezdenko                                              |
| Trichogramma cacoeciae                                                       |
| Trichogramma evanescens                                                      |
| Weisses Mineralöl (Petroleum)                                                |
| Xenorhabdus bovienii                                                         |
| Xylol                                                                        |
| alcohols, (c12-14), ethoxylated, monoethers with sulfuric acid, sodium salts |
| alcohols, c11-15-secondary, ethoxylated                                      |

``` r
srppp$products |>
  filter(!isSalePermission) |>
  left_join(srppp$categories, by = "pNbr") |>
  filter(category_de == "Fungizid") |>
  left_join(srppp$ingredients, by = "pNbr", relationship = "many-to-many") |>
  left_join(srppp$substances, by = "pk") |>
  select(substance_de) |>
  unique() |>
  arrange(substance_de) |>
  kable()
```

| substance_de                                                                                                   |
|:---------------------------------------------------------------------------------------------------------------|
| (Z)-9-Octadecen-1-ol ethoxylated                                                                               |
| 1,2-Benzisothiazol-3(2H)-on                                                                                    |
| 1,2-benzisothiazol-3(2H)-one; 1,2-benzisothiazolin-1 3-one                                                     |
| 1,2-benzisothiazol-3(2H)-one; 1,2-benzisothiazolin-3-one                                                       |
| 1,2-benzothiazol-3(2H)-on                                                                                      |
| 1-Butanol                                                                                                      |
| 1-Octyl-2-pyrrolidon                                                                                           |
| 2,2’,2’’-(hexahydro-1,3,5-triazine-1,3,5-triyl)triethanol / 1,3,5-tris(2-hydroxyethyl)hexahydro-1,3,5-triazine |
| 2-Ethylhexyl-S-Lactat                                                                                          |
| 2-Ethylhexyllaktat                                                                                             |
| 2-Methyl-2H-isothiazol-3-on                                                                                    |
| 2-methylaminoethanol                                                                                           |
| Alcohols C9-11, ethoxylated propoxylated                                                                       |
| Alcohols, C12-15, ethoxylated                                                                                  |
| Alcohols, C9-11, ethoxylated                                                                                   |
| Aluminiumfosetyl (Fosetyl-Al)                                                                                  |
| Aluminiumsulfat                                                                                                |
| Ametoctradin                                                                                                   |
| Amisulbrom                                                                                                     |
| Ampelomyces quisqualis                                                                                         |
| Anethol (1-methoxyl-(1-Propenyl) benzen)                                                                       |
| Aureobasidium pullulans                                                                                        |
| Azoxystrobin                                                                                                   |
| Bacillus amyloliquefaciens                                                                                     |
| Bacillus amyloliquefaciens Stamm MBI 600                                                                       |
| Benalaxyl-M                                                                                                    |
| Benzolsulfonsäure                                                                                              |
| Benzolsulfonsäure, 4-C10-13-sec-Alkylderivate                                                                  |
| Benzovindiflupyr                                                                                               |
| Benzylalkohol                                                                                                  |
| Bixafen                                                                                                        |
| Boscalid                                                                                                       |
| Bupirimate                                                                                                     |
| C14-C16-Alkanehydroxysulfonic acids sodium salts                                                               |
| Calcium Dodecylbenzene Sulfonate                                                                               |
| Captan                                                                                                         |
| Cyazofamid                                                                                                     |
| Cyflufenamid                                                                                                   |
| Cymoxanil                                                                                                      |
| Cyprodinil                                                                                                     |
| Dazomet (DMTT)                                                                                                 |
| Decanamide, N, N- dimethyl                                                                                     |
| Destillate (Erdöl)                                                                                             |
| Difenoconazol                                                                                                  |
| Dimethomorph                                                                                                   |
| Dinatriumphosphonat                                                                                            |
| Dipenten; Limonen                                                                                              |
| Disodium maleate                                                                                               |
| Dithianon                                                                                                      |
| Docusatnatrium                                                                                                 |
| Dodecylbenzolsulfonsäure, Verbindung mit 2-Aminoethanol (1:1)                                                  |
| Dodine                                                                                                         |
| Dreibasisches Kupfersulfat                                                                                     |
| Estragol                                                                                                       |
| Ethylenediamine, ethoxylated and propoxylated                                                                  |
| Fenhexamid                                                                                                     |
| Fenpropidin                                                                                                    |
| Fenpyrazamin                                                                                                   |
| Fluazinam                                                                                                      |
| Fludioxonil                                                                                                    |
| Fluopicolide                                                                                                   |
| Fluopyram                                                                                                      |
| Fluoxastrobin                                                                                                  |
| Flutolanil                                                                                                     |
| Fluxapyroxad                                                                                                   |
| Folpet                                                                                                         |
| Fosetyl                                                                                                        |
| Gemisch aus: 2-Ethylhexyl-mono-D-glucopyranosid und 2-Ethylhexyl-di-D-glucopyranosid                           |
| Imazalil                                                                                                       |
| Iprovalicarb                                                                                                   |
| Kaliumhydrogencarbonat                                                                                         |
| Kaliumphosphonat                                                                                               |
| Kresoxim-methyl                                                                                                |
| Kupfer                                                                                                         |
| Kupfer (als Kalkpräparat, Bordeaux-Brühe)                                                                      |
| Kupferhydroxid                                                                                                 |
| Kupferoctanoat                                                                                                 |
| Kupferoxychlorid                                                                                               |
| Lösungsmittelnaphtha (Erdöl), leichte aromatische                                                              |
| Mandipropamid                                                                                                  |
| Mefentrifluconazol                                                                                             |
| Mepanipyrim                                                                                                    |
| Mepiquatchlorid                                                                                                |
| Metalaxyl-M                                                                                                    |
| Metconazole                                                                                                    |
| Methenamin; Hexamethylenetetramin                                                                              |
| Metrafenone                                                                                                    |
| N,N-Dimethyloctanamide                                                                                         |
| N,N-dimethyldecanamide                                                                                         |
| Naphtalin                                                                                                      |
| Naphtha (Erdoel), schwere Alkylat- \[Enthält weniger als 0.1 % Benzol\]                                        |
| Naphthalenesulfonic acid, methyl-, polymer with formaldehyde, sodium salt                                      |
| Natriumdiisopropylnaphtalinsulfonat                                                                            |
| Natriumhydroxid                                                                                                |
| Oleum foeniculi                                                                                                |
| Orangenöl                                                                                                      |
| Oxathiapiprolin                                                                                                |
| Paclobutrazol                                                                                                  |
| Penconazole                                                                                                    |
| Pentanol, verzweigt und linear                                                                                 |
| Penthiopyrad                                                                                                   |
| Phlebia gigantea                                                                                               |
| Pin-2(3)-en                                                                                                    |
| Propamocarb                                                                                                    |
| Propamocarb-hydrochlorid                                                                                       |
| Propyllaktat                                                                                                   |
| Proquinazid                                                                                                    |
| Prothioconazole                                                                                                |
| Pseudomonas sp. Stamm DSMZ 13134                                                                               |
| Pyraclostrobin                                                                                                 |
| Pyrimethanil                                                                                                   |
| Pyriofenon                                                                                                     |
| Quarz                                                                                                          |
| Saccharomyces cervisiae (inert fraction)                                                                       |
| Schachtelhalmextrakt                                                                                           |
| Schwefel                                                                                                       |
| Schwefelkalk (Calciumpolysulfid)                                                                               |
| Solvent Naphtha                                                                                                |
| Solvent naphtha (petroleum), heavy arom.; Kerosine - unspecified                                               |
| Spiroxamine                                                                                                    |
| Tebuconazole                                                                                                   |
| Tetranatriumpyrophosphat                                                                                       |
| Thiabendazole                                                                                                  |
| Trifloxystrobin                                                                                                |
| Valifenalate                                                                                                   |
| Zoxamid                                                                                                        |
| alcohols, (c12-14), ethoxylated, monoethers with sulfuric acid, sodium salts                                   |
| alcohols, c11-15-secondary, ethoxylated                                                                        |
| linalyl alcohol                                                                                                |
| pentanoic acid, 5-(dimethylamino)-2-methyl-5-oxo-, methyl ester                                                |
| poly(oxy-1,2-ethanediyl),alphaisotridecyl-omegahydroxy                                                         |
| polyoxyethylene trimethyldecyl alcohol                                                                         |

The following genus names were established as filtering criteria.

``` r
microorganism_genus_names <- c(
  "Bacillus",
  "Beauveria",
  "Metarhizium",
  "Xenorhabdus",
  "Phlebia",
  "Pseudomonas")
kable(data.frame("Genus names" = microorganism_genus_names, check.names = FALSE))
```

| Genus names |
|:------------|
| Bacillus    |
| Beauveria   |
| Metarhizium |
| Xenorhabdus |
| Phlebia     |
| Pseudomonas |

This results in the following list of active ingredients.

``` r
microorganism_regexp <- paste(microorganism_genus_names, collapse = "|")
microorganism_ingredients <- srppp$substances |>
  filter(grepl(microorganism_regexp, substance_de)) |>
  select(pk, substance_de)
kable(microorganism_ingredients)
```

| pk                                   | substance_de                              |
|:-------------------------------------|:------------------------------------------|
| FE5D35CF-4666-45ED-8DB0-2A706C16A915 | Bacillus amyloliquefaciens                |
| DE9DB824-9848-4F67-863A-57A1CC8093E4 | Bacillus amyloliquefaciens Stamm MBI 600  |
| 38DDF6FB-43AF-4714-A033-253772A2C0F4 | Bacillus amyloliquefaciens ssp. plantarum |
| 158EE23A-D926-49BB-9E5F-D505695F4AC8 | Bacillus thuringiensis var. aizawai       |
| 1B400D81-EDD0-44E3-BEA9-2FECE7BB084E | Bacillus thuringiensis var. israeliensis  |
| 75729E67-9FE2-4211-B86E-5681BBC46822 | Bacillus thuringiensis var. kurstaki      |
| 3DD73DF0-9DAC-469C-9BFF-5CB56940E1A6 | Bacillus thuringiensis var. tenebrionis   |
| 526B05DE-13B4-4842-8BEB-4C2292F99370 | Beauveria bassiana                        |
| 56999C96-EA8A-4A86-915C-E3BE21BB4291 | Beauveria brongniartii                    |
| E5044E08-C281-4072-BB0D-1993562BFEA0 | Metarhizium anisopliae                    |
| D7339D7B-B8B2-4723-B22C-39847F4C6ACE | Phlebia gigantea                          |
| C9003121-80A4-458B-BC2E-777AEEAFE1FB | Pseudomonas chlororaphis                  |
| BD01EED4-AB21-406A-AE79-0D95F726311B | Pseudomonas sp. Stamm DSMZ 13134          |
| 694D1981-76EF-43D9-9DD4-900855086389 | Xenorhabdus bovienii                      |

The following products contain one of these active ingredients.

``` r
additional_products_containing_microorganisms <- srppp$products |>
  filter(!isSalePermission) |>
  left_join(srppp$ingredients, by = "pNbr", relationship = "many-to-many") |>
  filter(pk %in% microorganism_ingredients$pk) |>
  select(-pk) |>
  left_join(srppp$categories, by = "pNbr") |> 
  select(pNbr, wNbr, name, category_de) |>
  arrange(pNbr)
n_additional <- nrow(additional_products_containing_microorganisms)
kable(additional_products_containing_microorganisms)
```

| pNbr | wNbr | name                         | category_de                      |
|-----:|:-----|:-----------------------------|:---------------------------------|
| 4594 | 4574 | Beauveria-Schweizer          | Lebende Organismen (Pilze)       |
| 6415 | 5277 | Traunem                      | Insektizid                       |
| 6415 | 5277 | Traunem                      | Lebende Organismen (Nematoden)   |
| 6427 | 5386 | Entonem                      | Lebende Organismen (Nematoden)   |
| 6861 | 5745 | Solbac-Tabs                  | Insektizid                       |
| 6862 | 5744 | Solbac                       | Insektizid                       |
| 7023 | 5925 | Novodor 3 FC                 | Insektizid                       |
| 7088 | 5978 | Nemaplus                     | Lebende Organismen (Nematoden)   |
| 7241 | 6081 | Novodor 3 % FC               | Insektizid                       |
| 7496 | 6449 | Cerall                       | Saatbeizmittel                   |
| 7498 | 6486 | Cedomon                      | Saatbeizmittel                   |
| 7650 | 6423 | Metarhizium Schweizer        | Lebende Organismen (Pilze)       |
| 7766 | 6882 | Agree WP                     | Insektizid                       |
| 7773 | 6472 | FZB 24 flüssig               | Fungizid                         |
| 7773 | 6472 | FZB 24 flüssig               | Phytoregulator                   |
| 7870 | 6552 | Delfin                       | Insektizid                       |
| 8007 | 6888 | XenTari WG                   | Insektizid                       |
| 8040 | 6777 | Dipel DF                     | Insektizid                       |
| 8258 | 7151 | Amylo-X                      | Lebende Organismen (gegen Pilze) |
| 8296 | 6835 | Dipel DF                     | Insektizid                       |
| 8374 | 6912 | Deposan                      | Fungizid                         |
| 8374 | 6912 | Deposan                      | Lebende Organismen (Bakterien)   |
| 8457 | 6929 | Proradix                     | Saatbeizmittel                   |
| 8519 | 6966 | XenTari WG                   | Insektizid                       |
| 8596 | 7253 | Serenade ASO                 | Fungizid                         |
| 8596 | 7253 | Serenade ASO                 | Bakterizid                       |
| 8926 | 7580 | Wormox                       | Insektizid                       |
| 8926 | 7580 | Wormox                       | Lebende Organismen (Bakterien)   |
| 8946 | 7504 | Taegro                       | Fungizid                         |
| 8946 | 7504 | Taegro                       | Lebende Organismen (gegen Pilze) |
| 9019 | 7272 | Bio Buxus                    | Insektizid                       |
| 9020 | 7273 | Bio Raupen Stopp             | Insektizid                       |
| 9049 | 7316 | Naturalis-L                  | Lebende Organismen (Pilze)       |
| 9052 | 7324 | Rotstop                      | Fungizid                         |
| 9052 | 7324 | Rotstop                      | Lebende Organismen (gegen Pilze) |
| 9068 | 7638 | Serifel                      | Fungizid                         |
| 9139 | 7574 | Capirel                      | Lebende Organismen (Nematoden)   |
| 9173 | 7378 | Beauveria-Maschinenring      | Insektizid                       |
| 9173 | 7378 | Beauveria-Maschinenring      | Lebende Organismen (Pilze)       |
| 9174 | 7379 | Metarhizium-Maschinenring    | Insektizid                       |
| 9174 | 7379 | Metarhizium-Maschinenring    | Lebende Organismen (Pilze)       |
| 9384 | 7528 | Beauveria FL-Maschinenring   | Insektizid                       |
| 9384 | 7528 | Beauveria FL-Maschinenring   | Lebende Organismen (Pilze)       |
| 9385 | 7529 | Metarhizium FL-Maschinenring | Insektizid                       |
| 9385 | 7529 | Metarhizium FL-Maschinenring | Lebende Organismen (Pilze)       |
| 9389 | 7477 | Melocont GR                  | Lebende Organismen (Pilze)       |
| 9390 | 7478 | GranMet GR                   | Lebende Organismen (Pilze)       |
| 9481 | 7500 | Lalguard M52 GR              | Insektizid                       |
| 9481 | 7500 | Lalguard M52 GR              | Lebende Organismen (Pilze)       |
| 9698 | 7632 | Metapro                      | Lebende Organismen (Pilze)       |
| 9699 | 7633 | Beaupro                      | Lebende Organismen (Pilze)       |

## Summary

In summary, out of 1740 products, there are 23 in the microorganism
categories as shown above, and 51 products in the insecticide and
fungicide categories which contain an active substance that has a name
that contains one of the microorganism genus names listed above.

``` r
products_containing_microorganisms <- rbind(
  products_in_microorganism_categories, 
  additional_products_containing_microorganisms) |>
  arrange(pNbr, category_de) |>
  unique()
n_unique <- length(unique(products_containing_microorganisms$pNbr))
```

The consolidated list of the 45 unique products identified in this way
is shown below. Some of these products are listed twice, because they
were identified via both ways.

``` r
kable(products_containing_microorganisms)
```

| pNbr | wNbr | name                         | category_de                      |
|-----:|:-----|:-----------------------------|:---------------------------------|
| 4594 | 4574 | Beauveria-Schweizer          | Lebende Organismen (Pilze)       |
| 6415 | 5277 | Traunem                      | Insektizid                       |
| 6415 | 5277 | Traunem                      | Lebende Organismen (Nematoden)   |
| 6427 | 5386 | Entonem                      | Lebende Organismen (Nematoden)   |
| 6861 | 5745 | Solbac-Tabs                  | Insektizid                       |
| 6862 | 5744 | Solbac                       | Insektizid                       |
| 7023 | 5925 | Novodor 3 FC                 | Insektizid                       |
| 7088 | 5978 | Nemaplus                     | Lebende Organismen (Nematoden)   |
| 7241 | 6081 | Novodor 3 % FC               | Insektizid                       |
| 7496 | 6449 | Cerall                       | Saatbeizmittel                   |
| 7498 | 6486 | Cedomon                      | Saatbeizmittel                   |
| 7650 | 6423 | Metarhizium Schweizer        | Lebende Organismen (Pilze)       |
| 7766 | 6882 | Agree WP                     | Insektizid                       |
| 7773 | 6472 | FZB 24 flüssig               | Fungizid                         |
| 7773 | 6472 | FZB 24 flüssig               | Phytoregulator                   |
| 7870 | 6552 | Delfin                       | Insektizid                       |
| 8007 | 6888 | XenTari WG                   | Insektizid                       |
| 8025 | 6919 | Botector                     | Lebende Organismen (gegen Pilze) |
| 8029 | 6881 | BioAct WG                    | Lebende Organismen (Pilze)       |
| 8040 | 6777 | Dipel DF                     | Insektizid                       |
| 8119 | 6872 | Prestop                      | Lebende Organismen (gegen Pilze) |
| 8258 | 7151 | Amylo-X                      | Lebende Organismen (gegen Pilze) |
| 8296 | 6835 | Dipel DF                     | Insektizid                       |
| 8309 | 6847 | Lalstop K61 WP               | Lebende Organismen (gegen Pilze) |
| 8374 | 6912 | Deposan                      | Fungizid                         |
| 8374 | 6912 | Deposan                      | Lebende Organismen (Bakterien)   |
| 8457 | 6929 | Proradix                     | Saatbeizmittel                   |
| 8519 | 6966 | XenTari WG                   | Insektizid                       |
| 8596 | 7253 | Serenade ASO                 | Bakterizid                       |
| 8596 | 7253 | Serenade ASO                 | Fungizid                         |
| 8926 | 7580 | Wormox                       | Insektizid                       |
| 8926 | 7580 | Wormox                       | Lebende Organismen (Bakterien)   |
| 8946 | 7504 | Taegro                       | Fungizid                         |
| 8946 | 7504 | Taegro                       | Lebende Organismen (gegen Pilze) |
| 9014 | 7259 | AQ 10                        | Lebende Organismen (Pilze)       |
| 9019 | 7272 | Bio Buxus                    | Insektizid                       |
| 9020 | 7273 | Bio Raupen Stopp             | Insektizid                       |
| 9049 | 7316 | Naturalis-L                  | Lebende Organismen (Pilze)       |
| 9052 | 7324 | Rotstop                      | Fungizid                         |
| 9052 | 7324 | Rotstop                      | Lebende Organismen (gegen Pilze) |
| 9068 | 7638 | Serifel                      | Fungizid                         |
| 9139 | 7574 | Capirel                      | Lebende Organismen (Nematoden)   |
| 9173 | 7378 | Beauveria-Maschinenring      | Insektizid                       |
| 9173 | 7378 | Beauveria-Maschinenring      | Lebende Organismen (Pilze)       |
| 9174 | 7379 | Metarhizium-Maschinenring    | Insektizid                       |
| 9174 | 7379 | Metarhizium-Maschinenring    | Lebende Organismen (Pilze)       |
| 9384 | 7528 | Beauveria FL-Maschinenring   | Insektizid                       |
| 9384 | 7528 | Beauveria FL-Maschinenring   | Lebende Organismen (Pilze)       |
| 9385 | 7529 | Metarhizium FL-Maschinenring | Insektizid                       |
| 9385 | 7529 | Metarhizium FL-Maschinenring | Lebende Organismen (Pilze)       |
| 9389 | 7477 | Melocont GR                  | Lebende Organismen (Pilze)       |
| 9390 | 7478 | GranMet GR                   | Lebende Organismen (Pilze)       |
| 9479 | 7498 | Lalstop Contans WG           | Lebende Organismen (gegen Pilze) |
| 9481 | 7500 | Lalguard M52 GR              | Insektizid                       |
| 9481 | 7500 | Lalguard M52 GR              | Lebende Organismen (Pilze)       |
| 9698 | 7632 | Metapro                      | Lebende Organismen (Pilze)       |
| 9699 | 7633 | Beaupro                      | Lebende Organismen (Pilze)       |
