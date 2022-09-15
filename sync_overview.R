suppressMessages({
  library(httr)
  library(dataversionr)
  library(purrr)
  library(stringr)
  library(data.table)
  library(dplyr)
  source("set_env.R")
  source_funs <- sapply(list.files("R", full.names = TRUE), source, .GlobalEnv)
  
})

# Parameters
alphavantage_key = Sys.getenv("ALPHAVANTAGE")
rate_limit <- 75
rate_limit_seconds <- 60

# Get list of stocks
stocks <- read_dv(fix_path("alphavantage/batch_set", dest)) %>% pull(stock)

# Compute sequential delay
sequential_delay <- rate_limit_seconds/rate_limit 

# Query overview API for each stoc in the list (takes awhile)
queries <- map(stocks, ~ query_overview(.x, alphavantage_key, sequential_delay))
names(queries) <- stocks

# These are the failed stocks
failed <- discard(queries, ~ .x$exit_code == 0)

# These are the successful stocks
successful <- keep(queries, ~ .x$exit_code == 0)
overview <- as_tibble(rbindlist(map(successful, ~ .x$overview))) %>% 
  mutate(ver = 2,
         date_retrieved = lubridate::today())

# For the successful ones, update the overview dataset
old_overview <- read_dv(fix_path("alphavantage/overview", dest)) %>%
  mutate(ver = 1)

bind_rows(overview, old_overview) %>% 
  group_by(Symbol) %>% 
  filter(ver == max(ver)) %>% 
  ungroup() %>%
  select(-ver) %>%
  update_dv(fix_path("alphavantage/overview", dest))

message("FAILED QUERIES:")

rbindlist(map(failed, ~ dplyr::as_tibble(.x)), idcol = "symbol")
