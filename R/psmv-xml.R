globalVariables(c("id", "name", "pk", "wNbr", "wGrp", "pNbr", "add_txt_pk",
    "de", "fr", "it", "en", "exhaustionDeadline", "soldoutDeadline",
    "isSalePermission", "terminationReason"))

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
    date <- min(grep(paste0("^", date), psmv::psmv_xml_dates, value = TRUE))
  }
  path <- file.path(psmv::psmv_xml_idir, psmv::psmv_xml_zip_files[date])
  zip_contents <- utils::unzip(path, list = TRUE)
  xml_filename <- grep("PublicationData_20.._.._...xml",
    zip_contents$Name, value = TRUE)
  xml_con <- unz(path, xml_filename)
  ret <- read_xml(xml_con)
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

#' Get substances from an XML version of the PSMV
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
  ret <- tibble::as_tibble(sub_desc) |>
    dplyr::mutate(pk = as.integer(pk)) |>
    dplyr::arrange(pk)

  return(ret)
}

#' Get ingredients for all products described in an XML version of the PSMV
#'
#' @param psmv_xml An object as returned by 'psmv_xml_get'
#' @export
#' @examples
#' psmv_xml_get_ingredients()
psmv_xml_get_ingredients <- function(psmv_xml = psmv_xml_get()) {
  ingredient_nodeset <- xml_find_all(psmv_xml, "Products/Product/ProductInformation/Ingredient")

  get_ingredient_map <- function(ingredient_node) {
    wNbr <- xml_attr(xml_parent(xml_parent(ingredient_node)), "wNbr")
    pk <- xml_attr(xml_child(ingredient_node, search = 2), "primaryKey")
    type <- xml_text(xml_child(ingredient_node, search = 1))
    attributes <- xml_attrs(ingredient_node)
    ret <- c(wNbr, pk, type, attributes)
    names(ret) <- c("wNbr", "pk", "type", "percent", "g_per_L", "add_txt_pk")
    return(ret)
  }

  ingredients <- t(sapply(ingredient_nodeset, get_ingredient_map)) |>
    tibble::as_tibble() |>
    mutate(add_txt_pk = as.integer(add_txt_pk)) |>
    mutate(pk = as.integer(pk))

  ingredient_descriptions <- psmv_xml |>
    xml_find_all(paste0("MetaData[@name='IngredientAdditionalText']/Detail")) |>
    sapply(get_descriptions, code = FALSE) |> t() |>
    tibble::as_tibble() |>
    rename(ingredient_de = de, ingredient_fr = fr) |>
    rename(ingredient_it = it, ingredient_en = en) |>
    mutate(pk = as.integer(pk)) |>
    arrange(pk)

  ret <- ingredients |>
    left_join(ingredient_descriptions, by = c(add_txt_pk = "pk")) |>
    select(-add_txt_pk) |>
    arrange(wNbr, pk)

  return(ret)
}

#' Get uses ('indications') for all products described in an XML version of the PSMV
#'
#' @param psmv_xml An object as returned by 'psmv_xml_get'
#' @export
#' @examples
#' psmv_xml_get_uses()
psmv_xml_get_uses <- function(psmv_xml = psmv_xml_get()) {
  use_nodeset <- xml_find_all(psmv_xml, "Products/Product/ProductInformation/Indication")

  get_use <- function(node) {
    wNbr <- xml_attr(xml_parent(xml_parent(node)), "wNbr")
    attributes <- xml_attrs(node)
    units_pk <- xml_attr(xml_child(node, search = 1), "primaryKey")
    ret <- c(wNbr, attributes, units_pk)
    names(ret) <- c("wNbr", "min_dosage", "max_dosage", "waiting_period", "min_rate", "max_rate", "units_pk")
    return(ret)
  }

  uses <- t(sapply(use_nodeset, get_use)) |>
    tibble::as_tibble() |>
    group_by(wNbr) |>
    mutate(use_nr = sequence(rle(wNbr)$length), .after = wNbr) |> # https://stackoverflow.com/a/46613159
    mutate_at(c("min_dosage", "max_dosage", "min_rate", "max_rate"), as.numeric) |>
    mutate_at(c("waiting_period", "units_pk"), as.integer)

  rate_unit_descriptions <- psmv_xml |>
    xml_find_all(paste0("MetaData[@name='Measure']/Detail")) |>
    sapply(get_descriptions, code = FALSE) |> t() |>
    tibble::as_tibble() |>
    rename(units_de = de, units_fr = fr) |>
    rename(units_it = it, units_en = en) |>
    mutate(pk = as.integer(pk)) |>
    arrange(pk)

  ret <- uses |>
    left_join(rate_unit_descriptions, by = c(units_pk = "pk")) |>
    select(-units_pk)

  return(ret)
}

#' Create a dm object from an XML version of the PSMV
#'
#' @inheritParams psmv_xml_get
#' @return A [dm] object with tables linked by foreign keys
#' pointing to primary keys, i.e. with referential integrity.
#' @export
#' @examples
#' library(psmv)
#' library(dm)
#' psmv_2017 <- psmv_dm(2017)
#' dm_examine_constraints(psmv_2017)
#' dm_nrow(psmv_2017)
#' # Show some information for products named 'Boxer'
#' psmv_2017 |>
#'   dm_filter(products = (name == "Boxer")) |>
#'   dm_nrow()
psmv_dm <- function(date = last(names(psmv::psmv_xml_zip_files))) {
  psmv_xml <- psmv_xml_get(date)
  products <- psmv_xml_get_products(psmv_xml)
  # Get W-Numbers from product information node
  get_wNbr <- function(product_information_node) {
    xml_attr(xml_parent(xml_parent(product_information_node)), "wNbr")
  }

  # Get product information with descriptions from ProductInformation section
  product_information_descriptions <- function(xml_doc, tag_name, code = FALSE) {

    # Find nodes and apply the function
    ret <- xml_doc |>
      xml_find_all(paste0("MetaData[@name='", tag_name, "']/Detail")) |>
      sapply(get_descriptions, code = code) |> t() |>
      tibble::as_tibble() |> mutate(pk = as.integer(pk)) |> arrange(pk)

    return(ret)
  }

  product_information_table <- function(xml_doc, tag_name, code = FALSE) {
    descriptions <- product_information_descriptions(xml_doc, tag_name,
      code = code)

    product_information_nodes <- xml_find_all(xml_doc,
      paste0("Products/Product/ProductInformation/", tag_name))

    ret <- tibble::tibble(
      wNbr = sapply(product_information_nodes, get_wNbr),
      pk = as.integer(xml_attr(product_information_nodes, "primaryKey"))) |>
        left_join(descriptions, by = "pk") |>
        arrange(wNbr)

    return(ret)
  }

  product_categories <- product_information_table(psmv_xml, "ProductCategory")
  formulation_codes <- product_information_table(psmv_xml, "FormulationCode")
  danger_symbols <- product_information_table(psmv_xml, "DangerSymbol", code = TRUE)
  signal_words <- product_information_table(psmv_xml, "SignalWords")
  CodeS <- product_information_table(psmv_xml, "CodeS")
  CodeR <- product_information_table(psmv_xml, "CodeR")
  # Permission holder was skipped, as we will probably not need this information

  substances <- psmv_xml_get_substances(psmv_xml)

  ingredients <- psmv_xml_get_ingredients(psmv_xml)

  uses <- psmv_xml_get_uses(psmv_xml)

  psmv_dm <- dm(products,
    product_categories, formulation_codes, danger_symbols, CodeS, CodeR,
    substances, ingredients,
    uses) |>
    dm_add_pk(products, wNbr) |>
    dm_add_pk(substances, pk) |>
    dm_add_fk(product_categories, wNbr, products) |>
    dm_add_fk(formulation_codes, wNbr, products) |>
    dm_add_fk(danger_symbols, wNbr, products) |>
    dm_add_fk(CodeS, wNbr, products) |>
    dm_add_fk(CodeR, wNbr, products) |>
    dm_add_fk(ingredients, wNbr, products) |>
    dm_add_fk(ingredients, pk, substances) |>
    dm_add_fk(uses, wNbr, products)

    return(psmv_dm)
}

#' Clean product names
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

#' Get descriptions from a node with childrent that hold descriptions
#' @keywords internal
#' @param node The node to look at
#' @param code Do the description nodes have a child holding a code?
get_descriptions <- function(node, code = FALSE) {
  pk <- xml_attr(node, "primaryKey")
  desc <- sapply(xml_children(node), xml_attr, "value")
  if (code) {
    code <- xml_attr(xml_child(xml_child(node)), "value")
    ret <- c(pk, code, desc)
    names(ret) <- c("pk", "code", "de", "fr", "it", "en")
  } else {
    ret <- c(pk, desc)
    names(ret) <- c("pk", "de", "fr", "it", "en")
  }
  return(ret)
}
