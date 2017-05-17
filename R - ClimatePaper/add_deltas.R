###########adding cm2.6 deltas to climatological bias-corrected hycom
library(raster)

#deltas: F:/Climate_paper/CM2.6/rasters_point08deg/
# bias-corrected hycom: F:\Climate_paper\GAM_1\project

months=c("m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12")
variables=c("bs","bt","sh","SS","st")


########## read in historical rasters
setwd("F:/Climate_paper/GAM_1/project_future")
for(folder in list.files()){
  wd=paste(getwd(),"/",folder,sep="")
  print(folder)
    for (file in list.files(path=wd,pattern="*.tif$")){
      ras=paste(wd,"/",file,sep="")
      r=raster(ras)
      x=gsub(".tif","",file)
      name=paste(x,"_",folder,sep="")
      print(name)
      assign(name,r)
    }    
}

rm(list=c("folder","wd","file","ras","r","x","name"))
rm(list=ls(pattern="Depth"))
rm(list=ls(pattern="Rugosity"))

############## read in future deltas
setwd("F:/Climate_paper/CM2.6/rasters_point08deg/")
for(file in list.files(pattern="*.tif$")){
  r=raster(file)
  x=gsub(".tif","",file)
  assign(x,r)
}
rm(list=c("r","x"))
#### first create all the directories
for(delta in dlist){
  split=strsplit(delta, "_")
  folder=paste(unlist(split)[2],"_20",unlist(split)[3],sep="")
  print(folder)
  pt=paste(getwd(),"/",folder,sep="");dir.create(pt)
}


delta_list=list.files(pattern="*.tif$")
head(delta_list)
dlist=lapply(delta_list,function(x)gsub(".tif","",x))
clim_list=ls(pattern="*_2010")

setwd("F:/Climate_paper/GAM_1/project_future")
for(ras in clim_list){
  print(paste("current raster is ",ras,sep=""))
  current=get(ras)
  split=strsplit(ras, "_")
  print(split)
  var=unlist(split)[1] # define variable
  month=unlist(split)[2] # define month
  print(paste("the variable is ",var,sep=""))
  print(paste("the month is ",month,sep=""))
  var_month=gsub("_2010","",ras) #to identify rasters in dlist
  print(var_month)
  for(delta in dlist){
    if (grepl(var_month,delta)==TRUE){ # if delta is for same month and variable as ras
      print(paste("the future delta is ",delta,sep=""))
      future=get(delta)
      math=sum(current,future)
      split=strsplit(delta, "_") # where to save
      folder=paste(unlist(split)[2],"_20",unlist(split)[3],sep="") # where to save
      print(paste("raster math layer is being saved in folder ",folder,sep=""))
      pt=paste(getwd(),"/",folder,"/",var,sep="")
      print(paste(ras," has been added to ",delta," and is being saved here: ",pt,sep=""))
      writeRaster(math,pt,format="GTiff",bylayer=TRUE)
    }
  }
}

#read in static rasters and add to folders
setwd("F:/Climate_paper/static_rasters")
Rugosity=raster("F:/Climate_paper/static_rasters/gebco_rug_5_clp.tif")
Depth=raster("F:/Climate_paper/static_rasters/gebco_depth_clp.tif")


setwd("F:/Climate_paper/GAM_1/project_future") ###still need to do
list=list.files()
list2=list[-c(1,2)]
list2$m03_2010=NULL
for(file in list.files()){
  pt1=paste(getwd(),"/",file,"/Rugosity",sep="")
  pt2=paste(getwd(),"/",file,"/Depth",sep="")
  print(pt1)
  print(pt2)
  exist_pt1=paste(pt1,".tif",sep="")
  exist_pt2=paste(pt2,".tif",sep="")
    if(file.exists(exist_pt1)==FALSE){
      print("Rugosity doesn't exist, writing raster")
      writeRaster(Rugosity,pt1,format="GTiff",bylayer=TRUE)
    }
    if(file.exists(exist_pt2)==FALSE){
      print("Depth doesn't exist, writing raster")
      writeRaster(Depth,pt2,format="GTiff",bylayer=TRUE)
}
}

Rugosity=raster("F:/Climate_paper/static_rasters/gebco_rug_5_clp.tif")
Depth=raster("F:/Climate_paper/static_rasters/gebco_depth_clp.tif")

setwd("F:/Climate_paper/GAM_1/project_future")
for(file in list.files()){
  pt1=paste(getwd(),"/",file,"/Rugosity.tif",sep="")
  pt2=paste(getwd(),"/",file,"/Depth.tif",sep="")
  print(pt1)
  print(pt2)
  if(file.exists(pt1)==FALSE){
    print("Rugosity doesn't exist, copying raster")
    file.copy(Rugosity,pt1,overwrite=FALSE)
  }
  if(file.exists(pt2)==FALSE){
    print("Depth doesn't exist, copying raster")
    file.copy(Rugosity,pt2,overwrite=FALSE)
  }
}
