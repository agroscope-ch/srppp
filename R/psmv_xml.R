globalVariables(c("id", "name", "pk", "wNbr", "wGrp", "add_txt_pk"))
#' Read an XML version of the PSMV
#'
#' @param date The date of the publication in the format YYYY-MM-DD
#' @importFrom xml2 read_xml
#' @importFrom utils unzip
#' @return An object inheriting from 'psmv_xml', 'xml_document', 'xml_node'
#' @export
#' @examples
#' psmv_xml <- psmv_xml_get()
#' print(psmv_xml)
#' class(psmv_xml)
#' psmv_xml_get("2023-04-04")
psmv_xml_get <- function(date = dplyr::last(names(psmv::psmv_xml_zip_files)))
{
  path <- file.path(psmv::psmv_xml_idir, psmv::psmv_xml_zip_files[date])
  zip_contents <- unzip(path, list = TRUE)
  xml_filename <- grep("PublicationData_20.._.._...xml",
    zip_contents$Name, value = TRUE)
  xml_con <- unz(path, xml_filename)
  ret <- read_xml(xml_con)
  class(ret) <- c("psmv_xml", "xml_document", "xml_node")
  return(ret)
}

#' Get Products from an XML version of the PSMV
#'
#' @importFrom xml2 xml_find_all xml_attr
#' @importFrom tibble tibble as_tibble
#' @importFrom tidyr fill
#' @param psmv_xml An object as returned by 'psmv_xml_get'
#' @param verbose Should we give some feedback?
#' @return A tibble with a row for each product section
#' in the XML file. An attribute 'duplicated_wNbrs' is
#' also returned, containing duplicated W-Numbers, if applicable,
#' or NULL.
#' @export
#' @examples
#' psmv_xml_get_products()
psmv_xml_get_products <- function(psmv_xml = psmv_xml_get(), verbose = TRUE) {
  product_nodeset <- xml_find_all(psmv_xml, "Products/Product")
  product_attributes <- names(xml_attrs(product_nodeset[[1]]))
  products <- product_nodeset |>
    xml_attrs() |>
    unlist() |>
    matrix(ncol = 7, byrow = TRUE,
      dimnames = list(NULL, product_attributes)) |>
    as_tibble() |>
    dplyr::mutate(wGrp = as.integer(gsub("-.*$", "", wNbr)),
      .before = wNbr) |>
    dplyr::group_by(wGrp) |>
    dplyr::mutate(id = as.integer(id)) |>
    dplyr::mutate(pNbr = if_else(id < 38, NA, id),
      .after = id) |>
    tidyr::fill(pNbr) |>
    dplyr::ungroup() |>
    dplyr::group_by(pNbr) |>
    dplyr::arrange(wNbr, .by_group = TRUE) |>
    select(pNbr, wNbr, name, exhaustionDeadline, soldoutDeadline,
      isSalePermission, terminationReason)
  if (anyDuplicated(products$wNbr)) {
    dup_index <- which(duplicated(products$wNbr))
    dup_wNbrs <- products[dup_index, ]$wNbr
    if (verbose) message("Duplicated W-Numbers", dup_wNbrs)
    dup_wattr(products, "duplicated_wNbrs") <- dup_wNbrs
  } else {
    attr(products, "duplicated_wNbrs") = NULL
    if (verbose) message("No duplicated W-Numbers")
  }

  return(products)
}

#' Get Substances from an XML version of the PSMV
#'
#' @importFrom xml2 xml_find_all xml_attr xml_attrs xml_children
#' @importFrom tibble tibble as_tibble
#' @param psmv_xml An object as returned by 'psmv_xml_get'
#' @export
#' @examples
#' psmv_xml_get_substances()
psmv_xml_get_substances <- function(psmv_xml = psmv_xml_get()) {
  substance_nodeset <- xml_find_all(psmv_xml, "MetaData[@name='Substance']/Detail")

  sub_desc <- t(sapply(substance_nodeset, function(sub_node) {
    c(xml_attr(sub_node, "primaryKey"),
      xml_attr(sub_node, "iupacName"),
      xml_attr(xml_children(sub_node), "value")
    )
  }))

  colnames(sub_desc) <- c("pk", "iupac", "de", "fr", "it", "en", "lt")
  as_tibble(sub_desc) |>
    dplyr::mutate(pk = as.integer(pk)) |>
    dplyr::arrange(pk)
}

#' Get ingredients for all products described in an XML version of the PSMV
#'
#' This function takes a while for execution, as it extracts the
#' information from a few thousands of products.
#'
#' @importFrom xml2 xml_find_all xml_attrs xml_child xml_text
#' @importFrom tibble tibble as_tibble
#' @importFrom dplyr mutate
#' @param psmv_xml An object as returned by 'psmv_xml_get'
#' @param cores The number of cores to use in mclapply
#' @export
psmv_xml_get_ingredients <- function(psmv_xml = psmv_xml_get(), cores = 1) {
  product_nodeset <- xml_find_all(psmv_xml, "Products/Product")
  names(product_nodeset) <- xml_attr(product_nodeset, "wNbr")

  get_ingredient <- function(ingredient_node) {
    pk <- xml_attr(xml_child(ingredient_node, search = 2), "primaryKey")
    type <- xml_text(xml_child(ingredient_node, search = 1))
    attributes <- xml_attrs(ingredient_node)
    ret <- c(pk, type, attributes)
    names(ret) <- c("pk", "type", "percent", "g_per_L", "add_txt_pk")
    return(ret)
  }

  get_ingredient_table <- function(product_node) {
    ingredient_nodeset <- xml_find_all(product_node, "ProductInformation/Ingredient")
    t(sapply(ingredient_nodeset, get_ingredient))
  }

  ingredient_table_list <- parallel::mclapply(product_nodeset,
    get_ingredient_table,
    mc.cores = cores)

  ingredients <- vctrs::vec_rbind(!!!ingredient_table_list,
    .names_to = "wNbr") |>
    as_tibble() |>
    mutate(add_txt_pk = as.integer(add_txt_pk)) |>
    mutate(pk = as.integer(pk))

  return(ingredients)
}

#' Clean product names
#'
#' This function is used in the data generation script for [psmv_xml_product_names].
#'
#' @param names The product names that should be cleaned from comments
#' @export
psmv_xml_clean_product_names <- function(names) {
  names |>
    trimws() |>
    stringr::str_remove(" \\(Bew. suspendiert.*\\)$") |>
    stringr::str_remove(" \\(Bew. beendet.*\\)$") |>
    stringr::str_remove(" \\[Bewilligung beendet.*\\]$") |>
    stringr::str_remove(" Bewilligung beendet.*") |>
    stringr::str_remove(" \\[Die Verwendung der Charge.*$") |>
    stringr::str_remove(" \\[Erneuerungsgesuch in Bearbeitung\\]$") |>
    stringr::str_remove(" \\[Erneuerung in Bearbeitung\\]$") |>
    stringr::str_remove(" \\(Erneuerungsgesuch in Bearbeitung\\)$") |>
    stringr::str_remove(" \\[deman[cd]e de renouvellement en cours\\]$") |>
    stringr::str_remove(" \\(demande de renouvellement en cours\\)$") |>
    stringr::str_remove(" \\[Ausverkaufs.*frist.*\\]$") |>
    stringr::str_remove(" \\[Aufbrauch.*frist.*\\]$") |>
    stringr::str_remove(" \\[Wegen h.ngigem.*\\]$")
}
