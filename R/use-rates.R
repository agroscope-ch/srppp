#' Calculate application rates for active ingredients
#'
#' @note The reference application volume is used if there is no 'expenditure'.
#' It is selected only based on the product application area. This is not correct
#' if hops ('Hopfen') is the culture, as it has a unique reference application
#' volume of 3000 L/ha.
#' Applications to hops were excluded for calculating mean use rates in the
#' indicator project (Korkaric 2023), arguing that it is not grown in large
#' areas in Switzerland.
#' @param product_uses A tibble containing the columns 'application_area_de',
#' 'min_dosage', 'max_dosage', 'min_rate', 'max_rate', from the 'uses' table
#' in a [psmv_dm] object, as well as the columns 'percent' and 'g_per_L'
#' from the 'ingredients' table in a [psmv_dm] object.
#' @param aggregation How to represent a range if present, e.g. "mean" or "max"
#' @return A tibble containing one additional column 'rate_g_per_ha'
#' @export
#' @examples
#' library(psmv)
#' library(dplyr)
#' library(dm)
#' psmv <- psmv_list[["2022"]]
#'   
#' product_uses_with_ingredients <- psmv |>
#'   dm_filter(substances = 
#'     (substance_de %in% c("Halauxifen-methyl", "Kupfer (als Kalkpr\u00E4parat)"))) |>
#'   dm_flatten_to_tbl(uses, products) |>
#'   left_join(psmv$ingredients, by = join_by(wNbr),
#'     relationship = "many-to-many") |>
#'   left_join(psmv$substances, by = join_by(pk)) |>
#'   select(wNbr, name, use_nr, 
#'     min_dosage, max_dosage, min_rate, max_rate, units_de,
#'     application_area_de, 
#'     substance_de, percent, g_per_L)
#'
#' application_rate_g_per_ha(product_uses_with_ingredients) |>
#'   filter(name %in% c("Cerelex", "Pixxaro EC", "Bordeaux S")) |>
#'   select(ai = substance_de, app_area = application_area_de,
#'     min_d = min_dosage,  max_d = max_dosage,
#'     min_r = min_rate, max_r = max_rate,
#'     units_de, rate = rate_g_per_ha) |>
#'   print(n = Inf)
application_rate_g_per_ha <- function(product_uses,
  aggregation = c("mean", "max", "min"))
{
  aggregation = match.arg(aggregation)
  product_rates_dosage <- product_uses |>
    mutate( # First we set zeros to NA, as this is what they are
      min_rate = na_if(min_rate, 0),
      max_rate = na_if(max_rate, 0),
      min_dosage = na_if(min_dosage, 0),
      max_dosage = na_if(max_dosage, 0)) |>
    mutate( # Then we make ranges, possbily with min equals max
      rate_min = min_rate, # 'expenditures' are use rates (Aufwandmengen)
      rate_max = if_else(is.na(max_rate), # if zero, either no range or only conc
        min_rate, max_rate),
      dosage_min = min_dosage, # 'dosages' are in-use concentrations in percent
      dosage_max = if_else(is.na(max_dosage),
        min_dosage, max_dosage)
      ) |>
    mutate(
      product_rate = case_when(
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

  active_rates <- product_rates_dosage |>
    mutate(percent = as.numeric(percent), g_per_L = as.numeric(g_per_L)) |>
    mutate(g_per_L = if_else(is.na(g_per_L),
      percent * 10, g_per_L)) |> # Assume density 1 kg/L if necessary
    mutate(ref_volume = case_when(
      application_area_de %in% c("Feldbau", "Gem\u00FCsebau", "Beerenbau", "Zierpflanzen") ~ 1000,
      application_area_de %in% c("Weinbau", "Obstbau") ~ 1600,
      .default = NA)) |>
    mutate(rate_g_per_ha = case_when(
      units_de == "l/ha" ~ product_rate * g_per_L,
      units_de == "kg/ha" ~ product_rate * (percent * 10), # percent w/w means 10 g/kg
      units_de == "g/ha" ~ product_rate * (percent / 100), # percent w/w means 0.01 g/g
      units_de == "ml/m\u00B2" ~ (product_rate/1000) * (g_per_L) * 10000,
      units_de == "ml/10m\u00B2" ~ (product_rate/1000) * (g_per_L) * 100000,
      units_de == "ml/ha" ~ (product_rate/1000) * (g_per_L),
      units_de == "ml/a" ~ (product_rate/1000) * (g_per_L) * 100,
      is.na(units_de) ~ ref_volume * dosage/100 * g_per_L,
      .default = NA))
  ret <- bind_cols(product_uses, active_rates["rate_g_per_ha"])
  return(ret)
}
utils::globalVariables(c("percent", "g_per_L"))

#' Product application rate units convertible to grams active substance per hectare
#'
#' @docType data
#' @export
#' @seealso [application_rate_g_per_ha]
#' @examples
#' library(psmv)
#' library(dplyr)
#' # These are the convertible units
#' units_convertible_to_g_per_ha
units_convertible_to_g_per_ha <- c("l/ha", "kg/ha", "g/ha",
  "ml/m\u00B2", "ml/10m\u00B2", "ml/ha", "ml/a")

