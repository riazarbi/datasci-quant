library(tidyquant)
library(readr)
library(aws.s3)
library(stringr)
library(arrow)
library(janitor)
library(data.table)
library(dplyr)

files.sources = list.files("R", full.names = T)
sapply(files.sources, source)

s3_key = Sys.getenv("S3_KEY")
s3_secret = Sys.getenv("S3_SECRET")
s3_url = Sys.getenv("S3_URL")
alphavantage_key = Sys.getenv("ALPHAVANTAGE")
av_api_key(alphavantage_key)

sp500 <- retrieve_dataset("datasci-quant/tidyquant/sp500",
                          s3_key = s3_key,
                          s3_secret = s3_secret,
                          s3_url = s3_url)

stocks <- sp500$symbol

stocklist <- list()

for (i in seq_along(1:length(stocks))) {
  stock <- stocks[i]
  json_query <- httr::GET(paste0("https://www.alphavantage.co/query?function=OVERVIEW&symbol=",stock,"&apikey=",alphavantage_key)) 
  content <- httr::content(json_query)
  stocklist[[i]] <- as_tibble(content) %>% mutate(ver = 2)
  Sys.sleep(5)
}

overview <- rbindlist(stocklist)

old_overview <- retrieve_dataset("datasci-quant/alphavantage/overview", 
                                 s3_key = s3_key,
                                 s3_secret = s3_secret, 
                                 s3_url = s3_url) %>%
  mutate(ver = 1)

bind_rows(overview, old_overview) %>% 
  group_by(Symbol) %>% 
  filter(ver == max(ver)) %>% 
  ungroup() %>%
  select(-ver) %>%
  update_minio_dataset(prefix = "datasci-quant/alphavantage/overview", 
                       key_cols = "Symbol",
                       s3_key = s3_key,
                       s3_secret = s3_secret, 
                       s3_url = s3_url,
                       verbose = TRUE)


