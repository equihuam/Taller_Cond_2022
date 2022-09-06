library(httr)

id_tablero <- "uxjVPZm0dRE="
id_tablero <- "uXjVPf-z5Tg="

url <-  paste0("https://api.miro.com/v2/boards/", id_tablero)
queryString <- list(limit = "10")
response <- VERB("GET", url, 
                 add_headers('Authorization' = 
                             'Bearer eyJtaXJvLm9yaWdpbiI6ImV1MDEifQ_hS_tz0Dughp2VY6nZCYbsTouuAg'), 
                 query = queryString, content_type("application/octet-stream"), 
                 accept("application/json"))

content(response, "text")
