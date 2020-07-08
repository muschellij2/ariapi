library(httr)
library(ariExtra)
library(didactr)
api_url = "http://127.0.0.1:1400"
path = "/translate_slide"
url = paste0(api_url, path)

id = paste0("https://docs.google.com/presentation/d/",
            "1Tg-GTGnUPduOtZKYuMoelqUNZnUp3vvg_7TtpUPL7e8",
            "/edit#slide=id.g154aa4fae2_0_58")
id = ariExtra::get_slide_id(id)
result = httr::POST(
  url,
  body = list(file = id, 
              token = httr::upload_file('googlesheets_token.rds'),
              target = "es"
  )
)
