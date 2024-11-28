#' Resolve culture specifications to their lowest hierarchical level
#'
#' Resolves culture levels in a dataset to their lowest hierarchical level (leaf nodes)
#' using a parent-child relationship dataset derived from a culture tree using
#' the German culture names. Only German culture names are supported.
#' If no match is found, the function assigns `NA` to the `leaf_culture_de` column.
#' If `correct_culture_names` is set to `TRUE`, the function corrects variations in
#' the naming of aggregated culture groups with "allg.".
#'
#' @importFrom stringr str_detect str_replace
#' @importFrom rlang sym :=
#' @importFrom dplyr case_when mutate
#' @param dataset A data frame or tibble containing the data to be processed. It
#'   should include a column that represents the culture information to be
#'   resolved.
#' @param srppp An [srppp_dm] object. From this object the relations from each 
#'   culture to the leaf cultures (lowest level in the hierarchical tree) are used,
#'   which are stored as attribute 'culture_leaf_df' of the culture tree, which 
#'   is itself stored as an attribute of the object.
#' @param culture_column (Optional) A character string specifying the column in
#'   the dataset that contains the culture information to be resolved. Defaults
#'   to `"culture_de"`.
#' @param correct_culture_names If this argument is set to `TRUE`, the following
#'   corrections will be applied: In the `culture_tree`, and consequently in the
#'   `culture_leaf_df`, there are variations in the naming of aggregated culture
#'   groups with "allg.". For example, both "Obstbau allg." and "allg. Obstbau"
#'   exist. The information about the leaf nodes is only available in one of these terms. 
#'  Therefore, the information from the term containing the leaf nodes is transferred to 
#'  the corresponding "allg. ..." term.
#'
#' @return
#' A data frame or tibble with the same structure as the input
#'   `dataset`, but with an additional column `"leaf_culture_de"` that contains
#'   the resolved leaf culture levels.
#'
#' @details
#' The `resolve_cultures` function processes the input dataset as follows
#'
#' **Leaf Node Resolution**: The cultures in the specified column of the dataset are resolved to their
#'    lowest hierarchical level (leaf nodes) based on the `culture_leaf_df` mapping.
#'
#'    The result is an expanded dataset that includes an additional column (`leaf_culture_de`) containing
#'    the resolved cultures at their lowest level.
#'
#' @export
#' @examples
#' \donttest{
#' example_dataset_1 <- data.frame(
#'   substance_de = c("Spirotetramat", "Spirotetramat", "Spirotetramat", "Spirotetramat"),
#'   pNbr = c(7839, 7839, 7839, 7839),
#'   use_nr = c(5, 7, 18, 22),
#'   application_area_de = c("Obstbau", "Obstbau", "Obstbau", "Obstbau"),
#'   culture_de = c("Birne", "Kirsche", "Steinobst", "Kernobst"),
#'     pest_de = c("Birnblattsauger", "Kirschenfliege", "Blattläuse (Röhrenläuse)", "Spinnmilben")
#'     )
#'
#' example_dataset_2 <- data.frame(
#'   substance_de = c("Spirotetramat", "Spirotetramat", "Spirotetramat", "Spirotetramat"),
#'   pNbr = c(7839, 7839, 7839, 7839),
#'   use_nr = c(5, 7, 18, 22),
#'   application_area_de = c("Obstbau", "Obstbau", "Obstbau", "Obstbau"),
#'   culture_de = c("Birne", "Kirschen", "Steinobst", "Obstbau allg."),
#'     pest_de = c("Birnblattsauger", "Kirschenfliege", "Blattläuse (Röhrenläuse)", "Spinnmilben")
#'     )
#'
#' example_dataset_3 <- data.frame(
#'   substance_de = c("Pirimicarb"),
#'   pNbr = c(2210),
#'   use_nr = c(3),
#'   application_area_de = c("Feldbau"),
#'   culture_de = c("Getreide"),
#'     pest_de = c("Blattläuse (Röhrenläuse)")
#'     )
#'  
#'  example_dataset_4 <- data.frame(
#'   substance_de = c("Metaldehyd"),
#'   pNbr = c(6142),
#'   use_nr = c(1),
#'   application_area_de = c("Zierpflanzen"),
#'   culture_de = c("Zierpflanzen allg."),
#'     pest_de = c("Ackerschnecken/Deroceras Arten")
#'     )
#' library(srppp)
#' current_register <- srppp_dm()
#'
#' result1 <- resolve_cultures(example_dataset_1, current_register,
#'   correct_culture_names = FALSE)
#' print(result1)
#' result2 <- resolve_cultures(example_dataset_2, current_register,
#'  correct_culture_names = TRUE)
#' print(result2)
#' result3 <- resolve_cultures(example_dataset_2, current_register,
#'   correct_culture_names = FALSE)
#' print(result3)
#' result4 <- resolve_cultures(example_dataset_3, current_register,
#'   correct_culture_names = TRUE)
#' print(result4)
#' result5 <- resolve_cultures(example_dataset_4, current_register,
#'   correct_culture_names = TRUE)
#' print(result5)
#' }
resolve_cultures <- function(dataset, srppp,
  culture_column = "culture_de", correct_culture_names = TRUE)
{

  culture_leaf_df <- attr(attr(srppp, "culture_tree"), "culture_leaf_df")
  corrected_cultures <- FALSE

  if (correct_culture_names) {
        culture_leaf_df <- culture_leaf_df |>
      mutate(culture_de = case_when(
        str_detect(culture_de, "allg\\.") ~ str_replace(culture_de, "(.*) allg\\.", "allg. \\1"),
        TRUE ~ culture_de
      ) |> trimws())
    
    # Store original culture names
    original_cultures <- dataset[[culture_column]]

    # Reorganization of culture names
    dataset <- dataset |>
      mutate(!!sym(culture_column) := case_when(
        str_detect(!!sym(culture_column), "allg\\.") ~ str_replace(!!sym(culture_column), "(.*) allg\\.", "allg. \\1"),
        TRUE ~ !!sym(culture_column)
      ) |> trimws())

    # Check if any cultures were corrected
    corrected_cultures <- any(original_cultures != dataset[[culture_column]])

    if (corrected_cultures) {
      # Add new column with corrected names
      dataset[[paste0(culture_column, "_corrected")]] <- dataset[[culture_column]]
      # Restore original names in the main column
      dataset[[culture_column]] <- original_cultures

      dataset <-
      dataset |>
      mutate(!!sym(culture_column) := !!sym(paste0(culture_column, "_corrected"))) |>
        select(-all_of(paste0(culture_column, "_corrected")))


    }
  }

  join_spec <- "culture_de"
  names(join_spec) <- culture_column

  expanded_data <- dataset |>
    left_join(culture_leaf_df, by = join_spec, relationship = "many-to-many")

  return(expanded_data)
}
