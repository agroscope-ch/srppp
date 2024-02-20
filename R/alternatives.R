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
#' psmv <- psmv_list[["2024"]]
#'
#' actives_de <- c("Lambda-Cyhalothrin", "Deltamethrin")
#'
#' alternative_products(psmv, actives_de)
#' alternative_products(psmv, actives_de, missing = TRUE)
#' alternative_products(psmv, actives_de, details = TRUE)
#' alternative_products(psmv, actives_de, list = TRUE)
#'
#' # Example in Italian
#' actives_it <- c("Lambda-Cialotrina", "Deltametrina")
#' alternative_products(psmv, actives_it, lang = "it")
alternative_products <- function(psmv, active_ingredients,
  details = FALSE, missing = FALSE, list = FALSE, lang = "de")
{
  substance_column <- paste("substance", lang, sep = "_")
  selection_criteria = paste(c("application_area", "culture", "pest"), lang, sep = "_")

  # Select products from the PSM-V containing the active ingredients in question
  affected_products <- psmv$substances |>
    filter(psmv$substances[[substance_column]] %in% active_ingredients) |>
    left_join(psmv$ingredients, by = "pk") |> # get the W-Numbers
    left_join(psmv$products, by = "wNbr") |>  # get the P-Numbers
    select(c("pNbr", "wNbr")) |>
    arrange(pick(all_of(c("pNbr", "wNbr"))))

  affected_uses <- psmv$uses |>
    filter(wNbr %in% affected_products$wNbr)

  affected_cultures_x_pests <- affected_uses |>
    left_join(psmv$cultures, by = c("wNbr", "use_nr"), relationship = "many-to-many") |>
    left_join(psmv$pests, by = c("wNbr", "use_nr"), relationship = "many-to-many") |>
    select(all_of(selection_criteria)) |>
    unique() |>
    arrange(pick(all_of(selection_criteria)))

  return_columns <- c("pNbr", "wNbr", "use_nr", selection_criteria)

  # Select products without the active ingredients in question
  alternative_product_candidates <- psmv$products |>
    ungroup() |>
    filter(!psmv$products$wNbr %in% affected_products$wNbr) 

  alternative_product_candidate_uses <- alternative_product_candidates |>
    left_join(psmv$uses, by = "wNbr", relationship = "many-to-many") |>
    left_join(psmv$cultures, by = c("wNbr", "use_nr"), relationship = "many-to-many") |>
    left_join(psmv$pests, by = c("wNbr", "use_nr"), relationship = "many-to-many") |>
    select(all_of(return_columns)) |>
    arrange(pick(all_of(return_columns)))

  alternative_uses <- affected_cultures_x_pests |>
    left_join(alternative_product_candidate_uses,
      by = selection_criteria)

  uses_without_alternatives <- alternative_uses |>
    filter(is.na(alternative_uses$wNbr)) |>
    select(all_of(selection_criteria))

  n_alternative_products <- alternative_uses |>
    select(all_of(c("wNbr", selection_criteria))) |>
    unique() |>
    group_by(pick(all_of(selection_criteria))) |>
    summarise(n_wNbr = n(), .groups = "drop")

  n_alternative_product_types <- alternative_uses |>
    select(all_of(c("pNbr", selection_criteria))) |>
    unique() |>
    group_by(pick(all_of(selection_criteria))) |>
    summarise(n_pNbr = n(), .groups = "drop")

  n_alternatives <- n_alternative_products |>
    left_join(n_alternative_product_types, by = selection_criteria) 

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
