###########cleaning climate rasters

#########1. Creating the histclim variable
setwd("F:/Climate_paper/climate_data/downloaded_netcdfs")
library(RNetCDF)
library(ncdf4)
library(ncdf)
library(raster)

rm(list=ls())

####################1. read in all netcdfs as histclim rasters, give them back their original names
library(raster)
for (nc in list.files(pattern="*2099")){
  path=paste(getwd(),"/",nc,sep="")
  r=raster(path,varname="histclim")
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
  if (grepl("2050-2099",i)==TRUE){
    dat=get(i)
    name=gsub("2050-2099","PP",i)
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
setwd("F:/Climate_paper/climate_data/final_layers")
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(sorted=TRUE))){
  dat=get(i)
  writeRaster(dat,i,format="GTiff",bylayer=TRUE,overwrite=TRUE)
}

#########################################################################
####################adding anomalies and hisclim

####read in  rasters

##### historical rasters
library(raster)
setwd("F:/Climate_paper/climate_data/final_layers")
for (ras in list.files(pattern="*PP")){
  path=paste(getwd(),"/",ras,sep="")
  r=raster(path)
  name=gsub(".tif","",ras)
  assign(name,r)
}

##### NF anamolies
setwd("F:/Climate_paper/climate_data/projected_rasters_new")
for (ras in list.files(pattern="*NF")){
  path=paste(getwd(),"/",ras,sep="")
  r=raster(path)
  name=gsub(".tif","",ras)
  assign(name,r)
}

####getting the names of each var/season
X=ls(pattern="*PP") 
trial=lapply(X,function(x){gsub("_PP","",X)})
new=trial[[1]]


####another solution
# Output=NULL
# name=ls(pattern="*PP")
# 
# for (i in seq_along(name)){
#   new=gsub("_PP","",name[i])
#   tmp=assign(new,name[i])
#   Output[[i]]<-tmp
# }
# Output

#####add the rasters
setwd("F:/Climate_paper/climate_data/final_layers")
for (name in new){
  ras=Filter(function(x)inherits(get(x),"RasterLayer"),ls(pattern=name))
  for (ra in ras){
    if (grepl("NF",ra)==TRUE){
      future=get(ra)
      print(ra)
    } else if (grepl("PP",ra)==TRUE){
      present=get(ra)
      print(ra)
    }
  }
  math=sum(future,present)
  output=paste(name,"_NF",sep="")
  writeRaster(math,output,format="GTiff",bylayer=TRUE,overwrite=TRUE)
}

####now again, but with FF anomalies
##### NF anamolies
setwd("F:/Climate_paper/climate_data/projected_rasters_new")
for (ras in list.files(pattern="*FF")){
  path=paste(getwd(),"/",ras,sep="")
  r=raster(path)
  name=gsub(".tif","",ras)
  assign(name,r)
}


#####add the rasters
setwd("F:/Climate_paper/climate_data/final_layers")
for (name in new){
  ras=Filter(function(x)inherits(get(x),"RasterLayer"),ls(pattern=name))
  for (ra in ras){
    if (grepl("FF",ra)==TRUE){
      farfuture=get(ra)
      print(ra)
    } else if (grepl("PP",ra)==TRUE){
      present=get(ra)
      print(ra)
    }
    math=sum(farfuture,present)
    output=paste(name,"_FF",sep="")
    writeRaster(math,output,format="GTiff",bylayer=TRUE,overwrite=TRUE)
  }
}
