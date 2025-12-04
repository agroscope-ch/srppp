# Read an XML version of the Swiss Register of Plant Protection Products

Read an XML version of the Swiss Register of Plant Protection Products

## Usage

``` r
srppp_xml_get(from, ...)

# S3 method for class '`NULL`'
srppp_xml_get(from, ...)

# S3 method for class 'character'
srppp_xml_get(from, ...)

srppp_xml_get_from_path(path, from)
```

## Arguments

- from:

  A specification of the way to retrieve the XML

- ...:

  Unused argument introduced to facilitate future extensions

- path:

  A path to a zipped SRPPP XML file

## Value

An object inheriting from 'srppp_xml', 'xml_document', 'xml_node'

## Examples

``` r
# Try to get the current SRPPP as available from the FOAG website
# \donttest{
srppp_cur <- try(srppp_xml_get())
# }
```
