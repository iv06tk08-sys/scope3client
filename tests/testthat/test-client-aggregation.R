test_that("federated aggregation uses sufficient statistics", {
  supplier_results <- list(
    A = list(
      record_count = list(supplier_id = "A", n = 2),
      activity_totals = tibble::tibble(
        supplier_id = "A",
        activity_type = "Electricity",
        n = 2,
        total_emissions_tco2e = 3
      ),
      sufficient_statistics = list(
        supplier_id = "A",
        n = 2,
        sum_emissions_tco2e = 3,
        sum_squares_emissions_tco2e2 = 5
      )
    ),
    B = list(
      record_count = list(supplier_id = "B", n = 1),
      activity_totals = tibble::tibble(
        supplier_id = "B",
        activity_type = "Natural gas",
        n = 1,
        total_emissions_tco2e = 3
      ),
      sufficient_statistics = list(
        supplier_id = "B",
        n = 1,
        sum_emissions_tco2e = 3,
        sum_squares_emissions_tco2e2 = 9
      )
    )
  )

  federated <- aggregate_federated_results(supplier_results)

  expect_equal(federated$record_count, 3)
  expect_equal(federated$total_emissions_tco2e, 6)
  expect_equal(federated$mean_emissions_tco2e, 2)
  expect_equal(federated$sample_variance_emissions_tco2e2, stats::var(c(1, 2, 3)))
})

test_that("privacy check rejects raw fields", {
  expect_error(
    assert_response_is_aggregate_only(list(quantity = 100)),
    "blocked raw-data fields"
  )
})

test_that("calculation formula is visible to client package users", {
  formula <- emission_calculation_formula()

  expect_true(grepl("quantity", formula$local_record_formula))
  expect_true(grepl("sum_supplier_sum_squares", formula$federated_sample_variance_formula))
})
