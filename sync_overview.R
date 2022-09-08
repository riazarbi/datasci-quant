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


alphavantage_key = Sys.getenv("ALPHAVANTAGE")
rate_limit <- 75
rate_limit_seconds <- 60

sp500 <- get_diffs(fix_path("tidyquant/sp500", dest))
stocks <- unique(sp500$symbol)
stocks <- sample(stocks, length(stocks))

# for name compat between sp500 dataset and alphavantage dataset
stocks <- str_replace_all(stocks, pattern = "[.]", "-")
sequential_delay <- rate_limit_seconds/rate_limit 

queries <- map(stocks, ~ query_overview(.x, alphavantage_key, sequential_delay))
names(queries) <- stocks

# Get a list of exit code 1, create error report
failed <- discard(queries, ~ .x$exit_code == 0)

# Get list of exit code 2, create dv, update
successful <- keep(queries, ~ .x$exit_code == 0)
overview <- as_tibble(rbindlist(map(successful, ~ .x$overview))) %>% 
  mutate(ver = 2,
         date_retrieved = today())

old_overview <- read_dv(fix_path("alphavantage/overview", dest)) %>%
  mutate(ver = 1)

bind_rows(overview, old_overview) %>% 
  group_by(Symbol) %>% 
  filter(ver == max(ver)) %>% 
  ungroup() %>%
  select(-ver) %>%
  update_dv(fix_path("alphavantage/overview", dest))


