####working with netcdfs
##############################
############  http://geog.uoregon.edu/bartlein/courses/geog607/Rmd/netCDF_01.htm
library(ncdf4)
setwd("F:/Climate_paper/CM2.6")
#ncname <- "sh"
ncname="sh"
ncfname <- paste(ncname, ".nc", sep = "")
ncin <- nc_open(ncfname)
print(ncin)
dname="DELTA"

lon <- ncvar_get(ncin, "XT_OCEAN2001_2250")
nlon <- dim(lon)
head(lon)

lat <- ncvar_get(ncin, "YT_OCEAN1560_1809", verbose = F)
nlat <- dim(lat)
head(lat)

print(c(nlon, nlat))

t <- ncvar_get(ncin, "TIME")
tunits <- ncatt_get(ncin, "TIME", "units")
nt <- dim(t)

tmp.array <- ncvar_get(ncin, dname)
dlname <- ncatt_get(ncin, dname, "long_name")
dunits <- ncatt_get(ncin, dname, "units")
fillvalue <- ncatt_get(ncin, dname, "_FillValue")
dim(tmp.array)

library(chron) 
tustr <- strsplit(tunits$value, " ")
tdstr <- strsplit(unlist(tustr)[3], "-")
tmonth = as.integer(unlist(tdstr)[2])
tday = as.integer(unlist(tdstr)[3])
tyear = as.integer(unlist(tdstr)[1])
date=chron(t, origin = c(tmonth, tday, tyear))

tmp.array[tmp.array==fillvalue$value]=NA

########## for one raster
# m=1
# tmp.slice=tmp.array[,,m]
# dim(tmp.slice)
# 
# library(RColorBrewer)
# image(lon, lat, tmp.slice, col = rev(brewer.pal(10, "RdBu")))
# 
# lonlat=expand.grid(lon,lat)
# tmp.vec=as.vector(tmp.slice)
# tmp.df01 <- data.frame(cbind(lonlat, tmp.vec))
# names(tmp.df01) <- c("lon", "lat", paste(dname, as.character(m), sep = "_"))

###   doing it all   ie for all rasters at once
tmp.vec.long <- as.vector(tmp.array)
length(tmp.vec.long)

tmp.mat <- matrix(tmp.vec.long, nrow = nlon * nlat, ncol = nt)
dim(tmp.mat)

date2=as.character(chron(t, origin = c(tmonth, tday, tyear))) ####getting names together
d=lapply(date2,function(x)strsplit(x, " "))
e=lapply(d,function(x)strsplit(unlist(x)[1], "/"))
f=lapply(e,function(x)unlist(x)[c(1,3)])
g=lapply(f,function(x)paste(x[1],x[2],sep="_"))
h=lapply(g,function(x)gsub("\\(","m",x))

#names=c(1:960)
#names_full=lapply(names,function(x)paste("delta_",x,sep="")) ##need better naming convention
lonlat <- expand.grid(lon, lat)
names(lonlat) <- c("lon","lat")
tmp.df02 <- data.frame(tmp.mat)
names(tmp.df02) <- h
tmp.df02 <- cbind(lonlat, tmp.df02)

#options(width = 110)
#head(na.omit(tmp.df02, 20))

#tmp.df02$lat2=tmp.df02$lat
#tmp.df02$lon2=tmp.df02$lon


library(sp)
library(rgdal)
coordinates(tmp.df02)=~lon+lat # ~ long+lat ##note this will 'delete' your lat/long columns, you might want to copy them before you make the points spatial
plot(tmp.df02,add=TRUE)
#tmp.df03 <- tmp.df01[na.omit(tmp.df02@data)] ## doesn't work, need to get rid of the nas
# tmp.df02=tmp.df02[as.numeric(tmp.df02@data$lat2)]
# tmp.df02=tmp.df02[,c(1:960)]
# writeOGR(tmp.df02,"CM2.6","ssh",driver="ESRI Shapefile") ###only use if need to write out as points

###########################ignore, got around by creating raster in arcgis
###creating empty raster
#bbox(tmp.df02)
# library(raster)
# template=raster()
# res(template)=0.08
# ext=extent(Depth)
# extent(template)=ext
# ncol(template)=130
# nrow(template)=125
# projection(template)="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
###########################ignore, got around by creating raster in arcgis


setwd("F:/Climate_paper/CM2.6/raster/")
template=raster("F:/Climate_paper/CM2.6/raster/fshnt_fin.tif") ### .1 deg raster made from fishneting netcdf points
proj4string(template)
res(template)


study_area=raster("F:/Climate_paper/AVISO/extrct_ras")
setwd("F:/Climate_paper/CM2.6/rasters_point08deg")
for(n in names(tmp.df02)){
  r=rasterize(tmp.df02,template,field=n,fun=mean) # points to raster (.1 deg)
  x=resample(r,study_area,method="ngb") # origin and resolution to match study area
  e=mask(x,study_area) #clip to study area
  name=paste("sh_",n,sep="")
  print(name)
  writeRaster(e,name,format="GTiff",bylayer=TRUE)
}






##################### EXTRA BITS AND PIECES OF CODE
x=resample(r,study_area,method="ngb")
c=crop(study_area,x)
ext=bbox(study_area)
d=crop(x,ext)
e=mask(x,study_area)
writeRaster(e,"name1",format="GTiff",bylayer=TRUE)


setwd("F:/Climate_paper/CM2.6")
library(RNetCDF)
library(ncdf4)
#library(ncdf) ##outdated?

netcdf=open.nc("CM2.6_2xCO2_NYHOPS_domain_monthly_ocean_sealevel_delta.nc")
print.nc(netcdf) ###print out the netcdf file, like extract header
dat=read.nc(netcdf)
summary(dat)
time=dat$TIME
z=dat$DELTA
xlat=dat$YT_OCEAN1560_1809
ylon=dat$XT_OCEAN2001_2250

nlat=length(xlat)
nlog=length(ylon)
dates=trunc(length(time))
aray=array(z,dim=c(nlat,nlog,dates))
head(aray)

library(rerddap)

convert_time(n = 43845.5,units="days since 0001-01-01 00:00:00",method="web")
convert_time(n = 73034.5,units="days since 0001-01-01 00:00:00",method="web")

##do it for all time-slices
t=lapply(time,function(x) convert_time(n = x,units="days since 0001-01-01 00:00:00",method="web"))

data=var.get.nc(netcdf,"DELTA")
time_units=att.get.nc(netcdf,"TIME","units")
time_b=dat$TIME_bnds
dim.inq.nc(netcdf,dimension=4)


library(raster)
f="CM2.6_2xCO2_NYHOPS_domain_monthly_ocean_sealevel_delta.nc"
b=brick(f,lval=4)
p=points(f)

##reading in as points
time=dat$TIME
z=dat$DELTA
xlat=dat$YT_OCEAN1560_1809
ylon=dat$XT_OCEAN2001_2250
library(maptools)
image=SpatialPoints(cbind(ylon,xlat))
myproj="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" # projection of rasters
proj4string(image)=CRS(myproj) ## project records
summary(image)

rm(list=ls())

##look into this: http://gis.stackexchange.com/questions/79062/how-to-make-raster-from-irregular-point-data-without-interpolation

### interpolating
# https://gist.github.com/benmarwick/7331879
library(akima)

