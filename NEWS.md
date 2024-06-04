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
