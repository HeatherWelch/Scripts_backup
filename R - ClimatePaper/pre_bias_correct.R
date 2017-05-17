####preparing rasters for climate paper

setwd("F:/Climate_paper/hycom")

variables=c("BS","BT","SSH","SSS","SST")

###################### read in rasters
library(raster)
library(tools)
for(ras in list.files(pattern="*.img$",full.names=FALSE,recursive = TRUE)){
  no_extention=file_path_sans_ext(ras)
  print(no_extention)
  file=raster(ras)
  assign(no_extention,file)
}
##########re-naming rasters
################## re-name rasters (SST/1day/water_temp/Monthly_Climatology/Depth_0000m/)
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("SST/1day/water_temp/Monthly_Climatology/Depth_0000m/",i)==TRUE){
    dat=get(i)
    name=gsub("SST/1day/water_temp/Monthly_Climatology/Depth_0000m/","",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="SST/1day/water_temp/Monthly_Climatology/Depth_0000m/*"))

################## re-name rasters (SST/1day/water_temp/Monthly_Climatology/Depth_0000m/)
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("SSH/1day/surf_el/Monthly_Climatology/",i)==TRUE){
    dat=get(i)
    name=gsub("SSH/1day/surf_el/Monthly_Climatology/","",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="SSH/1day/surf_el/Monthly_Climatology/*"))

################## re-name rasters (BS/1day/salinity/Monthly_Climatology/Depth_20000m/)
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("BS/1day/salinity/Monthly_Climatology/Depth_20000m/",i)==TRUE){
    dat=get(i)
    name=gsub("BS/1day/salinity/Monthly_Climatology/Depth_20000m/","",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="BS/1day/salinity/Monthly_Climatology/Depth_20000m/*"))
ls()

################## re-name rasters (SSS/1day/salinity/Monthly_Climatology/Depth_0000m/)
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("SSS/1day/salinity/Monthly_Climatology/Depth_0000m/",i)==TRUE){
    dat=get(i)
    name=gsub("SSS/1day/salinity/Monthly_Climatology/Depth_0000m/","",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="SSS/1day/salinity/Monthly_Climatology/Depth_0000m/*"))
ls()

################## re-name rasters
rm(list=ls(pattern="scrap/*"))
ls()

################## re-name rasters BT/
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("BT/",i)==TRUE){
    dat=get(i)
    name=gsub("BT/","",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="BT/*"))
ls()

################## re-name rasters salinity_0000m_
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("salinity_0000m_",i)==TRUE){
    dat=get(i)
    name=gsub("salinity_0000m_","SS",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="salinity_0000m_*"))
ls()

################## re-name rasters ssmonth
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("SSmonth",i)==TRUE){
    dat=get(i)
    name=gsub("SSmonth","SS_month",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="SSmonth*"))
ls()

################## re-name rasters salinity_20000m
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("salinity_20000m",i)==TRUE){
    dat=get(i)
    name=gsub("salinity_20000m","bs_",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="salinity_20000m*"))
ls()

################## re-name rasters surf_el_
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("surf_el_",i)==TRUE){
    dat=get(i)
    name=gsub("surf_el_","sh_",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="surf_el_*"))
ls()

################## re-name rasters water_temp_0000m_
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("water_temp_0000m_",i)==TRUE){
    dat=get(i)
    name=gsub("water_temp_0000m_","st_",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="water_temp_0000m_*"))
ls()

################## re-name rasters water_temp_20000m_
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("water_temp_20000m_",i)==TRUE){
    dat=get(i)
    name=gsub("water_temp_20000m_","bt_",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="water_temp_20000m_*"))
ls()

################## re-name rasters _mean
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("_mean",i)==TRUE){
    dat=get(i)
    name=gsub("_mean","_pp",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="*_mean"))
ls()

################## re-name rasters bs__m
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("bs__m",i)==TRUE){
    dat=get(i)
    name=gsub("bs__m","bs_m",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="bs__m*"))
ls()

################## re-name rasters month
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("month",i)==TRUE){
    dat=get(i)
    name=gsub("month","m",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="month*"))
ls()

#########writing out renamed but otherwise unchanged rasters
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){
  dat=get(i)
  name=paste(getwd(),"/renamed/",i,sep="")
  writeRaster(dat,name,format="GTiff",bylayer=TRUE)
}

########## 2. clipping by extent
###read in extent
library(rgdal)
shape=readOGR(dsn="F:/Climate_paper/species_data/study_area",layer="study_area")
plot(sh_m01_pp)
plot(shape,add=TRUE)

for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){
  dat=get(i)
  clip=crop(dat,shape)
  assign(i,clip)
}

for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){
  dat=get(i)
  name=paste(getwd(),"/clipped/",i,sep="")
  writeRaster(dat,name,format="GTiff",bylayer=TRUE)
}

##########aviso SSH
setwd("F:/Climate_paper/AVISO/Global/DT all sat/MADT_h/Monthly_Climatology")
library(raster)
library(tools)
for(ras in list.files(pattern="*.img$",full.names=FALSE)){
  no_extention=file_path_sans_ext(ras)
  print(no_extention)
  file=raster(ras)
  assign(no_extention,file)
}
##### rename
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("month",i)==TRUE){
    dat=get(i)
    name=gsub("month","m",i)
    assign(name,dat)
  }
} 
rm(list=ls(pattern="month*"))
ls()

#########writing out renamed but otherwise unchanged rasters
setwd("F:/Climate_paper/AVISO/renamed/")
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){
  dat=get(i)
  name=paste(getwd(),"/",i,sep="")
  writeRaster(dat,name,format="GTiff",bylayer=TRUE)
}

#### 3. making sure pixels allign
#(http://www.inside-r.org/packages/cran/raster/docs/resample)
##not doing this now because they should all be fine because all hycom
