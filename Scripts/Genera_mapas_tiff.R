# Prepara mapa de ie

# packages
library(tidyverse)
library("raster")
library("rgdal")
library ("ggplot2")
library("data.table")
library("scales")

# Utiliza el comando "net" de DOS para mapear una url a un disco local virtual.
url <- "https://inecol.sharepoint.com/sites/ie-2016/Base_de_datos_IE/3_vars_explicativas"
if (!dir.exists("Y:/")) system(paste("net use Y:", url, sep = " "))

url <- "https://inecol.sharepoint.com/sites/ie-2016/Base_de_datos_IE/3_vars_explicativas/Formato_tabular"
if (!dir.exists("Z:/")) system(paste("net use Z:", url, sep = " "))

dir_shP_docs <- "~/1 Nubes/El Instituto de Ecología/Proyecto Integralidad Gamma - Documentos/03 Documentos en preparación/"
dir_ShP_gamma <- "Ecosystem Integrity/Versión Gamma de IE/"

dir_datos_bn  <- paste(dir_shP_docs, dir_ShP_gamma, "Valores_ie_tablas/", sep = "")# <- "Z:/"
archs_datos_ie <- list.files(dir_datos_bn, pattern = "IE_Gamma_trained_ROBIN70", full.names = TRUE)
# datos_bn <- paste(dir_datos_bn, "2_set_cobertura_completa/ie_time_series.csv", sep="")

# Lee datos variables explicativas para incluir coordenadas
coordenadas <- read_csv(paste(dir_shP_docs, dir_ShP_gamma, "data_all_vars_2004.csv", sep = ""))


# load data
for (arch in archs_datos_ie)
{
  year_name <- paste("ie_", regmatches(arch, regexpr("[0-9]{4}", arch)), sep = "")
  disc_tipo <- regmatches(arch, regexpr("disc_[0-9]{1,2}", arch))
  disc_tipo <- "train_ROBIN"
  ie_name <- paste(year_name, "_", disc_tipo, sep = "")
  print(ie_name)
  if(arch == archs_datos_ie[1])
  {
    datos_leidos <- read_csv(arch, na = "*")
    datos_leidos <- 100 * (18 - datos_leidos) / 18
    datos_ie_disc <- tibble(coordenadas$x, coordenadas$y, datos_leidos[[1]])
    names(datos_ie_disc) <- c("x", "y", ie_name)
  } else {
    datos_leidos <- read_csv(arch, na = "*")
    datos_leidos <- 100 * (18 - datos_leidos) / 18
    names(datos_leidos) <- ie_name
    datos_ie_disc <- cbind(datos_ie_disc, datos_leidos)
  }
}

# load base raster
map_raster <- path.expand(paste(dir_shP_docs, dir_ShP_gamma, "bov_cbz_km2.tif", sep=""))
base <- raster(map_raster)
plot (base)

for (ie_data in names(datos_ie_disc[,3:4]))
{
  # ie map
  mapa <- tibble(x=datos_ie_disc$x, y=datos_ie_disc$y, datos_ie_disc[, ie_data])
  coordinates(mapa) <- ~ x + y
  gridded(mapa) <- TRUE
  raster_map <- raster(mapa)
  
  # set projection
  projection(raster_map) <- projection(base)
  plot (raster_map, axes=FALSE, box=FALSE, main = state)
  
  # write to disk
  tif_file <- paste(dir_shP_docs, dir_ShP_gamma, "mapas_ie_y_zvh/", ie_data, sep = "")
  print(tif_file)
  ie <- writeRaster(raster_map, filename=tif_file, format="GTiff", overwrite=TRUE)
  print(state)
}
