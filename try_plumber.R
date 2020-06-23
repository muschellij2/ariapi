library(httr)
library(ariExtra)
# url = "http://127.0.0.1"
# port = 4710
# api_url = paste0(url, ":", port)

api_url = "https://rsconnect.biostat.jhsph.edu/ario"
# api_url = "https://rsconnect.biostat.jhsph.edu/content/13"
# api_url = paste0(api_url, "/to_ari")

helper_functions = system.file("extdata", "plumber_functions.R", 
                               package = "ariExtra")

source(helper_functions)
####################################################
# Testing
####################################################

# get voices
res = mario_voices()

# Google Slide ID
id = "1Opt6lv7rRi7Kzb9bI0u3SWX1pSz1k7botaphTuFYgNs"
res = mario(id)
httr::stop_for_status(res)

# Using PDF
pdf_file = system.file("extdata", "example.pdf", package = "ariExtra")
script = tempfile(fileext = ".txt")
paragraphs = c("hey", "ho")
writeLines(paragraphs, script)

# Trying with script or paragraphs
res = mario(pdf_file, script)
httr::stop_for_status(res)
res = mario(pdf_file, paragraphs)
httr::stop_for_status(res)

# Using PPTX - need libreoffice
file = system.file("extdata", "example.pptx", package = "ariExtra")
res = mario(file)

# Set of PNGs
file = system.file("extdata", c("example_1.png", "example_2.png"),
                   package = "ariExtra")

res = mario(file, script)
httr::stop_for_status(res)
res = mario(file, paragraphs)
httr::stop_for_status(res)



