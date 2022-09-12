#!/usr/bin/R

args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)!=2) {
  stop("Incorrect number of arguments supplied", call.=FALSE)
} 

if (!(args[2] %in% c("prices", "prices_adjusted"))) {
  stop("arg 2 must be one of prices, prices_adjusted")
}


suppressMessages({
  library(data.table)
  library(httr)
  library(dataversionr)
  source("set_env.R")
  source_funs <- sapply(list.files("R", full.names = TRUE), source, .GlobalEnv)
})

alphavantage_key = Sys.getenv("ALPHAVANTAGE")

stock <- toupper(args[1])
report <- tolower(args[2])


if(report == "prices") {
  result <- query_prices(stock, "time_series_daily", alphavantage_key)
}

if(report == "prices_adjusted") {
  result <- query_prices(stock, "time_series_daily_adjusted", alphavantage_key)
}


if(result$exit_code == 1) {
  print(result)
  quit(save = "no", status = 1)
} else {
  update <- create_or_update_dv(result$prices, 
            fix_path(paste0("alphavantage/",report,"/", stock), dest),
            key_cols = "date")
}

if(update) {
  message("Updated")
  quit(save = "no", status = 0)
} else {
  message("No new data")
  quit(save = "no", status = 0)
}
