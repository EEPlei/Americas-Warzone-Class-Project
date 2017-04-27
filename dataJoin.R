

# load community data from other sources #
load("/home/grad/rkm22/sta644/spatio_temp_proj/dataR/affordable_rent_housing_data.Rdata")
load("/home/grad/rkm22/sta644/spatio_temp_proj/dataR/avg_elec_usage_data.Rdata")
load("/home/grad/rkm22/sta644/spatio_temp_proj/dataR/avg_gas_usage_data.Rdata")
load("/home/grad/rkm22/sta644/spatio_temp_proj/dataR/graffiti_removal_data.Rdata")
load("/home/grad/rkm22/sta644/spatio_temp_proj/dataR/public_health_stats_data.Rdata")
load("/home/grad/rkm22/sta644/spatio_temp_proj/dataR/socioeconomic_indicators_data.Rdata")
load("/home/grad/rkm22/sta644/spatio_temp_proj/dataR/vacant_prop_data.Rdata")

# get cleaned armed robbery data #
source("/home/grad/rkm22/sta644/spatio_temp_proj/armedRobbery.R")

dupes = df %>% "["(.,df %>% select(`Case Number`) %>%
                     duplicated() %>% 
                     which()) %>% 
  select(`Case Number`) %>% 
  unlist()
dfArmed = dfArmed %>% filter(!(`Case Number` %in% dupes)) 
dfArmed = dfArmed %>% group_by(`Community Area`) %>% 
  summarise(ArmedRobbery = n()) 


# join new data to armed robbery data #
dfFull = left_join(dfArmed, avg_elec_usage_agg, by = c("Community Area" = "Community Area"))
dfFull = left_join(dfFull, avg_gas_usage_agg, by = c("Community Area" = "Community Area"))
dfFull = left_join(dfFull, graffiti_removal_agg, by = c("Community Area" = "Community Area"))
dfFull = left_join(dfFull, pubHealth, by = c("Community Area" = "Community Area"))
dfFull = left_join(dfFull, rent_housing_agg %>% na.omit(), by = c("Community Area" = "Community Area Number"))
dfFull[is.na(dfFull)] = 0
dfFull = left_join(dfFull, socioData, by = c("Community Area" = "Community Area Number"))
dfFull = left_join(dfFull, 
                   vacantData %>% group_by(`Community Area.y`) %>% summarise(vacantLots = sum(vacantLots)),
                   by = c("Community Area" = "Community Area.y"))
dfFull[is.na(dfFull)] = 0
save(dfFull, file = "full_data_set.Rdata")
