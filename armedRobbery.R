library(dplyr)
library(data.table)
library(sf)

source("loadData.R")

gunTypes = c("ARMED: HANDGUN", "ARMED: OTHER FIREARM", 
             "ATTEMPT: ARMED-HANDGUN", "ATTEMPT: ARMED-OTHER FIREARM")
dfArmed = df %>% filter(Description %in% gunTypes)

head(dfArmed)






