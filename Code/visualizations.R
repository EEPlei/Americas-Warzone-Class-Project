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

## --------------------- Wards to Model, Aggregate by 'Side' -------------------------------- ##
# Central = 08, 32, 33 -- 1737 Total
# North Side = 5,6,7,21,22 -- 3609 Total
# Far North Side = 1,2,3,4, 9,10,11,12,13,14, 76,77 -- 3296 Total
# Northwest Side = 15,16,17,18,19,20 -- 2527 Total
# West Side = 23 - 31 -- 21278 Total
# South Side = 34 - 43, 60, 69 -- 13626 Total
# Southwest Side = 56, 57, 58, 59, 61 - 68 -- 12607 Total
# Far Southeast Side = 44 - 55 -- 12249 Total
# Far Southwest Side = 70 - 75 -- 6342 Total

plot_d$side = 0 
central = c(8, 32, 33)
north = c(5,6,7,21,22)
far_north = c(1,2,3,4, 9,10,11,12,13,14, 76, 77)
northwest = c(15,16,17,18,19,20)
west = c(23:31)
south = c(34:43, 60, 69)
southwest = c(56, 57, 58, 59, 61:68)
far_southeast = c(44:55)
far_southwest = c(70:75)

plot_d$side[plot_d$AREA_NUMBE %in% central] = "Central"
plot_d$side[plot_d$AREA_NUMBE %in% north] = "North Side"
plot_d$side[plot_d$AREA_NUMBE %in% far_north] = "Far North Side"
plot_d$side[plot_d$AREA_NUMBE %in% northwest] = "Northwest Side"
plot_d$side[plot_d$AREA_NUMBE %in% west] = "West Side"
plot_d$side[plot_d$AREA_NUMBE %in% south] = "South Side"
plot_d$side[plot_d$AREA_NUMBE %in% southwest] = "Southwest Side"
plot_d$side[plot_d$AREA_NUMBE %in% far_southeast] = "Far Southeast Side"
plot_d$side[plot_d$AREA_NUMBE %in% far_southwest] = "Far Southwest Side"


ggplot(plot_d) +
  geom_sf(aes(fill=side))

load('dfArmed.Rdata')
armed_side = dfArmed %>% group_by(`Community Area`) %>% summarize(count = n()) 
armed_side$`Community Area` = as.factor(armed_side$`Community Area`)
plot_d = left_join(plot_d, armed_side, by = c('AREA_NUM_1'= "Community Area"))

ggplot(plot_d) +
  geom_sf(aes(fill=count/Total.Population))

library(rgdal)
coordinates(dfArmed2)<-~Longitude+Latitude
proj4string(dfArmed2)<-CRS("+proj=longlat +datum=NAD83")
dfArmed2<-st_transform(dfArmed2, CRS(st_crs(plot_d)$proj4string))
#dfArmed2<-spTransform(dfArmed2, CRS(st_crs(plot_d)$proj4string))
identical(st_crs(dfArmed2)$proj4string,st_crs(plot_d)$proj4string)

dfArmed2 = dfArmed %>%
  filter(Year == 2011)
ggplot(plot_d) +
  geom_sf(aes(fill=side))+
  #ggplot()+
  geom_point(aes(x = Longitude, y = Latitude),
             data = dfArmed2, size=0.1)
  #geom_sf(data=dfArmed, aes(color=Location),size=0.1)

st_crs(plot_d)$proj4string
st_crs(dfArmed$Latitude)$proj4string
