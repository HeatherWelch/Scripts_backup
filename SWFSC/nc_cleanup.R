## fix rotation error
years=as.character(seq(from=as.Date("2015-01-01"),to=as.Date("2015-07-31"),by="day"))
output_dir="/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite"

### attempt to rotate, failed
for(year in years){
  print(year)
  path=paste0(output_dir,"/",year)
  for(ras in list.files(path,pattern = "*.grd$")){
    a=raster(ras)
    if(xmin(a)>0){
      print(ras)
      ras1=gsub(".grd","",ras)
      file.remove(ras1)
      b=rotate(a)
      writeRaster(b,paste0(path,"/",ras1),overwrite=TRUE)
    }
  }
}

## checking to make sure file rotation worked
setwd("/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite/2015-08-01")

  for(ras in list.files(path,pattern = "*.grd$")){
    a=raster(ras)
    assign(ras,a)
    if(xmin(a)>0){
      print(ras)
      # ras1=gsub(".grd","",ras)
      # file.remove(ras1)
      # b=rotate(a)
      # writeRaster(b,paste0(path,"/",ras1),overwrite=TRUE)
    }
  }
}

#### rename 2012 sla to match 2015 nd rest of dates
years=as.character(seq(from=as.Date("2012-08-01"),to=as.Date("2012-12-31"),by="day"))
for(year in years){
  print(year)
  path=paste0(output_dir,"/",year)
  file.rename(paste0(path,"/sla_mean.grd"),paste0(path,"/sla.grd"))
  file.rename(paste0(path,"/sla_mean.gri"),paste0(path,"/sla.gri"))
  }
}

###### sst 2015, will copy onto real netcdf file

library(chron)
library(sp)
library(rgdal)
library(raster)
library(ncdf4)

template=raster() ##create template for resampling
res(template)=0.2487562
ncol(template)=201
nrow(template)=201
xmin(template)=-149.875
xmax(template)=-99.875
ymin(template)=10.125
ymax(template)=60.125
projection(template)="+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

# template_sst=raster() ##create template for resampling
# res(template)=0.01
# #ncol(template)=201
# #nrow(template)=201
# xmin(template)=-150
# xmax(template)=-99.875
# ymin(template)=9.875
# ymax(template)=60.125
# projection(template)="+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"


###################################################################### 2015

netcdf_dir="/Volumes/SeaGate/ERD_DOM/ncdf";setwd(netcdf_dir) #2012
#netcdf_dir="/Volumes/SeaGate/ERD_DOM/ncdf_2015";setwd(netcdf_dir) #2015
output_dir="/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite"

years=as.character(seq(from=as.Date("2015-01-01"),to=as.Date("2015-07-31"),by="day"))

##sst
netcdf=list.files(pattern="jplL4AvhrrOIv1fv2_2012") #2012
#netcdf=list.files(pattern="*jplG1SST*")#names of netcdffiles #2015
# netcdf=unlist(lapply(years,function(x)gsub("2016","larger_jplG1SST_2016",x)))
# templateSST=raster(paste(netcdf[1],".nc",sep=""))
template_native=raster(netcdf[1])

for(nc in netcdf){
  print(nc)
  #ncc=paste(nc,".nc",sep="")
  ncc=nc
  ncin <- nc_open(ncc)
  print(ncin)
  #dname="SST" # define variable of interest ########### change for each variable #2015
  dname="analysed_sst"
  print("defining variables")
  lon <- ncvar_get(ncin, "longitude") # define longitude
  nlon <- dim(lon)
  lat <- ncvar_get(ncin, "latitude", verbose = F) # define latitude
  nlat <- dim(lat)
  t <- ncvar_get(ncin, "time") # define time field
  tunits <- ncatt_get(ncin, "time", "units") # get time units
  nt <- dim(t)
  tmp.array <- ncvar_get(ncin, dname)
  dlname <- ncatt_get(ncin, dname, "long_name") #grab global attributes
  dunits <- ncatt_get(ncin, dname, "units") #grab global attributes
  fillvalue <- ncatt_get(ncin, dname, "_FillValue") #grab global attributes
  print("changing date format")
  tustr <- strsplit(tunits$value, " ") #changing date format
  tdstr <- strsplit(unlist(tustr)[3], "-") #changing date format
  tmonth = as.integer(unlist(tdstr)[2]) #changing date format
  tday = as.integer(unlist(tdstr)[3]) #changing date format ## block out for chla
  tday=as.integer(gsub("T00:00:00Z","",unlist(tdstr)[3]))
  tyear = as.integer(unlist(tdstr)[1]) #changing date format
  #date <- as.POSIXlt(t,origin='1970-01-01',tz= "UTC") ## unix time only ## block out for chla
  #date=chron(t, origin = c(tmonth, tday, tyear)) #changing date format, julian day only
  tmp.array[tmp.array==fillvalue$value]=NA #setting fill value
  tmp.vec.long <- as.vector(tmp.array)
  length(tmp.vec.long)
  tmp.mat <- matrix(tmp.vec.long, nrow = nlon * nlat, ncol = nt)
  print("Formatting column names")
  #date2=as.character(chron(t, origin = c(tmonth, tday, tyear))) ####getting names together
  date1=as.character(as.POSIXlt(t,origin='1970-01-01',tz= "UTC"))
  #date0=lapply(date1,function(x)(gsub(" 09:00:00","",x))) ##wind only
  #date2=unlist(date0) ##wind only
  # d=lapply(date2,function(x)strsplit(x, " ")) ## block out for chla
  # e=lapply(d,function(x)strsplit(unlist(x)[1], "/")) ## block out for chla
  # f=lapply(e,function(x)unlist(x)[c(1,2,3)]) ## block out for chla
  # g=lapply(f,function(x)paste(x[1],x[2],x[3],sep="-")) ## block out for chla
  # h=lapply(g,function(x)gsub("\\(","m",x)) ## block out for chla
  print("Creating spatial dataframe")
  lonlat <- expand.grid(lon, lat)
  names(lonlat) <- c("lon","lat")
  tmp.df02 <- data.frame(tmp.mat)
  #names(tmp.df02) <- h ## block out for chla
  names(tmp.df02) <- date1
  #names(tmp.df02) <- date2
  tmp.df02 <- cbind(lonlat, tmp.df02)
  coordinates(tmp.df02)=~lon+lat
  print("converting to raster")
  for(n in names(tmp.df02)){
    path=paste(output_dir,"/",n,"/analysed_sst.grd",sep="")
    if(file.exists(path)==FALSE){
      #r=rasterFromXYZ(tmp.df02[,n])
      r=rasterize(tmp.df02,template_native,field=n,fun=mean) # points to raster 
      rsd=focal(r, w=matrix(1,nrow=7,ncol=7), fun=sd,na.rm=TRUE)
      sst=raster::resample(r, template, method="bilinear")
      sst_sd=raster::resample(rsd, template, method="bilinear")
      print(paste(output_dir,"/",n,"/","analysed_sst",sep=""))
      writeRaster(sst,paste(output_dir,"/",n,"/","analysed_sst",sep=""),overwrite=TRUE)
      print(paste(output_dir,"/",n,"/","analysed_sst_sd",sep=""))
      writeRaster(sst_sd,paste(output_dir,"/",n,"/","analysed_sst_sd",sep=""),overwrite=TRUE)
    }
  }
}
