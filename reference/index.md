# Package index

## A simple entity relationship model for the SRPPP

- [`srppp_dm()`](https://agroscope-ch.github.io/srppp/reference/srppp_dm.md)
  [`print(`*`<srppp_dm>`*`)`](https://agroscope-ch.github.io/srppp/reference/srppp_dm.md)
  : Create a dm object from an XML version of the Swiss Register of
  Plant Protection Products

## Functions for working with XML versions of the SRPPP

- [`alternative_products()`](https://agroscope-ch.github.io/srppp/reference/alternative_products.md)
  : Find alternative products for all products containing certain active
  substances
- [`application_rate_g_per_ha()`](https://agroscope-ch.github.io/srppp/reference/application_rate_g_per_ha.md)
  : Calculate application rates for active ingredients
- [`resolve_cultures()`](https://agroscope-ch.github.io/srppp/reference/resolve_cultures.md)
  : Resolve culture specifications to their lowest hierarchical level
- [`srppp_xml_clean_product_names()`](https://agroscope-ch.github.io/srppp/reference/srppp_xml_clean_product_names.md)
  : Clean product names

## Data objects for working with XML versions of the SRPPP

- [`srppp_xml_url`](https://agroscope-ch.github.io/srppp/reference/srppp_xml_url.md)
  : URL of the XML version of the Swiss Register of Plant Protection
  Products
- [`units_convertible_to_g_per_ha`](https://agroscope-ch.github.io/srppp/reference/units_convertible_to_g_per_ha.md)
  : Product application rate units convertible to grams active substance
  per hectare

## Helper functions mainly used internally

- [`srppp_xml_get()`](https://agroscope-ch.github.io/srppp/reference/srppp_xml_get.md)
  [`srppp_xml_get_from_path()`](https://agroscope-ch.github.io/srppp/reference/srppp_xml_get.md)
  : Read an XML version of the Swiss Register of Plant Protection
  Products
- [`srppp_xml_get_products()`](https://agroscope-ch.github.io/srppp/reference/srppp_xml_get_products.md)
  : Get Products from an XML version of the Swiss Register of Plant
  Protection Products
- [`srppp_xml_get_substances()`](https://agroscope-ch.github.io/srppp/reference/srppp_xml_get_substances.md)
  : Get substances from an XML version of the Swiss Register of Plant
  Protection Products
- [`srppp_xml_get_ingredients()`](https://agroscope-ch.github.io/srppp/reference/srppp_xml_get_ingredients.md)
  : Get ingredients for all registered products described in an XML
  version of the Swiss Register of Plant Protection Products
- [`srppp_xml_get_uses()`](https://agroscope-ch.github.io/srppp/reference/srppp_xml_get_uses.md)
  : Get uses ('indications') for all products described in an XML
  version of the Swiss Register of Plant Protection Products
- [`srppp_xml_define_use_numbers()`](https://agroscope-ch.github.io/srppp/reference/srppp_xml_define_use_numbers.md)
  : Define use identification numbers in an SRPPP read in from an XML
  file
- [`srppp_xml_get_parallel_imports()`](https://agroscope-ch.github.io/srppp/reference/srppp_xml_get_parallel_imports.md)
  : Get Parallel Imports from an XML version of the Swiss Register of
  Plant Protection Products
- [`l_per_ha_is_water_volume`](https://agroscope-ch.github.io/srppp/reference/l_per_ha_is_water_volume.md)
  : Use definitions where the rate in l/ha refers to the volume of the
  spraying solution
