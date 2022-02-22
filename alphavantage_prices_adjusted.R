library(tidyquant)
library(readr)
library(aws.s3)
library(stringr)
library(arrow)
library(janitor)
library(data.table)
library(dplyr)
library(httr)
library(purrr)

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
  json_query <- GET(paste0("https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&outputsize=full&symbol=",
                           stock,
                           "&apikey=",alphavantage_key))
  
  result <- content(json_query)
  time_series_list <- result$`Time Series (Daily)`
  if(!is.null(time_series_list)) {
    time_series <- rbindlist(time_series_list, idcol = "date")
    
    update_minio_dataset(time_series, 
                         prefix = paste0("datasci-quant/alphavantage/prices_adjusted/",
                                         stock), 
                         key_cols = "date",
                         s3_key = s3_key,
                         s3_secret = s3_secret, 
                         s3_url = s3_url,
                         verbose = TRUE)
    
    
  }
  Sys.sleep(5)
}
