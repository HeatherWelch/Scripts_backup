##############script to get ready to run gams
######what needs to be done
# 1. rasters need to be renamed (wait till final data)
# 2. rasters need to be clipped by point minimum bounding box (wait till final data)
# 3. rasters need to be put in mmm_yyyyy folders e.g. m01_y2020 (wait till final data)

#####get script ready to deal with points
##data will come in as sp_code, lat, long, month
# 4. points need to be associate w rasters in correct month
# 5. species need to be divided into p/a and written out in individual csv


# 4. read in points as csv
###this is just a dummy set of points from 2003 observer
setwd("F:/Climate_paper/Observer_data/Cleaned")
records=read.csv("ObserverData2003.csv")
rec=records[,c(3:5,8,11)]
rec$GIS_LONHB=rec$GIS_LONHB*-1 ###make it negative lat/long

# 4.1 convert points to shp
library(sp)
rec$lat=rec$GIS_LATHB###should probably copy lat long columns and add to end in case we need them
rec$long=rec$GIS_LONHB###should probably copy lat long columns and add to end in case we need them

coordinates(rec)=~GIS_LONHB+GIS_LATHB
plot(rec)

##read in a known shapefile to check position
library(rgdal)
VTR=readOGR(dsn="F:/VMS/VTR",layer="Statistical_Areas_2010")
plot(VTR,add=TRUE)

# 4.2 read in rasters (this will be a totally different format depending on file tree)
#setwd("F:/Climate_paper/hycom/SSH/1day/surf_el/Monthly_Climatology")
setwd("F:/Climate_paper/hycom/SSS/1day/salinity/Monthly_Climatology/Depth_0000m")
library(raster)
for (ras in list.files(pattern="*.img$")){
  path=paste(getwd(),"/",ras,sep="")
  r=raster(path)
  name=gsub(".img","",ras)
  assign(name,r)
}

# 4.3 extract monthly env.var values at points
#getting months in a usuable format
library(stringr)
rec$month=str_pad(rec$month,2,pad="0") ##add leading zero to 1-9
#rec$month=as.numeric(rec$month)

#now attach points
months=c("01","02","03","04","05","06","07","08","09","10","11","12")
#variable=c("ph","pp","o2","CL","bt","bs","ss","st")
for (m in months){
  recm=subset(rec,month==m)
  print(m)
  for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(pattern="salinity*"))){
    if (grepl(m,i)==TRUE){ ##if value in iterative object
        print(i)
        dat=get(i)}
        recm$SSS=extract(dat,recm,method="simple")
        name=paste("m",m,sep="")
        assign(name,recm)
}
}

#####combining them
master=rbind(m01,m02,m03,m04,m05,m06,m07,m08,m09,m10,m11,m12)

###attach random raster to points to ensure species p/a's are not in the same grid cell
##made this earlier in GIS, created fishnets using a hycom rs, converted to raster using FID to grab unique values at each cell
setwd("F:/Climate_paper/hycom/random_raster")
random=raster(paste(getwd(),"/rr1",sep=""))
master$unique=extract(random,master,method="simple")
head(master)
master$m_unique=paste(master$month,"_",master$unique,sep="")

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
species=levels(master$SCINAME)
for(sp in species){
  print(sp)
  presence=subset(master,master$SCINAME==sp) # presences
  absence=subset(master,master$SCINAME!=sp)
  abs=absence@data%>%distinct(m_unique)
  ab=abs[!(abs$m_unique %in% presence$m_unique),] #final absences, unique, no points from presence
  presence$p_a=1 #binary
  ab$p_a=0 #binary
  complete=rbind(presence@data,ab)
  if(grepl(" ",sp)==TRUE){ ##won't need w species codes
    name=gsub(" ","_",sp) ##won't need w species codes
  } else{
      name=sp
    }
  output=paste("F:/Climate_paper/GAM_trial/species_SSS/",name,".csv",sep="")
  write.csv(complete,file=output)
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
