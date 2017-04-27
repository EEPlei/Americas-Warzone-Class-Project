source("/home/grad/rkm22/sta644/spatio_temp_proj/loadData.R")

gunTypes = c("ARMED: HANDGUN", "ARMED: OTHER FIREARM", 
             "ATTEMPT: ARMED-HANDGUN", "ATTEMPT: ARMED-OTHER FIREARM")
dfArmed = df %>% filter(Description %in% gunTypes) #93297 by 22
dfArmed = na.omit(dfArmed) #83817 by 22

dfArmed$Date = dfArmed$Date %>% mdy_hms(tz = "CDT")

dfArmed %>% mutate(Year = year(Date)) %>% 
  group_by(`Community Area`, Year) %>% summarise(N = n()) %>% 
  arrange(Year, `Community Area`) %>% View()

dfArmed$Date %>% year() %>% table()
