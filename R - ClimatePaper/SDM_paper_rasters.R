#####creating seasonal rasters from SMD_paper files
####common vars: SST, SSS, bottom temp, bottom sal, chl_a



setwd("F:/SDM_paper/maxent/Maxent_run/projections")

library(raster)
library(tools)
for (file in list.files(pattern=".asc$",recursive=TRUE)){ ###read in rasters of all relevant variables
  if (grepl("chl",file)==TRUE){
    name=no_extention=file_path_sans_ext(file)
    rastr=raster(file)
    assign(name,rastr)
  } else if (grepl("sal_0_",file)==TRUE){
    name=no_extention=file_path_sans_ext(file)
    rastr=raster(file)
    assign(name,rastr)
  } else if (grepl("sal_2_",file)==TRUE){
    name=no_extention=file_path_sans_ext(file)
    rastr=raster(file)
    assign(name,rastr)  
  } else if (grepl("t_0_",file)==TRUE){
    name=no_extention=file_path_sans_ext(file)
    rastr=raster(file)
    assign(name,rastr)
  } else if (grepl("t_2_",file)==TRUE){
    name=no_extention=file_path_sans_ext(file)
    rastr=raster(file)
    assign(name,rastr)
}
}  

rm(list=ls(pattern="*_sd")) ###delete all standard deviation rasters

###averaging rasters
#############build raster stacks based on months

####this works but didn't end up going down this route

# JFM=stack()
# AMJ=stack()
# JAS=stack()
# OND=stack()
# 
# 
# for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){
#   if(grepl("m01",i)==TRUE){
#     name=paste(i,".asc",sep="")
#     JFM=stack(JFM,name)
#   } else if(grepl("m02",i)==TRUE){
#     name=paste(i,".asc",sep="")
#     JFM=stack(JFM,name)
#   } else if(grepl("m03",i)==TRUE){
#     name=paste(i,".asc",sep="")
#     JFM=stack(JFM,name)
#   } else if(grepl("m04",i)==TRUE){
#     name=paste(i,".asc",sep="")
#     AMJ=stack(AMJ,name)
#   } else if(grepl("m05",i)==TRUE){
#     name=paste(i,".asc",sep="")
#     AMJ=stack(AMJ,name)
#   } else if(grepl("m06",i)==TRUE){
#     name=paste(i,".asc",sep="")
#     AMJ=stack(AMJ,name)
#   } else if(grepl("m07",i)==TRUE){
#     name=paste(i,".asc",sep="")
#     JAS=stack(JAS,name)
#   } else if(grepl("m08",i)==TRUE){
#     name=paste(i,".asc",sep="")
#     JAS=stack(JAS,name)
#   } else if(grepl("m09",i)==TRUE){
#     name=paste(i,".asc",sep="")
#     JAS=stack(JAS,name)
#   } else if(grepl("m10",i)==TRUE){
#     name=paste(i,".asc",sep="")
#     OND=stack(OND,name)
#   } else if(grepl("m11",i)==TRUE){
#     name=paste(i,".asc",sep="")
#     OND=stack(OND,name)
#   } else if(grepl("m12",i)==TRUE){
#     name=paste(i,".asc",sep="")
#     OND=stack(OND,name)
#   }
# }

#####How to average a raster stack
#r=mean(JFM,na.rm=TRUE)


#####code to average each variable into seasons

vars=c("chla","sal_0","sal_2","t_0","t_2")

for (v in vars){
  for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){
    if(grepl("m01",i)==TRUE && grepl(v,i)==TRUE){ 
      rast1=get(i)
      print(i)
    } else if(grepl("m02",i)==TRUE && grepl(v,i)==TRUE){ 
      rast2=get(i)
      print(i)
    } else if(grepl("m03",i)==TRUE && grepl(v,i)==TRUE){ 
      rast3=get(i)
      print(i)
    } else if(grepl("m04",i)==TRUE && grepl(v,i)==TRUE){ 
      rast4=get(i)
      print(i)
    } else if(grepl("m05",i)==TRUE && grepl(v,i)==TRUE){ 
      rast5=get(i)
      print(i)
    } else if(grepl("m06",i)==TRUE && grepl(v,i)==TRUE){ 
      rast6=get(i)
      print(i)
    } else if(grepl("m07",i)==TRUE && grepl(v,i)==TRUE){ 
      rast7=get(i)
      print(i)
    } else if(grepl("m08",i)==TRUE && grepl(v,i)==TRUE){ 
      rast8=get(i)
      print(i)
    } else if(grepl("m09",i)==TRUE && grepl(v,i)==TRUE){ 
      rast9=get(i)
      print(i)
    } else if(grepl("m10",i)==TRUE && grepl(v,i)==TRUE){ 
      rast10=get(i)
      print(i)
    } else if(grepl("m11",i)==TRUE && grepl(v,i)==TRUE){ 
      rast11=get(i)
      print(i)
    } else if(grepl("m12",i)==TRUE && grepl(v,i)==TRUE){ 
      rast12=get(i)
      print(i)
    }
  }
    name1=paste(v,"_JFM",sep="")
    print(name1)
    mean=overlay(rast1,rast2,rast3,fun=function(x,y,z) {(x+y+z)/3})
    assign(name1,mean)
    
    name2=paste(v,"_AMJ",sep="")
    print(name2)
    mean=overlay(rast4,rast5,rast6,fun=function(x,y,z) {(x+y+z)/3})
    assign(name2,mean)
    
    name3=paste(v,"_JAS",sep="")
    print(name3)
    mean=overlay(rast7,rast8,rast9,fun=function(x,y,z) {(x+y+z)/3})
    assign(name3,mean)
    
    name4=paste(v,"_OND",sep="")
    print(name4)
    mean=overlay(rast10,rast11,rast12,fun=function(x,y,z) {(x+y+z)/3})
    assign(name4,mean)

}  

#####writing out rasters
setwd("F:/Climate_paper/climate_data/heath_hist_proj")

season=c("JFM","AMJ","JAS","OND")

for (sea in season){
  for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(sorted=TRUE))){
    if(grepl(sea,i)==TRUE){ 
      dat=get(i)
      writeRaster(dat,i,format="GTiff",bylayer=TRUE,overwrite=TRUE)
    }
  }
}


#####adding anomalies to historical etc
rm(list=ls())


 ###read in historical rasters
setwd("F:/Climate_paper/climate_data/heath_hist_proj")
for (file in list.files()){ 
  name=no_extention=file_path_sans_ext(file)
  rastr=raster(file)
  assign(name,rastr)
}

####fix names to match ERSL convention
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){ ##filter objects to only get objects of class type "RasterLayer"
  if (grepl("chla",i)==TRUE){ #chla
    dat=get(i) ##then grab the data behind the object
    name=gsub("chla","CL",i) ##replace "value" with new "value
    assign(name,dat) ##give the object it's new name
  }
}  

for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("sal_0",i)==TRUE){ #suface sal
    dat=get(i)
    name=gsub("sal_0","ss",i)
    assign(name,dat)
  }
}  
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("sal_2",i)==TRUE){ #bottom sal
    dat=get(i)
    name=gsub("sal_2","bs",i)
    assign(name,dat)
  }
}  
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("t_0",i)==TRUE){ #surface temp
    dat=get(i)
    name=gsub("t_0","st",i)
    assign(name,dat)
  }
}  
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("t_2",i)==TRUE){ #bottom temp
    dat=get(i)
    name=gsub("t_2","bt",i)
    assign(name,dat)
  }
}  
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("JFM",i)==TRUE){
    dat=get(i)
    name=gsub("JFM","JFM_PP",i)
    assign(name,dat)
  }
}
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("AMJ",i)==TRUE){
    dat=get(i)
    name=gsub("AMJ","AMJ_PP",i)
    assign(name,dat)
  }
}
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("JAS",i)==TRUE){
    dat=get(i)
    name=gsub("JAS","JAS_PP",i)
    assign(name,dat)
  }
}
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){  
  if (grepl("OND",i)==TRUE){
    dat=get(i)
    name=gsub("OND","OND_PP",i)
    assign(name,dat)
  }
}
####deleting old rasters, i.e. raster that d.n. have a length of 9
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(sorted=TRUE))){
  if (nchar(i)!=9){
    rm(list=paste(i))
  }
} 

rm(list=ls(pattern="sal*"))

newprj="+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0"###GO W THIS PRJ
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){ ##filter objects to only get objects of class type "RasterLayer"
  dat=get(i)
  proj4string(dat)=CRS(newprj)
  assign(i,dat)
}

#####writing out rasters
setwd("F:/Climate_paper/climate_data/final_sdm")

for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(sorted=TRUE))){
    dat=get(i)
    writeRaster(dat,i,format="GTiff",bylayer=TRUE,overwrite=TRUE)
  }



#####reading in ESRL anomalies
##### NF anamolies
setwd("F:/Climate_paper/climate_data/projected_rasters_new")
for (ras in list.files(pattern="*NF")){
  path=paste(getwd(),"/",ras,sep="")
  r=raster(path)
  name=gsub(".tif","",ras)
  assign(name,r)
}

####historical SDM projections
setwd("F:/Climate_paper/climate_data/final_sdm")
for (ras in list.files(pattern="*PP")){
  path=paste(getwd(),"/",ras,sep="")
  r=raster(path)
  name=gsub(".tif","",ras)
  assign(name,r)
}

#####all rasters need to be at same resolution
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(pattern="*NF"))){
  dat=get(i)
  rs=resample(dat,st_AMJ_PP,method="ngb")
  assign(i,rs)
}

####write these out to save  
setwd("F:/Climate_paper/climate_data/final_layers/High_resolution")
for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls(pattern="*NF"))){
  dat=get(i)
  writeRaster(dat,i,format="GTiff",bylayer=TRUE,overwrite=TRUE)
}
  


#######fixing units between SDM hist rasters and ESRL anomaly rasters



  
####adding anomalies and hist sdm rasters
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


math=sum(rs1,st_AMJ_PP)




###########extra code

for (i in Filter(function(x)inherits(get(x),"RasterLayer"),ls())){
  if(grepl("m01",i)==TRUE) # & grepl("m03",i)==TRUE){
  print(i)
  }
}



JFM=c("m01","m02","m03")
AMJ=c("m04","m05","m06")
JAS=c("mo7","m08","m09")
OND=c("m10","m11","m12")

month.list=list.files() #grab list of months

for (month in month.list){
  if (month=="m01"){
    print(month)
  }
}


AMJ=stack()
for(i in names(JFM)){
  if(grepl("chla",i)==TRUE){
    name=paste(i,".asc",sep="")
    AMJ=stack(AMJ,name)
}
}

for (i in seq_along(name)){
  new=gsub("_PP","",name[i])
  tmp=assign(new,name[i])
  Output[[i]]<-tmp
}