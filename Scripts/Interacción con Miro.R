library(httr)
library(jsonlite)

id_tablero <- "uXjVPf-z5Tg="

tablero <-  paste0("https://api.miro.com/v2/boards/", id_tablero)
queryString <- list(limit = "10")
response <- VERB("GET", tablero, 
                 add_headers('Authorization' = 
                             'Bearer eyJtaXJvLm9yaWdpbiI6ImV1MDEifQ_hS_tz0Dughp2VY6nZCYbsTouuAg'), 
                 query = queryString, content_type("application/octet-stream"), 
                 accept("application/json"))

datos_tablero <- fromJSON(content(response, "text", encoding = "UTF-8"))

datos_tablero$sharingPolicy
