################ CM2.6.R adapted to batch all netcdfs
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

netcdf_dir="/Volumes/SeaGate/ERD_DOM/ncdf_2015";setwd(netcdf_dir)
output_dir="/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite"

years=as.character(seq(from=as.Date("2015-01-01"),to=as.Date("2015-07-31"),by="day"))

# wind
netcdf=list.files(pattern="*ncdcOwDly*")#names of netcdffiles
# netcdf=unlist(lapply(years,function(x)gsub("2016","larger_jplG1SST_2016",x)))
# templateSST=raster(paste(netcdf[1],".nc",sep=""))
template_native=raster(netcdf[1])

for(nc in netcdf){
  print(nc)
  #ncc=paste(nc,".nc",sep="")
  ncc=nc
  ncin <- nc_open(ncc)
  print(ncin)
  dname="v" # define variable of interest ########### change for each variable
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
  date0=lapply(date1,function(x)(gsub(" 09:00:00","",x))) ##wind only
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
  names(tmp.df02) <- date0
  #names(tmp.df02) <- date2
  tmp.df02 <- cbind(lonlat, tmp.df02)
  coordinates(tmp.df02)=~lon+lat
  print("converting to raster")
  for(n in names(tmp.df02)){
    path=paste(output_dir,"/",n,"/ywind.grd",sep="")
    if(file.exists(path)==FALSE){
    #r=rasterFromXYZ(tmp.df02[,n])
    r=rasterize(tmp.df02,template_native,field=n,fun=mean) # points to raster 
    #x=raster::resample(r,study_area,method="ngb") # origin and resolution to match study area
    #e=mask(x,study_area) #clip to study area
    wind=raster::resample(r, template, method="bilinear")
    print(paste(output_dir,"/",n,"/ywind",sep=""))
    writeRaster(wind,paste(output_dir,"/",n,"/ywind",sep=""),overwrite=TRUE)
  }
  }
}

# EKE
netcdf=list.files(pattern="*msla-uv*")#names of netcdffiles
template_native=raster(netcdf[1])

#### v
for(nc in netcdf){
  print(nc)
  ncc=nc
  ncin <- nc_open(ncc)
  print(ncin)
  dname="v" # define variable of interest ########### change for each variable
  print("defining variables")
  lon <- ncvar_get(ncin, "lon") # define longitude
  nlon <- dim(lon)
  lat <- ncvar_get(ncin, "lat", verbose = F) # define latitude
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
  tmp.array[tmp.array==fillvalue$value]=NA #setting fill value
  tmp.vec.long <- as.vector(tmp.array)
  length(tmp.vec.long)
  tmp.mat <- matrix(tmp.vec.long, nrow = nlon * nlat, ncol = nt)
  print("Formatting column names")
  date2=as.character(chron(t, origin = c(tmonth, tday, tyear))) ####getting names together
  a=unlist(lapply(date2,function(x)as.character(as.Date(x,format="%m/%d/%y"))))
  print("Creating spatial dataframe")
  lonlat <- expand.grid(lon, lat)
  names(lonlat) <- c("lon","lat")
  tmp.df02 <- data.frame(tmp.mat)
  #names(tmp.df02) <- h ## block out for chla
  names(tmp.df02) <- a
  #names(tmp.df02) <- date2
  tmp.df02 <- cbind(lonlat, tmp.df02)
  coordinates(tmp.df02)=~lon+lat
  print("converting to raster")
  for(n in names(tmp.df02)){
    path=paste(output_dir,"/",n,"/l.eke_mean.grd",sep="")
    if(file.exists(path)==FALSE){
      r=rasterize(tmp.df02,template_native,field=n,fun=mean) # points to raster 
      name=paste("v_",n,sep="")
      print(name)
      assign(name,r)
    }
  }
}

#### u
for(nc in netcdf){
  print(nc)
  ncc=nc
  ncin <- nc_open(ncc)
  print(ncin)
  dname="u" # define variable of interest ########### change for each variable
  print("defining variables")
  lon <- ncvar_get(ncin, "lon") # define longitude
  nlon <- dim(lon)
  lat <- ncvar_get(ncin, "lat", verbose = F) # define latitude
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
  tmp.array[tmp.array==fillvalue$value]=NA #setting fill value
  tmp.vec.long <- as.vector(tmp.array)
  length(tmp.vec.long)
  tmp.mat <- matrix(tmp.vec.long, nrow = nlon * nlat, ncol = nt)
  print("Formatting column names")
  date2=as.character(chron(t, origin = c(tmonth, tday, tyear))) ####getting names together
  a=unlist(lapply(date2,function(x)as.character(as.Date(x,format="%m/%d/%y"))))
  print("Creating spatial dataframe")
  lonlat <- expand.grid(lon, lat)
  names(lonlat) <- c("lon","lat")
  tmp.df02 <- data.frame(tmp.mat)
  #names(tmp.df02) <- h ## block out for chla
  names(tmp.df02) <- a
  #names(tmp.df02) <- date2
  tmp.df02 <- cbind(lonlat, tmp.df02)
  coordinates(tmp.df02)=~lon+lat
  print("converting to raster")
  for(n in names(tmp.df02)){
    path=paste(output_dir,"/",n,"/l.eke_mean.grd",sep="")
    if(file.exists(path)==FALSE){
      r=rasterize(tmp.df02,template_native,field=n,fun=mean) # points to raster 
      name=paste("u_",n,sep="")
      print(name)
      assign(name,r)
    }
  }
}



### l.eke
years=as.character(seq(from=as.Date("2015-01-01"),to=as.Date("2015-07-31"),by="day"))
for(eco_year in years){
  print(eco_year)
  u_ras=get(paste("u_",eco_year,sep=""))
  u_ras=raster::resample(u_ras, template, method="bilinear")
  v_ras=get(paste("v_",eco_year,sep=""))
  v_ras=raster::resample(v_ras, template, method="bilinear")
  eke<-1/2*(u_ras^2+v_ras^2)
  l.eke <- log(eke + 0.001)
  print(paste(output_dir,"/",eco_year,"/l.eke_mean",sep=""))
  writeRaster(l.eke,paste(output_dir,"/",eco_year,"/l.eke_mean",sep=""),overwrite=TRUE)
}

# SLA
netcdf=list.files(pattern="*msla_h*")#names of netcdffiles
template_native=raster(netcdf[1])

for(nc in netcdf){
  print(nc)
  ncc=nc
  ncin <- nc_open(ncc)
  print(ncin)
  dname="sla" # define variable of interest ########### change for each variable
  print("defining variables")
  lon <- ncvar_get(ncin, "lon") # define longitude
  nlon <- dim(lon)
  lat <- ncvar_get(ncin, "lat", verbose = F) # define latitude
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
  tmp.array[tmp.array==fillvalue$value]=NA #setting fill value
  tmp.vec.long <- as.vector(tmp.array)
  length(tmp.vec.long)
  tmp.mat <- matrix(tmp.vec.long, nrow = nlon * nlat, ncol = nt)
  print("Formatting column names")
  date2=as.character(chron(t, origin = c(tmonth, tday, tyear))) ####getting names together
  a=unlist(lapply(date2,function(x)as.character(as.Date(x,format="%m/%d/%y"))))
  print("Creating spatial dataframe")
  lonlat <- expand.grid(lon, lat)
  names(lonlat) <- c("lon","lat")
  tmp.df02 <- data.frame(tmp.mat)
  #names(tmp.df02) <- h ## block out for chla
  names(tmp.df02) <- a
  #names(tmp.df02) <- date2
  tmp.df02 <- cbind(lonlat, tmp.df02)
  coordinates(tmp.df02)=~lon+lat
  print("converting to raster")
  for(n in names(tmp.df02)){
    path=paste(output_dir,"/",n,"/sla.grd",sep="")
    if(file.exists(path)==FALSE){
      r=rasterize(tmp.df02,template_native,field=n,fun=mean)
      sla_ras=raster::resample(r, template, method="bilinear")# points to raster 
      rsd=focal(sla_ras, w=matrix(1,nrow=7,ncol=7), fun=sd,na.rm=TRUE)
      writeRaster(sla_ras,paste(output_dir,"/",n,"/sla",sep=""),overwrite=TRUE)
      writeRaster(rsd,paste(output_dir,"/",n,"/sla_sd",sep=""),overwrite=TRUE)
    }
  }
}


### chla
#years=as.character(seq(from=as.Date("2016-01-01"),to=as.Date("2016-12-30"),by="day"))
years=as.character(seq(from=as.Date("2016-08-06"),to=as.Date("2016-12-30"),by="day")) ##missing 2016-08-05
for(eco_year in years){
  print(eco_year)
  # a=strsplit(eco_year,"-")
  # b=unlist(a)
  # c=paste(b[2],b[3],b[1],sep="-")
  # netcdf_year=gsub("-2016","-16",c)
  # print(netcdf_year)
  modis_ras=get(paste("chlorophyll_",eco_year,sep=""))
  #modis_ras=raster::resample(rotate(modis_ras), template, method="bilinear")
  viirs_ras=get(paste("chlaVIIR_",eco_year," 12:00:00",sep=""))
  #viirs_ras=raster::resample(rotate(viirs_ras), template, method="bilinear")
  blend=raster::cover(modis_ras,viirs_ras)
  r=log(blend+0.001)
  print(paste(output_dir,"/",eco_year,"/l.blendChl",sep=""))
  writeRaster(r,paste(output_dir,"/",eco_year,"/l.blendChl",sep=""),overwrite=TRUE)
  
}

modis=raster::resample(`modis_2016-12-31`,template, method="bilinear")
viirs=raster::resample(`viirs_2016-12-31 12:00:00`,template, method="bilinear")
blend=raster::cover(modis,viirs)
r=log(blend+0.001)
writeRaster(r,paste(output_dir,"/2016-12-31/l.blendChl",sep=""),overwrite=TRUE)


#sst
years=as.character(seq(from=as.Date("2016-07-23"),to=as.Date("2016-08-04"),by="day"))

for(eco_year in years){
  print(eco_year)
  r=get(paste("sst_",eco_year,sep=""))
  rsd=focal(r, w=matrix(1,nrow=7,ncol=7), fun=sd,na.rm=TRUE)
  sst=raster::resample(r, template, method="bilinear")
  sst_sd=raster::resample(rsd, template, method="bilinear")
  print(paste(output_dir,"/",eco_year,"/","analysed_sst",sep=""))
  writeRaster(sst,paste(output_dir,"/",eco_year,"/","analysed_sst",sep=""),overwrite=TRUE)
  print(paste(output_dir,"/",eco_year,"/","analysed_sst_sd",sep=""))
  writeRaster(sst_sd,paste(output_dir,"/",eco_year,"/","analysed_sst_sd",sep=""),overwrite=TRUE)
}





###################################################################### 2016

#study_area=raster("/Volumes/SDM /Lacie backup October 2016/Lacie share/Climate_paper/AVISO/extrct_ras")
netcdf_dir="/Volumes/SeaGate/ERD_DOM/ncdf_2016";setwd(netcdf_dir)
netcdfs=list.files(pattern="*.nc$")#names of netcdffiles
output_dir="/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite"

# u, v, sla
# dataset-duacs-dt-global-allsat-msla-uv_1483554002897, dataset-duacs-nrt-over30d-global-allsat-msla-uv_1483554150931, dataset-duacs-nrt-global-merged-allsat-msla-l4_1483553671484
nc="erdMBchla8day_LonPM180_a3c9_4039_7296.nc"   ###########clunky, change for each variable
#netcdf=list.files(pattern="nrt_global_allsat_msla_h_20161231*")

years=as.character(seq(from=as.Date("2016-07-23"),to=as.Date("2016-08-04"),by="day"))
years=list(years,c("2016-12-31","2016-08-30","2016-01-26","2016-01-12"))
#years=unlist(years)
netcdf=unlist(lapply(years,function(x)gsub("2016","larger_jplG1SST_2016",x)))

templateSST=raster(paste(netcdf[1],".nc",sep=""))
#template=raster(netcdf[1])
for(nc in netcdf){
  print(nc)
  ncc=paste(nc,".nc",sep="")
  ncin <- nc_open(ncc)
  print(ncin)
  dname="chlorophyll" # define variable of interest ########### change for each variable
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
    #r=rasterFromXYZ(tmp.df02[,n])
    r=rasterize(tmp.df02,templateSST,field=n,fun=mean) # points to raster 
    #x=raster::resample(r,study_area,method="ngb") # origin and resolution to match study area
    #e=mask(x,study_area) #clip to study area
    name=paste("sst_",n,sep="")
    print(name)
    assign(name,r)
    # rsd=focal(r, w=matrix(1,nrow=7,ncol=7), fun=sd,na.rm=TRUE)
    # sst=raster::resample(r, template, method="bilinear")
    # sst_sd=raster::resample(rsd, template, method="bilinear")
    # writeRaster(sst,paste(output_dir,"/",n,"/","analysed_sst",sep=""),overwrite=TRUE)
    # writeRaster(sst_sd,paste(output_dir,"/",n,"/","analysed_sst_sd",sep=""),overwrite=TRUE)
  }
}

### l.eke
  #years=as.character(seq(from=as.Date("2016-01-01"),to=as.Date("2016-12-04"),by="day"))
years=as.character(seq(from=as.Date("2016-12-05"),to=as.Date("2016-12-31"),by="day"))
for(eco_year in years){
  print(eco_year)
  a=strsplit(eco_year,"-")
  b=unlist(a)
  #c=paste(b[2],b[3],b[1],sep="-")
  c=paste(b[2],b[3],b[1],sep="/")
  #netcdf_year=gsub("-2016","-16",c)
  netcdf_year=gsub("/2016","/16",c)
  print(netcdf_year)
  u_ras=get(paste("u_",netcdf_year,sep=""))
  u_ras=raster::resample(rotate(u_ras), template, method="bilinear")
  v_ras=get(paste("v_",netcdf_year,sep=""))
  v_ras=raster::resample(rotate(v_ras), template, method="bilinear")
  eke<-1/2*(u_ras^2+v_ras^2)
  l.eke <- log(eke + 0.001)
  print(paste(output_dir,"/",eco_year,"/l.eke_mean",sep=""))
  writeRaster(l.eke,paste(output_dir,"/",eco_year,"/l.eke_mean",sep=""),overwrite=TRUE)
 
}
  
  ### sla
  years=as.character(seq(from=as.Date("2016-01-01"),to=as.Date("2016-12-30"),by="day"))
  for(eco_year in years){
    print(eco_year)
    a=strsplit(eco_year,"-")
    b=unlist(a)
    c=paste(b[2],b[3],b[1],sep="-")
    netcdf_year=gsub("-2016","-16",c)
    print(netcdf_year)
    sla_ras=get(paste("sla_",netcdf_year,sep=""))
    sla_ras=raster::resample(rotate(sla_ras), template, method="bilinear")
    rsd=focal(sla_ras, w=matrix(1,nrow=7,ncol=7), fun=sd,na.rm=TRUE)
    print(paste(output_dir,"/",eco_year,"/sla",sep=""))
    writeRaster(sla_ras,paste(output_dir,"/",eco_year,"/sla",sep=""),overwrite=TRUE)
    writeRaster(rsd,paste(output_dir,"/",eco_year,"/sla_sd",sep=""),overwrite=TRUE)
    
  }
  
  sla_ras=raster::resample(rotate(`h_12/31/16`), template, method="bilinear")
  rsd=focal(sla_ras, w=matrix(1,nrow=7,ncol=7), fun=sd,na.rm=TRUE)
  print(paste(output_dir,"/2016-12-31/sla",sep=""))
  writeRaster(sla_ras,paste(output_dir,"/2016-12-31/sla",sep=""),overwrite=TRUE)
  writeRaster(rsd,paste(output_dir,"/2016-12-31/sla_sd",sep=""),overwrite=TRUE)
  
  
  ### chla
  #years=as.character(seq(from=as.Date("2016-01-01"),to=as.Date("2016-12-30"),by="day"))
  years=as.character(seq(from=as.Date("2016-08-06"),to=as.Date("2016-12-30"),by="day")) ##missing 2016-08-05
  for(eco_year in years){
    print(eco_year)
    # a=strsplit(eco_year,"-")
    # b=unlist(a)
    # c=paste(b[2],b[3],b[1],sep="-")
    # netcdf_year=gsub("-2016","-16",c)
    # print(netcdf_year)
    modis_ras=get(paste("chlorophyll_",eco_year,sep=""))
    #modis_ras=raster::resample(rotate(modis_ras), template, method="bilinear")
    viirs_ras=get(paste("chlaVIIR_",eco_year," 12:00:00",sep=""))
    #viirs_ras=raster::resample(rotate(viirs_ras), template, method="bilinear")
    blend=raster::cover(modis_ras,viirs_ras)
    r=log(blend+0.001)
    print(paste(output_dir,"/",eco_year,"/l.blendChl",sep=""))
    writeRaster(r,paste(output_dir,"/",eco_year,"/l.blendChl",sep=""),overwrite=TRUE)
    
  }
  
  modis=raster::resample(`modis_2016-12-31`,template, method="bilinear")
  viirs=raster::resample(`viirs_2016-12-31 12:00:00`,template, method="bilinear")
  blend=raster::cover(modis,viirs)
  r=log(blend+0.001)
  writeRaster(r,paste(output_dir,"/2016-12-31/l.blendChl",sep=""),overwrite=TRUE)
  
  
  ### ywind
  years=as.character(seq(from=as.Date("2016-01-01"),to=as.Date("2016-12-30"),by="day"))
  for(eco_year in years){
    print(eco_year)
    # a=strsplit(eco_year,"-")
    # b=unlist(a)
    # c=paste(b[2],b[3],b[1],sep="-")
    # netcdf_year=gsub("-2016","-16",c)
    # print(netcdf_year)
    wind=get(paste("ywind_",eco_year,sep=""))
    wind=raster::resample(wind, template, method="bilinear")
    print(paste(output_dir,"/",eco_year,"/ywind",sep=""))
    writeRaster(wind,paste(output_dir,"/",eco_year,"/ywind",sep=""),overwrite=TRUE)
    
    writeRaster(wind,paste(output_dir,"/2016-12-31/ywind",sep=""),overwrite=TRUE)

    
  }
  
  
  #sst
  years=as.character(seq(from=as.Date("2016-07-23"),to=as.Date("2016-08-04"),by="day"))
  
  for(eco_year in years){
    print(eco_year)
    r=get(paste("sst_",eco_year,sep=""))
    rsd=focal(r, w=matrix(1,nrow=7,ncol=7), fun=sd,na.rm=TRUE)
    sst=raster::resample(r, template, method="bilinear")
    sst_sd=raster::resample(rsd, template, method="bilinear")
    print(paste(output_dir,"/",eco_year,"/","analysed_sst",sep=""))
    writeRaster(sst,paste(output_dir,"/",eco_year,"/","analysed_sst",sep=""),overwrite=TRUE)
    print(paste(output_dir,"/",eco_year,"/","analysed_sst_sd",sep=""))
    writeRaster(sst_sd,paste(output_dir,"/",eco_year,"/","analysed_sst_sd",sep=""),overwrite=TRUE)
  }