library(data.table)
library(sf)
library(lubridate)
library(dplyr)


load("/home/grad/rkm22/sta644/data/fullCrimeData.Rdata")

areas = st_read('/home/grad/rkm22/sta644/spatio_temp_proj/shapeData/CommAreas.shp', 
                quiet=TRUE, stringsAsFactors=TRUE)
