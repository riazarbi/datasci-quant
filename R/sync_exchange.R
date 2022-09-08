sync_exchange <- function(exchange, dest) {
  
  exchange <- toupper(exchange)
  result <- query_exchange(exchange)
  
  if(result$exit_code == 1) {
    return(result)
  } else {
    update <- create_or_update_dv(result$overview, 
                                  fix_path(paste0("nasdaq/overview/",exchange), dest),
                                  key_cols = "symbol")
  }
  
  if(update) {
    return("Updated")
  } else {
    return("No new data")

}
}