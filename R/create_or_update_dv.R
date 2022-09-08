create_or_update_dv <- function(df, destination, key_cols, diffed = TRUE, backup_count = 0L) {
  if(is_dv(destination)) {
    update <- update_dv(df, destination)
    return(update)
  } else {
    create <- create_dv(df, 
              destination, 
              key_cols = key_cols, 
              diffed = diffed, 
              backup_count = backup_count)
    return(TRUE)
  }
}
