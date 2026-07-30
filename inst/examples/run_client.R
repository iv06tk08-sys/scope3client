library(scope3federatedclient)

suppliers <- data.frame(
  supplier_id = c(
    "SUPPLIER_AMERICAS_ENERGY",
    "SUPPLIER_APAC_ENERGY",
    "SUPPLIER_EUROPE_UTILITIES"
  ),
  base_url = rep("http://127.0.0.1:8080", 3)
)

result <- run_federated_analysis(
  suppliers = suppliers,
  output_dir = "outputs"
)

print(result$federated)
