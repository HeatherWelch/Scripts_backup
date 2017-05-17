#####associating species records w environmental vars

##############This is just a trial, not the actual data
################### read in some trial data
###read in some species data
setwd("F:/Climate_paper/Observer_data/Cleaned")
records=read.csv("ObserverData2003.csv",header=TRUE, sep=",")

###fix the GIS_LONHB column (make it negative)
head(records)
records$GIS_LONHB=records$GIS_LONHB*-1

###read in the PP rasters
##### historical rasters
library(raster)
setwd("F:/Climate_paper/climate_data/final_layers")
for (ras in list.files(pattern="*PP")){
  path=paste(getwd(),"/",ras,sep="")
  r=raster(path)
  name=gsub(".tif","",ras)
  assign(name,r)
}


#####convert records to points
library(sp)
coordinates(records)=~GIS_LONHB+GIS_LATHB
plot(records)


##read in a known shapefile to check position
library(rgdal)
VTR=readOGR(dsn="F:/VMS/VTR",layer="Statistical_Areas_2010")
plot(VTR,add=TRUE)


###trying it
################works! for each season, extracts all relevant rasters to points and adds and new column, end produce = 4 new dataframs, 1 for each season
season=c("JFM","AMJ","JAS","OND")
variable=c("ph","pp","o2","CL","bt","bs","ss","st")
for (sea in season){
  rec=subset(records,season==sea)
  print(sea)
  for (var in variable){
    for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(pattern=var))){
      if (grepl(sea,i)==TRUE){ ##if value in iterative object
        print(i)
        dat=get(i)}
      rec[[var]]=extract(dat,rec,method="simple")
      }
    }
  assign(sea,rec)
}

#####combining them
master=rbind(JFM,AMJ,JAS,OND)

###getting rid of NAs
names(master)
mast=master[,c(1:3,5:9,11:18)]
mast@data=na.omit(mast@data)
getwd()


###writing out a shapefile as a csv
setwd("F:/Climate_paper/maxent_trial")
library(shapefiles)
write.csv(mast@data,file="records.csv")

####read it back in
mast=read.csv("records.csv",header=TRUE, sep=",")
####grab lat long from original csv
merged=merge(records,mast,all.x=FALSE,all.y=TRUE,by="Acronym")
records=merged[,c(1,3:6,8:11,20:27)]


###futher cut it down
rec=records[,c(3:5,10:17)]
head(rec)
rec$GIS_LONHB=rec$GIS_LONHB*-1 ###make it negative lat/long
###write it out to save csv w speces, lat/long, vars
write.csv(rec,file="records_xy.csv")

#### presences and absences
species=levels(rec$SCINAME.x)
####need to know which records are in unique grid cells
rec$grid=paste(rec$ss,rec$st,sep="_") ##need to select presence records from other sp that aren't in same cell

lophius=subset(rec,rec$SCINAME.x=="LOPHIUS AMERICANUS")
absence=subset(rec,rec$SCINAME.x!="LOPHIUS AMERICANUS")
###remove dublicate absences
library(dplyr)
abs=absence%>%distinct(grid)

############################extra bits and pieces of code
    
setwd("F:/Climate_paper/Observer_data/Cleaned")
records2=read.csv("ObserverData2003.csv",header=TRUE, sep=",")  
records$new=extract(ss_AMJ_PP,records,method="simple")
write.csv(records2,"sss.csv")
plot(pp_AMJ_PP)


master[complete.cases(master$ph),]
x=master[complete.cases(master[,11:18]),]
x=na.omit(master$ph)
master[!(is.na(master[,11:18])),]
mast=master[,c(1:3,5:9,11:18)]
head(mast)
mast[complete.cases(mast),]
mast@data=mast[!is.na(mast@data[,9:16]),]
mast@data=na.omit(mast@data)