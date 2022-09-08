secrets <- 
  jsonlite::fromJSON(
    ifelse(Sys.getenv("SECRETS_FILE") == "",
           "~/secrets.json",
           Sys.getenv("SECRETS_FILE")))
