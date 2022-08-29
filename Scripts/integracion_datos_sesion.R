#####
##### Aquí irá todo el trabajo llevado a cabo en la sesión.

# Cargar paquetes.
library("raster") #terra

# Cargar un geotiff a R, de hecho el que sirve como evidencia para el modelo de IE.
ruta_evidencia <- "./delta_vp/hemerobia_250m.tif"
raster_evidencia <- raster(ruta_evidencia)

tabla_evidencia <- as.data.frame(rasterToPoints(raster_evidencia))

head(tabla_evidencia)

library("tools")

# Lista de los rasters considerados variables explicativas.
ruta_indep = list_files_with_exts("./indep_var_paths",
                                  exts = "tif")

rutasAMulti = function(dep_path,
                       indep_paths){
  
  bnbrik = brick()
  bnbrik = addLayer(bnbrik,raster(dep_path))
  for (i in 1:length(indep_paths)){
    bnbrik = addLayer(bnbrik,raster(indep_paths[i]))
  }
  return(bnbrik)
}

raster_multi <- rutasAMulti("./delta_vp/hemerobia_250m.tif", ruta_indep)

tabla_multi <- as.data.frame(rasterToPoints(raster_multi))

datos_modelo <- tabla_multi[,3:24] # Quitar coordenadas y ZVH.

datos_modelo <- datos_modelo[complete.cases(datos_modelo),] # Quitar casos con valores faltantes.

modelo_lineal <- lm(hemerobia_250m~. , data = datos_modelo) # Ajuste modelo. 
# La fórmula variable~. significa variable explicada por "todo lo demás".

conservados <- datos_modelo[datos_modelo$hemerobia_250m == 0,]

conservados_effect <- conservados
conservados_effect$propor_urbano <- 80

predict(modelo_lineal, conservados_effect)
