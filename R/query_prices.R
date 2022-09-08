query_prices <- function(stock, report_type, alphavantage_key) {
  
  
  report_type = tolower(report_type)
  
  if(!(report_type %in% list_price_reports())) {
    stop("Bad report_type value supplied")
  }
  
  api_query <- paste0("https://www.alphavantage.co/query?function=",report_type,"&outputsize=full&symbol=", stock,"&apikey=", alphavantage_key)
  response <- GET(api_query)
  response_test <- test_response(response)
  test_ok <- all(unlist(response_test))
  
  if (test_ok) {
    response_content <- content(response)
    prices <- setDF(rbindlist(response_content$`Time Series (Daily)`, idcol = "date"))

    payload <- list()
    
    payload$prices <- prices
    payload$report_type <- report_type
    payload$exit_code <- 0
    
  } else {
    payload <- response_test
    payload$report_type <- report_type
    payload$exit_code <- 1
  }
  
  return(payload)
  
}
