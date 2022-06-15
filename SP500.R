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

get_bucket(bucket = "datasci-quant",
           region = "us-east-1",
           key = s3_key,
           secret = s3_secret,
           verbose = TRUE) %>% 
  rbindlist %>% 
  arrange(desc(LastModified)) %>% 
  glimpse

tq_index("SP500") %>%
   update_minio_dataset(prefix = "datasci-quant/tidyquant/sp500", 
                      s3_key = s3_key,
                      s3_secret = s3_secret, 
                      s3_url = s3_url,
                      verbose = TRUE)
