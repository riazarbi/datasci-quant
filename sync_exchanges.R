#!/usr/bin/R

suppressMessages({
  library(data.table)
  library(httr)
  library(purrr)
  library(dataversionr)
  source("set_env.R")
  source_funs <- sapply(list.files("R", full.names = TRUE), source, .GlobalEnv)
})

exchanges <- list_exchanges()

operations <- map(exchanges, ~ sync_exchange(.x, dest))
names(operations) <- exchanges

print(operations)
