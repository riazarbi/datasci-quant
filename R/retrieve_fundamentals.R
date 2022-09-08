retrieve_fundamentals <- function(ticker, 
                         report_type,
                         periodicity,
                         timestamp_filter = NA,
                         s3_key2 = s3_key,
                         s3_secret2 = s3_secret,
                         s3_url2 = s3_url,
                         verbose = FALSE) {
  
  if(!(report_type %in% c("balance_sheet", "cash_flow", "earnings", "income_statement"))) {
    stop("Report type must be one of balance_sheet, cash_flow, earnings or income_statement")
  }
  
  if(!(periodicity %in% c("quarterly", "annual"))) {
    stop("Periodicity must be either quarterly or annual")
  }
  
  dataset_path <- paste0("datasci-quant/alphavantage/",periodicity,"_reports/",report_type,"/",ticker)
  retrieve_dataset(dataset_path,
                   timestamp_filter = timestamp_filter,
                   s3_key = s3_key2,
                   s3_secret = s3_secret2,
                   s3_url = s3_url2,
                   verbose = verbose)
} 
