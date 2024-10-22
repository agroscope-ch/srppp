build_culture_tree <- function(df) {
  # oot node (oberste Kulturebene)
  root <- Node$new("Cultures")

  # lookup table for nodes
  node_lookup <- new.env(hash = TRUE)

  # Nodes und Attribute bestimmen
  for (i in 1:nrow(df)) {
    if (is.null(node_lookup[[as.character(df$desc_pk[i])]])) {
      new_node <- root$AddChild(df$de[i])
      new_node$desc_pk <- df$desc_pk[i]  # desc_pk als Attribute
      node_lookup[[as.character(df$desc_pk[i])]] <- new_node
    }
  }

  # parent-child relationships
  for (i in 1:nrow(df)) {
    child_node <- node_lookup[[as.character(df$desc_pk[i])]]

    if (!is.na(df$parent_key_1[i])) {
      print("parent_key_1")
      parent_node <- node_lookup[[as.character(df$parent_key_1[i])]]
      if (!is.null(parent_node) &&
          !identical(child_node$parent, parent_node)) {
        child_node$parent$RemoveChild(child_node$name)
        parent_node$AddChildNode(child_node)
      }
    }

    if (!is.na(df$parent_key_2[i])) {
      print("parent_key_2")
      parent_node <- node_lookup[[as.character(df$parent_key_2[i])]]
      if (!is.null(parent_node) &&
          !identical(child_node$parent, parent_node)) {
        child_node$parent$RemoveChild(child_node$name)
        parent_node$AddChildNode(child_node)
      }
    }
  }

  return(root)
}


culture_tree <- build_culture_tree(Culture_descriptions)






#### Funktion Umwandlung culture-tree in mapping table (parent-child pairs) ####

# Initalisierung df for parent-child relationships
parent_child_df <- data.frame(parent = character(),
                              child = character(),
                              stringsAsFactors = FALSE)


extract_parent_child <- function(node) {
  if (!is.null(node$parent)) {
    parent_name <- node$parent$name
    child_name <- node$name


    parent_child_df <<- rbind(
      parent_child_df,
      data.frame(
        parent = parent_name,
        child = child_name,
        stringsAsFactors = FALSE
      )
    )
  }


  for (child in node$children) {
    extract_parent_child(child)
  }
}

# Apply the function to the root of the tree
extract_parent_child(culture_tree)

# Show the parent-child relationships
print(parent_child_df)







#### mapping unterste Kulturenebene ####
# Function to expand cultures using the culture tree and add lowest culture level
map_cultures_with_lowest <- function(dataset, culture_tree) {
  # Create an empty data frame to store expanded rows
  expanded_data <- data.frame()

  # Loop through each row in the dataset
  for (i in 1:nrow(dataset)) {
    row <- dataset[i, ]

    # Find matching cultures in the culture tree
    matching_cultures <- culture_tree %>%
      filter(parent == row$culture_de)

    # If matches are found, create a new row for each child culture
    if (nrow(matching_cultures) > 0) {
      for (j in 1:nrow(matching_cultures)) {
        new_row <- row
        # Set the new column to the child (specific culture)
        new_row$lowest_culture_de <- matching_cultures$child[j]
        expanded_data <- rbind(expanded_data, new_row)
      }
    } else {
      # If no match is found, the current culture is already the lowest level
      row$lowest_culture_de <- row$culture_de
      expanded_data <- rbind(expanded_data, row)
    }
  }

  return(expanded_data)
}


library(stringr)

df <- affected_cultures_x_pests %>%
  mutate(culture_de = case_when(
    str_detect(culture_de, "allg\\.") ~ str_replace(culture_de, "(.*) allg\\.", "allg. \\1"),
    TRUE ~ culture_de
  ) %>% trimws())

# Apply the function to the dataset
expanded_data <- map_cultures_with_lowest(df, parent_child_df)







