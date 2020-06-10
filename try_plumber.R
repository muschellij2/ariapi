library(httr)
library(ariExtra)
# url = "http://127.0.0.1"
# port = 5916
# api_url = paste0(url, ":", port)
api_url = "https://rsconnect.biostat.jhsph.edu/content/13"
api_url = paste0(api_url, "/to_ari")

open_video = function(res) {
  httr::stop_for_status(res)
  bin_data = content(res)
  output = tempfile(fileext = ".mp4")
  writeBin(bin_data, output)
  system2("open", output)
  output
}
# Google Slide ID
id = "1Opt6lv7rRi7Kzb9bI0u3SWX1pSz1k7botaphTuFYgNs"

body = list(
  # file = upload_file
  file = id
)
res = httr::POST(
  url = api_url, 
  body = body)
output = open_video(res)


# Using PDF
pdf_file = system.file("extdata", "example.pdf", package = "ariExtra")
script = tempfile(fileext = ".txt")
writeLines(c("hey", "ho"), script)

body = list(
  # file = upload_file
  file = upload_file(pdf_file),
  script = upload_file(script)
)
res = httr::POST(
  url = api_url, 
  body = body)
output = open_video(res)

