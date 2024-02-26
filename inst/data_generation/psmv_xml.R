# R code used to store data objects useful for or read in from the XML exports
# of the PSMV
library(here) # For writing to the right directory from an RStudio project
library(dplyr)
library(psmv)

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

save(
  list = c(
    "psmv_xml_url",
    "psmv_xml_idir",
    "psmv_xml_dates",
    "psmv_xml_zip_files"
  ),
  file = here("data/psmv_xml.rda"),
  compress = "xz")

# Install the package to make these objects known to psmv_dm,
# or source psmv_dm with these objects present

# One PSMV for each year
years <- 2011:2024
time <- system.time({
  psmv_list <- parallel::mclapply(years, psmv_dm, mc.cores = 4)
  names(psmv_list) <- years
})


# Get all pk values of substances that are used as active ingredients in any year
psmv_ingredients <- bind_rows(lapply(psmv_list, function(x) x$ingredients), .id = "year")
psmv_substances <- bind_rows(lapply(psmv_list, function(x) x$substances), .id = "year")
psmv_active_ingredient_pks <- psmv_ingredients |>
  filter(type == "ACTIVE_INGREDIENT") |>
  left_join(psmv_substances, by = join_by(pk, year)) |>
  select(pk) |>
  unique() |>
  arrange(pk)

# Manually check if pks always refer to the same substance
if (FALSE) {
  psmv_ai_check_dups <- psmv_substances |>
    filter(pk %in% psmv_active_ingredient_pks$pk) |>
    select(pk, iupac, substance_de, substance_fr, substance_it, substance_en) |>
    unique() |>
    arrange(pk)

  dup_ai_pks <- psmv_ai_check_dups[duplicated(psmv_ai_check_dups$pk), ]$pk |>
    unique()

  tmp <- psmv_ai_check_dups |>
    filter(pk %in% dup_ai_pks) |>
    select(pk, substance_de)

  print(tmp[1:39, ], n = Inf)
  print(tmp[40:79, ], n = Inf)
  print(tmp[80:120, ], n = Inf)
}

# This is the case, so we can establish a list of pk values from the last occurrence of each pk
psmv_active_substances <- psmv_substances |>
  group_by(pk) |>
  summarise(year = max(year)) |>
  left_join(psmv_substances, by = join_by(pk, year)) |>
  rename(latest_year = year)

save(psmv_active_substances, file = here("data/psmv_active_substances.rda"), compress = "xz")

# Check if accidentially included confidential information is removed
sapply(psmv_list, function(psmv) {
  confidential <- psmv$ingredients |>
    filter(type == "ADDITIVE_TO_DECLARE" & (percent != "" | g_per_L != ""))
  nrow(confidential)
})

# Check referential integrity of the dm objects
lapply(psmv_list, function(psmv) dm_examine_constraints(psmv))

save("psmv_list", file = here("data/psmv_list.rda"), compress = "xz")
