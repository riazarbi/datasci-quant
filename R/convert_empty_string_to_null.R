#' Convert empty string to null
#'
#' Convert empty trings to NULLs
#'
#' @param string A string.
#'
#' @return if the input string is empty, it returns a null, else it returns the unmodified string.
#' @export
#'
#' @examples
#' convert_empty_string_to_null("") == NULL
convert_empty_string_to_null <- function(string) {
  if(string == "") {
    string = NULL}
  return(string)
}
