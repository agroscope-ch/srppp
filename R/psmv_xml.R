globalVariables(c("id", "name", "pk", "wNbr", "wGrp", "add_txt_pk"))

#' Read an XML version of the PSMV
#'
#' @param date A number giving a year starting from 2011 up to the current year
#' or the date of the publication as a length one character vector in the
#' format YYYY-MM-DD
#' @return An object inheriting from 'psmv_xml', 'xml_document', 'xml_node'
#' @export
#' @examples
#' psmv_2015 <- psmv_xml_get(2015)
#' print(psmv_2015)
#' class(psmv_2015)
#'
#' # The current PSMV
#' psmv_xml <- psmv_xml_get()
psmv_xml_get <- function(date = last(names(psmv::psmv_xml_zip_files)))
{
  if (is.numeric(date)) {
    if (date < 2011) stop("PSMV XML files are only available starting from 2011")
    date <- min(grep(paste0("^", date), psmv_xml_dates, value = TRUE))
  }
  path <- file.path(psmv::psmv_xml_idir, psmv::psmv_xml_zip_files[date])
  zip_contents <- utils::unzip(path, list = TRUE)
  xml_filename <- grep("PublicationData_20.._.._...xml",
    zip_contents$Name, value = TRUE)
  xml_con <- unz(path, xml_filename)
  ret <- xml2::read_xml(xml_con)
  class(ret) <- c("psmv_xml", "xml_document", "xml_node")
  return(ret)
}

#' Get Products from an XML version of the PSMV
#'
#' @param psmv_xml An object as returned by 'psmv_xml_get'
#' @param verbose Should we give some feedback?
#' @return A tibble with a row for each product section
#' in the XML file. An attribute 'duplicated_wNbrs' is
#' also returned, containing duplicated W-Numbers, if applicable,
#' or NULL.
#' @export
#' @examples
#' library(psmv)
#' # The first PSMV from 2015 (2015-01-06) has a duplicate W-Number
#' products_2015 <- psmv_xml_get(2015) |>
#'   psmv_xml_get_products(verbose = TRUE)
#'
#' # Get the current list of products
#' psmv_xml_get_products()
psmv_xml_get_products <- function(psmv_xml = psmv_xml_get(), verbose = TRUE) {
  product_nodeset <- xml_find_all(psmv_xml, "Products/Product")
  product_attribute_names <- names(xml_attrs(product_nodeset[[1]]))
  products <- product_nodeset |>
    xml_attrs() |>
    unlist() |>
    matrix(ncol = 7, byrow = TRUE,
      dimnames = list(NULL, product_attribute_names)) |>
    tibble::as_tibble() |>
    mutate(wGrp = as.integer(gsub("-.*$", "", wNbr)),
      .before = wNbr) |>
    group_by(wGrp) |>
    mutate(id = as.integer(id)) |>
    mutate(pNbr = if_else(id < 38, NA, id),
      .after = id) |>
    tidyr::fill(pNbr) |>
    ungroup() |>
    group_by(pNbr) |>
    arrange(wNbr, .by_group = TRUE) |>
    select(pNbr, wNbr, name, exhaustionDeadline, soldoutDeadline,
      isSalePermission, terminationReason)
  if (anyDuplicated(products$wNbr)) {
    dup_index <- which(duplicated(products$wNbr))
    dup_wNbrs <- products[dup_index, ]$wNbr
    if (verbose) message("Duplicated W-Numbers: ", paste(dup_wNbrs, collapse = ", "))
    attr(products, "duplicated_wNbrs") <- dup_wNbrs
  } else {
    attr(products, "duplicated_wNbrs") = NULL
    if (verbose) message("No duplicated W-Numbers")
  }

  return(products)
}

#' Get Substances from an XML version of the PSMV
#'
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
