#' Compute df diff tables
#'
#' Returns a list of adds, updates and deletes required to transform old_df into new_df.
#' Part of the `dataset` family of functons in minio utils. These include `compute_df_diff_tables`, `update_minio_dataset`, `retrieve_dataset`, `retrieve_dataset_diffs` and `retrieve_dataset_diff_stats`.
#'
#' @param new_df dataframe. A dataframe of new data
#' @param old_df dataframe. A dataframe of old data. new_df and old_df can have overlapping data
#' @param key_cols optional vector of column names that constitite a unique table key.
#' @param verbose boolean, default FALSE. Should the processing be chatty?
#'
#' @return a list of dataframes with the structure
#'     list(
#'         "new_rows" = new_rows,
#'         "modified_rows" = modified_rows,
#'         "deleted_rows" = deleted_rows
#'         )
#' @export
#' @importFrom data.table setDF as.data.table
#' @import janitor
#'
#' @examples
#' iris$key <- 1:nrow(iris)
#'
#' old_df <- iris[1:100,]
#' old_df[75,1] <- 100
#' new_df <- iris[50:150,]
#' compute_df_diff_tables(new_df, old_df, key_cols = "key")
compute_df_diff_tables <-
  function(new_df,
           old_df = NA,
           key_cols = NA,
           verbose = FALSE) {

    # Make sure we've got the correct data types to work with
    if (!(any(class(new_df) %in% c("data.frame", "data.table")))) {
      stop("First argument is not a dataframe. Exiting.")
    }

    if (any(class(old_df) %in% c("logical"))) {
      if (verbose) {
        message(
          "Old dataframe argument is NA. Will create an empty dataframe to diff..."
          )
      }
      rm("old_df")
      old_df <- new_df[0,]
    }

    if (!(any(class(old_df) %in% c("data.frame", "data.table")))) {
      stop("Second argument is not a dataframe or NA. Exiting.")
    }

    if (!compare_df_cols_same(old_df, new_df)) {
      stop("Newly retrieved table does not have the same column structure as the stored version")
    }

    if (verbose) {
      message("Computing diff dataframe...")
    }

    # Convert to data.tables
    new_df <- as.data.table(new_df)
    old_df <- as.data.table(old_df)

    # create hash columns
    record_cols <- colnames(new_df)
    if (is.na(key_cols[1])) {
      key_cols <- record_cols
    }

    # Get new and modified rows

    new_and_modified_rows <- new_df[!old_df, on = record_cols]

    # Get new

    new_rows <- new_df[!old_df, on = key_cols]

    # Get modified

    modified_rows <-
      new_and_modified_rows[!new_rows, on = record_cols]

    # Get deleted rows

    deleted_rows <- old_df[!new_df, on = key_cols]


    setDF(new_rows)
    setDF(modified_rows)
    setDF(deleted_rows)

    list(
      "new_rows" = new_rows,
      "modified_rows" = modified_rows,
      "deleted_rows" = deleted_rows
    )


  }
