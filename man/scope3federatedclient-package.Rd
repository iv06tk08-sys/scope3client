\name{scope3federatedclient-package}
\alias{scope3federatedclient-package}
\alias{aggregate_federated_results}
\alias{assert_response_is_aggregate_only}
\alias{compare_with_reference}
\alias{emission_calculation_formula}
\alias{query_all_suppliers}
\alias{query_supplier}
\alias{run_federated_analysis}
\alias{supplier_activity_totals}
\alias{supplier_factor_version}
\alias{supplier_health}
\alias{supplier_record_count}
\alias{supplier_sufficient_statistics}
\alias{supplier_total_emissions}
\alias{write_federated_report}
\title{Client-side federated Scope 3 analysis helpers}
\description{
Client-side helpers for querying supplier API URLs, receiving aggregate-only
responses, aggregating global emissions results, and writing reports.
}
\usage{
emission_calculation_formula()
assert_response_is_aggregate_only(x)
supplier_health(base_url)
supplier_factor_version(base_url)
supplier_record_count(base_url, supplier_id)
supplier_total_emissions(base_url, supplier_id)
supplier_activity_totals(base_url, supplier_id)
supplier_sufficient_statistics(base_url, supplier_id)
query_supplier(base_url, supplier_id, include_health = TRUE)
query_all_suppliers(suppliers, include_health = TRUE)
aggregate_federated_results(supplier_results)
compare_with_reference(federated, reference, tolerance = sqrt(.Machine$double.eps))
run_federated_analysis(suppliers, reference = NULL, output_dir = NULL,
  include_health = TRUE)
write_federated_report(result, output_dir)
}
\arguments{
\item{x}{API response object to inspect for blocked raw fields.}
\item{base_url}{Supplier server base URL.}
\item{supplier_id}{Supplier identifier.}
\item{suppliers}{Data frame with \code{supplier_id} and \code{base_url} columns.}
\item{supplier_results}{List of aggregate supplier responses.}
\item{federated}{Federated aggregate result.}
\item{reference}{Optional centralised/reference result with matching metrics.}
\item{tolerance}{Numerical tolerance for comparison.}
\item{output_dir}{Directory for report outputs.}
\item{include_health}{Whether to query health and factor metadata endpoints.}
\item{result}{Result returned by \code{run_federated_analysis()}.}
}
\details{
The client does not load local supplier files. It computes global mean and
sample variance from supplier sufficient statistics:
\preformatted{
global_mean = sum_supplier_sum_emissions / sum_supplier_n
global_sample_variance =
  (sum_supplier_sum_squares - sum_supplier_sum_emissions^2 / sum_supplier_n) /
  (sum_supplier_n - 1)
}
}
\keyword{package}
