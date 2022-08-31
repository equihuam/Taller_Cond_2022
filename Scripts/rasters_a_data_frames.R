library(terra)

mapas_dir <- "../data/indep_vars"

# Lista de los rasters considerados variables explicativas.
lst_gtif <- list_files_with_exts("..//data/indep_vars",
                                 exts = "tif")
lst_gtif
todo <- rast(lst_gtif)
puntos <- as.points(todo, keepgeom = TRUE)
class(puntos)
names(puntos)
puntos_1 <- st_as_sf(puntos, coords = c("x", "y"))
class(puntos_1)
names(puntos_1)

puntos_1_coord <- as.data.frame(st_coordinates(puntos_1$geometry))
names(puntos_1_coord)
head(puntos_1_coord)

puntos_fin <- cbind(puntos_1_coord, puntos_1)
head(puntos_fin)
