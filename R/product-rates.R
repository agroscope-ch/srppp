#' Calculate product application rates
#'
#' An application rate in l/ha or kg/ha is calculated from information
#' on dosage (product concentration in the application solution), application volume,
#' or directly from the product application rate. This is complicated by the fact
#' that a rate ("expenditure" in the XML file) with units l/ha can refer
#' to the application solution or to the liquid product.
#'
#' In some cases (currently one), external information was found, indicating
#' that the "expenditure" is an application volume [l_per_ha_is_water_volume].
#'
#' @note A reference application volume is used if there is no 'expenditure'.
#' It is selected only based on the product application area and culture.
#'
#' @param product_uses A tibble containing the columns 'pNbr', 'use_nr',
#' 'application_area_de', 'min_dosage', 'max_dosage', 'min_rate', 'max_rate',
#' from the 'uses' table in a [srppp_dm] object, as well as the columns
#' 'percent' and 'g_per_L' from the 'ingredients' table in a [srppp_dm] object and
#' 'culture_de' from the 'cultures' table in [srppp_dm] object.
#' @param skip_l_per_ha_without_g_per_L Passed on to `application_rate_g_per_ha`,
#' but here, the default is FALSE, there it is TRUE.
#' @inheritParams application_rate_g_per_ha
#' @return A tibble containing one additional column 'rate_g_per_ha'
#' @export
#' @examples
#' \dontrun{
#' library(srppp)
#' library(dplyr, warn.conflicts = FALSE)
#' library(dm, warn.conflicts = FALSE)
#' sr <- srppp_dm()
#'
#' product_uses <- sr$products |>
#'   filter(name == "BIOHOP AudiENZ") |>
#'   left_join(sr$uses, by = "pNbr",
#'             relationship = "many-to-many") |>
#'   left_join(sr$cultures, by = c("pNbr", "use_nr"),
#'             relationship = "many-to-many") |>
#'   left_join(sr$ingredients, by = c("pNbr"),
#'             relationship = "many-to-many") |>
#'   select(name, pNbr, use_nr,
#'     min_dosage, max_dosage, min_rate, max_rate, units_de,
#'     application_area_de, culture_de, pk, percent, g_per_L)
#'
#' product_rates(product_uses, aggregation = "max") |>
#'   select(pNbr, name, culture_de, application_area_de,
#'   max_prod_rate=prod_rate, prod_unit) |>
#'   print(n = 10)
#' }
product_rates <- function(product_uses,
  aggregation = c("max", "mean", "min"),
  skip_l_per_ha_without_g_per_L = FALSE,
  fix_l_per_ha = TRUE)
{
  aggregation = match.arg(aggregation)
  rates_dosages <- product_uses |> # Rates are called "Expenditures" in the XML
    mutate( # First we set zeros to NA, as this is what they are
      min_rate = na_if(min_rate, 0),
      max_rate = na_if(max_rate, 0),
      min_dosage = na_if(min_dosage, 0),
      max_dosage = na_if(max_dosage, 0)) |>
    mutate( # Then we make ranges, possibly with min equals max
      rate_min = min_rate, # 'expenditures' are use rates (Aufwandmengen)
      rate_max = if_else(is.na(max_rate), # if zero, either no range or not given
        min_rate, max_rate),
      dosage_min = min_dosage, # 'dosages' are in-use concentrations in percent
      dosage_max = if_else(is.na(max_dosage),
        min_dosage, max_dosage)
      ) |>
    mutate(
      rate = if (aggregation == "mean") {
        (rate_min + rate_max)/2
      } else if (aggregation == "max") {
        rate_max
      } else {
        rate_min
      },
      dosage = if (aggregation == "mean") {
        (dosage_min + dosage_max)/2
      } else if (aggregation == "max") {
        dosage_max
      } else {
        dosage_min
      }
    )

  product_rates <- rates_dosages |>
    mutate(ref_volume = case_when(
      application_area_de %in% c("Feldbau", "Gem\u00FCsebau", "Beerenbau", "Zierpflanzen")
      & culture_de != "Hopfen" ~ 1000,
      culture_de == "Hopfen" ~ 3000,
      application_area_de %in% c("Weinbau", "Obstbau") ~ 1600,
      .default = NA)) |>
    left_join(l_per_ha_is_water_volume, by = c("pNbr", "use_nr")) |>
    mutate(prod_rate = case_when(
      units_de == "l/ha" ~ # l/ha can refer to product or water volume
        if_else(is.na(source) | rate < 100, # if no external information, or the rate is < 100 l/ha, start assuming that l/ha is product
          if_else(is.na(g_per_L), # if g_per_L is not defined
            if (skip_l_per_ha_without_g_per_L) NA # set to NA, as in the 2023 indicator
            else {
              if_else(is.na(dosage),
                # If we have no dosage, treat l/ha as kg/ha product rate
                rate, # l/ha is assumed to be product, correct for Metro 2017
                rate * dosage/100) # else assume that the rate refers to the application solution, and use dosage information (e.g. the corrected dosage for Rhodofix, or the amended dosage for Dirigol - N)
            },
            rate
          ),
          if (fix_l_per_ha) {
            rate * dosage / 100 # external info: l/ha is solution, use dosage
          } else NA),
      units_de == "kg/ha" ~ rate,                     # product already in kg/ha
      units_de == "g/ha" ~ rate / 1000,               # convert g/ha → kg/ha
      units_de == "ml/m\u00B2" ~ rate / 1000 * 10000, # ml/m² → L/ha
      units_de == "ml/10m\u00B2" ~ rate / 1000 * 1000,# ml/10m² → L/ha
      units_de == "ml/ha" ~ rate / 1000,              # ml/ha → L/ha
      units_de == "ml/a" ~ rate / 1000 * 100,         # ml/a → L/ha
      is.na(units_de) ~ ref_volume * dosage/100,      # dosage in %
      .default = NA),
      prod_unit = case_when(
        units_de %in% c("l/ha", "ml/m\u00B2", "ml/10m\u00B2", "ml/ha", "ml/a") ~ "l/ha",
        units_de %in% c("kg/ha", "g/ha") ~ "kg/ha",
        is.na(units_de) & is.na(g_per_L) & !is.na(percent) ~ "kg/ha",
        is.na(units_de) & !is.na(g_per_L) ~ "l/ha",
        .default = NA))
  ret <- bind_cols(product_uses, product_rates[c("prod_rate", "prod_unit")])
  return(ret)
}

#' Use definitions where the rate in l/ha refers to the volume of the spraying solution
#'
#' This information is used in the functions [product_rates] and [application_rate_g_per_ha]
#' in cases where a rate in l/ha exceeds 100 l/ha. It only affects older XML files,
#' in current versions of the XML files, rate specifications always refer to
#' the product.
#'
#' Currently, the affected products are Dormex (P-Nr. 5151) and Karate with
#' Zeon technology (P-Nr. 3756).
#' @docType data
#' @export
#' @seealso [product_rates]
#' @examples
#' library(srppp)
#' l_per_ha_is_water_volume
l_per_ha_is_water_volume <- tibble::tribble(
  ~ pNbr, ~ use_nr, ~ source, ~ url, ~ file,
  5151L, 1L, "EFSA conclusion on cyanamide 2010, p. 17",
  "https://doi.org/10.2903/j.efsa.2010.1873", NA,
  3756L, 14L, "Verzeichnis 2009 Pflanzenschutzmittel",
  NA, "Gr\u00FCnbuch 20090518.pdf"
)
