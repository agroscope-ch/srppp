roxy:
	Rscript -e "roxygen2::roxygenize(roclets = c('rd', 'collate', 'namespace'))"
check::
	Rscript -e "devtools::check('.')"
install:
	R CMD INSTALL .
pd: roxy
	Rscript -e 'pkgdown::build_site(lazy = TRUE, run_dont_run = TRUE)'
pd_all: roxy
	Rscript -e 'pkgdown::build_site(lazy = FALSE, run_dont_run = TRUE)'
bump:
	Rscript -e 'fledge::bump_version("patch")'
minor:
	Rscript -e 'fledge::bump_version("minor")'
major:
	Rscript -e 'fledge::bump_version("major")'
finalize:
	Rscript -e 'fledge::finalize_version()'
