#SCRIPT TO PROJECT STRIPED BASS AT ANNUAL TIME STEPS


############################################################################################################
# Project species distributions at monthly and yearly time slices

#libraries needed
library(raster)
library(mgcv)


#Set the primary working directories
primary_dir=paste("F:/Climate_paper/GAM_1");setwd(primary_dir)# swap folder names if necessary
spp_dir=paste(primary_dir,"/species/",sep="");#dir.create(spp_dir) # swap folder name if necessary
raster_dir=paste(primary_dir,"/project_future/",sep="");#dir.create(raster_dir)
projection_dir=paste(primary_dir,"/Species_Projections/",sep="");dir.create(projection_dir)

#Messaging to signal a tranisition 
print("starting to projection model predictors for each species")

## defining the species
species<-c("d139")

#creating a list of raster directories for looping and projecting
setwd(raster_dir)
dir_list<-list.dirs(".", recursive=FALSE)
#removing the ./ from the character string 
dir_name<-gsub("./", "", dir_list)

#start the projection script
for (spp in species){
  setwd(spp_dir)
  print(paste("started to project ",spp,sep=""))
  dat<-read.csv(paste("d139.csv",sep=""))
  #make sure to change the predictor variable names here
  final_object<-gam(p_a ~s(st,bs="ts")+s(bt,bs="ts")+s(SS,bs="ts")+s(bs,bs="ts")+s(sh,bs="ts"),family=binomial("logit"),data=dat,method="GCV.Cp")
  setwd(raster_dir)}
  #iterating through folders to project for each species
  for (d in dir_name){
    setwd(paste(raster_dir,"/",d,sep=""))
    SS<-raster("SS.tif")
    bs<-raster("bs.tif")
    st<-raster("st.tif")
    bt<-raster("bt.tif")
    sh<-raster("sh.tif")
    rasterStack<-stack(SS,bs,st,bt,sh)
    names(rasterStack)<-c("SS","bs","st","bt","sh")
    #setwd(paste(projection_dir,"/",spp,sep=""))
    raster::predict(rasterStack,final_object,filename=paste(projection_dir,"d139_",d,".tif",sep=""),fun=predict,format="GTiff", type="response",na.rm=TRUE,overwrite=TRUE,progress='text')
    #print(paste("projection of ",spp," finished",sep=""))
  }
}
}
