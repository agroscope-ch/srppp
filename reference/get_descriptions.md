# Get descriptions from a node with children that hold descriptions

Get descriptions from a node with children that hold descriptions

## Usage

``` r
get_descriptions(node, code = FALSE, latin = FALSE, parent_keys = FALSE)
```

## Arguments

- node:

  The node to look at

- code:

  Do the description nodes have a child holding a code?

- latin:

  Are there latin descriptions (e.g. for pest descriptions)

- parent_keys:

  For culture descriptions, we also return up to two primary keys that
  link to parent cultures
