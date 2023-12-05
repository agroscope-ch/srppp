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

#' Define use identification numbers in a PSMV read in from an XML file
#'
#' @param psmv_xml An object as returned by 'psmv_xml_get'
#' @return An psmv_xml object with use_nr added as an attribute of 'Indication' nodes.
#' @export
#' @examples
#' psmv_xml_define_use_numbers()
psmv_xml_define_use_numbers <- function(psmv_xml = psmv_xml_get()) {
  use_nodeset <- xml_find_all(psmv_xml, "Products/Product/ProductInformation/Indication")

  uses <- tibble(wNbr = sapply(use_nodeset, get_wNbr, n = 2)) |>
    group_by(wNbr) |>
    mutate(use_nr = sequence(rle(wNbr)$length)) # https://stackoverflow.com/a/46613159

  xml_attr(use_nodeset, "use_nr") <- uses$use_nr

  return(psmv_xml)
}

#' Get uses ('indications') for all products described in an XML version of the PSMV
#'
#' @param psmv_xml An object as returned by 'psmv_xml_get'
#' @export
#' @examples
#' psmv_xml <- psmv_xml_get()
#' psmv_xml_get_uses(psmv_xml)
psmv_xml_get_uses <- function(psmv_xml = psmv_xml_get()) {
  psmv_xml <- psmv_xml_define_use_numbers(psmv_xml)
  use_nodeset <- xml_find_all(psmv_xml, "Products/Product/ProductInformation/Indication")

  get_use <- function(node) {
    wNbr <- xml_attr(xml_parent(xml_parent(node)), "wNbr")
    attributes <- xml_attrs(node)
    units_pk <- xml_attr(xml_child(node, search = 1), "primaryKey")
    
    # Searching for a child nodes with time units by name is too slow
    #time_units_pk <- xml_attr(xml_child(node, search = "TimeMeasure"), "primaryKey")
    
    ret <- c(wNbr, attributes, units_pk)
    names(ret) <- c("wNbr", "min_dosage", "max_dosage", "waiting_period", "min_rate", "max_rate", "use_nr", "units_pk")
    return(ret)
  }
  
  rate_unit_descriptions <- description_table(psmv_xml, "Measure") |> 
    rename(units_de = de, units_fr = fr) |>
    rename(units_it = it, units_en = en) |>
    mutate(pk = as.integer(pk)) |>
    arrange(pk)

  time_units_nodeset <- xml_find_all(psmv_xml, "Products/Product/ProductInformation/Indication/TimeMeasure")
  get_time_units <- function(node) {
    wNbr <- xml_attr(xml_parent(xml_parent(xml_parent((node)))), "wNbr")
    use_nr <- xml_attr(xml_parent(node), "use_nr")   
    time_units_pk <- xml_attr(node, "primaryKey")
    ret <- (c(wNbr, use_nr, time_units_pk))
    names(ret) <- c("wNbr", "use_nr", "time_units_pk")
    return(ret)
  }
  time_units <- t(sapply(time_units_nodeset, get_time_units)) |> 
    as_tibble() |> 
    mutate_at(c("use_nr", "time_units_pk"), as.integer)
  
  time_unit_descriptions <- psmv_xml |>
    xml_find_all(paste0("MetaData[@name='TimeMeasure']/Detail")) |>
    sapply(get_descriptions, code = FALSE) |> t() |>
    tibble::as_tibble() |>
    rename(time_units_de = de, time_units_fr = fr) |>
    rename(time_units_it = it, time_units_en = en) |>
    mutate(pk = as.integer(pk)) |>
    arrange(pk)
  
  uses <- t(sapply(use_nodeset, get_use)) |>
    tibble::as_tibble() |>
    mutate_at(c("min_dosage", "max_dosage", "min_rate", "max_rate"), as.numeric) |>
    mutate_at(c("waiting_period", "use_nr", "units_pk"), as.integer) |>
    select(wNbr, use_nr, min_dosage, max_dosage, waiting_period, min_rate, max_rate, units_pk) |> 
    left_join(time_units, by = join_by(wNbr, use_nr)) 

  ret <- uses |>
    left_join(rate_unit_descriptions, by = c(units_pk = "pk")) |>
    left_join(time_unit_descriptions, by = c(time_units_pk = "pk")) |>
    select(-units_pk, -time_units_pk)

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
  
  product_information_table <- function(psmv_xml, tag_name, code = FALSE) {
    descriptions <- description_table(psmv_xml, tag_name, code = code)

    product_information_nodes <- xml_find_all(psmv_xml,
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
  psmv_xml <- psmv_xml_define_use_numbers(psmv_xml)
  
  indication_information_table <- function(psmv_xml, tag_name) {
    
    indication_information_nodes <- xml_find_all(psmv_xml,
      paste0("Products/Product/ProductInformation/Indication/", tag_name))

    ret <- tibble::tibble(
      wNbr = sapply(indication_information_nodes, get_wNbr, n = 3),
      use_nr = sapply(indication_information_nodes, get_use_nr),
      pk = as.integer(xml_attr(indication_information_nodes, "primaryKey"))) |>
        arrange(wNbr)

    return(ret)
  }
  
  application_area_descriptons <- description_table(psmv_xml, "ApplicationArea")
  application_areas <- indication_information_table(psmv_xml, "ApplicationArea") |> 
    left_join(application_area_descriptions, by = join_by(pk)) |> 
    rename(application_area_de = de, application_area_fr = fr) |>
    rename(application_area_it = it, application_area_en = en) |>
    mutate(use_nr = as.integer(use_nr)) |> 
    select(-pk)
    
  application_comment_descriptions <- description_table(psmv_xml, "ApplicationComment")
  # In the culture descriptions, links to parent cultures are filtered out
  culture_descriptions <- description_table(psmv_xml, "Culture")
  pest_descriptions <- description_table(psmv_xml, "Pest", latin = TRUE)
  obligation_descriptions <- description_table(psmv_xml, "Obligation", code = TRUE)

  psmv_dm <- dm(products,
    product_categories, formulation_codes, danger_symbols, CodeS, CodeR,
    substances, ingredients,
    uses, application_areas) |>
    dm_add_pk(products, wNbr) |>
    dm_add_pk(substances, pk) |>
    dm_add_pk(uses, c(wNbr, use_nr)) |>
    dm_add_fk(product_categories, wNbr, products) |>
    dm_add_fk(formulation_codes, wNbr, products) |>
    dm_add_fk(danger_symbols, wNbr, products) |>
    dm_add_fk(CodeS, wNbr, products) |>
    dm_add_fk(CodeR, wNbr, products) |>
    dm_add_fk(ingredients, wNbr, products) |>
    dm_add_fk(ingredients, pk, substances) |>
    dm_add_fk(uses, wNbr, products) |> 
    dm_add_fk(application_areas, c(wNbr, use_nr), uses)

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

#' Get W-Numbers from parent or grandparent node
#' @keywords internal
get_wNbr <- function(node, n = 1) {
  wNbr <- case_when(
    n == 1 ~ xml_attr(xml_parent(node), "wNbr"),
    n == 2 ~ xml_attr(xml_parent(xml_parent(node)), "wNbr"),
    n == 3 ~ xml_attr(xml_parent(xml_parent(xml_parent(node))), "wNbr"))
  
  return(wNbr)
}

#' Get use number from parent node (indication information node)
#' @keywords internal
get_use_nr <- function(node) {
  xml_attr(xml_parent(node), "use_nr")
}

#' Get a table of descriptions for a certain Meta Information Tag
#' @keywords internal
description_table <- function(psmv_xml, tag_name, code = FALSE, latin = FALSE) {
  
  # Find nodes and apply the function
  ret <- psmv_xml |>
    xml_find_all(paste0("MetaData[@name='", tag_name, "']/Detail")) |>
    sapply(get_descriptions, code = code, latin = latin) |> t() |> 
    tibble::as_tibble() |> mutate(pk = as.integer(pk)) |> arrange(pk)

  return(ret)
}

#' Get descriptions from a node with children that hold descriptions
#' @keywords internal
#' @param node The node to look at
#' @param code Do the description nodes have a child holding a code?
#' @param latin Are there latin descriptions (e.g. for pest descriptions)
#' @examples
#' psmv_xml <- psmv_xml_get()
#' culture_detail_nodeset <- xml_find_all(psmv_xml, 
#'   "MetaData[@name='Culture']/Detail")
#' get_descriptions(culture_detail_nodeset[[1]])
#' get_descriptions(culture_detail_nodeset[[5]])
#' obligation_detail_nodeset <- xml_find_all(psmv_xml, 
#'   "MetaData[@name='Obligation']/Detail")
#' get_descriptions(obligation_detail_nodeset[[5]], code = TRUE)
get_descriptions <- function(node, code = FALSE, latin = FALSE) {
  pk <- xml_attr(node, "primaryKey")
  desc <- sapply(xml_children(node), xml_attr, "value")
  if (code) {
    if (xml_length(xml_child(node)) == 1) {
      code <- xml_attr(xml_child(xml_child(node)), "value")
    } else {
      code <- NA
    }
    ret <- c(pk, code, desc)
    names(ret) <- c("pk", "code", "de", "fr", "it", "en")
  } else {
    desc <- desc[!is.na(desc)] # Remove results from <Parent> nodes without "value"
    ret <- c(pk, desc)
    if (latin) {
      names(ret) <- c("pk", "de", "fr", "it", "en", "lt")
    } else {
      names(ret) <- c("pk", "de", "fr", "it", "en")
    }
  }
  return(ret)
}
