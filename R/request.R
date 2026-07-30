###############################################################################
# httr2 request helpers
#
# Every function in this file talks to an API URL. There are no local supplier
# `.rds` reads in this package.
###############################################################################

build_supplier_url <- function(base_url, supplier_id, endpoint = NULL) {
  path <- paste0(
    "/suppliers/",
    utils::URLencode(as.character(supplier_id), reserved = TRUE)
  )

  if (!is.null(endpoint) && nzchar(endpoint)) {
    path <- paste0(path, "/", sub("^/", "", endpoint))
  }

  paste0(sub("/$", "", base_url), path)
}

client_request <- function(url) {
  response <- httr2::request(url) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  body <- httr2::resp_body_json(response, simplifyVector = TRUE)

  if (httr2::resp_status(response) >= 400) {
    message <- body$error
    if (is.null(message)) {
      message <- paste("Supplier API returned HTTP", httr2::resp_status(response))
    }
    stop(message, call. = FALSE)
  }

  assert_response_is_aggregate_only(body)
  body
}

supplier_health <- function(base_url) {
  result <- httr2::request(paste0(sub("/$", "", base_url), "/health")) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  body <- httr2::resp_body_json(result, simplifyVector = TRUE)
  assert_response_is_aggregate_only(body)
  body
}

supplier_factor_version <- function(base_url) {
  result <- httr2::request(paste0(sub("/$", "", base_url), "/emission-factors/version")) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  body <- httr2::resp_body_json(result, simplifyVector = TRUE)
  assert_response_is_aggregate_only(body)
  body
}

supplier_record_count <- function(base_url, supplier_id) {
  client_request(build_supplier_url(base_url, supplier_id, "record-count"))
}

supplier_total_emissions <- function(base_url, supplier_id) {
  client_request(build_supplier_url(base_url, supplier_id, "emissions/total"))
}

supplier_activity_totals <- function(base_url, supplier_id) {
  client_request(build_supplier_url(base_url, supplier_id, "emissions/by-activity"))
}

supplier_sufficient_statistics <- function(base_url, supplier_id) {
  client_request(build_supplier_url(base_url, supplier_id, "emissions/sufficient-statistics"))
}

query_supplier <- function(base_url, supplier_id, include_health = TRUE) {
  result <- list(
    supplier_id = supplier_id,
    base_url = base_url,
    record_count = supplier_record_count(base_url, supplier_id),
    total_emissions = supplier_total_emissions(base_url, supplier_id),
    activity_totals = supplier_activity_totals(base_url, supplier_id),
    sufficient_statistics = supplier_sufficient_statistics(base_url, supplier_id)
  )

  if (isTRUE(include_health)) {
    result$health <- supplier_health(base_url)
    result$factor_version <- supplier_factor_version(base_url)
  }

  assert_response_is_aggregate_only(result)
  result
}

query_all_suppliers <- function(suppliers, include_health = TRUE) {
  required <- c("supplier_id", "base_url")
  missing <- setdiff(required, names(suppliers))
  if (length(missing) > 0) {
    stop(
      "suppliers must contain columns: ",
      paste(required, collapse = ", "),
      call. = FALSE
    )
  }

  stats::setNames(
    lapply(seq_len(nrow(suppliers)), function(i) {
      query_supplier(
        base_url = suppliers$base_url[[i]],
        supplier_id = suppliers$supplier_id[[i]],
        include_health = include_health
      )
    }),
    suppliers$supplier_id
  )
}
