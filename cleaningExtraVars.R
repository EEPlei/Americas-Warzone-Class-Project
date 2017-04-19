library(data.table)
library(dplyr)

##########################
pubHealth = fread("/home/grad/lsq3/spatio_temp_proj/data/public_health_stats_data.csv")

# find which cols have NA vals #
NAVals = apply(pubHealth, 2, is.na) %>% 
  colSums() 

NAVals[NAVals > 0]

pubHealth = pubHealth %>% select(-`Childhood Blood Lead Level Screening`, -`Gonorrhea in Females`, 
                     -`Childhood Lead Poisoning`, -`Gonorrhea in Males`)

save(pubHealth, file = "/home/grad/rkm22/sta644/spatio_temp_proj/demoData//public_health_stats_data.Rdata")

##########################
socioData = fread("/home/grad/lsq3/spatio_temp_proj/data/socioeconomic_indicators_data.csv")
socioData = socioData[-78,]

apply(socioData, 2, is.na) %>% 
  colSums() 

save(socioData, file = "/home/grad/rkm22/sta644/spatio_temp_proj/demoData/socioeconomic_indicators_data.Rdata")


##########################
vacantData = fread("/home/grad/lsq3/spatio_temp_proj/data/vacant_prop_data.csv")

areas = pubHealth %>% select(`Community Area`, `Community Area Name`)
areas$`Community Area Name` = tolower(areas$`Community Area Name`)

vacantData$`Community Area` = tolower(vacantData$`Community Area`)
colnames(vacantData)[2] = "vacantLots"

vacantData = left_join(vacantData, areas, by = c("Community Area" = "Community Area Name"))
vacantData$`Community Area.y`[is.na(vacantData$`Community Area.y`)] = c(57,45)


