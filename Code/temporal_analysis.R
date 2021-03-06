source("loadData.R")
library(ggplot2)
gunTypes = c("ARMED: HANDGUN", "ARMED: OTHER FIREARM", 
             "ATTEMPT: ARMED-HANDGUN", "ATTEMPT: ARMED-OTHER FIREARM")
dfArmed = df %>% filter(Description %in% gunTypes) #93297 by 22
dfArmed = na.omit(dfArmed) #83817 by 22
save(dfArmed, file="dfArmed.Rdata")

dfArmed$Date = dfArmed$Date %>% mdy_hms(tz = "CDT")

#dfArmed %>% mutate(Year = year(Date)) %>% 
#  group_by(`Community Area`, Year) %>% summarise(N = n()) %>% 
#  arrange(Year, `Community Area`) %>% View()

#dfArmed$Date %>% year() %>% table()

## Temporal Analysis
dfTime = dfArmed
dfTime$Dnew = dfTime$Date %>% date() 
# Remove 2001-2002 and 2017 and there is at least 1 robbery every day, t = 1 day
dfTime = dfTime %>% filter(Year > 2002) %>% filter(Year < 2017)
aggTime = dfTime %>% group_by(Dnew) %>% summarize(count = n())

plot(aggTime$Dnew, aggTime$count, main = 'Armed Robberies by Day', ylab = 'Count',
     xlab = 'Date', type = 'l')


## Aggregate by Ward
aggArea = dfArmed %>% group_by(`Community Area`) %>% summarize(count = n()) 
barplot(aggArea$count)
ggplot(aggArea, aes(`Community Area`)) + geom_bar(aes(weight = count)) + 
  ggtitle('Armed Robberies by Community Area')

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

dfArmed$Dnew = dfArmed$Date %>% date() 
dfArmed = dfArmed %>% filter(Year > 2002) %>% filter(Year < 2017)

central = dfArmed %>% filter(`Community Area` %in% c(8,32,33)) %>%
  group_by(Dnew %>% year(), Dnew %>% month()) %>% summarize(count = n())
north_side = dfArmed %>% filter(`Community Area` %in% c(5,6,7,21,22)) %>%
  group_by(Dnew %>% year(), Dnew %>% month()) %>% summarize(count = n())
far_north_side = dfArmed %>% filter(`Community Area` %in% c(1:4, 9:14, 76:77)) %>%
  group_by(Dnew %>% year(), Dnew %>% month()) %>% summarize(count = n())
northwest_side = dfArmed %>% filter(`Community Area` %in% c(15:20)) %>%
  group_by(Dnew %>% year(), Dnew %>% month()) %>% summarize(count = n())
west_side = dfArmed %>% filter(`Community Area` %in% c(23:31)) %>%
  group_by(Dnew %>% year(), Dnew %>% month()) %>% summarize(count = n())
south_side = dfArmed %>% filter(`Community Area` %in% c(34:43, 60, 69)) %>%
  group_by(Dnew %>% year(), Dnew %>% month()) %>% summarize(count = n())
southwest_side = dfArmed %>% filter(`Community Area` %in% c(56,57,58,59,61:68)) %>%
  group_by(Dnew %>% year(), Dnew %>% month()) %>% summarize(count = n())
far_southeast_side = dfArmed %>% filter(`Community Area` %in% c(44:55)) %>%
  group_by(Dnew %>% year(), Dnew %>% month()) %>% summarize(count = n())
far_southwest_side = dfArmed %>% filter(`Community Area` %in% c(70:75)) %>%
  group_by(Dnew %>% year(), Dnew %>% month()) %>% summarize(count = n())


#central = central %>% group_by(Dnew %>% year() %>%month()) %>% 
#  summarize(count = n()) %>% plot(count, type = 'l')
# -------------------------------------------------------------

# Central AR(2), Seasonal, Period = 12
acf(central$count)
pacf(central$count)
## AR(2) looks appropriate
library(forecast)
ar_central = Arima(central$count, order = c(2,0,0), seasonal=list(order=c(1,0,0), period=12),
                   include.constant = TRUE)
summary(ar_central)
plot(ar_central$residuals)
acf(ar_central$residuals, main = 'ACF of AR(2) Residuals - Central')
pacf(ar_central$residuals, main = 'PACF of AR(2) Residuals - Central')

 
# North Side AR(3,1), Seasonal 12
acf(north_side$count)
pacf(north_side$count)
ar_north_side = Arima(north_side$count, order = c(3,0,1), seasonal=list(order=c(1,0,0), period=12),
                      include.constant = TRUE)
summary(ar_north_side)
plot(ar_north_side$residuals)
acf(ar_north_side$residuals, main = 'ACF of AR(2) Residuals - North Side')
pacf(ar_north_side$residuals, main = 'PACF of AR(2) Residuals - North Side')

# Far North Side AR(3), Seasonal Period 12
acf(far_north_side$count)
pacf(far_north_side$count)
ar_far_north_side = Arima(far_north_side$count, order = c(3,0,0), seasonal=list(order=c(1,0,0), period=12),
                          include.constant = TRUE)
summary(ar_far_north_side)
plot(ar_far_north_side$residuals)
acf(ar_far_north_side$residuals, main = 'ACF of AR(2) Residuals - Far North Side')
pacf(ar_far_north_side$residuals, main = 'PACF of AR(2) Residuals - Far North Side')


# Northwest Side - AR(3), Seasonal Period 12
acf(northwest_side$count)
pacf(northwest_side$count)
ar_northwest_side = Arima(northwest_side$count, order = c(3,0,0), seasonal=list(order=c(1,0,0), 
                                                                                period=12),
                          include.constant = TRUE)
summary(ar_northwest_side)
plot(ar_northwest_side$residuals)
acf(ar_northwest_side$residuals, main = 'ACF of ARMA(2, 1) Residuals - Far North Side')
pacf(ar_northwest_side$residuals, main = 'PACF of ARMA(2, 1) Residuals - Far North Side')

# West Side - AR(2), Seasonal Period 12
acf(west_side$count)
pacf(west_side$count)
ar_west_side = Arima(west_side $count, order = c(2,0,0), seasonal=list(order=c(1,0,0), period=12),
                     include.constant = TRUE)
summary(ar_west_side)
plot(ar_west_side$residuals)
acf(ar_west_side$residuals, main = 'ACF of AR(2), Seasonal 12 Residuals - Far North Side')
pacf(ar_west_side$residuals, main = 'PACF of AR(2), Seasonal 12 Residuals - Far North Side')

# South Side - AR(4), Seasonal Period 12
acf(south_side$count)
pacf(south_side$count)
ar_south_side = Arima(south_side$count, order = c(4,0,0), seasonal=list(order=c(1,0,0), period=12),
                      include.constant = TRUE)
summary(ar_south_side)
plot(ar_south_side$residuals)
acf(ar_south_side$residuals, main = 'ACF of AR(4) Seasonal 12 Residuals - Far North Side')
pacf(ar_south_side$residuals, main = 'PACF of AR(4) Seasonal 12 Residuals - Far North Side')

# Southwest Side - AR(12), Seasonal Period 12
acf(southwest_side$count)
pacf(southwest_side$count)
ar_southwest_side = Arima(southwest_side$count, order = c(12,0,0), seasonal=list(order=c(1,0,0), period=12),
                      include.constant = TRUE)
summary(ar_southwest_side)
plot(ar_southwest_side$residuals)
acf(ar_southwest_side$residuals, main = 'ACF of AR(4) Seasonal 12 Residuals - Far North Side')
pacf(ar_southwest_side$residuals, main = 'PACF of AR(4) Seasonal 12 Residuals - Far North Side')


# Far Southeast Side - AR(12), Seasonal Period 12
acf(far_southeast_side$count)
pacf(far_southeast_side$count)
ar_far_southeast_side = Arima(far_southeast_side$count, order = c(12,0,0), seasonal=list(order=c(1,0,0), period=12),
                          include.constant = TRUE)
summary(ar_far_southeast_side)
plot(ar_far_southeast_side$residuals)
acf(ar_far_southeast_side$residuals, main = 'ACF of AR(4) Seasonal 12 Residuals - Far North Side')
pacf(ar_far_southeast_side$residuals, main = 'PACF of AR(4) Seasonal 12 Residuals - Far North Side')


# Far Southeast Side - AR(12), Seasonal Period 12
acf(far_southwest_side$count)
pacf(far_southwest_side$count)
ar_far_southwest_side = Arima(far_southwest_side$count, order = c(5,0,0), seasonal=list(order=c(1,0,0), period=12),
                              include.constant = TRUE)
summary(ar_far_southwest_side)
plot(ar_far_southwest_side$residuals)
acf(ar_far_southwest_side$residuals, main = 'ACF of AR(4) Seasonal 12 Residuals - Far North Side')
pacf(ar_far_southwest_side$residuals, main = 'PACF of AR(4) Seasonal 12 Residuals - Far North Side')



