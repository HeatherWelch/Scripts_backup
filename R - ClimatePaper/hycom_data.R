##access, processing, editing hycom data

library(ncdf4)
library(RNetCDF)

setwd("F:/Climate_paper/Cm2.6_tests/hycom_download")


#########   SSH
setwd("F:/Climate_paper/hycom/SSH")

##access to hycom data grids: http://ncss.hycom.org/thredds/ncss/grid/GLBu0.08/expt_19.1/dataset.html
url_grid="http://ncss.hycom.org/thredds/ncss/GLBu0.08/expt_19.1?var=surf_el&north=45&west=-80.5&east=-65&south=23&disableProjSubset=on&horizStride=1&time_start=1996-01-01T00%3A00%3A00Z&time_end=2012-12-31T00%3A00%3A00Z&timeStride=1&vertCoord=&accept=netcdf"
download.file(url_grid2, "ssh.nc", method = "auto",
              quiet = FALSE, mode="wb", cacheOK = TRUE)







url_grid <- "http://tds.hycom.org/thredds/dodsC/GLBu0.08/expt_19.1?depth[0:1:39],lon[0:360],time[0:1:24],salinity[0:1:24][0:1:39][0:45][0:360]"
url_grid2="http://ncss.hycom.org/thredds/ncss/GLBu0.08/expt_19.1?var=surf_el&north=50&west=-80&east=-60&south=0&disableProjSubset=on&horizStride=1&time_start=1995-08-01T00%3A00%3A00Z&time_end=1995-08-02T00%3A00%3A00Z&timeStride=1&vertCoord=&accept=netcdf"

download.file(url_grid2, "trial.nc", method = "auto",
              quiet = FALSE, mode="wb", cacheOK = TRUE)

grid.nc <- open.nc("trial.nc")
grid.nc
names(grid.nc[['var']])
names(grid.nc$var)
print.nc(grid.nc)


# Get grid data
G.x=var.get.nc(grid.nc,'lon')
G.y=var.get.nc(grid.nc,'lat')


# get only first timestep
G.z <- var.get.nc(grid.nc,'time')[1]


##convert to raters
library(raster)
b<- brick("trial.nc", varname="surf_el")
names(b)  ### get name for each raster layer in the brick
plot(b$X1995.08.02.01.00.00) ###plot an individual letter

##averaging by month
for(i in names(b)){
  print(i)
  if (grepl(".08.",i)==TRUE){
    print("oh yeah!")
  }
}

####grabbing an august subset
for(i in names(b)){
  if(grepl(".08.",i)==TRUE){
    print(i)
    sub=subset(b,i, drop=TRUE) ###grabs all rasters for august
  }
}

###averaging across all august rasters
august=cellStats(sub, stat='mean', na.rm=TRUE)
august=calc(sub, fun=mean)
plot(august)









#################################bits and pieces of code

aug=list()
for(i in names(b)){
  if(grepl(".08.",i)==TRUE){
    print(i)
    aug=list(aug,i)
  }
}
    
    sub=subset(b,i, drop=TRUE)
    name=i
    assign(name,sub)
    august=brick(august,name)
  }
}

sub=subset(b, c("X1995.08.01.01.00.00","X1995.08.02.01.00.00"), drop=TRUE)

for(i in 1:b@file@nbands){
  print(i)
}
  
  if (grepl(".08.",i)==TRUE){
    print(i)
    if()
  }
}
