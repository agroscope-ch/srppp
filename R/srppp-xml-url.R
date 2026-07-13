#' Determine the URL of the XML version of the Swiss Register of Plant Protection Products
#'
#' @importFrom rvest html_elements html_attr
#' @return length one character string
#' @export
#' @examples
#' srppp_xml_url()
srppp_xml_url <- function() {
  base_url <- "https://www.blv.admin.ch/de/pflanzenschutzmittelverzeichnis"
  html_page <- read_html(base_url)

  links <- html_page |>
    html_elements("a") |>
    html_attr("href")

  link_index <- which(grepl("daten-pflanzenschutzmittelverzeichnis-de.zip", links))

  n_matching <- length(link_index)
  if (n_matching != 1) stop("Search for URL gave ", n_matching, " results")

  return(links[link_index])
}
