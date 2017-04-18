source("loadData.R")

gunTypes = c("ARMED: HANDGUN", "ARMED: OTHER FIREARM", 
             "ATTEMPT: ARMED-HANDGUN", "ATTEMPT: ARMED-OTHER FIREARM")
dfArmed = df %>% filter(Description %in% gunTypes) #93297 by 22
dfArmed = na.omit(dfArmed) #83817 by 22

dfArmed %>% group_by(`Community Area`) %>% summarise(N = n()) %>% t() %>% View()



