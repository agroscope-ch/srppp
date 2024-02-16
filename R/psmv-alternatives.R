#' Find alternative products for all products containing certain active substances
#'
#' This function searches for uses of a given list of active substances and reports
#' either a table of uses with the number of available alternative products for each
#' use, a detailed table of the alternative product uses, a table of uses without
#' alternatives, or a list containing these three tables.
#' 
#' A use is defined as a combination of an application area, a crop
#' ('culture') and a pathogen ('pest').
#'
#' @param psmv A [psmv_dm] object.
#' @param active_ingredients Character vector of active ingredient names that will be
#' matched against the column 'substances_de' in the psmv table 'substances'.
#' @param details Should a table of alternative uses with 'wNbr' 'use_nr' be returned?
#' @param missing If this is set to TRUE, uses without alternative product registrations
#' are listed. 
#' @param list If TRUE, a list of three tables is returned, a table of uses
#' without alternative products, a table with the number of alternative
#' products, if they are available, and a detailed table of all the alternative
#' uses. This argument overrides the arguments 'details' and 'missing'.
#' @param lang The language used for the active ingredient names and the returned
#' tables. Unfortunately, it is not trivial to generalise the implementation
#' to support the other languages, so for now only German ('de') is supported.
#' @export
#' @examples
#' psmv <- psmv_dm() # Read the latest XML locally accessible
#'
#' actives <- c("Lambda-Cyhalothrin", "Deltamethrin")
#'
#' alternative_products(psmv, actives, missing = TRUE)
#' alternative_products(psmv, actives)
#' alternative_products(psmv, actives, details = TRUE)
#' alternative_products(psmv, actives, list = TRUE)
alternative_products <- function(psmv, active_ingredients,
  details = FALSE, missing = FALSE, list = FALSE, lang = "de")
{
  if (lang[1] != "de") stop("Only German is currently implemented")

  # Select entries from the PSM-V with the active substance
  psmv_ai <- dm_filter(psmv,
     substances = (substance_de %in% active_ingredients))

  uses_x_pests_x_cultures <- psmv_ai$uses |>
    left_join(psmv$cultures, by = join_by(wNbr, use_nr), relationship = "many-to-many") |>
    left_join(psmv$pests, by = join_by(wNbr, use_nr), relationship = "many-to-many")

  pests_x_cultures <- uses_x_pests_x_cultures |>
    select(application_area_de, culture_de, pest_de) |>
    unique() |>
    arrange(application_area_de, culture_de, pest_de)

  alternative_products_all_uses <- psmv$products |>
    filter(!wNbr %in% psmv_ai$products$wNbr) |>
    left_join(psmv$uses, by = join_by(wNbr), relationship = "many-to-many") |>
    left_join(psmv$cultures, by = join_by(wNbr, use_nr), relationship = "many-to-many") |>
    left_join(psmv$pests, by = join_by(wNbr, use_nr), relationship = "many-to-many") |>
    select(pNbr, wNbr, use_nr, application_area_de, culture_de, pest_de) |>
    arrange(pNbr, wNbr, use_nr, application_area_de, culture_de, pest_de)

  alternative_uses <- pests_x_cultures |>
    left_join(alternative_products_all_uses,
      by = join_by(application_area_de, culture_de, pest_de))

  uses_without_alternatives <- alternative_uses |>
    filter(is.na(wNbr))
  
  n_alternatives <- alternative_uses |>
      group_by(application_area_de, culture_de, pest_de) |>
      summarise(n = n(), .groups = "drop_last") |>
      arrange(application_area_de, culture_de, pest_de)

  if (list) {
      ret <- list(
        uses_without_alternatives,
        n_alternatives,
        alternative_uses)
      names(ret) <- c(
        "No alternative", 
        "Number of alternatives", 
        "Alternative uses")
      return(ret)
  } else {
    if (details & missing) {
      stop("You cannot get details for missing alternatives")
    } else {
      if (missing) {
        return(uses_without_alternatives)
      } else {
        if (details) {
          return(alternative_uses)
        } else {
          return(n_alternatives)
        }
      }
    }
  }
}
utils::globalVariables(c("substance_de",
  "application_area_de", "culture_de", "pest_de", 
  "g_per_L", "percent"))
