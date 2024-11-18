#' Resolve Cultures Function
#'
#' Resolves culture levels in a dataset to their lowest hierarchical level (leaf nodes)
#' using a parent-child relationship dataset derived from a culture tree.
#' If no match is found, the function assigns `NA` to the `leaf_culture_de` column.
#'
#' @importFrom stringr str_detect str_replace
#' @importFrom rlang sym :=
#' @importFrom dplyr case_when mutate
#' @param dataset A data frame or tibble containing the data to be processed. It
#'   should include a column that represents the culture information to be
#'   resolved.
#' @param srppp An [srppp_dm] object. From this object the parent child relations
#'   from the culture tree are used, which are stored as attribute 'parent_child_df'
#'   of the culture tree, which is itself stored as an attribute of the object.
#' @param culture_column (Optional) A character string specifying the column in
#'   the dataset that contains the culture information to be resolved. Defaults
#'   to `"culture_de"`.
#' @param correct_culture_names If this argument is set to `TRUE`, the following
#'   corrections will be applied: In the `culture_tree`, and consequently in the
#'   `parent_child_df`, there are variations in the naming of aggregated culture
#'   groups with "allg.". For example, both "Obstbau allg." and "allg. Obstbau"
#'   exist. However, information about the leaf nodes is only available in the
#'   culture groups that start with "allg. ...". This will be adjusted.
#'@param name_dup Logical. If `TRUE` (default), keeps "[dup]" suffixes in
#'  culture names. If `FALSE`, removes "[dup]" suffixes in the return data frame
#'  in the `leaf_culture_de` column. See Details for more information.
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
#'    lowest hierarchical level (leaf nodes) based on the `parent_child_df` mapping.
#'    For each row in the dataset, the function searches for a match in `parent_child_df`:
#'      - If a match is found, new rows are generated for each corresponding leaf culture.
#'      - If no match is found, the `leaf_culture_de` column is set to `NA`.
#'
#'    The result is an expanded dataset that includes an additional column (`leaf_culture_de`) containing
#'    the resolved cultures at their lowest level.
#'
#'**Duplicate Handling**: In the culture tree, some child cultures may have multiple parents. To distinguish
#'    these cases, the function appends "[dup]" to the culture name when a child has more than one parent.
#'    This helps maintain the integrity of the parent-child relationships in the resolved data.
#'
#'    However, the "[dup]" suffix can interfere with data processing tasks that require exact matching of
#'    culture names. For this reason, the `name_dup` parameter is provided:
#'    - When `name_dup = TRUE` (default), "[dup]" suffixes are kept, preserving the distinction between
#'      cultures with multiple parents.
#'    - When `name_dup = FALSE`, "[dup]" suffixes are removed in the return dataset in the `leaf_culture_de` column.
#'    This can be useful for tasks that require exact matching of culture names.
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
#' library(srppp)
#' current_register <- srppp_dm()
#'
#' result1 <- resolve_cultures(example_dataset_1, current_register)
#' print(result1)
#' result2 <- resolve_cultures(example_dataset_2, current_register)
#' print(result2)
#' result3 <- resolve_cultures(example_dataset_2, current_register,
#'   correct_culture_names = FALSE)
#' print(result3)
#'  result4 <- resolve_cultures(example_dataset_3, current_register,
#'   correct_culture_names = FALSE)
#' print(result4)
#' result5 <- resolve_cultures(example_dataset_3, current_register,
#'   correct_culture_names = FALSE,  name_dup = FALSE)
#' print(result5)
#' }
resolve_cultures <- function(dataset, srppp,
  culture_column = "culture_de", correct_culture_names = TRUE, name_dup = TRUE)
{

  parent_child_df <- attr(attr(srppp, "culture_tree"), "parent_child_df")
  corrected_cultures <- FALSE

  if (correct_culture_names) {
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
    }
  }

  # Helper function to get all descendants of a culture
  get_all_descendants <- function(culture, parent_child_df) {
    descendants <- culture
    children <- parent_child_df$child[parent_child_df$parent == culture]

    while (length(children) > 0) {
      descendants <- c(descendants, children)
      children <- unique(unlist(lapply(children, function(x) parent_child_df$child[parent_child_df$parent == x])))
      children <- children[!children %in% descendants]
    }

    return(unique(descendants))
  }

  # Get leaf nodes (cultures with no children)
  leaf_nodes <- setdiff(parent_child_df$child, parent_child_df$parent)

  expanded_data <- data.frame()

  for (i in 1:nrow(dataset)) {
    row <- dataset[i, ]
    culture <- if (corrected_cultures) row[[paste0(culture_column, "_corrected")]] else row[[culture_column]]

    # Get all descendants of the culture
    all_descendants <- get_all_descendants(culture, parent_child_df)

    # Filter for leaf nodes among descendants
    leaf_cultures <- intersect(all_descendants, leaf_nodes)

    if (length(leaf_cultures) > 0) {
      for (leaf in leaf_cultures) {
        new_row <- row
        new_row$leaf_culture_de <- leaf
        expanded_data <- rbind(expanded_data, new_row)
      }
    } else {
      # If no leaf cultures found, set leaf_culture_de to NA
      new_row <- row
      new_row$leaf_culture_de <- NA
      expanded_data <- rbind(expanded_data, new_row)
    }
  }

  # Remove "[dup]" if name_dup is FALSE
  if (!name_dup) {
    expanded_data <- expanded_data %>%
      mutate(across(c(!!sym(culture_column), leaf_culture_de),
                    ~str_remove(., "\\s*\\[dup\\]")))
  }

  return(expanded_data)
}
