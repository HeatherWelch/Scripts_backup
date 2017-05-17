#### exploring DOM environmental data

library(raster)
library(sp)
library(chron)
library(rgdal)
library(ncdf4)

path='/Volumes/SeaGate/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite/2012-08-01'
#path_nc='/Volumes/SeaGate/ERD_DOM/ncdf/aviso_delayed_time_madt_u_1993-01-01.nc'

#list.files(path)
#path_grd='/Volumes/SeaGate/ERD_DOM/ncdf/aspect_filtered.xyz'
#x=raster(paste(path,"/analysed_sst_sd.grd",sep=""))
#x=raster(path_grd)
#plot(x)
#proj4string(x)
#bbox(x)
#resolution(x)
#dim(x)

path_nc='/Volumes/SeaGate/ERD_DOM/ncdf/Bight/etopo180_48d2_23d2_fc23.nc'
nc=nc_open(path_nc)
nc


#path_grd='/Volumes/SeaGate/ERD_DOM/ncdf/aspect_filtered.xyz'
#path_grd='/Volumes/SeaGate/ERD_DOM/ncdf/aspectnan.xyz'
path_grd='/Volumes/SeaGate/ERD_DOM/ncdf/bathyrms_blockmean.xyz'
#path_grd='/Volumes/SeaGate/ERD_DOM/ncdf/bathyrms.xyz'
x=read.table(path_grd)
head(x)
#tail(x)
#summary(x$V3)
coordinates(x)=~V1+V2
#plot(x)
#class(x)
y=rasterFromXYZ(x)
plot(y)
y


r <- raster(ncols=2401, nrows=3000)
a=rasterize(x,r,x@data[,1],fun=mean)
extent(a)=extent(x)
plot(a)
a

