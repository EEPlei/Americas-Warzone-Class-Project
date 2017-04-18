library(dplyr)
library(data.table)
library(sf)

load("/home/grad/rkm22/sta644/data/fullCrimeData.Rdata")

gunTypes = c("ARMED: HANDGUN", "ARMED: OTHER FIREARM", "ATTEMPT: ARMED-HANDGUN", "ATTEMPT: ARMED-OTHER FIREARM")
dfArmed = df %>% filter(Description %in% gunTypes)

head(dfArmed)






