library(ggplot2)
library(tidyverse)
library(sf)
library(terra)
library(tidyterra)
#library(raster)


# Ubicación archivo "ESRI-shape" de estados de la república mexicana
mapas_dir <- "z:/Datos/layers_harmon"
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
edos_shp_tr[1:3]$NOMGEO
plot(edos_shp_tr[1:3,])
plot(edos_shp_tr[2, 3])
quer_v <- subset(edos_shp_tr, edos_shp_tr$NOMGEO == "Querétaro", 
                c("CVEGEO", "CVE_ENT", "NOMGEO"))
quer_v$NOMGEO
plot(quer_v, "NOMGEO")

# Tipo de datos en estos mapas
class(edos_shp_tr)
class(ie2018_r_tr)

## Podemos extraer datos de un raster (aquí ie2018) con base en un polígono. 
ie2018_quer <- tibble(edo = "Que", extract(ie2018_r_tr, 
                              quer_v, na.rm=TRUE, xy = TRUE))
coordinates(ie2018_quer) <-  ~ x + y
names(ie2018_quer)
ie2018_quer_v <- vect(ie2018_quer)
crs(ie2018_quer_v)  <- "epsg:6372"
plot(ie2018_quer_v, "ie_2018_st_v2")

# Promedio
ie2018_quer_prom <- extract(ie2018_r_tr, quer_v, na.rm=TRUE, fun = mean,
                            as.spatvector = TRUE, xy = TRUE, bind = TRUE)
plot(ie2018_quer_prom, "ie_2018_st_v2")

extract(ie2018_r_tr, quer_v, na.rm=TRUE, as.spatvector = TRUE, 
        xy = TRUE)

# Mapa con más control de diseño
edos_shp_sf <- st_as_sf(edos_shp_tr)
names(edos_shp_sf)
ggplot(edos_shp_sf) + 
  geom_sf(aes(fill = NOMGEO), show.legend = FALSE) +
  labs(title = "México", subtitle = "objeto espacial sf a partir de <<SpatVector>>")

r_puntos <- st_as_sf(as.points(ie2018_r_tr))

# Mapas raster
ggplot() +
  geom_spatraster(data = ie2018_r_tr) +
  scale_fill_whitebox_c(palette = "muted", direction = -1)

ie2018_quer_r <- rasterize(ie2018_quer_v, ie2018_r_tr, "ie_2018_st_v2")
ggplot() +
  geom_sf(edos_shp_sf, aes(colour = "black"))

ggplot(edos_shp_sf) +
  geom_sf(aes(), fill = "white", show.legend = FALSE) +
  geom_spatraster(data = ie2018_quer_r) +
  scale_fill_whitebox_c(palette = "muted", direction = -1)
