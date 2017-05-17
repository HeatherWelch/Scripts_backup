##### WORKING WITH NWA POINTS, TRYING TO EXTRACT BOTTOM VALUES FOR TEMP AND SALINITY

###STARTING WITH JUST ONE LAYER

setwd("F:/Climate_paper/NWA _clims/clipped_downloads/temp_clip")

## 01. read in shapefile
library(rgdal)
shapes=readOGR(dsn="F:/Climate_paper/NWA _clims/clipped_downloads/temp_clip",layer="nwa_all_t01")
plot(shape)

#read in known shapefile to check extent
VTR=readOGR(dsn="F:/VMS/VTR",layer="Statistical_Areas_2010")
plot(VTR,add=TRUE)

#define NAs
shape@data[shape@data==0]=NA
shape@data[shape@data==0.000]=NA
shape@data[shape@data==-999.999]=NA

##delete surface value (we want NAs there if d.n. exist)
shp=shape@data[,c(2:57)]

#grap last value for each row
lastvalue=function(x) tail(x[!is.na(x)],1)
shape$btm=apply(shape@data,1,lastvalue)


##writeout
writeOGR(shape,dsn="F:/Climate_paper/NWA _clims/clipped_downloads/bot_temp","bot_01",driver="ESRI Shapefile")

###########batching that shit
########temp first
setwd("F:/Climate_paper/NWA _clims/clipped_downloads/temp_clip")
lastvalue=function(x) tail(x[!is.na(x)],1)
for(file in list.files(pattern="*.shx")){
  name=gsub(".shx","",file)
  print(name)
  shape=readOGR(dsn="F:/Climate_paper/NWA _clims/clipped_downloads/temp_clip",layer=name)
  shape@data[shape@data==0]=NA
  shape@data[shape@data==0.000]=NA
  shape@data[shape@data==-999.999]=NA
  #shape@data=shape@data[,-(1)]
  shape@data$btm=apply(shape@data,1,lastvalue)
  #sh@data$btm=sh@data$btm$MNIMI
  writeOGR(shape,dsn="F:/Climate_paper/NWA _clims/clipped_downloads/bot_temp",name,driver="ESRI Shapefile")
}

###########doing this in arc to speed things up
#convert to raster
# library(raster)
# r=raster(res=.25,ncols=65,nrows=54)
# bt=rasterize(shape,r,field="btm",fun=mean)
