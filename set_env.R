library(arrow)

if(Sys.getenv("MODE") == "") {
  Sys.setenv(MODE = "DEV")
  message("!! Running in DEV mode !!")
} else {
  message("!! Running in PROD mode !!")
}

if(Sys.getenv("ALPHAVANTAGE") == "") {
  Sys.setenv(ALPHAVANTAGE = secrets$alphavantage)
  message("Setting ALPHAVANTAGE var from secrets...")
}

fs <- LocalFileSystem$create()
if (Sys.getenv("MODE") == "DEV") {
  dest <- fs$cd("/data/quant-dev")  
} else {
  dest <- fs$cd("/data/quant")
}
