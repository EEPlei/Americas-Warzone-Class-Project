library(data.table)
library(sf)
library(lubridate)
library(dplyr)


load("/home/grad/rkm22/sta644/data/fullCrimeData.Rdata")

areas = st_read('/home/grad/rkm22/sta644/spatio_temp_proj/shapeData/CommAreas.shp', 
                quiet=TRUE, stringsAsFactors=TRUE)

source("ColinsVeryUsefulCode.R")


pois_model = "model{
  for(i in 1:length(y)) {
y[i] ~ dpois(lambda[i])
y_pred[i] ~ dpois(lambda[i])
log(lambda[i]) <- log_offset[i] + X[i,] %*% beta + omega[i]
}

for(i in 1:2) {
beta[i] ~ ddexp(0, lambda)#dnorm(0,1)
}

omega ~ dmnorm(rep(0,length(y)), tau * (D - phi*W))
sigma2 <- 1/tau
tau ~ dgamma(2, 2)
phi ~ dunif(0,0.99)
lambda ~ dunif(0.001, 10)
}"

m = jags.model(
  textConnection(pois_model), 
  data = list(
    D = diag(rowSums(W)),
    X = model.matrix(~scale(lip_cancer$pcaff)),
    log_offset = log(lip_cancer$Expected),
    y = lip_cancer$Observed,
    W = W = st_distance(lip_cancer) %>% strip_class() < 1e-6
  ),
  n.adapt=10000
)

update(m, n.iter=25000)
pois_coda = coda.samples(
  m, variable.names=c("sigma2","tau", "beta", "omega", "phi", "y_pred"),
  n.iter=25000, thin=25
)