
<!-- README.md is generated from README.rmd. Please edit that file -->

# srppp - R package to read XML dumps of the Swiss Register of Plant Protection Products

<!-- badges: start -->

[![CRAN
version](https://www.r-pkg.org/badges/version/srppp)](https://cran.r-project.org/package=srppp)
[![R-universe
status](https://agroscope-ch.r-universe.dev/badges/srppp)](https://agroscope-ch.r-universe.dev/srppp)
[![R-CMD-check](https://github.com/agroscope-ch/srppp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/agroscope-ch/srppp/actions/workflows/R-CMD-check.yaml)
[![DOI](https://zenodo.org/badge/832080563.svg)](https://doi.org/10.5281/zenodo.13993340)
<!-- badges: end -->

## Description

Generate data objects from XML versions of the Swiss Register of Plant
Protection Products. An online version of the register can be accessed
at <https://www.psm.admin.ch/de/produkte>. There is no guarantee of
correspondence of the data read in using this package with that online
version, or with the original registration documents. Also, the Federal
Food Safety and Veterinary Office, coordinating the authorisation of
plant protection products in Switzerland, does not answer requests
regarding this package. Please refer to the website of the registration
authorities for additional information about the data made available via
this package. The following important notes published at that website
are included here in an inofficial translation for convenience: The
register contains all plant protection products registered in
Switzerland, independent of their availability on the market; The
mentioning of a product does not imply a recommendation; Products with
expired authorisation and retracted parallel imports remain in the
register until the deadline for the last lawful use
(“exhaustionDeadline” in the XML file) has expired; In case of doubt,
only the original registration documents apply; When using the data, the
BLV (Federal Food Safety and Veterinary Office) has to be mentioned as
the data source, and a reference to the official register has to be
made; Commercial use of the data without consent of the BLV is
prohibited.

## Installation from CRAN

    install.packages("srppp")

## Installation of the latest development code

    install.packages("srppp",
      repos = c("https://agroscope-ch.r-universe.dev", "https://cran.r-project.org"))

## Documentation

A good point to start is the vignette [“Get
Started”](https://agroscope-ch.github.io/srppp/articles/srppp.html) in
the online documentation.

## See also

You may also be interested in our
[agroscope-ch/srppphist](https://agroscope-ch.github.io/srppphist/)
package containing historical registration data starting from 2011. This
package is generally updated each year after the first publication of
the register as an XML file.
