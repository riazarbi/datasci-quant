library(tidyquant)
library(readr)
library(aws.s3)
library(stringr)
library(arrow)
library(janitor)
library(data.table)
library(dplyr)
library(httr)

files.sources = list.files("R", full.names = T)
sapply(files.sources, source)

s3_key = Sys.getenv("S3_KEY")
s3_secret = Sys.getenv("S3_SECRET")
s3_url = Sys.getenv("S3_URL")
alphavantage_key = Sys.getenv("ALPHAVANTAGE")

sp500 <- retrieve_dataset("datasci-quant/tidyquant/sp500",
                          s3_key = s3_key,
                          s3_secret = s3_secret,
                          s3_url = s3_url)

stocks <- sample(sp500$symbol, nrow(sp500))

for (i in seq_along(1:length(stocks))) {
  stock <- stocks[i]
  json_query <- GET(paste0("https://www.alphavantage.co/query?function=EARNINGS&symbol=",
                           stock,
                           "&apikey=",alphavantage_key))
  
  result <- content(json_query)
  if(!is.null(result$annualEarnings)) {
    annual_earnings_list <- rbindlist(result$annualEarnings)
    
    update_minio_dataset(annual_earnings_list, 
                         prefix = paste0("datasci-quant/alphavantage/annual_reports/earnings/",
                                         stock), 
                         key_cols = "fiscalDateEnding",
                         s3_key = s3_key,
                         s3_secret = s3_secret, 
                         s3_url = s3_url,
                         verbose = TRUE)
  }
  if(!is.null(result$quarterlyEarnings)) {
    
    quarterly_earnings_list <- rbindlist(result$quarterlyEarnings)
    
    update_minio_dataset(quarterly_earnings_list, 
                         prefix = paste0("datasci-quant/alphavantage/quarterly_reports/earnings/",
                                         stock), 
                         key_cols = "fiscalDateEnding",
                         s3_key = s3_key,
                         s3_secret = s3_secret, 
                         s3_url = s3_url,
                         verbose = TRUE)
    
    
  }
  Sys.sleep(5)
}
