## CLIMATE PAPER ROUND 2.
#A. FIRST NEED TO KNOW WHICH RASTERS ARE EMPTY
#B. THEN NEED TO REPROJECT ON THEM BASED ON A MODEL OBJECT

#Set the primary working directories
primary_dir="/Volumes/SeaGate/ClimatePaperCM2.6";setwd(primary_dir)# swap folder names if necessary
spp_model_dir=paste(primary_dir,"/species_models/",sep=""); # folder with model objects for each species, names with species names
raster_dir="/Volumes/SDM /Lacie backup October 2016/Lacie share/Climate_paper/GAM_1/project_future/";#dir.create(raster_dir)
projection_dir="/Volumes/SDM /Lacie backup October 2016/Lacie share/Climate_paper/GAM_1/Species_Projections_all/";#dir.create(projection_dir)
jenn_dir=paste(primary_dir,"/new_rasters/",sep="");dir.create(jenn_dir)

###TESTING IF RASTERS ARE EMPTY
library(raster)
setwd(raster_dir) #setwd(projection_dir)
blank=list()
fileslist=list.files()
for(f in fileslist){
  path=paste(getwd(),"/",f,sep="")
  #print(path)
  small_list=list.files(path,full.names = TRUE)
  for(tif in small_list){
    if((file.info(tif)$size<10000)==TRUE){
      blank=list(blank,tif)
    }
  }
}

final_list=unlist(blank) ## list of blank rasters with path

#### Projecting missing rasters

for(raster in final_list){
  a=unlist(strsplit(raster,"/"))
  species_name=a[length(a)-1]
  print(species_name)
  modelRDS=readRDS(paste(spp_model_dir,species_name,".rds",sep="")) ## get rds model object for the missing species
  date1=gsub(".tif","",a[length(a)])
  date=gsub(paste(species_name,"_",sep=""),"",date1)
  print(date)
  layers_dir=paste(raster_dir,date,sep="")
  Depth<-raster(paste(layers_dir,"/Depth.tif",sep=""))
  Rugosity<-raster(paste(layers_dir,"/Rugosity.tif",sep=""))
  SS<-raster(paste(layers_dir,"/SS.tif",sep=""))
  bs<-raster(paste(layers_dir,"/bs.tif",sep=""))
  st<-raster(paste(layers_dir,"/st.tif",sep=""))
  bt<-raster(paste(layers_dir,"/bt.tif",sep=""))
  sh<-raster(paste(layers_dir,"/sh.tif",sep=""))
  rasterStack<-stack(Depth,Rugosity,SS,bs,st,bt,sh)
  names(rasterStack)<-c("Depth","Rugosity","SS","bs","st","bt","sh") ## make a raster stack for the missing date
  file_name=paste(projection_dir,species_name,"/",date1,".tif",sep="")
  print(paste("Creating new projection: ",file_name,sep=""))
  raster::predict(rasterStack,modelRDS,filename=file_name,fun=predict,format="GTiff", type="response",na.rm=TRUE,overwrite=TRUE,progress='text')
  file.copy(file_name,jenn_dir)
}




