test_response <- function(av_response) {
  status_code = av_response$status_code == 200
  
  not_empty = (length(content(av_response)) != 0)
  
  is_json = stringr::str_detect(av_response$headers$`content-type`, "application/json") 
  
  not_informational = if (not_empty) {
    names(content(av_response)[1]) != "Information"
  } else {
    NA
  }
  
  api_limit_ok = if (not_empty) {
    !(grepl("higher API", content(av_response)[1], fixed = TRUE))
  } else {
    NA
  }
  
  api_call_valid = if (not_empty) {
    !(grepl("Invalid API call", content(av_response)[1], fixed = TRUE))
  } else {
    NA
  }
  
  
  return(
    list(
      status_code = status_code,
      not_empty = not_empty,
      is_json = is_json,
      not_informational = not_informational,
      api_limit_ok = api_limit_ok,
      api_call_valid = api_call_valid
    )
  )
}
