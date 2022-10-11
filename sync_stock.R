#!/usr/bin/R
args = commandArgs(trailingOnly = TRUE)

# test if there is at least one argument: if not, return an error
if (length(args) != 1) {
  stop("Incorrect number of arguments supplied", call. = FALSE)
}

suppressMessages({
  library(data.table)
  library(httr)
  library(dataversionr)
  source("set_env.R")
  source_funs <-
    sapply(list.files("R", full.names = TRUE), source, .GlobalEnv)
})


alphavantage_key = Sys.getenv("ALPHAVANTAGE")

stock <- toupper(args[1])
message(stock)

## FUNDAMENTALS ##
reports <- list_fundamental_reports()

for (report in reports) {
  message(report)
  result <- query_fundamentals(stock, report, alphavantage_key)
  
  if (result$exit_code == 1) {
    print(result)
    quit(save = "no", status = 1)
  } else if (nrow(result$annual_reports) != 0 & 
             nrow(result$quarterly_reports)) {
    message("  annual")
    updatea <- create_or_update_dv(result$annual_reports,
                                   fix_path(
                                     paste0("alphavantage/annual_reports/", report, "/", stock),
                                     dest
                                   ),
                                   key_cols = "fiscalDateEnding")
    message("  quarterly")
    updateq <- create_or_update_dv(result$quarterly_reports,
                                   fix_path(
                                     paste0("alphavantage/quarterly_reports/", report, "/", stock),
                                     dest
                                   ),
                                   key_cols = "fiscalDateEnding")
    update <- (updateq | updateq)
    
    if (update) {
      message("update")
    } else {
      message("noupdate")
    }
  } else {
    message("nodata")
  }
} 
  

## PRICES ##
reports <- list_price_reports()

for (report in reports) {
  message(report)
  
  result <- query_prices(stock, report, alphavantage_key)
  
  if (report == "time_series_daily") {
    path <- "prices"
  }
  
  if (report == "time_series_daily_adjusted") {
    path <- "prices_adjusted"
  }
  
  if (result$exit_code == 1) {
    print(result)
    quit(save = "no", status = 1)
  } else if (nrow(result$prices) != 0) {
    update <- create_or_update_dv(result$prices,
                                  fix_path(paste0("alphavantage/", path, "/", stock), dest),
                                  key_cols = "date")
  
    
    if (update) {
      message("update")
    } else {
      message("noupdate")
    }
    
  } else {
      message("nodata")
    }
  
}
