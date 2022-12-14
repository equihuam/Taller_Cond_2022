library(drake)
library(dplyr)
library(ggplot2)
library(tidyr)
library(terra)

# Establecer rutas a archivos importantes.
ruta_ie <- "../data/ie/ie_yucatan_2018.tif"

# Cargar funciones auxiliares.
histograma_ie <- function(df_ie){
  ggplot(df_ie, aes(ie_yucatan_2018, fill = cut(ie_yucatan_2018,11))) +
    geom_histogram(show.legend = FALSE, bins = 101)+
    scale_fill_brewer(palette="RdYlGn", direction = -1)+
    xlab("Integridad ecosistémica") + 
    ylab("Cantidad de píxeles (250m)")
}

plan <- drake_plan(
    rast_ie = rast(ruta_ie),
    
    data = rast_ie %>% as.data.frame(),
    
    histograma = histograma_ie(data),
    
    ggsave("../blog/figuras/histograma_yucatan_ie.png")
)


plan

vis_drake_graph(plan)

make(plan)

history <- drake_history(analyze = TRUE)
history
