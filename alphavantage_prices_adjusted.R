library(data.table)
library(httr)
library(dataversionr)

source("set_env.R")

alphavantage_key = Sys.getenv("ALPHAVANTAGE")

sp500 <- read_dv("/data/quant/tidyquant/sp500")

stocks <- sample(sp500$symbol, nrow(sp500))

for (i in seq_along(1:length(stocks))) {
  cat(i)
  stock <- stocks[i]
  json_query <- GET(paste0("https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&outputsize=full&symbol=",
                           stock,
                           "&apikey=",alphavantage_key))
  
  result <- content(json_query)
  time_series_list <- result$`Time Series (Daily)`
  if(!is.null(time_series_list)) {
    time_series <- rbindlist(time_series_list, idcol = "date")
    
    update_dv(time_series, 
                         paste0("/data/quant/alphavantage/prices_adjusted/",
                                         stock))
    
    
  }
}
