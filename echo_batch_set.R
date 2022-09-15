suppressMessages({
  library(httr)
  library(dplyr)
  library(dataversionr)
  library(jsonlite)
  library(stringr)
  source("set_env.R")
  source_funs <- sapply(list.files("R", full.names = TRUE), source, .GlobalEnv)
})

read_dv(fix_path("alphavantage/batch_set", dest)) %>% 
  pull(stock) %>%
  jsonlite::toJSON() %>% 
  write(stdout())

