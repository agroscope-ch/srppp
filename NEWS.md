## version 0.99.2

- R/srppp-xml.R: Revise the structure of the `srppp_dm` object, after verifying that the product sections of different products with the same P-Number are identical, with the exception of the permission holder. Therefore, all tables describing the products, including the use definitions, are now tied to the `pNbrs` table with the `pNbr` as the primary key, instead of the `products` table which has the `wNbr` as a primary key. Functions, example code, vignettes and tests were adapted accordingly.

## version 0.99.1

- vignettes/srppp.rmd: Add an overview vignette which is displayed with the link 'Get started' in the online documentation

## version 0.3.4

- Rename the package from 'psmv' to 'srppp'

## version 0.3.3

### Format changes

- Remove redundant information from the ingredients table by removing
  all W-Numbers containing a dash. P-Numbers were added to the ingredient
  table as well, so product compositions can more easily be obtained
  using the ingredients table. Finally remove W-Numbers from the ingredients
  table. As a consequence, products and ingredients must now be joined
  by 'pNbr', and the relationship is 'many-to-many', as a 'pNbr' can
  occur more than once in the products table.
- The grouping of the products table by P-Numbers was removed, as it
  seemed not to be used anywhere and created spurious messages during 
  constraint checking.
