# R code used to store data objects useful for or read in from the XML exports
# of the PSMV
library(here) # For writing to the right directory from an RStudio project
library(dplyr)

# The URL of the current version published by BLV
psmv_xml_url <- paste0("https://www.blv.admin.ch/dam/blv/de/dokumente/",
  "zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/",
  "daten-pflanzenschutzmittelverzeichnis.zip.download.zip/",
  "Daten%20Pflanzenschutzmittelverzeichnis.zip")

# The path to the directory of the zip files containing the XML files
psmv_xml_idir <- file.path(fgpsm::WS_DB_idir, "06_PSMV/_PublicationData")

psmv_xml_zip_files <- dir(psmv_xml_idir, "PublicationData.*\\.zip", recursive = TRUE)
psmv_xml_dates <- gsub(
  "20../PublicationData_(....)_(..)_(..).*\\.zip",
  "\\1-\\2-\\3",
  psmv_xml_zip_files)
names(psmv_xml_zip_files) <- psmv_xml_dates

# The current PSMV as dm object


save(
  list = c(
    "psmv_xml_url",
    "psmv_xml_idir",
    "psmv_xml_dates",
    "psmv_xml_zip_files"
  ),
  file = here("data/psmv_xml.rda"),
  compress = "xz")
