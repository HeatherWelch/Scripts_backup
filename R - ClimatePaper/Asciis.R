###script to import asciis into r and add coordinate info, set names to common format, etc

setwd("F:/Climate_paper/climate_data/raw_asciis")

library(raster)
library(tools)
library(rgdal)
library(devtools)
library(maps)
library(mapdata)
library(maptools)
library(sp)
library(ggplot2)


#library(adehabitat)

#####THESE DON"T WORK OR DO SOMETHING UNEXPECTED
# for (asc in list.files(getwd())){
#   ext_asc=paste(getwd(),"/",asc,sep="")
#   name=no_extention=file_path_sans_ext(asc)
#   grdname=paste(name,".grd",sep="")
#   ext_asc=raster(ext_asc)
#   writeRaster(ext_asc,grdname,format="raster",bylayer=TRUE,overwrite=TRUE)
# }

# for (asc in list.files(getwd())){
#   name=no_extention=file_path_sans_ext(asc)
#   layer=import.asc(asc)
#   rastr=raster(layer)
#   assign(name,raster)
# }

#####THIS ONE WORKS TO READ IN ASCIIS AND ASSIGN THEM THEIR ORIGINAL NAME
for (asc in list.files()){
  name=no_extention=file_path_sans_ext(asc)
  rastr=raster(asc)
  assign(name,rastr)
}

#####Projecting rasters
newprj="+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0"###GO W THIS PRJ
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){ ##filter objects to only get objects of class type "RasterLayer"
  dat=get(i)
  proj4string(dat)=CRS(newprj)
  assign(i,dat)
}


###renaming rasters
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){ ##filter objects to only get objects of class type "RasterLayer"
  if (grepl("SCHL",i)==TRUE){ ##if "value" in "iterative object" = TRUE
    dat=get(i) ##then grab the data behind the object
    name=gsub("SCHL","CL",i) ##replace "value" with new "value
    assign(name,dat) ##give the object it's new name
  }
}  
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("SO2",i)==TRUE){ ###repeat this for everything you want to replace
    dat=get(i)
    name=gsub("SO2","O2",i)
    assign(name,dat)
  }
}  
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("SpH",i)==TRUE){
    dat=get(i)
    name=gsub("SpH","PH",i)
    assign(name,dat)
  }
}  
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("2006_2055",i)==TRUE){
    dat=get(i)
    name=gsub("2006_2055","NF",i)
    assign(name,dat)
  }
}
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("2006_205",i)==TRUE){
    dat=get(i)
    name=gsub("2006_205","NF",i)
    assign(name,dat)
  }
}
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){ 
  if (grepl("2006_20",i)==TRUE){
    dat=get(i)
    name=gsub("2006_20","NF",i)
    assign(name,dat)
  }
}  
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("2005_205",i)==TRUE){
    dat=get(i)
    name=gsub("2005_205","NF",i)
    assign(name,dat)
  }
}
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("2050_2099",i)==TRUE){
    dat=get(i)
    name=gsub("2050_2099","FF",i)
    assign(name,dat)
  }
}  
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("2050_209",i)==TRUE){
    dat=get(i)
    name=gsub("2050_209","FF",i)
    assign(name,dat)
  }
}  
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("2050_20",i)==TRUE){
    dat=get(i)
    name=gsub("2050_20","FF",i)
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
setwd("F:/Climate_paper/climate_data/projected_rasters")
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(sorted=TRUE))){
  dat=get(i)
  writeRaster(dat,i,format="GTiff",bylayer=TRUE,overwrite=TRUE)
}


###############SOME EXTRA MISC STUFF
#Getting prj4string
summary(shp)
proj4string(shp)
projection(file)
bbox(file) #checking bounding box

#####READING IN SHAPEFILES
#myproj="+proj=utm +zone=18 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
#shp1=readOGR(dsn="E:/Latest_BOEM_Data/North Atlantic Shoreline",layer="North_Atlantic_Shoreline_NAD83UTM18")
shp=readShapeLines("E:/Latest_BOEM_Data/North Atlantic Shoreline/North_Atlantic_Shoreline_NAD83UTM18",proj4string=CRS(myproj),delete_null_obj=TRUE)
VTR=readOGR(dsn="F:/VMS/VTR",layer="Statistical_Areas_2010")

####mapping shapefiles
ggplot()+geom_line(data=shp,aes(x=long,y=lat,group=group))

####projecting_raster
new=projectRaster(SCHL_JFM_2006_20,crs=myproj)
proj4string(SCHL_AMJ_2006_20)=CRS(myproj)
newprj="+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0"###GO W THIS PRJ
proj4string(PP_AMJ_2006_2055)=CRS(newprj)

###writing out raster
writeRaster(PP_AMJ_2006_2055,"grdname",format="GTiff",bylayer=TRUE,overwrite=TRUE)

###reading in a csv to shp
read.csv(etc etc)
coordinates(data4)=~GIS_LONHB+GIS_LATHB
plot(data4)
