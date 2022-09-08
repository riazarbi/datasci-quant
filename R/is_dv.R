is_dv <- function(destination) {
  tryCatch(is.list(get_metadata(destination)), 
           error = function(e) FALSE)
}