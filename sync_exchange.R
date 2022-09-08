#!/usr/bin/R
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)!=1) {
  stop("Incorrect number of arguments supplied", call.=FALSE)
} 

suppressMessages({
  library(data.table)
  library(httr)
  library(dataversionr)
  source("set_env.R")
  source_funs <- sapply(list.files("R", full.names = TRUE), source, .GlobalEnv)
})


exchange <- toupper(args[1])

result <- query_exchange(exchange)

if(result$exit_code == 1) {
  print(result)
  quit(save = "no", status = 1)
} else {
  update <- create_or_update_dv(result$overview, 
                       fix_path(paste0("nasdaq/overview/",exchange), dest),
                       key_cols = "symbol")
}

if(update) {
  message("Updated")
  quit(save = "no", status = 0)
} else {
  message("No new data")
  quit(save = "no", status = 0)
}