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
  json_query <- GET(paste0("https://www.alphavantage.co/query?function=EARNINGS&symbol=",
                           stock,
                           "&apikey=",alphavantage_key))
  
  result <- content(json_query)
  if(!is.null(result$annualEarnings)) {
    annual_earnings_list <- rbindlist(result$annualEarnings)
    
    update_dv(annual_earnings_list, 
                         paste0("/data/quant/alphavantage/annual_reports/earnings/",
                                         stock))
  }
  if(!is.null(result$quarterlyEarnings)) {
    
    quarterly_earnings_list <- rbindlist(result$quarterlyEarnings)
    
    update_dv(quarterly_earnings_list, 
                         paste0("/data/quant/alphavantage/quarterly_reports/earnings/",
                                         stock))
    
    
  }
}
