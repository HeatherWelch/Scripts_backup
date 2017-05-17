##############script to get ready to run gams
######what needs to be done
# 4. points need to be associate w rasters in correct month # FULL HYCOM RASTERS
# 4.1 points need to be bias corrected
# 5. species need to be divided into p/a and written out in individual csvs

# 2. rasters need to be clipped by point minimum bounding box (wait till final data)
# 3. rasters need to be put in mmm_yyyyy folders e.g. m01_y2020 (wait till final data)


# 1. read in points as csv
setwd("F:/Climate_paper/species_data/final_records_6_7_2016")
records=read.csv("NES_Ecoregion_Above7_Clp_Var1.csv")
rec=records[,c(4:15)]
#rec$GIS_LONHB=rec$GIS_LONHB*-1 ###make it negative lat/long

# 1.1 convert points to shp
library(sp)
rec$lat=rec$LAT_WGS64###should probably copy lat long columns and add to end in case we need them
rec$long=rec$LON_WGS64###should probably copy lat long columns and add to end in case we need them

coordinates(rec)=~LON_WGS64+LAT_WGS64
plot(rec)
myproj="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" # projection of rasters
proj4string(rec)=CRS(myproj) ## project records

##read in a known shapefile to check position
library(rgdal)
VTR=readOGR(dsn="F:/VMS/VTR",layer="Statistical_Areas_2010")
plot(VTR,add=TRUE)

# 2. read in rasters: unclipped hycom rasters, will need to bias correct these points
# clipped rasters have spatial extents slightly smaller than points
# will use rasters in setwd("F:/Climate_paper/hycom/adjusted") for projection

setwd("F:/Climate_paper/hycom/renamed")

library(raster)
for (ras in list.files(pattern="*.tif$",recursive = TRUE)){
  path=paste(getwd(),"/",ras,sep="")
  r=raster(path)
  name=gsub(".tif","",ras)
  assign(name,r)
  print(ras)
}

rm(list=c("r","name","path","ras"))

# 3. extract monthly env.var values at points
#getting months in a usuable format
library(stringr)
rec$month=str_pad(rec$month,2,pad="0") ##add leading zero to 1-9
#rec$month=as.numeric(rec$month)

#now attach points
months=c("01","02","03","04","05","06","07","08","09","10","11","12")
vars=c("bt","sh","st","bs","SS")
for (m in months){ # for a given month
  recm=subset(rec,month==m)
  print(m)
  for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){ # for each raster layer 
    if (grepl(m,i)==TRUE){ ##if raster is from month "m"
      for(v in vars){
        if (grepl(v,i)==TRUE){ ##if raster is from month "m" and variable "v"
          print(v)
          print(i)
          dat=get(i)
          recm@data[[v]]=extract(dat,recm,method="simple")}
      }
    }
  }
  name=paste("m",m,sep="")
  assign(name,recm)
}
rm(list=c("dat","v","i","m","recm","name"))

#####combining them
master=rbind(m01,m02,m03,m04,m05,m06,m07,m08,m09,m10,m11,m12)
complete=master[complete.cases(master@data),]

# 4. bias correct variables
#hycom corrected by NWA/AVISO
#### see bias_correct_final.R for complete script

######### 1. read in observed and predicted
## observed will always be real-time trawl variables, predicted real-time hycom variables
setwd("F:/SDM_paper/extracted_variables")
vars=read.csv("Habitat_variables5_filled.csv")
var=vars[,c(8:11,54,57,58,59)]
va=var[,c(1:4,6,8,5,7)]

## names (va) "SURFTEMP"  "BOTTEMP"   "SURFSALIN" "BOTSALIN" 
##  names(master) "bs"         "bt"         "sh"         "SS"         "st"  

##### 4.1 surface temp
# obs=va$SURFTEMP[!is.na(va$SURFTEMP)] #observed trawl data # change for each var **********************************
# pred=va$t_0_rt[!is.na(va$t_0_rt)] #real time hycom # change for each var **********************************

###### 4.1 surface sal
# obs=va$SURFSALIN[!is.na(va$SURFSALIN)] #observed trawl data # change for each var **********************************
# pred=va$sal_0_rt[!is.na(va$sal_0_rt)] #real time hycom # change for each var **********************************

###### 4.1 bottom sal
# obs=va$BOTSALIN[!is.na(va$BOTSALIN)] #observed trawl data # change for each var **********************************
# pred=va$sal_2_rt[!is.na(va$sal_2_rt)] #real time hycom # change for each var **********************************

##### 4.1 bottom te,[]
obs=va$BOTTEMP[!is.na(va$BOTTEMP)] #observed trawl data # change for each var **********************************
pred=va$t_2_rt[!is.na(va$t_2_rt)] #real time hycom # change for each var **********************************

####### bias correction method selection
library(qmap)
library(fBasics)
meth=c("PTF","RQUANT","QUANT","SSPLIN")

############## 5. first, find best adjustment for predicted (real-time hycom)
for(m in meth){
  x=fitQmap(obs,pred,method=m)
  name=paste("fit_",m,sep="")
  assign(name,x)
  y=doQmap(pred,x)
  name=paste("pred_",m,sep="")
  assign(name,y)
}

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

fit=gsub("pred","fit",adj)
x=get(fit) # the fit parameter we are going to ust to adjust rasters 

############## 9. apply bias correction to extracted points
sim=complete@data$sh_plus ####################################### change for each var
complete@data$sh_bias_plus=doQmap(sim,x) ####################################### change for each var
head(complete)

##### SH bias correction
####### A. read in observed
library(tools)
setwd("F:/Climate_paper/AVISO/clipped/")
for(ras in list.files(pattern="*.tif$",full.names=FALSE,recursive = TRUE)){
  no_extention=file_path_sans_ext(ras)
  print(no_extention)
  file=raster(ras)
  assign(no_extention,file)
}

######### C. convert raster to xyz points
##convert it back to raster using dummy after analysis
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(pattern = "MADT"))){
  dat=get(i)
  pnts=as.data.frame(rasterToPoints(dat,fun=NULL,spatial=FALSE))
  assign(i,pnts)
}

######### D. stack points by variable
##give columns the same name so we can stack
for(i in ls(pattern = "MADT")){
  dat=get(i)
  reduce=as.data.frame(dat[,3])
  colnames(reduce)[1]="value"
  assign(i,reduce)
}

########## define observed and predicted
ob=rbind(MADT_h_m01_pp,MADT_h_m02_pp,MADT_h_m03_pp,MADT_h_m04_pp,MADT_h_m05_pp,MADT_h_m06_pp,MADT_h_m07_pp,MADT_h_m08_pp,MADT_h_m09_pp,MADT_h_m10_pp,MADT_h_m11_pp,MADT_h_m12_pp)
ob$value=ob$value+1 ## add 1 to remove negatives
obs=as.numeric(ob$value)

complete@data$sh_plus=complete@data$sh+1
pred=complete@data$sh_plus

## use above script to select method ^
##subtract 1
complete@data$sh_bias=complete@data$sh_bias_plus-1

###writing out to save work
setwd("F:/Climate_paper/GAM_1")
write.csv(complete,"records_vars_A.csv") #full copy

clean=complete@data[,c(1:21,24)]
clean2=clean[,c(1:12,18:22)]
colnames(clean2)[13]="st" ##so variables will match rasters
colnames(clean2)[14]="SS"
colnames(clean2)[15]="bs"
colnames(clean2)[16]="bt"
colnames(clean2)[17]="sh"
write.csv(clean2,"records_vars_B.csv") #cleaned copy

###getting read to divide by species
## going back to complete because it's still spatial
clean=complete[,c(1:21,24)]
clean2=clean[,c(1:12,18:22)]
colnames(clean2@data)[13]="st" ##so variables will match rasters
colnames(clean2@data)[14]="SS"
colnames(clean2@data)[15]="bs"
colnames(clean2@data)[16]="bt"
colnames(clean2@data)[17]="sh"


###attach random raster to points to ensure species p/a's are not in the same grid cell
##made this earlier in GIS, created fishnets using a hycom rs, converted to raster using FID to grab unique values at each cell
setwd("F:/Climate_paper/hycom/random_raster")
random=raster(paste(getwd(),"/rr1",sep=""))
clean2$unique=extract(random,clean2,method="simple")
head(clean2)
clean2$m_unique=paste(clean2$month,"_",clean2$unique,sep="")

# 5. first for one species
presence=subset(master,master$SCINAME=="LOPHIUS AMERICANUS") ##where species is
absence=subset(master,master$SCINAME!="LOPHIUS AMERICANUS") ##where species is not
library(dplyr)
abs=absence@data%>%distinct(m_unique) ##remove duplicate absences, @data used for spatial objects to access non-spatial data
ab=abs[!(abs$m_unique %in% presence$m_unique),] ##get rid of m_uniques in abs that are already in presence
presence$p_a=1 #binary
ab$p_a=0 #binary
LOPHIUS_AMERICANUS=rbind(presence@data,ab)

# 5.1 batch for all species
species=levels(clean2$Species)
for(sp in species){
  print(sp)
  presence=subset(clean2,clean2$Species==sp) # presences
  absence=subset(clean2,clean2$Species!=sp)
  abs=absence@data%>%distinct(m_unique)
  ab=abs[!(abs$m_unique %in% presence$m_unique),] #final absences, unique, no points from presence
  presence$p_a=1 #binary
  ab$p_a=0 #binary
  complete=rbind(presence@data,ab)
#   if(grepl(" ",sp)==TRUE){ ##won't need w species codes
#     name=gsub(" ","_",sp) ##won't need w species codes
#   } else{
#       name=sp
#     }
  output=paste("F:/Climate_paper/GAM_1/species/",sp,".csv",sep="")
  write.csv(complete,file=output)
}  

############# organizing rasters into mm_yyyy folders
rm(list=ls())

#read in climatological rasters
setwd("F:/Climate_paper/hycom/adjusted/SH")
library(raster)
for (ras in list.files(pattern="*.tif$",recursive = TRUE)){
  path=paste(getwd(),"/",ras,sep="")
  r=raster(path)
  name=gsub(".tif","",ras)
  assign(name,r)
  print(ras)
}
rm(list=c("path","r","name","ras"))

#read in static rasters
setwd("F:/Climate_paper/static_rasters")
Rugosity=raster("F:/Climate_paper/static_rasters/gebco_rug_5_clp.tif")
Depth=raster("F:/Climate_paper/static_rasters/gebco_depth_clp.tif")

###cleaning up
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){
  if(grepl("_pnts",i)==TRUE){
    dat=get(i)
    name=gsub("_pnts","",i)
    assign(name,dat)
  }
}
rm(list=ls(pattern="pnts"))
rm(list=c("dat","name","i"))

#####now, put rasters in folder
months=c("01","02","03","04","05","06","07","08","09","10","11","12")
vars=c("bt","sh","st","bs","SS")

setwd("F:/Climate_paper/GAM_1/project")
for(m in months){
  folder=paste(getwd(),"/",m,"_2010",sep="");dir.create(folder)
  rug_save=paste(folder,"/Rugosity",sep="")
  writeRaster(Rugosity,rug_save,format="GTiff",bylayer=TRUE)
  dep_save=paste(folder,"/Depth",sep="")
  writeRaster(Depth,dep_save,format="GTiff",bylayer=TRUE)
  for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){
    if (grepl(m,i)==TRUE){
      print(i)
      dat=get(i)
      remove=paste("_m",m,"_pp",sep="")
      name=gsub(remove,"",i)
      save=paste(folder,"/",name,sep="")
      writeRaster(dat,save,format="GTiff",bylayer=TRUE)
  }
  }
}

###running gams, just w SSH to test for relationship
library(mgcv)
NS=read.csv(file="F:/Climate_paper/GAM_trial/species/METAL_DEBRIS.csv")
gmNS=gam(p_a~s(SSH,bs="ts"),family=binomial,data=NS)
summary(gmNS)$dev.expl
s=summary(gmNS)$s.table

setwd("F:/Climate_paper/GAM_trial/species_SSS")
library(tools)
for(csv in list.files()){
  no_extention=file_path_sans_ext(csv)
  temp=read.csv(csv,header=TRUE,sep=",")
  assign(no_extention,temp)
}

species=file_path_sans_ext(list.files()) ## get list of species
for(sp in species){
  dat=dat=get(sp)
  gm=gam(p_a~s(SSS,bs="ts"),family=binomial,data=dat)
  assign(sp,gm)
}

############################making a gam results dataframe
## 1. extract test statistics
species=file_path_sans_ext(list.files()) ## get list of species (this will be a folder w all the csvs for each species)
dataF=data.frame() # create empty data frame
for(sp in species){
  dat=get(sp)
  summ=summary(dat)$s.table
  df=data.frame(matrix(unlist(summ),nrow=1,byrow=T))
  df$spp=sp # add new column for species name
  dataF=rbind(dataF,df) # iteratively update dataframe
}
write.csv(dataF,file="test_stats.csv")


## 2. read data back in, objects replaced by gams
setwd("F:/Climate_paper/GAM_trial/species_SSS")
library(tools)
for(csv in list.files(pattern="*.csv$")){
  no_extention=file_path_sans_ext(csv)
  name=paste(no_extention,"_df",sep="")
  temp=read.csv(csv,header=TRUE,sep=",")
  assign(name,temp)
}

## 3. extracting numbers of presence/absences
setwd("F:/Climate_paper/GAM_trial/species_SSS")
species=file_path_sans_ext(list.files()) ## get list of species
dataframes=ls(pattern="*_df")
for(sp in species){
  for(df in dataframes){
    if(grepl(sp,df)==TRUE){
      dat=get(df)
      pres=length(which(dat[,10]==1)) #update to p_a column position as needed
      abs=length(which(dat[,10]==0)) #update to p_a column position as needed
      dataF$presence[which(dataF$spp==sp)]=pres #presence column for each species
      dataF$absence[which(dataF$spp==sp)]=abs #absence column for each specie
      }
    }
  }

## 4. calculating AUCS
library(pROC)
for(sp in species){
  dataframe=paste(sp,"_df",sep="")
  dataS=get(dataframe)
  dat=dataS[complete.cases(dataS),]
  gm=get(sp)
  prob=predict(gm,type=c("response"))
  dat$prob=prob
  g=roc(p_a~prob,data=dat)
  name=paste(sp,"_AUC",sep="")
  assign(name,g)
}

## 5. adding AUCs to dataF
for(file in ls(pattern="*_AUC")){
  sp=gsub("_AUC","",file)
  dat=get(file)
  auc=as.numeric(dat["auc"])
  dataF$auc[which(dataF$spp==sp)]=auc
}


############### k-fold model evaluation
# 1 model first
library(mgcv)
library(pROC)
form=as.formula(p_a~s(ss,bs="ts")+s(st,bs="ts")+s(sh,bs="ts")+s(ss,bs="ts"))
gm=gam(form,data=ALOSA_AESTIVALIS,family='binomial')
prediction=kfoldcv(formula=form, data=ALOSA_AESTIVALIS,depvar='failure',k=10,method='logit.gam')



###EXTRA BITS AND PIECES OF CODE


if(dataF$spp==sp){
  dataF$presence=pres
  dataF$absence=abs

for(dataF[dataF$spp %in% sp,]{
  dataF$presence=pres

  dataF$absence=ifelse(dataF$spp==sp,abs,)
  
dataF$presence=ifelse(dataF$spp==sp,pres,)
dataF$absence=ifelse(dataF$spp==sp,abs,)

  dataF$presence
pres=length(which(ACIPENSER_OXYRHYNCHUS_df$p_a==1))
abs=length(which(ACIPENSER_OXYRHYNCHUS_df$p_a==0))


summary_list=lapply(species,summary)
df=data.frame(matrix(unlist(summ),nrow=1,byrow=T))
s.table_list=lapply(summary_list,'[[','s.table')
