# scope3federatedclient

`scope3federatedclient` is the client-side R package for the hosted federated
Scope 3 Category 3 architecture.

It is designed for the laptop/user side. It does not read local supplier `.rds`
files. It only talks to API URLs and aggregates supplier responses.

## Example

```r
library(scope3federatedclient)

suppliers <- data.frame(
  supplier_id = c(
    "SUPPLIER_AMERICAS_ENERGY",
    "SUPPLIER_APAC_ENERGY",
    "SUPPLIER_EUROPE_UTILITIES"
  ),
  base_url = c(
    "https://scope3-server.example.com",
    "https://scope3-server.example.com",
    "https://scope3-server.example.com"
  )
)

result <- run_federated_analysis(
  suppliers = suppliers,
  output_dir = "outputs"
)

result$federated
```

## What the client receives

The client receives only:

- record counts;
- total emissions;
- activity-level totals that passed the server-side minimum group-size rule;
- sufficient statistics: `n`, `sum(x)`, and `sum(x^2)`.

It does not receive:

- invoice-level records;
- site-level records;
- individual fuel-purchase records;
- raw activity quantities;
- invoice references.

## Formula visibility

Run:

```r
emission_calculation_formula()
```

to see the server-side record formula and the client-side federated aggregation
formula.

## Client-server workflow article

The client-server workflow is documented in:

```text
vignettes/client-server-workflow.Rmd
```

An installed Markdown copy is also available at:

```r
system.file("doc", "client-server-workflow.md", package = "scope3federatedclient")
```

It demonstrates how to start the `scope3supplier` API and obtain emissions
results from `scope3federatedclient` using only API URLs.
