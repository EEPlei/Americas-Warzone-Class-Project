# Check for libraries and install #
listOfPackages <- c("dplyr", "ggplot2", "rgdal", "rgeos", "e1071", "sp", "raster", "maptools", "plyr", "nnet", "magrittr", 
                    "lubridate", "stringr", "data.table", "png", "ggmap", "modelr", "tidyr", "rjags", "stringr", "readr",
                    "purrr", "forcats", "forecast", "astsa", "fields", "sf", "data.table", "lubridate", "dplyr")
NewPackages <- listOfPackages[!(listOfPackages %in% installed.packages()[,"Package"])]
if(length(NewPackages)>0) {install.packages(NewPackages,repos="http://cran.rstudio.com/")}

library(raster)
library(glmnet)
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
library(sf)
library(data.table)
library(lubridate)
library(dplyr)


load("full_data_set.Rdata")


areas = st_read('/home/grad/rkm22/sta644/spatio_temp_proj/shapeData/CommAreas.shp', 
                quiet=TRUE, stringsAsFactors=TRUE)
areas = areas %>% mutate(`Community Area` = as.numeric(as.character(AREA_NUM_1)))
areas = areas %>% arrange(`Community Area`) %>% select(-`Community Area`)

source("ColinsVeryUsefulCode.R")
#W = areas %>% st_distance() %>% strip_class() < 1e-6
if (!file.exists("weightMatrix.Rdata"))
{ W = areas %>% st_distance() %>% strip_class() < 1e-6
  save(W, file = "weightMatrix.Rdata")
} else{ load("weightMatrix.Rdata")}
D = diag(rowSums(W))

X = model.matrix(~scale(dfFull %>% select(-contains("community area"), -contains("geog"), -contains("armedrobbery"))))
Xvars = dfFull %>% select(-contains("community area"), -contains("geog"), -contains("armedrobbery")) %>% colnames()
colnames(X) = c("Intercept", Xvars)
log_offset = log(dfFull$ArmedRobbery)
y = dfFull$ArmedRobbery
morans_I(y = y, w = D %*% W)
pois_model = "model{
  for(i in 1:length(y)) {
y[i] ~ dpois(lambda[i])
y_pred[i] ~ dpois(lambda[i])
log(lambda[i]) <-  X[i,] %*% beta + omega[i]
}

for(i in 1:nCol) {
beta[i] ~ ddexp(0, eta)#dnorm(0,1)
}

omega ~ dmnorm(rep(0,length(y)), tau * (D - phi*W))
sigma2 <- 1/tau
tau ~ dgamma(2, 2)
phi ~ dunif(0,0.99)
eta ~ dunif(0.001, 10)
}"

if (!file.exists("poisOrig_model.Rdata"))
{
  m = jags.model(
    textConnection(pois_model), 
    data = list(
      D = D,
      y = y,
      X = X,
      W = W,
      nCol = ncol(X)
    ),
    n.adapt=10000
  )
  
  update(m, n.iter=25000)#, progress.bar="none")
  
  pois_coda = coda.samples(
    m, variable.names=c("sigma2","tau", "beta", "omega", "phi", "y_pred", "eta"),
    n.iter=25000, thin=25
  )
  save(pois_coda, m, file="poisOrig_model.Rdata")
} else {
  load("poisOrig_model.Rdata")
}


beta_params = get_coda_parameter(pois_coda,"beta")
colnames(beta_params) = c("Intercept", Xvars)
ar_params = get_coda_parameter(pois_coda,"sigma|phi")
omega = get_coda_parameter(pois_coda,"omega") %>% post_summary()
y_pred = get_coda_parameter(pois_coda,"y_pred") %>% post_summary()

armed_robbery_pred = areas %>% 
  mutate(obs_pred = y_pred$post_mean, resid = dfFull$ArmedRobbery - y_pred$post_mean)
  



grid.arrange(
  ggplot(armed_robbery_pred) +
    geom_sf(aes(fill=obs_pred), color=NA) + 
    labs(title="Predicted Cases",fill=""),
  ggplot(armed_robbery_pred) +
    geom_sf(aes(fill=resid), color=NA) +
    labs(title="Residuals",fill=""),
  ncol=2
)

# RMSE 
armed_robbery_pred$resid %>% .^2 %>% mean() %>% sqrt()

# lasso without spatial random effect #

uncoolFit = glmnet(x = X[,-1], y = y , family = "poisson", alpha = 1)
plot(uncoolFit)



uncool_pred = areas %>% 
  mutate(obs_pred = predict(uncoolFit, X[,-1],type = "response", s = 1) %>% as.vector(),
         resid = (y - predict(uncoolFit, X[,-1],type = "response", s = 1)) %>% as.vector())

grid.arrange(
  ggplot(uncool_pred) +
    geom_sf(aes(fill=obs_pred), color=NA) + 
    labs(title="Predicted Cases",fill=""),
  ggplot(uncool_pred) +
    geom_sf(aes(fill=resid), color=NA) +
    labs(title="Residuals",fill=""),
  ncol=2
)

# RMSE 
uncool_pred$resid %>% .^2 %>% mean() %>% sqrt()


comb_pred = rbind(uncool_pred, armed_robbery_pred)
comb_pred = comb_pred %>% mutate(Regression = rep(c("Penalized", "Spatial Penalized"), each = 77))
pdf("results.pdf", width = 9, height = 9)
grid.arrange(
  ggplot(comb_pred) +
    geom_sf(aes(fill=obs_pred), color=NA) + 
    labs(title="Predicted Cases",fill="") + 
    facet_grid(Regression ~ .) + 
    scale_fill_gradient2(low = "purple", mid = "blue", high = "green", 
                        na.value = "grey50", guide = "colourbar", midpoint = 5000),
  ggplot(comb_pred) +
    geom_sf(aes(fill=resid), color=NA) + 
    labs(title="Residuals",fill="") + 
    facet_grid(Regression ~ .) + 
    scale_fill_gradient2(low = "purple", mid = "blue",high = "green", 
                        na.value = "grey50", guide = "colourbar", midpoint = 0),
  ncol=2
)
dev.off()

lassoCoef = data.frame(Variable = c("Intercept", Xvars), 
                       Lasso = coef(uncoolFit, s= 1) %>% 
                         as.vector())
lassoCoef = lassoCoef[lassoCoef$Lasso != 0,, drop = F]

pdf("/home/grad/lsq3/spatio_temp_proj/write_up/Plots/lassoCoef.pdf", width = 6, height = 3)
grid.table(lassoCoef %>% arrange(desc(Lasso)) %>% `[`(1:10,))
dev.off()


cis = apply(beta_params, 2, function(x) c(quantile(x, c(0.025, 0.975)),
                                          mean(x)))
cis = rbind(cis, IncludeZero = (cis[1,] <= 0) & (cis[2,] >= 0))
cis = t(cis) %>% data.frame()
colnames(cis) = c("2.5%", "97.5%", "Spatial", "IncludeZero")
cis$Variable = c("Intercept", Xvars)

pdf("/home/grad/lsq3/spatio_temp_proj/write_up/Plots/spatialCoef.pdf", width = 6, height = 3)
grid.table(cis %>% arrange(desc(Spatial)) %>% `[`(1:10,) %>% select(Variable, Spatial))
dev.off()

pdf("/home/grad/lsq3/spatio_temp_proj/write_up/Plots/allCoef.pdf", width = 12, height = 3)
grid.table(cbind(lassoCoef %>% arrange(desc(Lasso)) %>% `[`(1:10,),
                 cis %>% arrange(desc(Spatial)) %>% `[`(1:10,) %>% select(Variable, Spatial)))
dev.off()





