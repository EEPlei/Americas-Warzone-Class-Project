source('armedRobbery.R')

dupes = df %>% "["(.,df %>% select(`Case Number`) %>%
                     duplicated() %>% 
                     which()) %>% 
  select(`Case Number`) %>% 
  unlist()
df %>% filter(`Case Number` %in% dupes) %>% arrange(`Case Number`) %>% View()

testDate = df$Date %>% head()
mdy_hms(testDate, tz = "CDT") %>% year()

public_health_stats = fread("/home/grad/lsq3/spatio_temp_proj/data/public_health_stats_data.csv")
comm_area_dict = public_health_stats %>% select(`Community Area`, `Community Area Name`)


rent_housing = fread("/home/grad/lsq3/spatio_temp_proj/data/affordable_rent_housing_data.csv")
rent_housing_agg = rent_housing %>% group_by(`Community Area Number`) %>% 
  summarise(N_Aff_Housing = n())
save(rent_housing_agg, 
     file = "/home/grad/lsq3/spatio_temp_proj/dataR/affordable_rent_housing_data.Rdata")


avg_elec_usage = fread("/home/grad/lsq3/spatio_temp_proj/data/avg_elec_usage_data.csv")
colnames(avg_elec_usage) = c("Community Area Name", "KWH Total SQFT")
avg_elec_usage = avg_elec_usage %>% filter(`Community Area Name` %in% c("Montclare", "Lakeview")) %>% 
  mutate(`Community Area Name` = c("Montclaire", "Lake View")) %>% 
  rbind(., avg_elec_usage) 
avg_elec_usage_agg = left_join(avg_elec_usage, comm_area_dict, by = "Community Area Name")
avg_elec_usage_agg = na.omit(avg_elec_usage_agg)
save(avg_elec_usage_agg, 
     file = "/home/grad/lsq3/spatio_temp_proj/dataR/avg_elec_usage_data.Rdata")


avg_gas_usage = fread("/home/grad/lsq3/spatio_temp_proj/data/avg_gas_usage_data.csv")
colnames(avg_gas_usage) = c("Community Area Name", "THERMS Total SQFT")
avg_gas_usage = avg_gas_usage %>% filter(`Community Area Name` %in% c("Montclare", "Lakeview")) %>% 
  mutate(`Community Area Name` = c("Montclaire", "Lake View")) %>% 
  rbind(., avg_gas_usage) 
avg_gas_usage_agg = left_join(avg_gas_usage, comm_area_dict, by = "Community Area Name")
avg_gas_usage_agg = na.omit(avg_gas_usage_agg)
save(avg_gas_usage_agg, 
     file = "/home/grad/lsq3/spatio_temp_proj/dataR/avg_gas_usage_data.Rdata")


graffiti_removal = fread("/home/grad/lsq3/spatio_temp_proj/data/graffiti_removal_data.csv")
graffiti_removal_agg = graffiti_removal %>% group_by(`Community Area`) %>% 
  summarise(N_Graffiti = n())
save(graffiti_removal_agg, 
     file = "/home/grad/lsq3/spatio_temp_proj/dataR/graffiti_removal_data.Rdata")

