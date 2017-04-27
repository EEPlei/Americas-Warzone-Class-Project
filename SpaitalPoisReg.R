library(raster)
library(magrittr)
library(modelr)
library(ggplot2)
library(tidyr)
library(rjags)
library(stringr)
library(gridExtra)
library(readr)
library(purrr)
library(forcats)
library(forecast)
library(astsa)
library(fields)
library(readr)
library(sf)
library(forcats)
library(data.table)
library(lubridate)
library(dplyr)


load("full_data_set.Rdata")


areas = st_read('/home/grad/rkm22/sta644/spatio_temp_proj/shapeData/CommAreas.shp', 
                quiet=TRUE, stringsAsFactors=TRUE)
source("ColinsVeryUsefulCode.R")
#W = areas %>% st_distance() %>% strip_class() < 1e-6
if (!file.exists("weightMatrix.Rdata"))
{save(W, file = "weightMatrix.Rdata")
} else{ load("weightMatrix.Rdata")}
D = diag(rowSums(W))

X = model.matrix(~scale(dfFull[, !grepl("community area", colnames(dfFull) %>% tolower())]))
log_offset = log(dfFull$ArmedRobbery)
y = dfFull$ArmedRobbery

pois_model = "model{
  for(i in 1:length(y)) {
y[i] ~ dpois(lambda[i])
y_pred[i] ~ dpois(lambda[i])
log(lambda[i]) <- log_offset[i] + X[i,] %*% beta + omega[i]
}

for(i in 1:37) {
beta[i] ~ ddexp(0, rambda)#dnorm(0,1)
}

omega ~ dmnorm(rep(0,length(y)), tau * (D - phi*W))
sigma2 <- 1/tau
tau ~ dgamma(2, 2)
phi ~ dunif(0,0.99)
rambda ~ dunif(0.001, 10)
}"

if (!file.exists("pois_model.Rdata"))
{
  m = jags.model(
    textConnection(pois_model), 
    data = list(
      D = D,
      y = y,
      X = X,
      W = W,
      log_offset = log_offset
    ),
    n.adapt=10000
  )
  
  update(m, n.iter=25000)#, progress.bar="none")
  
  pois_coda = coda.samples(
    m, variable.names=c("sigma2","tau", "beta", "omega", "phi", "y_pred"),
    n.iter=25000, thin=25
  )
  save(pois_coda, m, file="pois_model.Rdata")
} else {
  load("pois_model.Rdata")
}