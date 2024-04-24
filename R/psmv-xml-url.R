#' Path to the directory where the published XML versions of the PSMV are stored
#'
#' This is a string, specifying the path to the input files, meant to be used on the RStudio server machines, where the
#' corresponding mount should be present.
#'
#' @docType data
#' @format length one character string
#' @export
#' @examples
#' print(psmv_xml_url)
psmv_xml_url <- paste0("https://www.blv.admin.ch/dam/blv/de/dokumente/",
  "zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/",
  "daten-pflanzenschutzmittelverzeichnis.zip.download.zip/",
  "Daten%20Pflanzenschutzmittelverzeichnis.zip")
