library(tidyquant)
library(dplyr)
library(dataversionr)

alphavantage_key = Sys.getenv("ALPHAVANTAGE")
av_api_key(alphavantage_key)


tq_index("SP500") %>%
  update_dv("/data/quant/tidyquant/sp500")
