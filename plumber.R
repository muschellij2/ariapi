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
library(animation) #need for ffmpeg




#' @examples 
#' library(httr)
#' file = system.file("extdata", "example.pdf", package = "ariExtra")
#' tfile = tempfile()
#' script = c("hey", "ho")
#' writeLines(script, tfile)
#' 
#' api_url = "http://127.0.0.1:4892"
#' POST(paste0(api_url, "/pdf_to_video"),
#'    body = list(file = upload_file(file), script = upload_file(tfile)))
name_contents = function(req) {
  contents = mime::parse_multipart(req)
  arg_names = c("file", "script", "voice",
                "service")
  contents_names = names(contents)
  print(arg_names)
  named_contents = contents[contents_names %in% arg_names ]
  contents = contents[!names(contents) %in% arg_names]
  n_contents = seq_along(contents)
  print(contents)
  names(contents) = setdiff(arg_names, contents_names)[n_contents]
  contents = c(named_contents, contents)
  
  voice = contents$voice
  service = contents$service
  if (is.null(service)) {
    service = "amazon"
  }
  if (is.null(voice)) {
    voice = text2speech::tts_default_voice(service = service)
  }
  contents$voice = voice
  contents$service = service
  
  return(contents)
}

guess_ari_func = function(contents) {
  file = contents$file
  if (!is.data.frame(file)) {
    func_name = "ariExtra::gs_to_ari"
  } else {
    type = file$type
    btype = tolower(basename(type))
    if (btype %in% "pdf") {
      func_name = "ariExtra::pdf_to_ari"
    }
    if (btype %in% "png") {
      func_name = "ariExtra::pngs_to_ari"
    }
    if (any(grepl("officedocument.presentation", btype))) {
      func_name = "ariExtra::pptx_to_ari"
    }
    # func_name = "mp4_to_ari"
    
    # func_name = "rmd_to_ari"
    # func_name = "mp4_to_ari"
  }
  
  # use do.call
  return(func_name)

}

#* @apiTitle Presentation Video Generation API

#* Echo back the input
#* @param file file upload of PDF slides
#* @param script file upload of script
#* @serializer contentType list(type="video/mp4")
#* @post /pdf_to_video
function(req) {
  
  # stop("Not ready")
  contents = name_contents(req)
  func_to_run = guess_ari_func(contents)
  file = contents$file
  print(file)
  script = contents$script
  print(script)
  voice = contents$voice
  service = contents$service
  
  file = file$datapath
  script = script$datapath
  
  cat(file)
  cat(script)
  # args = list(file = file, script = script)
  # args$service = service
  # args$voice = voice
  # args$open = FALSE
  # do.call(func_to_run, args = args)
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
  readBin(output, "raw", n = file.info(output)$size)
}

