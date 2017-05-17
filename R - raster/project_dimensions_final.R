####fixing remote sensing rasters
#01. load some librarys
library(raster)
library(shapefiles)
library(maptools)
library(rgdal)
library(dplyr)
library(tools)
library(sp)
library(spatial.tools)

#02. set wd, find dimensions of a good raster
#setwd("F:/Remote Sensing Data/Maxent")
setwd("F:/hycom_GLBu0.08_clean2")
good=raster("F:/Remote Sensing Data/Maxent/GHRSST_clim/ghrsst_m01")
good # get dimensions

#03. use dimensions of good raster to build a template raster for projection
template=raster()
res(template)=0.01098633
ncol(template)=638
nrow(template)=637
xmin(template)=-76.00391
xmax(template)=-68.99463
ymin(template)=35.00245
ymax(template)=42.00074
values(template)=1 #set the values of pixels to 1 so it can be drawn
projection(template)="+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"
plot(template)

#04. build iterative script
myfiles=list.files()
mf=myfiles
#mf2=myfiles[!grepl("chl_a_clim_mean",myfiles)]#create a new list of files minus GHRSST_clim which is alreay in correct proj/extent
#mf1=mf2[!grepl("chl_a_clim_sdv",mf2)]#create a new list of files minus GHRSST_clim which is alreay in correct proj/extent
#mf=myfiles[!grepl("tiffs",myfiles)]#create a new list of files minus GHRSST_clim which is alreay in correct proj/extent
#mf_1=mf0[!grepl("MODIS_sst_clim_mean",mf0)]#create a new list of files minus GHRSST_clim which is alreay in correct proj/extent
#mf=mf_1[!grepl("MODIS_sst_clim_sdv",mf_1)]#create a new list of files minus GHRSST_clim which is alreay in correct proj/extent

for(file in mf){
  print(file)#name of file
  folder=paste(getwd(),"/",file,sep="")#name of file with full path
  print(folder)
  #directory=paste("F:/Remote Sensing Data/Maxent-Copy_reprojected/",file,"/",sep="");#dir.create(directory)#create a new directory for each folder
  directory=paste("F:/hycom_GLBu0.08_reprojected/",file,"/",sep="");dir.create(directory)#create a new directory for each folder
  for(layer in list.files(folder,pattern="*.img$")){ #list .img files
    print(layer)
    layer_path=paste(folder,"/",layer,sep="")
    bad=raster(layer_path) #read in .img a raster
    d=projectRaster(bad,template,method="ngb",filename="project2",overwrite=TRUE)#reformat layer
    no_extention=file_path_sans_ext(layer)
    n=paste(directory,no_extention,sep="")
    print(n)
    writeRaster(d,n,format="GTiff",bylayer=TRUE,overwrite=TRUE)#write out
  }
}
    
###now same script for the stuff that GRID (not img)
#first convert all files to img, otherwise it misses the projection information
grd_fldr=c("t_btm_m","t_btm_sd","u_btm_m","u_btm_sd")

for(grd in grd_fldr){
  pth=paste("F:/Remote Sensing Data/Bottom_hycom_bottom_temp_U/img/",grd,sep="")
  print(pth)
  directory=paste("F:/Remote Sensing Data/Maxent-Copy_reprojected/",grd,"/",sep="");#dir.create(directory)#create a new directory for each folde
  print(directory)
  #lst=list.dirs(pth,full.names=FALSE)
  #mf2=lst[3:14]
  #print(mf2)
  for(layer in list.files(pth,pattern="*.img$")){ 
    print(layer)
    layer_path=paste(pth,"/",layer,sep="")
    bad=raster(layer_path) #read in .img a raster
    #crs="+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"
    #projection(bad)=crs
    d=projectRaster(bad,template,method="ngb",filename="project2",overwrite=TRUE)#reformat layer
    no_extention=file_path_sans_ext(layer)
    n=paste(directory,no_extention,sep="")
    print(n)
    writeRaster(d,n,format="GTiff",bylayer=TRUE)#write out
}
  }

