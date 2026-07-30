###############################################################################
# Client-side privacy checks
#
# The client package should be safe to install on another laptop: it talks only
# to API URLs and should never receive supplier raw activity data. These helpers
# define the field names that would indicate an accidental privacy breach.
###############################################################################

blocked_response_fields <- c(
  "record_id",
  "site_id",
  "site_name",
  "city",
  "region",
  "reporting_month",
  "month_name",
  "quantity",
  "quantity_before_calibration",
  "calibration_factor",
  "invoice_reference",
  "data_source"
)

response_names <- function(x) {
  if (is.data.frame(x) || is.list(x)) {
    unique(c(names(x), unlist(lapply(x, response_names), use.names = FALSE)))
  } else {
    character()
  }
}

assert_response_is_aggregate_only <- function(x) {
  leaked <- intersect(response_names(x), blocked_response_fields)
  if (length(leaked) > 0) {
    stop(
      "Supplier response contains blocked raw-data fields: ",
      paste(leaked, collapse = ", "),
      call. = FALSE
    )
  }

  TRUE
}
