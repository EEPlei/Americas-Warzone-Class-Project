library(sf)
library(data.table)
library(stringr)
library(ggplot2)
library(ggmap)


comm = st_read('shapeData/CommAreas.shp', quiet=TRUE, stringsAsFactors = TRUE)
names(comm) = c("AREA","PERIMETER","COMAREA_","COMAREA_ID","AREA_NUMBE","Geog", 
                "AREA_NUM_1","SHAPE_AREA","SHAPE_LEN","geometry")
dem = fread('chicago_dem_data.csv', header = TRUE)
dem$Geog = str_replace_all(tolower(str_replace_all(dem$Geog, "[^[:alnum:]]", "")), " ", "")
comm$Geog = str_replace_all(tolower(comm$Geog), " ", "")
comm[which(comm$Geog =="loop"),]$Geog = "theloop"
plot_d = merge(comm, dem[,c(1,3)], by="Geog")


ggplot(plot_d) +
  geom_sf(aes(fill=Total.Population))

