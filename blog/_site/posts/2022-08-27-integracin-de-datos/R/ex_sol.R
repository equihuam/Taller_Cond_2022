# 2.
scale_fill_brewer(palette="RdYlGn", direction = -1)

# 3.
for (i in 1:22){ # Esto se lee para i que tomará los valores 1,2,3,...,22
  raster_i <- raster(ruta_indep[i]) # Lee el i-esimo raster y lo asigna a un objeto
}

# 4.
library("raster")
library("tools")

# Lista de los rasters considerados variables explicativas.
ruta_indep = list_files_with_exts("./indep_var_paths",
                                  exts = "tif")

dep_var_path = "./delta_vp/hemerobia_250m.tif"

rutasAMulti = function(dep_path,
                       indep_paths){
  
  bnbrik = brick()
  bnbrik = addLayer(bnbrik,raster(dep_path))
  for (i in 1:length(indep_paths)){
    bnbrik = addLayer(bnbrik,raster(indep_paths[i]))
  }
  return(bnbrik)
}

raster_multi <- rutasAMulti(dep_var_path, ruta_indep)

tabla_multi <- as.data.frame(rasterToPoints(raster_multi))

datos_modelo <- tabla_multi[,3:24] # Quitar coordenadas y ZVH.

modelo_lineal <- lm(hemerobia_250m~., data = datos_modelo)

summary(modelo_lineal)

### Respuesta
obs_conservadas <- datos_modelo[datos_modelo$hemerobia_250m == 0,]

obs_conservadas$propor_urbano <- 60

predict(modelo_lineal, obs_conservadas)
