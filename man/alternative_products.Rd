% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/alternatives.R
\name{alternative_products}
\alias{alternative_products}
\title{Find alternative products for all products containing certain active substances}
\usage{
alternative_products(
  srppp,
  active_ingredients,
  details = FALSE,
  missing = FALSE,
  list = FALSE,
  lang = c("de", "fr", "it"),
  resolve_cultures = TRUE
)
}
\arguments{
\item{srppp}{A \link{srppp_dm} object.}

\item{active_ingredients}{Character vector of active ingredient names that
will be matched against the column 'substances_de' in the srppp table
'substances'.}

\item{details}{Should a table of alternative uses with 'wNbr' and 'use_nr' be
returned?}

\item{missing}{If this is set to TRUE, uses without alternative product
registrations are listed.}

\item{list}{If TRUE, a list of three tables is returned, a table of uses
without alternative products ("Lückenindikationen"), a table of the number
of alternative products for each use, if any, and a detailed table of all
the alternative uses. This argument overrides the arguments 'details' and
'missing'.}

\item{lang}{The language used for the active ingredient names and the
returned tables.}

\item{resolve_cultures}{Logical. Specifies whether to resolve culture levels
to their most specific hierarchical level (leaf nodes) using a parent-child
relationship dataset derived from a culture tree.
\itemize{
\item If \code{TRUE} (default), the function maps culture levels to their corresponding
leaf nodes. This enables precise identification of alternative products at
the most specific culture level. This resolves the problem that products
are sometimes authorised for different cultural groups. This means that
actual "Lückenindikationen" can be identified. Only supported in German,
i.e. if \code{lang = "de"}.
\item If \code{FALSE}, the function retains the original culture levels without
hierarchical resolution. This option is useful when the original structure
of the culture data needs to be preserved.
\strong{Note}: This argument is only applicable when the language is set to
German (\code{de}). For other languages, the \code{resolve_cultures} functionality
is not implemented and must be set to \code{FALSE}.
}}
}
\value{
A \link[tibble:tibble]{tibble::tibble} containing use definitions as defined above, i.e.
containing columns with the application area, crop and pathogen. Depending
on the arguments, columns summarizing or listing the alternative products
and/or uses are also contained.
}
\description{
This function searches for uses of a given list of active substances and reports
either a table of uses with the number of available alternative products for each
use, a detailed table of the alternative product uses, a table of uses without
alternatives, or a list containing these three tables.
}
\details{
A use is defined here as a combination of an application area, a crop
('culture') and a pathogen ('pest'). This means, that for an alternative
product to be found, there has to be an exact match of application
area, crop an pathogen.
}
\examples{
\donttest{
sr <- try(srppp_dm())

# Fall back to internal test data if downloading or reading fails
if (inherits(sr, "try-error")) {
  sr <- system.file("testdata/Daten_Pflanzenschutzmittelverzeichnis_2024-12-16.zip",
      package = "srppp") |>
    srppp_xml_get_from_path(from = "2024-12-16") |>
    srppp_dm()
}

# Examples with two active substances
actives_de <- c("Lambda-Cyhalothrin", "Deltamethrin")
alternative_products(sr, actives_de)
alternative_products(sr, actives_de, resolve_cultures = FALSE)
alternative_products(sr, actives_de, missing = TRUE)
alternative_products(sr, actives_de, details = TRUE)
alternative_products(sr, actives_de, list = TRUE)

# Examples resolving cultures
actives_de <- c("Spinetoram")
alternative_products(sr, actives_de, resolve_cultures = FALSE, list = TRUE)
alternative_products(sr, actives_de, resolve_cultures = TRUE, list = TRUE)

actives_de <- c("Schalenwicklergranulose-Virus")
alternative_products(sr, actives_de, resolve_cultures = FALSE, list = TRUE)
alternative_products(sr, actives_de, resolve_cultures = TRUE, list = TRUE)

actives_de <- c("Emamectinbenzoat")
alternative_products(sr, actives_de, resolve_cultures = FALSE, list = TRUE)
alternative_products(sr, actives_de, resolve_cultures = TRUE, list = TRUE)

# Example in Italian
actives_it <- c("Lambda-Cialotrina", "Deltametrina")
alternative_products(sr, actives_it, lang = "it", resolve_cultures = FALSE)
}
}
