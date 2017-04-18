source('armedRobbery.R')

dupes = df %>% "["(.,df %>% select(`Case Number`) %>%
                     duplicated() %>% 
                     which()) %>% 
  select(`Case Number`) %>% 
  unlist()
df %>% filter(`Case Number` %in% dupes) %>% arrange(`Case Number`) %>% View()

testDate = df$Date %>% head()
mdy_hms(testDate, tz = "CDT") %>% year()
