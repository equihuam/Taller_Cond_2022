library(terra)

# Ubicación archivo "ESRI-shape" de estados de la repúba mexicana
mapas_dir <- "../data/indep_vars"
lst_gtif <- list.files(mapas_dir, ".tif$", full.names = TRUE)

tiempo_inicio <- Sys.time()
multi_capas <- c()
capas <- c()
for (r in lst_gtif)
{
  capas <- c(capas, sub(".tif", "", basename(r)))
  multi_capas <- c(multi_capas, st_as_sf(as.points(rast(r))))
}


names(multi_capas) <- capas
capas_df <- as.data.frame(multi_capas)
head(capas_df)
tiempo_fin = Sys.time()
tiempo_fin - tiempo_inicio


# Ruta con biblioteca raster 
tiempo_inicio <- Sys.time()
datos_brk <- raster(lst_gtif[1])    
for (r in lst_gtif[2:length(lst_gtif)])
{
  datos_brk <- addLayer(datos_brk, raster(r))
}

names(datos_brk)
datos_tbl <- as.data.frame(rasterToPoints(datos_brk))
head(datos_tbl)
tiempo_fin = Sys.time()
tiempo_fin - tiempo_inicio

write.csv(datos_tbl, file = paste0(mapas_dir,"/datos_yuc_2018.csv"), 
          na = "*", row.names = FALSE, quote = FALSE)
