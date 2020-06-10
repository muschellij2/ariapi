library(httr)
library(ariExtra)
url = "http://127.0.0.1"
port = 5916
api_url = paste0(url, ":", port)
id = "1Opt6lv7rRi7Kzb9bI0u3SWX1pSz1k7botaphTuFYgNs"

body = list(
  # file = upload_file
  file = id
)
res = httr::POST(
  url = api_url, 
  path = "to_ari",
  body = body)
res
content(res)
