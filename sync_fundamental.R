#!/usr/bin/R
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)!=2) {
  stop("Incorrect number of arguments supplied", call.=FALSE)
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

result <- query_fundamentals(stock, report, alphavantage_key)

if(result$exit_code == 1) {
  print(result)
  quit(save = "no", status = 1)
} else {
  updatea <- update_dv(result$annual_reports, 
            fix_path(paste0("alphavantage/annual_reports/",report,"/", stock), dest))
  updateq <- update_dv(result$quarterly_reports, 
                       fix_path(paste0("alphavantage/quarterly_reports/",report,"/", stock), dest))
  update <- (updateq | updateq)
}

if(update) {
  message("Updated")
} else {
  message("No new data")
}