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
batch_size <- 100

# Get list of stocks
#stocks <- make_batch_set(dest, batch_size)
stocks <- make_batch_set2(dest, batch_size)

# Save for echo_universe
create_or_update_dv(data.frame(stock=stocks), 
                    fix_path("alphavantage/batch_set", dest), 
                    key_cols = "stock")
