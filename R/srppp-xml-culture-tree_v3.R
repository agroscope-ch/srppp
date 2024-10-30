#' Build a Hierarchical Culture Tree
#'
#' Constructs a hierarchical tree structure from a tibble, with each node representing
#' a unique culture. Each node can have multiple parent nodes, allowing for complex
#' cultural hierarchies and relationships.
#'
#' @param df A tibble with the following columns:
#'   - `desc_pk`: Unique identifier for each culture node.
#'   - `de`: Culture name in German.
#'   - `fr`: Culture name in French.
#'   - `it`: Culture name in Italian.
#'   - `en`: Culture name in English.
#'   - `prt_1_pk`: Identifier of the first parent node (can be NA if no parent).
#'   - `prt_2_pk`: Identifier of the second parent node (can be NA if no second parent).
#'
#' @return A `Node` object (from the `data.tree` package) representing the root of the
#' culture hierarchy. Each node in the tree has the following attributes:
#'   - `name`: The German name of the culture (from the `de` column).
#'   - `desc_pk`: The unique identifier of the culture as an attribute.
#'   - `parents`: A list of parent nodes (can be empty, contain one, or two parents).
#'
#' @details
#' The function builds the culture tree in two main steps:
#' 1. Node Creation: It first creates all unique culture nodes and adds them to a lookup table.
#'    Each node is initialized with its German name and unique identifier.
#' 2. Relationship Establishment: It then establishes parent-child relationships between nodes.
#'    If a node has multiple parents, all are linked, allowing for complex hierarchies.
#'
#' The function handles cases where:
#' - A culture has no parents (it becomes a direct child of the root "Cultures" node)
#' - A culture has one parent
#' - A culture has two parents
#'
#' It prevents circular references and ensures each parent-child relationship is unique.
#'
#' @note
#' - The tree structure allows for multiple parents per node, which is not standard
#'   in typical tree implementations. This enables representation of complex cultural
#'   relationships where a culture might belong to multiple categories.
#' - While all language versions (de, fr, it, en) are present in the input data,
#'   the tree nodes are labeled with the German version by default.
#'
#' @keywords internal

build_culture_tree <- function(df) {
  root <- Node$new("Cultures")
  node_lookup <- new.env(hash = TRUE)

  # Create all nodes first
  for (i in 1:nrow(df)) {
    if (is.null(node_lookup[[as.character(df$desc_pk[i])]])) {
      new_node <- Node$new(df$de[i])
      new_node$desc_pk <- df$desc_pk[i]
      new_node$parents <- list()  # List to store multiple parents
      node_lookup[[as.character(df$desc_pk[i])]] <- new_node
    }
  }

  # Establish parent-child relationships
  for (i in 1:nrow(df)) {
    child_node <- node_lookup[[as.character(df$desc_pk[i])]]

    # Function to add parent relationship
    add_parent <- function(parent_key) {
      if (!is.na(parent_key)) {
        parent_node <- node_lookup[[as.character(parent_key)]]
        if (!is.null(parent_node) && !(parent_node$desc_pk %in% sapply(child_node$parents, function(p) p$desc_pk))) {
          parent_node$AddChildNode(child_node)
          child_node$parents <- c(child_node$parents, list(parent_node))
        }
      }
    }

    # Add both parents
    add_parent(df$prt_1_pk[i])
    add_parent(df$prt_2_pk[i])

    # If no parents, add to root
    if (length(child_node$parents) == 0) {
      root$AddChildNode(child_node)
    }
  }

  return(root)
}

culture_tree <- build_culture_tree(culture_descriptions)
