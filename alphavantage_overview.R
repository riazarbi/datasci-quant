library(data.table)
library(httr)
library(dataversionr)
library(dplyr)
library(lubridate)

source("set_env.R")

alphavantage_key = Sys.getenv("ALPHAVANTAGE")

sp500 <- read_dv("/data/quant/tidyquant/sp500")

stocks <- sample(sp500$symbol, nrow(sp500))

# but a list of all stock overviews 
stocklist <- list()
for (i in seq_along(1:length(stocks))) {
  cat(i)
  stock <- stocks[i]
  json_query <- httr::GET(paste0("https://www.alphavantage.co/query?function=OVERVIEW&symbol=",stock,"&apikey=",alphavantage_key)) 
  content <- httr::content(json_query)
  stocklist[[i]] <- as_tibble(content) %>% mutate(ver = 2, 
                                                  date_retrieved = today())
  Sys.sleep(3)
}

# This drops 0 row stocks (i.e there is no overview)
overview <- rbindlist(stocklist[lapply(stocklist, nrow) != 0])

old_overview <- read_dv("/data/quant/alphavantage/overview") %>%
  mutate(ver = 1)

bind_rows(overview, old_overview) %>% 
  group_by(Symbol) %>% 
  filter(ver == max(ver)) %>% 
  ungroup() %>%
  select(-ver) %>%
  update_dv("/data/quant/alphavantage/overview")


