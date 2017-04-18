library(data.table)
library(dplyr)
#library(jsonlite)
#test2 = fromJSON("https://data.cityofchicago.org/resource/6zsd-86xi.json")
df = fread("crime_data.csv")
save(df, file = "crime_data.Rdata")

load("crime_data.Rdata")
