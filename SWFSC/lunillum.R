### adding lunillum
library(lunar)
library(raster)
setwd("/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite")  ## change for each user

template=raster() ##create template for resampling
res(template)=0.2487562
ncol(template)=201
nrow(template)=201
xmin(template)=-149.875
xmax(template)=-99.875
ymin(template)=10.125
ymax(template)=60.125
projection(template)="+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

fileslist=list.files()
for(a in fileslist){
  path=paste(getwd(),"/",a,"/lunillum.grd",sep="")
  if(file.exists(path)==FALSE){
    date=as.Date(a)
    value <- lunar.illumination(date)
    lunar_ras=template
    values(lunar_ras)=value
    writeRaster(lunar_ras,paste(getwd(),"/",a,"/lunillum",sep=""))
    print(paste(getwd(),"/",a,"/lunillum",sep=""))
  }
}


### adding z_pt25, z, zsd
library(raster)
setwd("/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite")  ## change for each user

z_pt25=raster("/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite/2012-08-01/z_pt25.grd") ## change for each user
z=raster("/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite/2012-08-01/z.grd")
zsd=raster("/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite/2012-08-01/zsd.grd")


fileslist=list.files()
for(a in fileslist){
  path=paste(getwd(),"/",a,"/zsd.grd",sep="")
  if(file.exists(path)==FALSE){
    writeRaster(z_pt25,paste(getwd(),"/",a,"/zsd.grd",sep=""))
    print(paste(getwd(),"/",a,"/zsd.grd",sep=""))
  }
}



