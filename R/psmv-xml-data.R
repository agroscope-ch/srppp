#' Path to the directory where the published XML versions of the PSMV are stored
#'
#' This is a string, specifying the path to the input files, meant to be used on the RStudio server machines, where the
#' corresponding mount should be present.
#'
#' @name psmv_xml_idir
#' @docType data
#' @format length one character string
#' @examples
#' print(psmv_xml_idir)
"psmv_xml_idir"

#' Publication dates of the available zip files
#'
#' @name psmv_xml_dates
#' @docType data
#' @format character vector of publication dates in the format YYYY-MM-DD
#' @examples
#' print(psmv_xml_dates)
"psmv_xml_dates"

#' Relative paths of the available zip files
#'
#' @name psmv_xml_zip_files
#' @docType data
#' @format character vector of paths relative to 'psmv_xml_idir',
#' named with their publication dates in the format YYYY-MM-DD
#' @examples
#' print(psmv_xml_zip_files)
"psmv_xml_zip_files"

#' URL of the current XML version of the PSMV published by the BLV
#'
#' @name psmv_xml_url
#' @docType data
#' @format length one character string
#' @examples
#' print(psmv_xml_url)
"psmv_xml_url"

#' List of 'psmv_dm' objects for all years starting 2012
#'
#' For each year, the first XML dump published by FOAG is used.
#'
#' @name psmv_list
#' @docType data
#' @format list A list of PSMV versions created with [psmv_dm], named with a
#' character vector of the respective years
#' @examples
#' names(psmv_list)
"psmv_list"
