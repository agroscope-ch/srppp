PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
TGZ     := $(PKGNAME)_$(PKGVERS).tar.gz
TGZVNR  := $(PKGNAME)_$(PKGVERS)-vignettes-not-rebuilt.tar.gz
RBIN ?= $(shell dirname "`which R`")

pkgfiles = \
	.Rbuildignore \
	data/* \
	DESCRIPTION \
	inst/data_generation/* \
	man/* \
	NAMESPACE \
	README.md \
	R/* \
	vignettes/*.Rmd

$(TGZ): $(pkgfiles)
	"$(RBIN)/R" CMD build . 2>&1 | tee log/build.log

$(TGZVNR): $(pkgfiles)
	"$(RBIN)/R" CMD build . --no-build-vignettes;\
	mv $(TGZ) $(TGZVNR)

roxy:
	Rscript -e "roxygen2::roxygenize(roclets = c('rd', 'collate', 'namespace'))"
	# https://stackoverflow.com/a/72679175/3805440 describes how to make PhantomJS work in roxygen markdown
	# by setting an environment variable, but this is not currently used here

build: $(TGZ)

install: $(TGZ)
	"$(RBIN)/R" CMD INSTALL $(TGZ)

quickinstall: $(TGZVNR)
	"$(RBIN)/R" CMD INSTALL $(TGZVNR)

check: $(TGZ)
	_R_CHECK_CRAN_INCOMING_REMOTE_=false "$(RBIN)/R" CMD check --as-cran --no-tests $(TGZ) 2>&1 | tee log/check.log

quickcheck: $(TGZVNR)
	mv $(TGZVNR) $(TGZ)
	_R_CHECK_CRAN_INCOMING_REMOTE_=false "$(RBIN)/R" CMD check --no-tests --no-build-vignettes --no-vignettes $(TGZ)
	mv $(TGZ) $(TGZVNR)

pd:
	Rscript -e 'pkgdown::build_site(lazy = TRUE, run_dont_run = TRUE)'

pd_all:
	Rscript -e 'pkgdown::build_site(lazy = FALSE, run_dont_run = TRUE)'

test: 
	Rscript -e 'devtools::test()' 2>&1 | tee log/test.log
	sed -i -e "s/.*\r.*\r//" log/test.log

.PHONY: roxy build install quickinstall check quickcheck pd pd_all test
