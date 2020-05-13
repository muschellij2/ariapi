#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)
library(ari)
library(ariExtra)
library(didactr)
library(rmarkdown)

file = system.file("extdata", "example.pdf", package = "ariExtra")
script = c("hey", "ho")

#* @apiTitle Presentation Video GenerationAPI

#* Echo back the input
#* @param msg The message to echo
#* @put /pdf_to_video
function(file, script, voice = NULL) {
  res = pdf_to_ari(file, script = script, 
                   open = FALSE)
  doc_args = list(verbose = TRUE)
  doc_args$voice = voice
  format = do.call(ari_document, args = doc_args)
  
  out = rmarkdown::render(res$output_file, output_format = format)
  output = output_movie_file
  if (!file.exists(output)) {
    stop("Video was not generated") 
  }
  return()
}

#* Plot a histogram
#* @png
#* @get /plot
function() {
    rand <- rnorm(100)
    hist(rand)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b) {
    as.numeric(a) + as.numeric(b)
}
