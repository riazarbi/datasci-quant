library(arrow)

if(Sys.getenv("MODE") == "") {
  Sys.setenv(MODE = "dev")
}

secrets <- 
  jsonlite::fromJSON(
    ifelse(Sys.getenv("SECRETS_FILE") == "",
           "~/secrets.json",
           Sys.getenv("SECRETS_FILE")))


if(Sys.getenv("ALPHAVANTAGE") == "") {
  Sys.setenv(ALPHAVANTAGE = secrets$alphavantage)
}

fs <- LocalFileSystem$create()
if (Sys.getenv("MODE") == "prod") {
  dest <- fs$cd("/data/quant")  
} else {
  dest <- fs$cd("/data/quant-dev")
}
