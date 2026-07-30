###############################################################################
# Federated aggregation
#
# These functions combine supplier aggregate responses into global results. They
# do not require, load, or request raw supplier activity records.
###############################################################################

as_tibble_safe <- function(x) {
  if (is.data.frame(x)) {
    tibble::as_tibble(x)
  } else {
    tibble::as_tibble(as.data.frame(x, stringsAsFactors = FALSE))
  }
}

aggregate_federated_results <- function(supplier_results) {
  assert_response_is_aggregate_only(supplier_results)

  stats <- dplyr::bind_rows(lapply(supplier_results, function(x) {
    as_tibble_safe(x$sufficient_statistics)
  }))

  record_counts <- dplyr::bind_rows(lapply(supplier_results, function(x) {
    as_tibble_safe(x$record_count)
  }))

  activity_totals <- dplyr::bind_rows(lapply(supplier_results, function(x) {
    as_tibble_safe(x$activity_totals)
  }))

  total_n <- sum(as.numeric(stats$n))
  total_sum <- sum(as.numeric(stats$sum_emissions_tco2e))
  total_sum_squares <- sum(as.numeric(stats$sum_squares_emissions_tco2e2))

  list(
    record_count = sum(as.numeric(record_counts$n)),
    total_emissions_tco2e = total_sum,
    mean_emissions_tco2e = total_sum / total_n,
    sample_variance_emissions_tco2e2 =
      (total_sum_squares - (total_sum^2 / total_n)) / (total_n - 1),
    activity_totals = activity_totals |>
      dplyr::group_by(activity_type) |>
      dplyr::summarise(
        n = sum(as.numeric(n)),
        total_emissions_tco2e = sum(as.numeric(total_emissions_tco2e)),
        .groups = "drop"
      ) |>
      dplyr::arrange(activity_type)
  )
}

compare_with_reference <- function(
    federated,
    reference,
    tolerance = sqrt(.Machine$double.eps)
) {
  scalar_comparison <- tibble::tibble(
    metric = c(
      "record_count",
      "total_emissions_tco2e",
      "mean_emissions_tco2e",
      "sample_variance_emissions_tco2e2"
    ),
    reference_value = c(
      reference$record_count,
      reference$total_emissions_tco2e,
      reference$mean_emissions_tco2e,
      reference$sample_variance_emissions_tco2e2
    ),
    federated_value = c(
      federated$record_count,
      federated$total_emissions_tco2e,
      federated$mean_emissions_tco2e,
      federated$sample_variance_emissions_tco2e2
    )
  ) |>
    dplyr::mutate(
      absolute_difference = abs(reference_value - federated_value),
      tolerance = tolerance,
      matches = absolute_difference <= tolerance
    )

  if (
    is.null(reference$activity_totals) ||
      nrow(reference$activity_totals) == 0
  ) {
    return(scalar_comparison)
  }

  activity_comparison <- dplyr::full_join(
    reference$activity_totals |>
      dplyr::rename(reference_value = total_emissions_tco2e),
    federated$activity_totals |>
      dplyr::rename(federated_value = total_emissions_tco2e),
    by = "activity_type"
  ) |>
    dplyr::transmute(
      metric = paste0("activity_total_tco2e:", activity_type),
      reference_value = reference_value,
      federated_value = federated_value,
      absolute_difference = abs(reference_value - federated_value),
      tolerance = tolerance,
      matches = absolute_difference <= tolerance
    )

  dplyr::bind_rows(scalar_comparison, activity_comparison)
}

run_federated_analysis <- function(
    suppliers,
    reference = NULL,
    output_dir = NULL,
    include_health = TRUE
) {
  supplier_results <- query_all_suppliers(suppliers, include_health = include_health)
  federated <- aggregate_federated_results(supplier_results)

  result <- list(
    supplier_results = supplier_results,
    federated = federated,
    formula = emission_calculation_formula()
  )

  if (!is.null(reference)) {
    result$comparison <- compare_with_reference(federated, reference)
  }

  if (!is.null(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
    write_federated_report(result, output_dir)
  }

  result
}
