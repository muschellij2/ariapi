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
  # print("req is this!")
  # print(req)
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

guess_ari_func = function(contents, verbose = TRUE) {
  file = contents$file
  if (!is.data.frame(file)) {
    if (verbose) {
      print("gs")
    }
    func_name = ariExtra::gs_to_ari
    attr(func_name, "type") = "gs"
    
  } else {
    type = file$type
    btype = tolower(basename(type))
    if (btype %in% "pdf") {
      if (verbose) {
        print("pdf")
      }      
      func_name = ariExtra::pdf_to_ari
      attr(func_name, "type") = "png"
      
    }
    if (btype %in% "png") {
      if (verbose) {
        print("png")
      }      
      func_name = ariExtra::pngs_to_ari
      attr(func_name, "type") = "png"
    }
    if (any(grepl("officedocument.presentation", btype))) {
      if (verbose) {
        print("pptx")
      }      
      func_name = ariExtra::pptx_to_ari
      attr(func_name, "type") = "pptx"
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
#* @param script file upload of script
#* @param file file upload of PDF slides, PPTX file, or list of PNGs
#* @serializer contentType list(type="video/mp4")
#* @post /to_ari
function(req) {
  
  # stop("Not ready")
  contents = name_contents(req)
  print("contents")
  print(contents)
  func_to_run = guess_ari_func(contents, verbose = TRUE)
  type_out = attr(func_to_run, "type")
  attr(func_to_run, "type") = NULL
  print("func_to_run")
  # print(func_to_run)
  file = contents$file
  print("file")
  print(file)
  script = contents$script
  print(script)
  voice = contents$voice
  service = contents$service
  
  if (is.null(type_out) || !type_out %in% "gs") {
    file = file$datapath
  }
  script = script$datapath
  
  cat(file)
  cat(script)
  args = list(path = file, script = script)
  args$service = service
  args$voice = voice
  args$open = FALSE
  res = do.call(func_to_run, args = args)
  # res = func_to_run(file, script = script, 
  #                   open = FALSE)
  ari_processor(res, voice = voice)
}


ari_processor = function(res, voice) {
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
