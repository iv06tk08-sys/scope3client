###############################################################################
# Public calculation documentation
#
# The client does not calculate supplier emissions from raw supplier records in
# the federated workflow. That calculation happens server-side. This function is
# included so someone cloning only the client package can still see the emission
# formula and the aggregate statistics used by the client.
###############################################################################

emission_calculation_formula <- function() {
  list(
    local_record_formula = paste(
      "total_emissions_tco2e = quantity *",
      "(upstream_wtt_factor_kgco2e_per_unit + td_loss_factor_kgco2e_per_unit)",
      "/ 1000"
    ),
    federated_mean_formula = "global_mean = sum_supplier_sum_emissions / sum_supplier_n",
    federated_sample_variance_formula = paste(
      "global_sample_variance =",
      "(sum_supplier_sum_squares - sum_supplier_sum_emissions^2 / sum_supplier_n)",
      "/ (sum_supplier_n - 1)"
    ),
    privacy_note = paste(
      "The client receives n, totals, grouped totals, sum(x), and sum(x^2).",
      "It does not receive row-level quantities or invoice records."
    )
  )
}
