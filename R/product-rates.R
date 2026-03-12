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
#' @param aggregation How to represent a range if present, e.g. "max" (default)
#' or "mean".
#' @param dosage_units If no units are given, or units are "%", then the applied
#' amount in l/ha or kg/ha is calculated using a reference application volume and
#' the dosage. As the dosage units are not explicitly given, we can specify our
#' assumptions about these using this argument (currently not implemented, i.e.
#' specifying the argument has no effect).
#' @param fix_l_per_ha During the review of the 2023 indicator
#' project calculations, a number of cases were identified where the unit
#' l/ha specifies a water volume, and not a product volume. If TRUE (default),
#' these cases are corrected, if FALSE, these cases are discarded.
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
  dosage_units = c("percent_ww", "percent_vv", "state_of_matter"),
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
      rate = case_when(
        aggregation == "mean" ~ (rate_min + rate_max)/2,
        aggregation == "max" ~ rate_max,
        aggregation == "min" ~ rate_min
      ),
      dosage = case_when(
        aggregation == "mean" ~ (dosage_min + dosage_max)/2,
        aggregation == "max" ~ dosage_max,
        aggregation == "min" ~ dosage_min
      )
    )

  # if (is.na(rates_dosages$culture_de))
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
        if_else(is.na(source), # if no external information, assume l/ha is product
                if_else(is.na(g_per_L) & !is.na(percent), # if g_per_L is not defined and percent is given
                        if_else(!is.na(dosage) & rate > 100,
                                # If we have a dosage and the rate is above 100 l/ha, the rate in l/ha is assumed to be the application solution
                                rate * dosage / 100, # Correct for Rhodofix 2009 (Grünbuch) and 2012 (XML)
                                # If we have no dosage, treat l/ha as kg/ha product rate
                                rate # Correct for Metro 2017

                                ),
                        rate # l/ha is product
                ),
                if (fix_l_per_ha) {
                  rate * dosage / 100 # external info: l/ha for solution, weighted by dosage
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
#' @docType data
#' @export
#' @seealso [product_rates]
#' @examples
#' library(srppp)
#' l_per_ha_is_water_volume
l_per_ha_is_water_volume <- tibble::tribble(
  ~ pNbr, ~ use_nr, ~ source, ~ url,
  5151L, 1L, "EFSA conclusion on cyanamide 2010, p. 17",
  "https://doi.org/10.2903/j.efsa.2010.1873"
)
