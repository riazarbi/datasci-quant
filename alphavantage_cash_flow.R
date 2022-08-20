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
  json_query <- GET(paste0("https://www.alphavantage.co/query?function=CASH_FLOW&symbol=",
                           stock,
                           "&apikey=",alphavantage_key))
  
  result <- content(json_query)
  if(!is.null(result$annualReports)) {
    
    annual_reports_list <- rbindlist(result$annualReports)
    update_dv(annual_reports_list, 
             paste0("/data/quant/alphavantage/annual_reports/cash_flow/",
                                         stock))
  }
  if(!is.null(result$quarterlyReports)) {
    
    quarterly_reports_list <- rbindlist(result$quarterlyReports)
    
    update_dv(quarterly_reports_list, 
                         paste0("/data/quant/alphavantage/quarterly_reports/cash_flow/",
                                         stock))
    
    
  }

}
