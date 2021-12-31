#' Retrieve dataset diffs
#'
#' Retrieves a dataset record diff operations from a minio location. Takes optional timestamp parameter that uses the diff tables to recreate the table at that point in time.
#'
#' Part of the `dataset` family of functons in minio utils. These include `compute_df_diff_tables`, `update_minio_dataset`, `retrieve_dataset`, `retrieve_dataset_diffs` and `retrieve_dataset_diff_stats`.
#'
#' @param prefix string. The prefix at which the dataset root resides. If the root is a bucket just give the bucket name.
#' @param timestamp_filter a datetime object. The date up until which we want to retrieve the history. Defaults to NA, which gives the entire history.
#' @param collect TRUE/FALSE. Ignored if `timestamp` parameter is set. Should we collect the dataset and return the full dataframe in memory (TRUE), or should we just return the dataset connection for use with `arrow` dataset so that the user can run`dplyr` supported verbs before runing `collect()`? Defaults to TRUE.
#' @param s3_key string. S3 access key. Defaults to Sys.getenv("AWS_ACCESS_KEY_ID").
#' @param s3_secret string. S3 secret key. Defaults to Sys.getenv("AWS_SECRET_ACCESS_KEY")
#' @param s3_url string. S3 url. Defaults to "NULL"
#' @param verbose TRUE/FALSE. Should the operations be chatty.
#'
#' @return a dataframe of all operations (CREATE/UPDATE/DELETE) recorded against the dataset up until the timestamp.
#' @export
#' @import arrow
#' @import dplyr
#' @import lubridate
#'
#' @examples
#'\dontrun{
#' #'# Set AWS secrets
#' Sys.setenv(
#'   "AWS_ACCESS_KEY_ID" = MINIO_KEY,
#'  "AWS_SECRET_ACCESS_KEY" = MINIO_SECRET
#' )
#'
#' retrieve_dataset_diffs("test_dataset",
#'                        lubridate::now() - lubridate::days(90))
#'                        }
retrieve_dataset_diffs <- function(prefix,
                                   timestamp_filter = NA,
                                   collect = TRUE,
                                   s3_key = Sys.getenv("AWS_ACCESS_KEY_ID"),
                                   s3_secret = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
                                   s3_url = NULL,
                                   verbose = FALSE) {
  if(!collect) {
    stop("Running collect = FALSE is not yet implemented for this function.")
  }
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

  key_cols_history <- retrieve_dataset_diff_stats(prefix,
                                                  first_principles = FALSE,
                                                  s3_key = s3_key,
                                                  s3_secret = s3_secret,
                                                  s3_url = s3_url,
                                                  verbose = verbose) %>%
    pull(.data$key_cols) %>% unique

  key_vars <- unlist(strsplit(key_cols_history[length(key_cols_history)], "\\|"))


  if (is.na(timestamp_filter)) {
    if (verbose) {
      message("No timestamp set. Retrieving latest copy.")
    }
    open_dataset(dataset_prefix$path("history")) %>%
      collect %>%
      as_tibble

  } else {
    timestamp_filter <- with_tz(timestamp_filter, tzone = "UTC")
    if (verbose) {
      message(paste(
        "Filtering dataset to timestamp",
        timestamp_filter,
        "UTF"
      ))
    }


    open_dataset(dataset_prefix$path("history")) %>%
      filter(timestamp <= timestamp_filter) %>%
      collect() %>%
      as_tibble

  }
}

