query_overview <- function(stock, alphavantage_key, query_delay = 0.1) {
  Sys.sleep(query_delay)
  api_query <- paste0("https://www.alphavantage.co/query?function=OVERVIEW&symbol=",stock,"&apikey=",alphavantage_key)
  response <- GET(api_query) 
  response_test <- test_response(response)
  test_ok <- all(unlist(response_test))
  
  if (test_ok) {
    response_content <- content(response)
    
    overview <- as_tibble(response_content)
    
    payload <- list()
    
    payload$overview <- overview
    payload$report_type <- "overview"
    payload$exit_code <- 0
    
  } else {
    payload <- response_test
    payload$report_type <- "overview"
    payload$exit_code <- 1
  }
  
  return(payload)
  
}
