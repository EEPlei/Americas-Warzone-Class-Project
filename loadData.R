library(data.table)
library(sf)
library(lubridate)
library(dplyr)
library(readxl)
library(gridExtra)


load("/home/grad/rkm22/sta644/data/fullCrimeData.Rdata")

pdf("totaldata.pdf", width = 33, height = 5.5)
grid.table(df[1:10,])
dev.off()
