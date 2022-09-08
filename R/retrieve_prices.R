retrieve_prices <- function(ticker, 
                   report_type,
                   timestamp_filter = NA,
                   s3_key2 = s3_key,
                   s3_secret2 = s3_secret,
                   s3_url2 = s3_url,
                   verbose = FALSE) {
  
  if(!(report_type %in% c("prices", "prices_adjusted"))) {
    stop("Report type must be one of prices or prices_adjusted")
  }
  
  
  dataset_path <- paste0("datasci-quant/alphavantage/",report_type,"/",ticker)
  retrieve_dataset(dataset_path,
                   timestamp_filter = timestamp_filter,
                   s3_key = s3_key2,
                   s3_secret = s3_secret2,
                   s3_url = s3_url2,
                   verbose = verbose)
} 
