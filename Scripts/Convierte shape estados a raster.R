library(ggplot2)
library(tidyverse)
library(sf)
library(terra)
library(raster)


# Ubicación archivo "ESRI-shape" de estados de la república mexicana
mapas_dir <- "V:/Datos/layers_harmon"
edos_arch <- list.files(mapas_dir, pattern = "^00.*shp$", full.names = TRUE)
ie2018_r_arch <- list.files(mapas_dir, pattern = "^ie_2018.*.tif$", full.names = TRUE)

# Hacer todo con TERRA para leer vectores y raster
edos_shp_tr <- vect(edos_arch)
ie2018_r_tr <- rast(ie2018_r_arch)
Encoding(edos_shp_tr$NOMGEO) <- "latin1"

# Hay que tener cuidado con la codificación de proyecciones
# Este mapa tiene una proyección Lambert CC 2008, con EPSG:6372
cat(crs(edos_shp_tr))
cat(crs(ie2018_r_tr))

# Despliegue simple de los mapas
plot(ie2018_r_tr)
lines(edos_shp_tr)

# Geometría
crs(edos_shp_tr, describe=TRUE)$area

# Conviene mejorar la especificación de la proyección con un códigos "epsg"
crs(ie2018_r_tr)  <- "epsg:6372"
crs(edos_shp_tr)    <- "epsg:6372"
crs(edos_shp_tr, describe=TRUE)$area


### SpatVector: selección de objetos geográficos
edos_shp_tr[1:3, 3]
plot(edos_shp_tr[1:3,])
plot(edos_shp_tr[1:2, 3])
quer_v <- subset(edos_shp_tr, edos_shp_tr$NOMGEO == "Querétaro", 
                c("CVEGEO", "CVE_ENT", "NOMGEO"))
quer_v$NOMGEO
plot(quer_v)

# Tipo de datos en estos mapas
class(edos_shp_tr)
class(ie2018_r_tr)

## Podemos extraer datos de un raster (aquí ie2018) con base en un polígono. 
ie2018_quer <- tibble(edo = "Que", 
                   ie2018 = sort(unique(extract(ie2018_r_tr, 
                              quer_v, na.rm=TRUE)$ie_2018_st_v2)))
ie2018_quer_prom <- extract(ie2018_r_tr, quer_v, na.rm=TRUE, fun = mean,
                            as.spatvector = TRUE, xy = TRUE, bind = TRUE)
plot(ie2018_quer_prom, "ie_2018_st_v2")

# Mapa con más control de diseño
edos_shp_sf <- st_as_sf(edos_shp_tr)
names(edos_shp_sf)
ggplot(edos_shp_sf) + 
  geom_sf(aes(fill = NOMGEO), show.legend = FALSE) +
  labs(title = "México", subtitle = "objeto espacial sf a partir de <<SpatVector>>")

r_puntos <- st_as_sf(as.points(ie2018_r_tr))

ggplot(r_puntos) +
  geom_sf(aes(col = zvh_inegi)) 
