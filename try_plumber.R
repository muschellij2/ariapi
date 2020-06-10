library(httr)
library(ariExtra)
# url = "http://127.0.0.1"
# port = 4710
# api_url = paste0(url, ":", port)
api_url = "https://rsconnect.biostat.jhsph.edu/content/13"
api_url = paste0(api_url, "/to_ari")

api_key = Sys.getenv("CONNECT_API_KEY")
auth_hdr = NULL
if (nzchar(api_key)) {
  auth_hdr = httr::add_headers(
    Authorization = paste0("Key ", api_key))
}

open_video = function(res, open = TRUE) {
  httr::stop_for_status(res)
  bin_data = httr::content(res)
  bin_data = bin_data$video[[1]]
  bin_data = base64enc::base64decode(bin_data)
  output = tempfile(fileext = ".mp4")
  writeBin(bin_data, output)
  if (open) {
    system2("open", output)
  }
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
  body = body,
  auth_hdr)
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
  body = body, 
  auth_hdr)
output = open_video(res)

# Using PPTX - need libreoffice
file = system.file("extdata", "example.pptx", package = "ariExtra")

body = list(
  file = upload_file(file),
)
res = httr::POST(
  url = api_url, 
  body = body, 
  auth_hdr)
output = open_video(res)


# does not work - can't do multiple files - maybe base64 encode?
# file = system.file("extdata", c("example_1.png", "example_2.png"),
#                      package = "ariExtra")
# body = list(
#   # file = upload_file
#   file = lapply(file, upload_file),
#   script = upload_file(script)
# )
# res = httr::POST(
#   url = api_url, 
#   body = body, 
#   auth_hdr)
# output = open_video(res)

