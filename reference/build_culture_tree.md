# Build a Culture Tree

Constructs a hierarchical tree structure from a culture description
table that is created within the
[srppp_dm](https://agroscope-ch.github.io/srppp/reference/srppp_dm.md)
function. As each culture can have one or two parent nodes in an srppp
XML file, the nodes with two parent nodes are duplicated. The duplicated
nodes retain their primary key as an attribute, so the information on
their identity does not get lost.

## Usage

``` r
build_culture_tree(culture_descriptions)
```

## Arguments

- culture_descriptions:

  A tibble containing culture descriptions with the following columns:

  - `desc_pk`: Unique identifier for each culture node.

  - `de`: Culture name in German.

  - `fr`: Culture name in French.

  - `it`: Culture name in Italian.

  - `en`: Culture name in English.

  - `prt_1_pk`: Identifier of the first parent node (can be NA if no
    parent).

  - `prt_2_pk`: Identifier of the second parent node (can be NA if no
    second parent).

## Value

A [data.tree::Node](https://rdrr.io/pkg/data.tree/man/Node.html)
representing the root of the culture hierarchy. Each node in the tree
has the following attributes:

- `name_de`: The German name of the culture (from the `de` column).

- `name_fr`: The French name of the culture (from the `fr` column).

- `name_it`: The Italian name of the culture (from the `it` column).

- `culture_id`: The unique identifier of the culture

## Details

The function builds the culture tree in two main steps:

1.  Node Creation: It first creates all unique culture nodes and adds
    them to a lookup environment. Each node is initialized with its
    German name and its `culture_id`.

2.  Relationship Establishment: It then establishes parent-child
    relationships between nodes. Any node that has a second parent
    culture is duplicated and the duplicate is associated with the
    second parent culture
