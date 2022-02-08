#' Update minio dataset
#'
#' Updates an old_df at a particular minio location with a new_df. Silently adds dataset_diffs and diff stats to the same minio location
#'
#' Part of the `dataset` family of functons in minio utils. These include `compute_df_diff_tables`, `update_minio_dataset`, `retrieve_dataset`, `retrieve_dataset_diffs` and `retrieve_dataset_diff_stats`.
#'
#' @param new_df a data frame containing the new table contents.
#' @param prefix string. The prefix at which the dataset root resides. If the root is a bucket just give the bucket name.
#' @param key_cols ordered string vector. The columns which, combined, make a unique key for the dataset.
#' @param validate_key_cols TRUE/FALSE. Should we check that the declared key columns above are the same as the ones previously applied to the dataset? Defaults to TRUE.
#' @param s3_key string. S3 access key. Defaults to Sys.getenv("AWS_ACCESS_KEY_ID").
#' @param s3_secret string. S3 secret key. Defaults to Sys.getenv("AWS_SECRET_ACCESS_KEY")
#' @param s3_url string. S3 url. Defaults to NULL
#' @param verbose TRUE/FALSE. Should the operations be chatty.
#'
#' @return boolean success flag.
#' @export
#' @import stringr
#' @import arrow
#' @import lubridate
#' @import dplyr
#'
#' @examples
#'\dontrun{
#' # Set AWS secrets
#' Sys.setenv(
#'   "AWS_ACCESS_KEY_ID" = MINIO_KEY,
#'  "AWS_SECRET_ACCESS_KEY" = MINIO_SECRET
#' )
#'
#'# Set up
#'bucket <- "bucket-diff"
#'# Create unique prefix for testing
#'prefix <- paste0(bucket, "/", round(as.numeric(now()) * 10000), 0)
#'make_bucket(bucket)
#'# Create sample dataframe
#'numbers <- 1:6
#'letters2 <- c("s", "j", "f", "u", "l", "i")
#'new_df <- data.frame(a = numbers[2:6], b = letters2[2:6])
#'new_df[3, 2] <- "update"
#'old_df <- data.frame(a = numbers[1:5], b = letters2[1:5])
#'
#'update_minio_dataset(old_df,
#'                     prefix,
#'                     key_cols = "a")
#'update_minio_dataset(new_df,
#'                     prefix,
#'                     key_cols = "a")
#'                     }

update_minio_dataset <- function(new_df,
                                 prefix,
                                 key_cols = NA,
                                 validate_key_cols = TRUE,
                                 s3_key = Sys.getenv("AWS_ACCESS_KEY_ID"),
                                 s3_secret = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
                                 s3_url = NULL,
                                 verbose = FALSE) {

  s3_key <- convert_empty_string_to_null(s3_key)
  s3_secret <- convert_empty_string_to_null(s3_secret)

  bucket <- str_split(prefix, "/", 2)[[1]][1]
  
  region_endpoint <-
    stringr::str_split_fixed(s3_url, pattern = "\\.", n = 2)
  region <- region_endpoint[[1]]
  endpoint <- region_endpoint[[2]]
  

  if (
    aws.s3::bucket_exists(
    bucket = bucket,
    region = region,
    base_url = endpoint,
    key = s3_key,
    secret = s3_secret,
    verbose = TRUE
    )) {
    if (verbose) {
      message("Bucket exists...")
    }
  } else {
    stop("Bucket does not exist.")
  }

  lake <- S3FileSystem$create(
    access_key = s3_key,
    secret_key = s3_secret,
    scheme = "https",
    #endpoint_override = endpoint,
    region = region
  )

  dataset_prefix <- lake$cd(prefix)

  # Read in the old table
  if (verbose) {
    message("Reading cached dataset...")
  }

  old_df <- tryCatch({
      insistently_collect(open_dataset(dataset_prefix$path("latest")))
  }, error = function(error_condition) {
    NA
  })

  if ("logical" %in% class(old_df)) {
    if (verbose) {
      warning("NO CACHED DATASET FOUND...",
              immediate. = TRUE)
    }
  }

  # Calculate diff tables
  diff_tables <-
    compute_df_diff_tables(new_df, old_df, key_cols = key_cols, verbose = verbose)

  # Count number of changes
  diff_counts <- unlist(lapply(diff_tables, nrow))
  number_of_changes <- sum(diff_counts)

  # Define a little function for use inside this function
  put_diff <- function(df, operation, timestamp) {
    if (nrow(df) > 0) {
      if (verbose) {
        message(paste("Operation", operation, "has", nrow(df), "diffs..."))
      }

      df <- df %>%
        mutate(timestamp = with_tz(write_timestamp, tzone = "UTC"),
               operation = operation) %>%
        select(timestamp, everything(), operation)
      
      insistently_write_parquet(df,
                    dataset_prefix$path(
                      paste0(
                        "history/",
                        as.numeric(write_timestamp),
                        "_",
                        operation,
                        ".parquet"
                      )
                    ))
    } else {
      if (verbose) {
        message(paste("Operation", operation, "has no diffs..."))
      }
    }
  }

  # Actual write operation logic
  # First, just exit if there are no diffs.
  if (number_of_changes == 0) {
    message("No new data detected. Exiting without write.")
  }
  # If there are actually diffs
  else {
    write_timestamp <- now()

    # Create a full-row composite key if no key has been specified
    if (is.na(key_cols[1])) {
      key_cols <- colnames(new_df)
    }


    if (verbose) {
      message("Writing diff statistics...")
    }

    # If specified, validate that the keys used are the same as the keys used in the past
    if(validate_key_cols) {
      # Skip validation if there is no cached dataset
      if ("logical" %in% class(old_df)) {
        if (verbose) {
          message("Validating key_cols will be skipped because there is no cached dataset.")
        }
        # If there is a cached dataset, pull the diff stats
      } else {
        if (verbose) {
          message("Validating key_cols are the same for incoming data...")
        }
        # Pull history of key cols in diff stats
        key_cols_history <- retrieve_dataset_diff_stats(prefix,
                                                        first_principles = FALSE,
                                                        s3_key = s3_key,
                                                        s3_secret = s3_secret,
                                                        s3_url = s3_url,
                                                        verbose = verbose) %>% pull(key_cols)

        # Get a list of unique key cols. There should only be one!
        old_key_cols <- unique(key_cols_history)

        if(old_key_cols != paste(key_cols, collapse = "|")) {
          message <- paste0("Key_col validation failed. Old key_cols are ",
                            old_key_cols,
                            ". New key_cols are ",
                            paste(key_cols, collapse = "|"))
          stop(message)
        } else {
          if(verbose) {message("key_col validation passed.")}
        }

      }
    }

    diff_counts_df <- diff_counts %>% t %>%
      as.data.frame %>%
      mutate(`timestamp` = as.character(with_tz(write_timestamp, tzone = "UTC")),
             key_cols = paste(key_cols, collapse = "|"),
             minio_user = s3_key) %>%
      rename(create = .data$new_rows,
             update = .data$modified_rows,
             delete = .data$deleted_rows) %>%
      select(.data$timestamp, everything())

    insistently_write_csv_arrow(diff_counts_df,
                    dataset_prefix$path(paste0(
                      "diff_stats/",
                      as.numeric(write_timestamp),
                      ".csv"
                    )),)

    if (verbose) {
      message("Writing diffs...")
    }
    put_diff(diff_tables$new_rows, "create", write_timestamp)
    put_diff(diff_tables$modified_rows, "update", write_timestamp)
    put_diff(diff_tables$deleted_rows, "delete", write_timestamp)

    if (verbose) {
      message("Writing new dataset...")
    }
    insistently_write_parquet(new_df,
                  dataset_prefix$path(
                      "latest/data-01.parquet"
                    )
                  )
    return(TRUE)
  }
}
