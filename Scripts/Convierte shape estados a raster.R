library(ggplot2)
library(tidyverse)
library(sf)
library(terra)
library(tidyterra)
library(RColorBrewer)
library(paletteer)

# Ubicación archivo "ESRI-shape" de estados de la república mexicana
mapas_dir <- "../datos/"
edos_arch <- list.files(mapas_dir, pattern = "^00.*shp$", 
                        full.names = TRUE, recursive = TRUE)
ie2018_r_arch <- list.files(mapas_dir, pattern = "^ie_2018.*.tif$", 
                            full.names = TRUE, recursive = TRUE)

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

# Tipo de datos en estos mapas
class(edos_shp_tr)
class(ie2018_r_tr)

# Geometría
crs(edos_shp_tr, describe=TRUE)$area

# Conviene mejorar la especificación de la proyección con un códigos "epsg"
crs(ie2018_r_tr)  <- "epsg:6372"
crs(edos_shp_tr)    <- "epsg:6372"
crs(edos_shp_tr, describe=TRUE)$area
ext(edos_shp_tr)

### SpatVector: selección de objetos geográficos
edos_shp_tr[1:3]$NOMGEO
plot(edos_shp_tr[1:3,])
plot(edos_shp_tr[2, 3])
quer_v <- subset(edos_shp_tr, edos_shp_tr$NOMGEO == "Querétaro", 
                c("CVEGEO", "CVE_ENT", "NOMGEO"))

# Características de los Resultados y mapa
cat(crs(quer_v))
ext(quer_v)
quer_v$NOMGEO
plot(quer_v, "NOMGEO")


## Podemos extraer datos de un raster (aquí ie2018) con base en un polígono. 
ie2018_quer <- tibble(edo = "Querétaro", extract(ie2018_r_tr, quer_v, na.rm=TRUE, 
                                           xy = TRUE, bind = TRUE))

ie2018_quer <- vect(ie2018_quer, geom = c("x", "y"))
crs(ie2018_quer)  <- "epsg:6372"
names(ie2018_quer)
plot(ie2018_quer, "ie_2018_st_v2", main = "Querétaro IIE2018 v2")

# Promedio
ie2018_edo_prom_v <- extract(ie2018_r_tr, edos_shp_tr, na.rm=TRUE, fun = mean,
                            as.spatvector = TRUE, xy = TRUE, bind = TRUE)
plot(ie2018_edo_prom_v, "México IIE2018 v2")
head(ie2018_edo_prom_v) 

# Mapa con más control de diseño mediante "ggplot2"
# Mapa de estados de la república
edos_shp_sf <- st_as_sf(edos_shp_tr)
names(edos_shp_sf)
ggplot(edos_shp_sf) + 
  geom_sf(aes(fill = NOMGEO), show.legend = FALSE) +
  labs(title = "México", subtitle = "objeto espacial sf a partir de <<SpatVector>>")

# Integridad promedio por Estado
ie2018_edo_prom_v_sf <- st_as_sf(ie2018_edo_prom_v)
names(ie2018_edo_prom_v_sf)
ggplot(ie2018_edo_prom_v_sf) + 
  geom_sf(aes(fill = ie_2018_st_v2), show.legend = TRUE) +
  labs(title = "México", subtitle = "Condición (IIE-2018 v2") +
  scale_fill_gradient2(midpoint = 0.5, low = "firebrick", mid = "khaki1", 
                       high = "darkolivegreen4", na.value = "transparent")

# Mapas raster
ggplot() +
  geom_spatraster(data = ie2018_r_tr) +
  labs(title = "México", subtitle = "IE-2018 v2 (objeto SpatRraster)")+
  guides(fill = guide_legend(title="Condición (IIE)")) +
  scale_fill_gradient2(midpoint = 0.5, low = "firebrick", mid = "khaki1", 
                       high = "darkolivegreen4", na.value = "transparent")

# Caso Querétaro
quer_v_sf <- st_as_sf(quer_v)
ie2018_quer_r <- rasterize(ie2018_quer_v, ie2018_r_tr, "ie_2018_st_v2")
ext(ie2018_quer_r) <- ext(quer_v) 
plot(ie2018_quer_r)
lines(quer_v)

ext(ie2018_quer_r)

ie2018_quer_r <- crop(ie2018_r_tr, quer_v)

ggplot(quer_v_sf) +
  geom_sf(aes(), fill = "white", show.legend = FALSE) +
  geom_spatraster(data = ie2018_quer_r) +
  scale_fill_whitebox_c(palette = "muted", direction = -1)
