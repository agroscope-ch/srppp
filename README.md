# srppp - R package to deal with XML dumps of the Swiss Register of Plant Protection Products

<!-- badges: start -->
  [![R-CMD-check](https://github.com/agroscope-ch/srppp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/agroscope-ch/srppp/actions/workflows/R-CMD-check.yaml)
[![srppp status badge](https://agroscope-ch.r-universe.dev/badges/srppp)](https://agroscope-ch.r-universe.dev/ui/#package:srppp)
<!-- badges: end -->

## Description

Functions to generate data objects from XML versions of the Swiss
Register of Plant Protection Products (SRPPP). An online version of the
register can be accessed at <https://www.psm.admin.ch/de/produkte>. There is no
guarantee of correspondence of the data read in using this package with that
online version, or with the original registration documents.  Also, the
Federal Food Safety and Veterinary Office, coordinating the authorisation of
plant protection products in Switzerland, does not answer requests regarding
this package. 

## Installation

```
install.packages("srppp",
  repos = c("https://agroscope-ch.r-universe.dev", "https://cran.r-project.org"))
```

## Documentation

Please visit the [Documentation page](https://agroscope-ch.github.io/srppp)!

## See also

You may also be interested in our
[agroscope-ch/srppphist](https://github.com/agroscope-ch/srppphist) package containing
historical registration data starting from 2011.
