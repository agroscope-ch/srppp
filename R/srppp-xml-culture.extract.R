
# library(srppp)
# srppp_xml <- srppp_xml_get()
# Culture_descriptions <- description_table_culture(srppp_xml)


#' Get a table of descriptions for Culture Meta Information Tag
#' @keywords internal
description_table_culture <- function(srppp_xml) {
  nodes <- srppp_xml |>
    xml_find_all(paste0("MetaData[@name='", "Culture", "']/Detail"))


  if (length(nodes) > 0) {
    ret <- nodes |>
      sapply(get_descriptions_culture) |>  t() |>
      as_tibble() |>
      mutate(desc_pk = as.integer(desc_pk)) |>
      arrange(desc_pk) |>
      separate(
        parent_keys,
        into = c("parent_key_1", "parent_key_2"),
        sep = ",",
        fill = "right",
        remove = FALSE
      ) |>
      select(-parent_keys)

  } else {
    ret <- NA
  }

  print(ret)
  return(ret)
}



#' Get descriptions from a node with children that hold descriptions
get_descriptions_culture <- function(node) {
  desc_pk <- xml_attr(node, "primaryKey")


  desc <- sapply(xml_children(node), function(child) {
    if (xml_name(child) == "Description") {
      return(xml_attr(child, "value"))
    }
    return(NULL)
  })
  desc <- desc[!sapply(desc, is.null)]  # Remove NULL values
  desc <- unlist(desc)

  parent_nodes <- xml_find_all(node, ".//Parent")

  if (length(xml_attr(parent_nodes, "primaryKey")) > 2) {stop("controll point: More than 2 parent cultures defined") }

  parent_keys <- NA
  if (length(xml_attr(parent_nodes, "primaryKey")) > 0) {
    parent_keys <- vector("character", length = length(parent_nodes))


    for (i_pn in 1:length(parent_nodes)) {
      parent_keys[i_pn] <- xml_attr(parent_nodes[i_pn], "primaryKey")
    }

    parent_keys <- paste(parent_keys, collapse = ",")
  }

  ret <- c(desc_pk, parent_keys, desc)
  names(ret) <- c("desc_pk", "parent_keys", "de", "fr", "it", "en")


  return(ret)
}



