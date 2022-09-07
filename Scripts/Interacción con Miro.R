library(httr)
library(jsonlite)

# Siguiendo las instruccioes de https://developers.miro.com/reference/api-reference

id_tablero <- "uXjVPf-z5Tg="

tablero <-  paste0("https://api.miro.com/v2/boards/", id_tablero)
queryString <- list(limit = "10")
response <- VERB("GET", tablero, 
                 add_headers('Authorization' = 
                             'Bearer eyJtaXJvLm9yaWdpbiI6ImV1MDEifQ_hS_tz0Dughp2VY6nZCYbsTouuAg'), 
                 query = queryString, content_type("application/octet-stream"), 
                 accept("application/json"))

datos_tablero <- fromJSON(content(response, "text", encoding = "UTF-8"))

datos_tablero$id


tablero["id"] = tablero["id"]
tablero["nombre"] = tablero["name"]
tablero["descripción"] = tablero["description"]

print(f"Tablero: {tablero['id']}")
print(f"    nombre: {tablero['nombre']}")
print(f"    descripción: {tablero['descripción']}\n")

# Recupera items de cualquier tipo
url = "https://api.miro.com/v2/boards/uXjVPZm0dRE%3D/items?limit=50&type=shape"
all_items = requests.get(url, headers=headers).json()
cuadros = [a["data"]["content"] for a in all_items["data"]]
cuadros = [re.sub("<.*?>|&#.*?;|⏩|⛔|\\ufe0f", "", c) for c in cuadros]
colores = {"cyan": [c for c in cuadros if "Continuar" in c][0],
  "light_blue":  [c for c in cuadros if "Actuar" in c][0],
  "red":  [c for c in cuadros if "Resolver" in c][0],
  "yellow":  [c for c in cuadros if "Inventar" in c][0]}

# Recupera sticky_notes en el tablero
url = "https://api.miro.com/v2/boards/uXjVPZm0dRE%3D/items?limit=50&type=sticky_note"
items = requests.get(url, headers=headers).json()
tablero.update({"Num items": items["total"]})

if "cursor" in items.keys():
  items_sig = items["cursor"]
url2 = "https://api.miro.com/v2/boards/uXjVPZm0dRE%3D/items?limit=49&type=sticky_note&cursor="
url2 = url2 + items_sig

pegotes = [[i["style"]["fillColor"], i["data"]["content"]] for i in items["data"]]
pegotes = [[i[0], re.sub("<.*?>|&#.*?;|\\xa0|\\ufe0f", "", i[1])] for i in pegotes]
pegotes = sorted(pegotes, key=lambda x:x[0])

with open("../data/Miro/Miro_notitas.csv", "w", encoding="utf-8") as sale:
  sale.write("color,acción,idea\n")
[sale.write(f"{p[0]},'{colores[p[0]]}','{p[1]}'\n") for p in pegotes]

