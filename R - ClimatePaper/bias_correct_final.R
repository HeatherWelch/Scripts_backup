###bias correction
#(hycom corrected by NWA/AVISO)

########## 1. read in observed and predicted
## observed will always be real-time trawl variables, predicted real-time hycom variables
setwd("F:/SDM_paper/extracted_variables")
vars=read.csv("Habitat_variables5_filled.csv")
var=vars[,c(8:11,54,57,58,59)]
va=var[,c(1:4,6,8,5,7)]

################# first BS BT SS ST

########## 2. read in modeled
## the data we are trying to adjust, i.e. climatological hycom
###will need to batch this for multiple rasters, perhaps one variable at a time
###these are clipped and renamed hycom rasters created using pre_bias_correct.R
setwd("F:/Climate_paper/hycom/clipped")
library(raster)
library(tools)
for(ras in list.files(pattern="*.tif$",full.names=FALSE,recursive = TRUE)){
  no_extention=file_path_sans_ext(ras)
  print(no_extention)
  file=raster(ras)
  assign(no_extention,file)
}

######### 3. convert raster to xyz points
##convert it back to raster using dummy after analysis
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){
  dat=get(i)
  pnts=rasterToPoints(dat,fun=NULL,spatial=TRUE)
  assign(i,pnts)
}

######### 4. stack points by variable
##give columns the same name so we can stack
vars=c("sh_","SS_","st_","bs_","bt_")
for(v in vars){
  for(i in ls(pattern=v)){
  dat=get(i)
  colnames(dat@data)[1]="value"
  assign(i,dat)
  }
}

##stacking
# surf_temp=rbind(st_m01_pp,st_m02_pp,st_m03_pp,st_m04_pp,st_m05_pp,st_m06_pp,st_m07_pp,st_m08_pp,st_m09_pp,st_m10_pp,st_m11_pp,st_m12_pp)
# bott_temp=rbind(bt_m01_pp,bt_m02_pp,bt_m03_pp,bt_m04_pp,bt_m05_pp,bt_m06_pp,bt_m07_pp,bt_m08_pp,bt_m09_pp,bt_m10_pp,bt_m11_pp,bt_m12_pp)
# surf_sal=rbind(SS_m01_pp,SS_m02_pp,SS_m03_pp,SS_m04_pp,SS_m05_pp,SS_m06_pp,SS_m07_pp,SS_m08_pp,SS_m09_pp,SS_m10_pp,SS_m11_pp,SS_m12_pp)
# bott_sal=rbind(bs_m01_pp,bs_m02_pp,bs_m03_pp,bs_m04_pp,bs_m05_pp,bs_m06_pp,bs_m07_pp,bs_m08_pp,bs_m09_pp,bs_m10_pp,bs_m11_pp,bs_m12_pp)
# surf_hght=rbind(sh_m01_pp,sh_m02_pp,sh_m03_pp,sh_m04_pp,sh_m05_pp,sh_m06_pp,sh_m07_pp,sh_m08_pp,sh_m09_pp,sh_m10_pp,sh_m11_pp,sh_m12_pp)


########## 4. define predicted, observed
###no nas anywhere
library(qmap)
library(fBasics)
meth=c("PTF","DIST","RQUANT","QUANT","SSPLIN")

"
names(va)
SURFTEMP,BOTTEMP,SURFSALIN,BOTSALIN,t_0_rt,t_2_rt,sal_0_rt,sal_2_rt
"

###### 4.1 surface temp
# obs=va$SURFTEMP[!is.na(va$SURFTEMP)] #observed trawl data # change for each var **********************************
# pred=va$t_0_rt[!is.na(va$t_0_rt)] #real time hycom # change for each var **********************************

###### 4.1 surface sal
# obs=va$SURFSALIN[!is.na(va$SURFSALIN)] #observed trawl data # change for each var **********************************
# pred=va$sal_0_rt[!is.na(va$sal_0_rt)] #real time hycom # change for each var **********************************

###### 4.1 bottom sal
# obs=va$BOTSALIN[!is.na(va$BOTSALIN)] #observed trawl data # change for each var **********************************
# pred=va$sal_2_rt[!is.na(va$sal_2_rt)] #real time hycom # change for each var **********************************

###### 4.1 bottom sal
obs=va$BOTTEMP[!is.na(va$BOTTEMP)] #observed trawl data # change for each var **********************************
pred=va$t_2_rt[!is.na(va$t_2_rt)] #real time hycom # change for each var **********************************

############## 5. first, find best adjustment for predicted (real-time hycom)
for(m in meth){
  x=fitQmap(obs,pred,method=m)
  name=paste("fit_",m,sep="")
  assign(name,x)
  y=doQmap(pred,x)
  name=paste("pred_",m,sep="")
  assign(name,y)
}

############## 6. plot ajusted real-time hycom and observed, predicted to observe closest fit
##print off plot
setwd("F:/Climate_paper/hycom/adjusted/BT/")# change for each var **********************************
jpeg("ECDF.jpg")
plot(ecdf(obs), col='red', ylab='CDF', main='Q-Q adjustment')
lines(ecdf(pred), col='black')
lines(ecdf(pred_PTF), col='green')
lines(ecdf(pred_DIST), col='blue')
lines(ecdf(pred_RQUANT), col='pink')
lines(ecdf(pred_QUANT), col=9)
lines(ecdf(pred_SSPLIN), col=107)
legend('topleft', c('Observed','pred','pred_PTF','pred_DIST','pred_RQUANT',"pred_QUANT","pred_SSPLIN"), lty=1, col=c('red','black','green','blue','pink', 9 ,107))
dev.off()

############## 7. because it's hard to see what's best, use Kolmogorov-Smirnov test to see if observed and adjusted predicted come from same distribution
# http://www.itl.nist.gov/div898/handbook/eda/section3/eda35g.htm
a1=ks.test(obs,pred_PTF)
b1=ks.test(obs,pred_DIST)
c1=ks.test(obs,pred_RQUANT)
d1=ks.test(obs,pred_QUANT)
e1=ks.test(obs,pred_SSPLIN)

#create a table of p-values
## Ho: the two datasets have the same distribution
## Ha: the two datasets have different distributions
## want the largest p-value (least chance of rejecting the null, because we want our adjusted predicted data to look like our observed data)

## nvm, use D stastics (p-values are iffy if distributions are unknown)
#D statistic explanation: http://www.physics.csbsju.edu/stats/KS-test.html
#want lowest D stat (D stat is the maximum different between the two datasets)
ks_test=data.frame(test="KS")
           
ks_test$pred_PFT=a1$statistic
ks_test$pred_DIST=b1$statistic
ks_test$pred_RQUANT=c1$statistic
ks_test$pred_QUANT=d1$statistic
ks_test$pred_SSPLIN=e1$statistic

adj=names(ks_test)[which.min(apply(ks_test,MARGIN=2,min))]
adj ##get name of method which is best adjustment
#assign("st",ks_test)
write.csv(ks_test,"ks_test.csv") 

############## 8. now use best_adjust to fit ajustment to modeled data (climatological hycom)
fit=gsub("pred","fit",adj)
x=get(fit) # the fit parameter we are going to ust to adjust rasters 

############## 9. turn points back into rasters
for (i in ls(pattern="bt_")){ # change for each var **********************************
  #print(i)
  dat=get(i)
  dat$z=doQmap(dat@data,x) ## y is now the adjusted values across all rasters
  reduce=dat[,2]
  ras=rasterFromXYZ(reduce,res=c(.08,.08),crs="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
  assign(i,ras)
  writeRaster(ras,i,format="GTiff",bylayer=TRUE)
  }

############## 10. sea_surface height


####### A. read in observed
library(tools)
library(raster)
setwd("F:/Climate_paper/AVISO/clipped/")
for(ras in list.files(pattern="*.tif$",full.names=FALSE,recursive = TRUE)){
  no_extention=file_path_sans_ext(ras)
  print(no_extention)
  file=raster(ras)
  assign(no_extention,file)
}


########## B. read in modeled
## the data we are trying to adjust, i.e. climatological hycom
###will need to batch this for multiple rasters, perhaps one variable at a time
###these are clipped and renamed hycom rasters created using pre_bias_correct.R
setwd("F:/Climate_paper/hycom/clipped")
library(raster)
library(tools)
for(ras in list.files(pattern="sh",full.names=FALSE,recursive = TRUE)){
  no_extention=file_path_sans_ext(ras)
  print(no_extention)
  file=raster(ras)
  assign(no_extention,file)
}
rm(no_extention)
rm(ras)
rm(file)

######### C. convert raster to xyz points
##convert it back to raster using dummy after analysis
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){
  dat=get(i)
  pnts=as.data.frame(rasterToPoints(dat,fun=NULL,spatial=FALSE))
  assign(i,pnts)
}
rm(dat)
rm(pnts)

######### D. stack points by variable
##give columns the same name so we can stack
  for(i in ls(pattern="sh_")){  ####change pattern argument
    dat=get(i)
    reduce=as.data.frame(dat[,3])
    colnames(reduce)[1]="value"
    assign(i,reduce)
  }


########## define observed and predicted
ob=rbind(MADT_h_m01_pp,MADT_h_m02_pp,MADT_h_m03_pp,MADT_h_m04_pp,MADT_h_m05_pp,MADT_h_m06_pp,MADT_h_m07_pp,MADT_h_m08_pp,MADT_h_m09_pp,MADT_h_m10_pp,MADT_h_m11_pp,MADT_h_m12_pp)
pre=rbind(sh_m01_pp,sh_m02_pp,sh_m03_pp,sh_m04_pp,sh_m05_pp,sh_m06_pp,sh_m07_pp,sh_m08_pp,sh_m09_pp,sh_m10_pp,sh_m11_pp,sh_m12_pp)

ob$value=ob$value+1 ## add 1 to remove negatives
pre$value=pre$value+1 ## add 1 to remove negatives

obs=as.numeric(ob$value)
pred=as.numeric(pre$value)

####fitting bias correct
library(qmap)
library(fBasics)
meth=c("PTF","RQUANT","QUANT","SSPLIN")
for(m in meth){
  x=fitQmap(obs,pred,method=m)
  name=paste("fit_",m,sep="")
  assign(name,x)
  y=doQmap(pred,x)
  name=paste("pred_",m,sep="")
  assign(name,y)
}

####testing best bias correction method
a1=ks.test(obs,pred_PTF)
b1=ks.test(obs,pred_DIST)
c1=ks.test(obs,pred_RQUANT)
d1=ks.test(obs,pred_QUANT)
e1=ks.test(obs,pred_SSPLIN)

ks_test=data.frame(test="KS")

ks_test$pred_PFT=a1$statistic
ks_test$pred_DIST=b1$statistic
ks_test$pred_RQUANT=c1$statistic
ks_test$pred_QUANT=d1$statistic
ks_test$pred_SSPLIN=e1$statistic

adj=names(ks_test)[which.min(apply(ks_test,MARGIN=2,min))]
adj ##get name of method which is best adjustment
write.csv(ks_test,"ks_test.csv") 

fit=gsub("pred","fit",adj)
x=get(fit) ## object to be used in doQmap

################## adding one to hycom rasters
setwd("F:/Climate_paper/hycom/clipped") #read back in rasters, have to handle these differently for doQmap
for(ras in list.files(pattern="sh",full.names=FALSE,recursive = TRUE)){
  no_extention=file_path_sans_ext(ras)
  print(no_extention)
  file=raster(ras)
  pnts=rasterToPoints(file,fun=NULL,spatial=TRUE)
  name=paste(no_extention,"_pnts",sep="")
  assign(name,pnts)
}
rm(list=c("no_extention","file","pnts","name"))

for(i in ls(pattern="pnts")){  ##add 1 to each series of points
  print(i)
  dat=get(i)
  colnames(dat@data)[1]="value"
  dat@data[1]=dat@data[1]+1
  assign(i,dat)
}
rm(list=c("dat"))

setwd("F:/Climate_paper/hycom/adjusted/SH")
for (i in ls(pattern="pnts")){ # change for each var **********************************
  print(i)
  dat=get(i)
  dat$z=doQmap(dat@data,x) ## y is now the adjusted values across all rasters
  reduce=dat[,2]
  reduce@data[1]=reduce@data[1]-1
  ras=rasterFromXYZ(reduce,res=c(.08,.08),crs="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
  assign(i,ras)
  writeRaster(ras,i,format="GTiff",bylayer=TRUE)
}











obs=as.data.frame(obs)
pred=as.data.frame(pred)
obs=as.vector(obs)
pred=as.vector(pred)
colnames(obs)[1]="pr"
colnames(pred)[1]="pr"

obs$date=sample(c(2000:2010),size=nrow(obs),replace=TRUE)
pred$date=sample(c(2000:2010),size=nrow(pred),replace=TRUE)
pred2=pred
pred2$date=sample(c(2020:2030),size=nrow(pred2),replace=TRUE)

obs=obs[,c(2,1)]
pred=pred[,c(2,1)]

library(downscaleR)
obs=get(sh_m01_pp)
prd=get(sh_m02_pp)
sim=get(sh_m03_pp)
assign("obs",sh_m01_pp)
assign("prd",sh_m02_pp)
assign("sim",sh_m03_pp)
trial=biasCorrection(obs,prd,sim,method="delta")

trial=biasCorrection(obs[1],pred[1],pred[1],method="delta")
trial=biasCorrection(obs$pr,pred$pr,pred$pr,method="delta")
trial=biasCorrection(sh_m01_pp,sh_m02_pp,sh_m03_pp,method="delta")

library(hyfo)
x=biasCorrect(pred2,pred,obs,method="scaling")
