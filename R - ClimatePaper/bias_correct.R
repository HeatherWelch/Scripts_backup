###bias correction
#(hycom corrected by NWA/AVISO)

setwd("F:/SDM_paper/extracted_variables")

vars=read.csv("Habitat_variables5_filled.csv")
names(vars)
var=vars[,c(8:11,54,57,58,59)]
names(var)
va=var[,c(1:4,6,8,5,7)]
names(va)

### surface temperature
## for real do by month
library(graphics)
obs=va$SURFTEMP
pred=va$t_0_rt
plot(ecdf(obs), col='red', ylab='CDF', main='Q-Q adjustment')
lines(ecdf(pred), col='green')
legend('topleft', c('Observed SST','Predicted SST'), lty=1, col=c('red','green'))

#read raster
setwd("F:/Climate_paper/hycom/SST/1day/water_temp/Monthly_Climatology/Depth_0000m")
library(raster)
hycom=raster("water_temp_0000m_month01_mean.img")

d=getValues(hycom)
dd=as.matrix(hycom)
s=setValues(raster,dd)

temp=lm(SURFTEMP~t_0_rt,data=va)
summary(temp)
plot(temp)

library(hyfo)
#frc=hycom)
hindcast=va$t_0_rt
obs=va$SURFTEMP
x=biasCorrect(hycom, hindcast, obs, method = "scaling", scaleType = "multi",preci = FALSE, prThreshold = 0, extrapolate = "no")


library(qmap)
library(raster)
#pred=getValues(hycom)
pred=vars$t_0_m
pred_f=pred[!is.na(pred)]
obs=va$SURFTEMP
obs_f=obs[!is.na(obs)]
mod=va$t_0_rt
mod_f=mod[!is.na(mod)]
x=fitQmap(obs_f,mod_f,method="DIST")
z=doQmap(obs_f,x)

plot(ecdf(obs_f), col='red', ylab='CDF', main='Q-Q adjustment')
lines(ecdf(mod_f), col='green')
lines(ecdf(y), col='blue')
lines(ecdf(pred_f), col='black')
lines(ecdf(y), col='black')
legend('topleft', c('Observed SST','Predicted SST','Model_Adjusted SST','Modeled SST'), lty=1, col=c('red','green','blue','black'))

pred_f=pred[!is.na(pred)]
obs_f=obs[!is.na(obs)]
mod_f=mod[!is.na(mod)]

ptf=fitQmap(obs_f,mod_f,method="PTF")
dist=fitQmap(obs_f,mod_f,method="DIST")
RQUANT=fitQmap(obs_f,mod_f,method="RQUANT")
QUANT=fitQmap(obs_f,mod_f,method="QUANT")
SSPLIN=fitQmap(obs_f,mod_f,method="SSPLIN")

ptf_p=doQmap(obs_f,ptf)
dist_p=doQmap(obs_f,dist)
RQUANT_p=doQmap(obs_f,RQUANT)
QUANT_p=doQmap(obs_f,QUANT)
SSPLIN_p=doQmap(obs_f,SSPLIN)

plot(ecdf(obs_f), col='red', ylab='CDF', main='Q-Q adjustment')
lines(ecdf(ptf_p), col='green')
lines(ecdf(dist_p), col='blue')
lines(ecdf(RQUANT_p), col='black')
lines(ecdf(QUANT_p), col=9)
lines(ecdf(SSPLIN_p), col=107)
legend('topleft', c('Observed SST','ptf','dist','RQUANT',"QUANT","SSPLIN"), lty=1, col=c('red','green','blue','black', 9 ,107))

##comparison
decdf=function(x,obs_f,ptf_p) ecdf(obs_f)(x)-ecdf(ptf_p)(x)
anova(ptf_p,dist_p)

###http://www.itl.nist.gov/div898/handbook/eda/section3/eda35g.htm
###http://astrostatistics.psu.edu/su07/R/html/stats/html/ks.test.html
library(fBasics)
a1=ks.test(obs_f,ptf_p)
b1=ks.test(obs_f,dist_p)
c1=ks.test(obs_f,RQUANT_p)
d1=ks.test(obs_f,QUANT_p)
e1=ks.test(obs_f,SSPLIN_p)

ks_test=data.frame(nrow=10,ncol=10)
ks_test$ptf_p=a1$p.value
ks_test$dist_p=b1$p.value
ks_test$RQUANT_p=c1$p.value
ks_test$QUANT_p=d1$p.value
ks_test$SSPLIN_p=e1$p.value

library(devtools)
install_github("SantanderMetGroup/downscaleR")
library(downscaleR)
obss=va$SURFTEMP
obss=va[,1]
pred=va$t_0_rt
sim=vars$t_0_m
sim=getValues(hycom)
sims=biasCorrection(va$SURFTEMP,pred,sim,method = "delta")



library(fume)
calibrateProj(obs, pred, sim, method = c("qqadj", "qqmap", "bias"), 
              varcode = c("tas", "hurs", "pr", "wss"), return.par = TRUE)


