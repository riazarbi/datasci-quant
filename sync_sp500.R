suppressMessages({
  library(tidyquant)
  library(dplyr)
  library(dataversionr)
  
  source("set_env.R")
})

update <- tq_index("SP500") %>%
  update_dv(fix_path("tidyquant/sp500", dest))

if(update) {
  message("Updated")
  quit(save = "no", status = 0)
} else {
  message("No new data")
  quit(save = "no", status = 0)
}


