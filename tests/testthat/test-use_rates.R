test_that("Use rates are correctly converted to g/ha", {

  # Halauxifen-methyl in Cerelex in arable crops, e.g. in the PSMV 2024
  use_arable_one_rate_l_ha <- tibble::tibble(
    pNbr = 8550L, use_nr = 1L, substance_de = "Halauxifen-methyl",
    application_area_de = "Feldbau",
    culture_de = "Gerste",
    min_dosage = NA,
    max_dosage = NA,
    min_rate = 0.75,
    max_rate = NA,
    units_de = "l/ha",
    percent = 0.68,
    g_per_L = 6.3
  )

  expect_equal(
    application_rate_g_per_ha(use_arable_one_rate_l_ha)$rate_g_per_ha,
    4.725)

  # Seven uses of Alial containing Fosetyl
  uses_fosetyl <- tibble::tibble(
    pNbr = 7877L,
    use_nr = c(1, 2, 3, 4, 5, 6, 7),
    application_area_de = c("Zierpflanzen", "Weinbau", "Obstbau", "Beerenbau", "Gemüsebau", "Gemüsebau", "Zierpflanzen"),
    culture_de = c("allg.", "Reben", "Birne", "Erdbeere", "Kopfsalate", "Kürbisgewächse (Cucurbitaceae)", "allg."),
    min_dosage = c(0.5, 0.125, 0.3, 0.75, NA, 0.2, 0.25),
    max_dosage = NA,
    min_rate = c(NA, 2.0, 4.8, 7.5, 2.0, 3.0, NA),
    max_rate = NA,
    units_de = c(NA, rep("kg/ha", 5), NA),
    percent = 80,
    g_per_L = NA)

  expect_equal(
    application_rate_g_per_ha(uses_fosetyl)$rate_g_per_ha,
    c(4000, 1600, 3840, 6000, 1600, 2400, 2000)) # Reference generated in the PAIV indicator project

  # A use of Difcor 250 EC on strawberries
  # sr <- srppphist::srppp_list[["2024"]]
  # sr$products |>
  #   filter(name == "Misto 12") |>
  #   left_join(sr$uses, by = "pNbr") |>
  #   left_join(sr$cultures, by = c("pNbr", "use_nr")) |>
  #   filter(culture_de %in% c("Kernobst")) |>
  #   left_join(sr$ingredients, by = "pNbr", relationship = "many-to-many") |>
  #   filter(type == "ACTIVE_INGREDIENT") |>
  #   select(pNbr, wNbr, use_nr, application_area_de, culture_de,
  #     min_dosage, max_dosage, min_rate, max_rate, units_de, percent, g_per_L)

  uses_Misto_12 <- tibble::tibble(
    pNbr = 1865,
    use_nr = c(2, 4, 7),
    application_area_de = "Obstbau",
    culture_de = "Kernobst",
    min_dosage = c(2, 1, 3.5),
    max_dosage = NA,
    min_rate = NA, # 32, 16, 56, to be reproduced as intermediate result
    max_rate = NA,
    units_de = NA,
    percent = 99.1,
    g_per_L = 830)

 product_rates_Misto_12 <- product_rates(uses_Misto_12)

 expect_equal(
   product_rates_Misto_12$prod_rate,
   c(32, 16, 56))

  expect_equal(
    application_rate_g_per_ha(uses_Misto_12)$rate_g_per_ha,
    c(32, 16, 56) * 830)

  # Products with units_de = "l/ha" and is.na(g_per_L), e.g. Metro 2017
  uses_unit_l_ha_no_g_per_L <- tibble::tibble(
    pNbr = rep(5068, 4),
    use_nr = c(1, 2, 1, 2),
    substance_de = c(rep("Ethephon", 2),
                     rep("Trinexapac-ethyl", 2)),
    application_area_de = rep("Feldbau", 4),
    culture_de = rep("Triticale", 4),
    min_dosage = rep(NA,4),
    max_dosage = rep(NA,4),
    min_rate = c(0.6, 1, 0.6, 1),
    max_rate = c(1, 1.2, 1, 1.2),
    units_de = "l/ha",
    percent = c(rep(22.6, 2), rep(26.6, 2)),
    g_per_L = NA
  )

  expect_equal(
    application_rate_g_per_ha(uses_unit_l_ha_no_g_per_L, aggregation = "min",
                              skip_l_per_ha_without_g_per_L = FALSE
                              )$rate_g_per_ha,
    c(135.6, 226.0, 159.6, 266.0))

  expect_equal(
    application_rate_g_per_ha(uses_unit_l_ha_no_g_per_L,
                              skip_l_per_ha_without_g_per_L = FALSE
    )$rate_g_per_ha,
    c(226.0, 271.2, 266.0, 319.2))

  # Another product with units_de = "l/ha" and is.na(g_per_L) is Rhodofix
  # For this product, the dosage information was corrected based on the
  # Grünbuch 2009 and the current register starting from srppp v2.0.5,
  # used for producing srppphist v2.0.2. This is tested below after
  # testing uses in hops ("Hopfen")

  # Products with and without unit and culture_de = "Hopfen"
  uses_with_and_without_units <- tibble::tibble(
    pNbr = c(rep(7522, 3), rep(4567, 2)),
    use_nr = c(2, 3, 29, 2, 3),
    substance_de = c(rep("Deltamethrin", 3),
                     rep("Folpet", 2)),
    application_area_de = c(rep("Feldbau", 3),
                            rep("Gemüsebau", 2)),
    culture_de = c("Zuckerrübe", "Mais", "Hopfen", "Tomaten", "Knollensellerie"),
    min_dosage = c(rep(NA, 2), 0.05, 0.2, NA),
    max_dosage = c(rep(NA, 3), 0.3, NA),
    min_rate = c(0.5, 0.5, NA, NA, 2.5),
    max_rate = c(rep(NA,5)),
    units_de = c("l/ha","l/ha", NA, NA, "l/ha"),
    percent = c(rep(1.47, 3), rep(21, 2)),
    g_per_L = c(rep(15, 3), rep(280, 2))
  )

  expect_equal(
    application_rate_g_per_ha(uses_with_and_without_units, aggregation = "min",
                              skip_l_per_ha_without_g_per_L = FALSE
    )$rate_g_per_ha,
    c(7.5, 7.5, 22.5, 560.0, 700.0))

  # The following tests rely on srppphist >= 2.0.2, which was generated
  # using srppp 2.0.5 to address some corner cases checked below
  skip_if_not_installed("srppphist", minimum_version = "2.0.2")

  sr12 <- srppphist::srppp_list[["2012"]]

  uses_rate_greater_100_l_ha <- sr12$uses |>
    left_join(sr12$ingredients, by = "pNbr", relationship = "many-to-many") |>
    filter(units_de == "l/ha" & min_rate > 100) |>
    left_join(sr12$products, by = "pNbr", relationship = "many-to-many") |>
    left_join(sr12$cultures, by = c("pNbr", "use_nr"), relationship = "many-to-many") |>
    select(pNbr, wNbr, name, use_nr, application_area_de, culture_de,
           min_dosage, max_dosage, min_rate, max_rate, units_de, percent, g_per_L)

  product_rates_for_use_rates_greater_100_l_ha <- product_rates(uses_rate_greater_100_l_ha)

  expect_equal(
    product_rates_for_use_rates_greater_100_l_ha$prod_rate,
    c(rep(0.2, 4), 15, rep(166, 4))
  )

  expect_equal(
    application_rate_g_per_ha(uses_rate_greater_100_l_ha,
      skip_l_per_ha_without_g_per_L = FALSE)$rate_g_per_ha,
    c(10, 10, NA, NA, 7800, rep(31042, 4)))


})

