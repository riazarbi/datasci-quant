secrets <- 
  jsonlite::fromJSON(
    ifelse(Sys.getenv("SECRETS_FILE") == "",
           "~/secrets.json",
           Sys.getenv("SECRETS_FILE")))


if(Sys.getenv("S3_KEY") == ""){
  Sys.setenv(S3_KEY = secrets$aws_datasci_quant$aws_user_key)
  }
if(Sys.getenv("S3_SECRET") == "") {
  Sys.setenv(S3_SECRET = secrets$aws_datasci_quant$aws_secret_key)
}
if(Sys.getenv("S3_URL") == "") {
  Sys.setenv(S3_URL = "eu-central-1.s3.amazonaws.com")
}
if(Sys.getenv("ALPHAVANTAGE") == "") {
  Sys.setenv(ALPHAVANTAGE = secrets$alphavantage)
}
