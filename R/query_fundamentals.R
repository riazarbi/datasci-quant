query_fundamentals <- function(stock, report_type, alphavantage_key) {
  
  report_type = tolower(report_type)
  
  if(!(report_type %in% list_fundamental_reports())) {
    stop("Bad report_type value supplied")
  }
  
  api_query <- paste0("https://www.alphavantage.co/query?function=",report_type,"&symbol=", stock,"&apikey=", alphavantage_key)
  response <- GET(api_query)
  response_test <- test_response(response)
  test_ok <- all(unlist(response_test))
  
  if (test_ok) {
    response_content <- content(response)
    if(report_type == "earnings") {
      annual <- setDF(rbindlist(response_content$annualEarnings))
      quarterly <- setDF(rbindlist(response_content$quarterlyEarnings))
    } else {
      annual <- setDF(rbindlist(response_content$annualReports))
      quarterly <- setDF(rbindlist(response_content$quarterlyReports))
      
    }
    
    
    payload <- list()
    
    payload$annual_reports <- annual
    payload$quarterly_reports <- quarterly
    payload$report_type <- report_type
    payload$exit_code <- 0
    
  } else {
    payload <- response_test
    payload$report_type <- report_type
    payload$exit_code <- 1
  }
  return(payload)
}
