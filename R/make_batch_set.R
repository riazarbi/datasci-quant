make_batch_set <- function(dest, batch_size = 500) {
  
  # Get a list of stocks
  stocks <- read_dv(fix_path("alphavantage/listed_assets/", dest)) %>% 
    filter(assetType == "Stock")
  stocks <- unique(stocks$symbol)
  
  # Get a history of stock refreshes
  refresh_history <- read_dv(fix_path("alphavantage/overview", dest))
  refresh_history <- refresh_history %>% select(Symbol, date_retrieved)
  
  # listed assets which don't appear in the overview
  not_captured <- stocks[!(stocks %in% refresh_history$Symbol)]
  # overview stocks which are listed arranged by staleness
  captured_listed <- refresh_history %>% filter(Symbol %in% stocks) %>% arrange(date_retrieved) %>% pull(Symbol)
  
  if(length(not_captured) >= batch_size){
    stocks <- not_captured[1:batch_size]
  } else {
    stocks <- c(not_captured, captured_listed[1:(batch_size - length(not_captured))])
  }
  stocks <- stocks[!is.na(stocks)]
  return(stocks)
}



################
make_batch_set2 <- function(dest, batch_size = 500) {
  stocks <- read_dv(fix_path("tidyquant/sp500", dest)) %>% pull(symbol)
  stocks <- str_replace_all(stocks, pattern = "[.]", "-")
  
  # Get a history of stock refreshes
  refresh_history <- read_dv(fix_path("alphavantage/overview", dest))
  refresh_history <- refresh_history %>% select(Symbol, date_retrieved)
  
  # listed assets which don't appear in the overview
  not_captured <- stocks[!(stocks %in% refresh_history$Symbol)]
  # overview stocks which are listed arranged by staleness
  captured_listed <- refresh_history %>% filter(Symbol %in% stocks) %>% arrange(date_retrieved) %>% pull(Symbol)
  
  if(length(not_captured) >= batch_size){
    stocks <- not_captured[1:batch_size]
  } else {
    stocks <- c(not_captured, captured_listed[1:(batch_size - length(not_captured))])
  }
  stocks <- stocks[!is.na(stocks)]
  
  return(stocks)

}