
# 1. read in points as csv
setwd("/Volumes/SeaGate/Other/Briana_Abrahms")
records=read.csv("Site_Fidelity_ARS_subsampled.csv")
rec=records
#rec$GIS_LONHB=rec$GIS_LONHB*-1 ###make it negative lat/long

# 1.1 convert points to shp
library(sp)
rec$lat_copy=rec$lat###should probably copy lat long columns and add to end in case we need them
rec$lon_copy=rec$lon###should probably copy lat long columns and add to end in case we need them

coordinates(rec)=~lon_copy+lat_copy
plot(rec)
myproj="+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" # projection of rasters
proj4string(rec)=CRS(myproj) ## project records

# 2. read in rasters

setwd("/Volumes/SeaGate/Other/Briana_Abrahms/larger_extent/aqua/monthly/4km/CHL_chlor_a/Monthly_Climatology")
setwd("/Volumes/SeaGate/Other/Briana_Abrahms/larger_extent/GLOB/JPL/MUR/analysed_sst/Monthly_Climatology")

library(raster)
for (ras in list.files(pattern="*.img$",recursive = TRUE)){
  path=paste(getwd(),"/",ras,sep="")
  r=raster(path)
  name=gsub(".tif","",ras)
  assign(name,r)
  print(ras)
}

rm(list=c("r","name","path","ras"))


# 3. extract monthly env.var values at points
#getting months in a usuable format
library(stringr)
#rec$month=str_pad(rec$month,2,pad="0") ##add leading zero to 1-9
#rec$month=as.numeric(rec$month)

#now attach points
##aqua
months=c("01","02","03","04","05","06","07","08","09","10","11","12")
#vars=c("bt","sh","st","bs","SS")
for (m in months){ # for a given month
  name1=paste("m",m,sep="")
  recm=subset(rec,month==name1)
  print(m)
  for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(pattern="aqua*"))){ # for each raster layer 
    if (grepl(m,i)==TRUE){ ##if raster is from month "m"
        print(i)
        dat=get(i)
        recm@data$Chla=extract(dat,recm,method="simple")}
      }
  name=paste("m",m,sep="")
  assign(name,recm)
}

rm(list=c("dat","v","i","m","recm","name"))

#####combining them
master_aqua=rbind(m01,m02,m03,m04,m05,m06,m07,m08,m09,m10,m11,m12)
#complete_aqua=master[complete.cases(master@data),]

#GHRSST
months=c("01","02","03","04","05","06","07","08","09","10","11","12")
#vars=c("bt","sh","st","bs","SS")
for (m in months){ # for a given month
  name1=paste("m",m,sep="")
  name2=paste("month",m,sep="")
  recm=subset(master_aqua,month==name1)
  print(m)
  for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(pattern="analysed*"))){ # for each raster layer 
    if (grepl(name2,i)==TRUE){ ##if raster is from month "m"
      print(i)
      dat=get(i)
      recm@data$GHRSST=extract(dat,recm,method="simple")}
  }
  name=paste("m",m,sep="")
  assign(name,recm)
}

#####combining them
master=rbind(m01,m02,m03,m04,m05,m06,m07,m08,m09,m10,m11,m12)
#complete_ghrsst=master[complete.cases(master@data),]

write.csv(master@data,"Site_Fidelity_ARS_subsampled_SD.csv")
