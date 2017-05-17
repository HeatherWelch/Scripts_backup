############preparing for UCSC/NOAA job (hopefully): 
"Knowledge of relevant HDF4, HDF5, NetCDF3 and NetCDF4 file formats and data processing capabilities."
###

#HDF: hierarchical data format
#NetCDF: network common data form
  #self-deciribing, machine-independant data format for array-oriented data

#HDF vs NetCDF: http://www.cise.ufl.edu/~rms/HDF-NetCDF%20Report.pdf
#HDF (4, latest version) and HDF5 are two different products

#########
#HDF5
# group: contains multiple HDF5 objects and metadata
# dataset: multidimensional array or data elements and metadata

###NetCDF4 is based on HDF5
# r package ncdf4 includes HDF5 support, RNetCDF does not

library(ncdf4)
library(raster)
setwd("F:/SDM_paper/maxent/Maxent_run/projections/m01")
list.files()

a=raster("t_0_m.asc")
b=raster("t_1_m.asc")
c=raster("t_2_m.asc")

#https://www.getdatajoy.com/learn/Read_and_Write_NetCDF_from_R


x=1:nrow(a)
y=1:ncol(a)
aa=as.matrix(a)

dim1 <- ncdim_def('EW', 'degrees', as.double(x))
dim2 <- ncdim_def('SN', 'degrees', as.double(y))

varz <- ncvar_def('Temperature','degrees', list(dim1, dim2),-9999, longname = 'Surface temperature')

outnc=nc_create("F:/trial/netcdf/temp.nc",varz,force_v4=TRUE)
ncvar_put(outnc,varz,aa)
nc_close(outnc)

ncin <- nc_open("F:/trial/netcdf/temp2.nc")
print(ncin)

aaa=raster("F:/trial/netcdf/temp2.nc")
plot(aaa)


###single raster to netcdf
writeRaster(a,"F:/trial/netcdf/temp2.nc","CDF",varname="temperature",varunit="degrees",longname="degrees Celcius",xname="lon",yname="lat")

###multiple rasters to netcdf
bb=stack(c(a,b,c))
writeRaster(bb,"F:/trial/netcdf/temp3.nc","CDF",varname="temperature",varunit="degrees",longname="degrees Celcius",xname="lon",yname="lat")

ncin <- nc_open("F:/trial/netcdf/temp3.nc")
print(ncin)
q=brick("F:/trial/netcdf/temp3.nc",lvar=3)
plot(q)


###from: http://geog.uoregon.edu/GeogR/topics/netCDF-write-ncdf4.html

library(ncdf4)


# define dimensions
londim <- ncdim_def("lon","degrees_east",as.double(lon3)) 
latdim <- ncdim_def("lat","degrees_north",as.double(lat3)) 
timedim <- ncdim_def("time",tunits3,as.double(t3))

# define variables
fillvalue <- 1e32
dlname <- "2m air temperature"
tmp_def <- ncvar_def("tmp","deg_C",list(londim,latdim,timedim),fillvalue,dlname,prec="single")
dlname <- "mean_temperture_warmest_month"
mtwa_def <- ncvar_def("mtwa","deg_C",list(londim,latdim),fillvalue,dlname,prec="single")
dlname <- "mean_temperature_coldest_month"
mtco_def <- ncvar_def("mtco","deg_C",list(londim,latdim),fillvalue,dlname,prec="single")
dlname <- "mean_annual_temperature"
mat_def <- ncvar_def("mat","deg_C",list(londim,latdim),fillvalue,dlname,prec="single")

# create netCDF file and put arrays
ncfname <- "cru10min30_ncdf4.nc"
ncout <- nc_create(ncfname,list(tmp_def,mtco_def,mtwa_def,mat_def),force_v4=T)

# put variables
ncvar_put(ncout,tmp_def,tmp_array3)
ncvar_put(ncout,mtwa_def,mtwa_array3)
ncvar_put(ncout,mtco_def,mtco_array3)
ncvar_put(ncout,mat_def,mat_array3)

# put additional attributes into dimension and data variables
ncatt_put(ncout,"lon","axis","X") #,verbose=FALSE) #,definemode=FALSE)
ncatt_put(ncout,"lat","axis","Y")
ncatt_put(ncout,"time","axis","T")

# add global attributes
ncatt_put(ncout,0,"title",title$value)
ncatt_put(ncout,0,"institution",institution$value)
ncatt_put(ncout,0,"source",datasource$value)
ncatt_put(ncout,0,"references",references$value)
history <- paste("P.J. Bartlein", date(), sep=", ")
ncatt_put(ncout,0,"history",history)
ncatt_put(ncout,0,"Conventions",Conventions$value)

# close the file, writing data to disk
nc_close(ncout)


###
library(ncdf4)
library(raster)
setwd("F:/SDM_paper/maxent/Maxent_run/projections/m01")
list.files()

a=raster("t_0_m.asc")
summary(a)
proj4string(a)
a
aa=as.matrix(a)
dim(aa)
arrayy=array(aa,dim=c(637, 638))

##### two dimensions

a=raster("t_0_m.asc")
b=as.matrix(a)
r=as.vector(a)
c=as.vector(t(b)) ###gotta get it across and then down, instead of vice versa (transpose)
r=rasterToPoints(a,spatial=T)


#####tricky coordinates...netcdf uses cell center, raster and ascii use cell corner
lon=ncdim_def('longitude', 'degrees_east', seq(-75.99841309, -69.00012207,by=0.010986328125))
lat=ncdim_def('latitude', 'degrees_north', seq(41.99524689, 35.00794220,by=-0.010986328125))
temp=ncvar_def("temperature","degrees_celcius",list(lon,lat),-9999,prec="float")
nc=nc_create("T.nc",list(temp))
ncvar_put(nc,temp,c)

###adding global attributes
ncatt_put(nc,0,"title","Heather made it",prec="text")
ncatt_put(nc,0,"institution","J.J. Howard Marine Lab",prec="text")
ncatt_put(nc,0,"source","Hycom GBU",prec="text")

#how to end each netcdf creation
nc_close(nc)

nc_open(paste(getwd(),"/T.nc",sep=""))
print(nc)
long=ncvar_get(nc,"longitude")
latt=ncvar_get(nc,"latitude")
lonlat=expand.grid(long,latt)
length(lonlat)
dname="temperature"
tmp.array=ncvar_get(nc,dname)
tmp.vec=as.vector(tmp.array)
df=data.frame(cbind(lonlat,tmp.vec))
head(df)
library(sp)
library(rgdal)
coordinates(df)=~Var1+Var2
gridded(df) = TRUE
r=raster(df)
projection(r) = CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")
plot(r)


######### three dimensions

library(ncdf4)
library(raster)
setwd("F:/SDM_paper/maxent/Maxent_run/projections/m01")
list.files()

a=raster("t_0_m.asc")
b=raster("t_1_m.asc")
c=raster("t_2_m.asc")

setwd("F:/trial/netcdfs")
d=as.vector(t(a))
e=as.vector(t(b))
f=as.vector(t(c))
#g=c(d,e,f)
q=brick(a,b,c)
r=as.vector(q)
#s=as.matrix(q)

lon=ncdim_def('longitude', 'degrees_east', seq(-75.99841309, -69.00012207,by=0.010986328125))
lat=ncdim_def('latitude', 'degrees_north', seq(41.99524689, 35.00794220,by=-0.010986328125))
time=ncdim_def('Time','month',1:3)
temp=ncvar_def("temperature","degrees_celcius",list(lon,lat,time),-9999,prec="float")

nc=nc_create("T3.nc",list(temp))
ncvar_put(nc,temp,r)

nc_close(nc)
nc_open(paste(getwd(),"/T3.nc",sep=""))
print(nc)

aa=ncvar_get(nc,varid="temperature",)


long=ncvar_get(nc,"longitude")
latt=ncvar_get(nc,"latitude")
tim=ncvar_get(nc,"Time")
lonlat=expand.grid(long,latt)
length(lonlat)
dname="temperature"
tmp.array=ncvar_get(nc,dname)
tmp.vec=as.vector(tmp.array)
df=data.frame(cbind(lonlat,tmp.vec))
head(df)
df1=df[df$Var3==1,]
df2=df1[,2]
library(sp)
library(rgdal)
coordinates(df2)=~Var1+Var2
gridded(df2) = TRUE
r=raster(df2)
projection(r) = CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")
plot(r)
