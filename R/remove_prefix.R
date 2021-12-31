#' Remove all objects under a particular prefix in minio
#'
#' @param prefix_path string. Prefix path in minio. Setting to "" removes everything in a bucket.
#' @param bucket_name string. Name of the bucket.
#' @param minio_key string. S3 access key. Defaults to Sys.getenv("AWS_ACCESS_KEY_ID").
#' @param minio_secret string. S3 secret key. Defaults to Sys.getenv("AWS_SECRET_ACCESS_KEY")
#' @param minio_url string. S3 url. Defaults to "lake.capetown.gov.za"
#'
#' @return returns TRUE/FALSE
#' @export
#' @import dplyr aws.s3
#'
#' @examples
#'\dontrun{
#' # Set AWS secrets
#' Sys.setenv(
#'   "AWS_ACCESS_KEY_ID" = MINIO_KEY,
#'  "AWS_SECRET_ACCESS_KEY" = MINIO_SECRET
#' )
#'
#' remove_minio_prefix("prefix_under_test",
#'                     "test")
#'                     }
remove_prefix <- function(prefix_path,
                          bucket_name,
                          s3_key = Sys.getenv("AWS_ACCESS_KEY_ID"),
                          s3_secret = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
                          s3_url = "lake.capetown.gov.za") {

  region_endpoint <-
    stringr::str_split_fixed(s3_url, pattern = "\\.", n = 2)
  region <- region_endpoint[[1]]
  endpoint <- region_endpoint[[2]]
  
  # Bucket contents in dataframe
  bucket <-
    aws.s3::get_bucket(
      bucket_name,
      prefix = prefix_path,
      max = Inf,
      base_url = endpoint,
      region = region,
      key = s3_key,
      secret = s3_secret
    ) %>% rbindlist
  
  if (nrow(bucket) == 0) {
    stop("There are no objects listed under the prefix path.")
  }
  
  # List of files to delete
  files_to_delete <- bucket$Key
  
  # Loop through file list
  for (file in files_to_delete) {
    aws.s3::delete_object(file,
                          bucket_name,
                          base_url = endpoint,
                          region = region,       
                          key = s3_key,
                          secret = s3_secret
    )
  }
  # Bucket contents in dataframe
  bucket <-
    aws.s3::get_bucket(
      bucket_name,
      prefix = prefix_path,
      max = Inf,
      base_url = endpoint,
      region = region,
      key = s3_key,
      secret = s3_secret
    ) %>% rbindlist
  
  return(nrow(bucket) == 0)
}

