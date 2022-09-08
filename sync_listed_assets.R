suppressMessages({
  library(httr)
  library(dplyr)

  source("set_env.R")
  source_funs <- sapply(list.files("R", full.names = TRUE), source, .GlobalEnv)
})

alphavantage_key = Sys.getenv("ALPHAVANTAGE")


# All listed stocks
listed_rsp <-
  GET(
    paste0(
      "https://www.alphavantage.co/query?function=LISTING_STATUS&apikey=",
      alphavantage_key,
      "&state=listed"
    )
  )

listed <-
  content(
    listed_rsp,
    type = "text/csv",
    encoding = "UTF-8",
    as = "parsed",
    col_types = "ccccDDc"
  )

# Send to dv
update <- create_or_update_dv(listed, 
                    fix_path("alphavantage/listed_assets", dest), 
                    key_cols = "symbol")

if(update) {
  message("Updated")
  quit(save = "no", status = 0)
} else {
  message("No new data")
  quit(save = "no", status = 0)
}

