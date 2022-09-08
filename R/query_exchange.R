query_exchange <- function(exchange) {
  exchange = tolower(exchange)
  
  if(!(exchange %in% list_exchanges())) {
    stop("Bad report_type value supplied")
  }
  
  exchange_call <- paste0("https://api.nasdaq.com/api/screener/stocks?tableonly=true&download=true&exchange=", exchange)
  response <- httr::GET(exchange_call,
                        httr::add_headers(
                          "Accept" =	"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
                          "Accept-Encoding" = "gzip, deflate, br",
                          "Accept-Language"	= "en-US,en;q=0.5",
                          "Connection"	= "keep-alive",
                          "Host"	= "api.nasdaq.com",
                          "Sec-Fetch-Dest"	= "document",
                          "Sec-Fetch-Mode"	= "navigate",
                          "Sec-Fetch-Site"	= "none",
                          "Sec-Fetch-User"	= "?1",
                          "TE" = "trailers",
                          "Upgrade-Insecure-Requests"	= "1",
                          "User-Agent" = "Mozilla/5.0 (X11; FreeBSD amd64; rv:102.0) Gecko/20100101 Firefox/102.0"))
  
  
  response_test <- test_response(response)
  test_ok <- all(unlist(response_test))
  
  if (test_ok) {
    response_content <- content(response)
    
    overview <- data.table::rbindlist(response_content$data$rows)
    
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
