####working with netcdfs
##############################script to 1. read in netcdfs, 2. convert netcdfs to raster, 3. project, 4. rename

setwd("F:/Climate_paper/climate_data/downloaded_netcdfs")
library(RNetCDF)
library(ncdf4)
library(ncdf)

####################1. read in all netcdfs, give them back their original names
###this one works but i'm having trouble workign w these files
for (nc in list.files()){
  path=paste(getwd(),"/",nc,sep="")
  netcdf=open.nc(nc)
  name=gsub(".nc","",nc)
  assign(name,netcdf)
}

####################1. read in all netcdfs, give them back their original names
######this script works better
library(ncdf4)
for (nc in list.files()){
  path=paste(getwd(),"/",nc,sep="")
  netcdf.file <- path
  netcdf = ncdf4::nc_open(netcdf.file)
  name=gsub(".nc","",nc)
  assign(name,netcdf)
}  

#################### Basic NETCDF commands
names(`intpp_AMJ_2006-2055`$var) ##get variable names
print.nc(netcdf) ###print out the netcdf file


####################2. netcdf to raster
######apparently just read netcdfs in as rasters, don't read them as netcdfs and then convert
library(raster)
for (nc in list.files()){
  path=paste(getwd(),"/",nc,sep="")
  r=raster(path,varname="anomaly")
  name=gsub(".nc","",nc)
  assign(name,r)
}


###########3. project
newprj="+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0"###GO W THIS PRJ
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){ ##filter objects to only get objects of class type "RasterLayer"
  dat=get(i)
  proj4string(dat)=CRS(newprj)
  assign(i,dat)
}

###########3. change longitude from 0-360 to -180-180
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){ ##filter objects to only get objects of class type "RasterLayer"
  dat=get(i)
  extent(dat)=extent(-86,-64,21,50)
  assign(i,dat)
}


################4. renaming rasters
#####chlorophyll a ##old=chl ##new=ch
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){ ##filter objects to only get objects of class type "RasterLayer"
  if (grepl("chl",i)==TRUE){ ##if "value" in "iterative object" = TRUE
    dat=get(i) ##then grab the data behind the object
    name=gsub("chl","CL",i) ##replace "value" with new "value
    assign(name,dat) ##give the object it's new name
  }
}  
#####sea surface temperature a ##old=tos ##new=st
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("tos",i)==TRUE){ ###repeat this for everything you want to replace
    dat=get(i)
    name=gsub("tos","st",i)
    assign(name,dat)
  }
}  
#####sea surface salinity ##old=sos ##new=ss
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("sos",i)==TRUE){
    dat=get(i)
    name=gsub("sos","ss",i)
    assign(name,dat)
  }
}  
#####primary productivity ##old=intpp ##new=pp
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("intpp",i)==TRUE){
    dat=get(i)
    name=gsub("intpp","pp",i)
    assign(name,dat)
  }
}  
#####bottom temperature ##old=temp.bot300 ##new=bt
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("temp.bot300",i)==TRUE){
    dat=get(i)
    name=gsub("temp.bot300","bt",i)
    assign(name,dat)
  }
}  
#####bottom salinity ##old=salt.bot300 ##new=bs
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("salt.bot300",i)==TRUE){
    dat=get(i)
    name=gsub("salt.bot300","bs",i)
    assign(name,dat)
  }
}
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("2006-2055",i)==TRUE){
    dat=get(i)
    name=gsub("2006-2055","NF",i)
    assign(name,dat)
  }
}
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("2050-2099",i)==TRUE){
    dat=get(i)
    name=gsub("2050-2099","FF",i)
    assign(name,dat)
  }
}  


####deleting old rasters, i.e. raster that d.n. have a length of 9
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(sorted=TRUE))){
  if (nchar(i)!=9){
    rm(list=paste(i))
  }
} 

#####writing out rasters
setwd("F:/Climate_paper/climate_data/projected_rasters_new")
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(sorted=TRUE))){
  dat=get(i)
  writeRaster(dat,i,format="GTiff",bylayer=TRUE,overwrite=TRUE)
}




#######################bits and pieces of code
##this one works
library(RNetCDF)
netcdf=open.nc("C:/Users/Heather.Welch/Downloads/myplot.1917.1459354086.78.nc")  ##step1: open downloaded netcdf
read.nc(netcdf,unpack = TRUE) ##setp2: read object that you've just opened
print.nc(netcdf)

##this one also works and allows you to read var names, which i can't figure out the other way
library(ncdf4)
netcdf.file <- "C:/Users/Heather.Welch/Downloads/tos_JFM_2050-2099.nc"
nc = ncdf4::nc_open(netcdf.file)
variables = names(nc[['var']]) ##get variable names

rast<-raster(`tos_AMJ_2006-2055`, varname="anomaly")
ras=raster(`tos_AMJ_2006-2055.nc4`)
rast<-brick(`tos_AMJ_2006-2055`, varname="anomaly")
variables = names(`tos_AMJ_2006-2055`[['var']]) ##get variable names

r=raster("F:/Climate_paper/climate_data/downloaded_netcdfs/tos_AMJ_2006-2055.nc",varname="anomaly") ###works, how to read in netcdfs