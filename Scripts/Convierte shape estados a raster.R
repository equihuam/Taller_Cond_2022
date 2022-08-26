library(raster)
library(ggplot2)
library(tidyverse)
library(sf)
library(sp)

# Ubicación archivo "ESRI-shape" de estados de la república mexicana
mapas_dir <- "V:/Datos/layers_harmon"
edos_arch <- list.files(mapas_dir, pattern = "^00.*shp$", full.names = TRUE)
edos_shp <- shapefile(edos_arch[1])
class(edos_shp)
Encoding(edos_shp$NOMGEO) <- "latin1"
names(edos_shp)
edos_shp$NOMGEO
plot(edos_shp, main = "México\nalgorítmo r básico")


# Solución más actualizada (conviere datos tipo "sp" a "sf")
edos_shp.sf = st_as_sf(edos_shp)

# Hay que tener cuidado con la codificación de proyecciones
st_crs(edos_shp.sf) <- projection(edos_shp.sf)
class(edos_shp.sf)
ggplot(edos_shp.sf) + 
  geom_sf(aes(fill = NOMGEO), show.legend = FALSE) +
  labs(title = "México", subtitle = "objeto espacial preferido actualmente: sf")

# Especificación geográfica
projection(edos_shp.sf)

# Conversión a raster, tomando atributos de un mapa GeoTIFF de referencia
raster_ref_arch <- list.files(mapas_dir, pattern = "^zvh.*.tif$", full.names = TRUE)
raster_ref <- raster(raster_ref_arch)
plot(raster_ref)

edos_rast <- rasterize(edos_shp.sf, raster_ref, fun = "first")
plot(edos_rast)

# Este raster tiene las siguientes propiedades geométricas
st_crs(edos_rast)
extent(edos_rast)
res(edos_rast)

# Para convertir estos mapas en datos tabulares convertimos a puuntos y luego a tabla
edos_tbl <- as_tibble(rasterToPoints(edos_rast))

# Agregar esta columna a la base de datos de todas las variables, es un "csv"
vars_arch <- list.files(mapas_dir, pattern = "^ie_train.*.csv$", full.names = TRUE)
vars_tbl  <- read_csv(vars_arch, na = "*")

