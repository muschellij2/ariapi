library(httr)
# remotes::install_github("muschellij2/ariExtra", upgrade = FALSE)
library(ariExtra)

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




id = paste0("https://docs.google.com/presentation/d/",
            "1Tg-GTGnUPduOtZKYuMoelqUNZnUp3vvg_7TtpUPL7e8",
            "/edit#slide=id.g154aa4fae2_0_58")
id = ariExtra::get_slide_id(id)
words = strsplit(
  c("hey what do you think of this thing? ", 
    "I don't know what to type here."), split = " ")
script = tempfile(fileext = ".txt")
script = writeLines(
  rep(unlist(words), 
      length.out = 41), con = script)

out = mario(file = id, 
      script = script, 
      token = "googlesheets_token.rds", 
      target = "es")
