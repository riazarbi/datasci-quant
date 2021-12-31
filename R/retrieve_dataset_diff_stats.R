#' Retrieve dataset diff statistics from a dataset stored in minio
#'
#' Part of the `dataset` family of functons in minio utils. These include `compute_df_diff_tables`, `update_minio_dataset`, `retrieve_dataset`, `retrieve_dataset_diffs` and `retrieve_dataset_diff_stats`.
#'
#' @param prefix string. The prefix at which the dataset root resides. If the root is a bucket just give the bucket name.
#' @param first_principles TRUE/FALSE. Should the diff statistics be computed from first principles (TRUE, slow) or retrieved from the cached statistics (FALSE, fast). Defaults to FALSE.
#' @param s3_key string. S3 access key. Defaults to Sys.getenv("AWS_ACCESS_KEY_ID").
#' @param s3_secret string. S3 secret key. Defaults to Sys.getenv("AWS_SECRET_ACCESS_KEY")
#' @param s3_url string. S3 url. Defaults to "NULL"
#' @param verbose TRUE/FALSE. Should the operations be chatty.
#'
#' @return a dataframe of the diff statistics over the life of the dataset.
#' @export
#' @import arrow
#' @import dplyr
#' @import tidyr
#'
#' @examples
#'\dontrun{
#'# Set AWS secrets
#' Sys.setenv(
#'   "AWS_ACCESS_KEY_ID" = MINIO_KEY,
#'  "AWS_SECRET_ACCESS_KEY" = MINIO_SECRET
#' )
#'
#' retrieve_dataset_diff_stats ("test_dataset")
#' }

retrieve_dataset_diff_stats <- function(prefix,
                                        first_principles = FALSE,
                                        s3_key = Sys.getenv("AWS_ACCESS_KEY_ID"),
                                        s3_secret = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
                                        s3_url = NULL,
                                        verbose = FALSE) {
  s3_key <- convert_empty_string_to_null(s3_key)
  s3_secret <- convert_empty_string_to_null(s3_secret)
  
  region_endpoint <-
    stringr::str_split_fixed(s3_url, pattern = "\\.", n = 2)
  region <- region_endpoint[[1]]
  endpoint <- region_endpoint[[2]]
  
  lake <- S3FileSystem$create(
    access_key = s3_key,
    secret_key = s3_secret,
    scheme = "https",
    #endpoint_override = endpoint,
    region = region
  )

  dataset_prefix <- lake$cd(prefix)


  if (first_principles) {
    if (verbose) {
      message("Computing diff stats from first principles...")
    }
    open_dataset(dataset_prefix$path("history")) %>%
      collect() %>%
      group_by(.data$timestamp, .data$operation) %>%
      summarise(count = as.integer(n()), .groups = "keep") %>%
      ungroup() %>%
      pivot_wider(id_cols = .data$timestamp,
                  names_from = .data$operation,
                  values_from = count) %>%
      mutate(across(where(is.integer), ~ as.integer(replace_na(.x, 0))))
  } else {
    if (verbose) {
      message("Retrieving diff stats...")
    }
    open_dataset(dataset_prefix$path("diff_stats"), format = "csv") %>% collect()
  }
}
