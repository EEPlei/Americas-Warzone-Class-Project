library(data.table)
library(sf)
library(lubridate)
library(dplyr)
library(readxl)
library(gridExtra)
library(xtable)


load("/home/grad/rkm22/sta644/data/fullCrimeData.Rdata")

pdf("totaldata.pdf", width = 15.5, height = 9)
grid.table(df[1:20,] %>% 
             select(`Case Number`, Date, Block, 
                     Description, Beat, District, 
                     Ward, `Community Area`, Location))
dev.off()


print(xtable(df[1:20,] %>% 
               select(`Case Number`, Date, Block, 
                      Description, Beat, District, 
                      Ward, `Community Area`, Location)), 
      include.rownames = F)
