suppressMessages({
  library(httr)
  library(dplyr)
  library(dataversionr)
  library(jsonlite)
  source("set_env.R")
  source_funs <- sapply(list.files("R", full.names = TRUE), source, .GlobalEnv)
})


get_diffs(fix_path("tidyquant/sp500/", dest)) %>% 
  pull(symbol) %>% 
  unique %>% jsonlite::toJSON() %>% write(file = "/tmp/universe.json")
