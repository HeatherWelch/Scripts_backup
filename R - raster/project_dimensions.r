####fixing remote sensing rasters

library("raster")
setwd("F:/trial/projections_trial")
list.files()
bad=raster("sal_1_m06_m.img")
good=raster("ghrsst_m01")

#change properties of bad raster
res(bad)=0.01098633
ncol(bad)=638
nrow(bad)=637
projection(bad)="+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"

f="sal_1_m06_m.img"
r=raster(f)
plot(r)
plot(r,good)

###doing it right
plot(r)
good
resample(r,good,method="ngb",filename="resample.grd") #failed, objects d.n.intersect

###projecting
crs(r)
crs(good)
projection(r)=good
proj=crs(good,asText=FALSE,filename="resample.grd")
projection(r)=proj
plot(r)
plot(good)
c=projectRaster(r,good,method="ngb",filename="project")
plot(c)
d=projectRaster(bad,template,method="ngb",filename="project2",overwrite=TRUE)

##defining an empty template raster that matches the GHRSST layers
template=raster()
res(template)=0.01098633
ncol(template)=638
nrow(template)=637
#ncell(template)=406406
xmin(template)=-76.00391
xmax(template)=-68.99463
ymin(template)=35.00245
ymax(template)=42.00074
values(template)=1
projection(template)="+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs"
plot(template)
d=projectRaster(bad,template,method="ngb",filename="project2",overwrite=TRUE)
writeRaster(d,"final2",format="ascii",bylayer=TRUE)
writeRaster(d,"final3",format="GTiff",bylayer=TRUE)
writeFormats()


##read in shoreline to check location of template
#fail, wrong pcs
library(shapefiles)
library(maptools)
library(rgdal)
shore=shapefile("E:/Latest_BOEM_Data/North Atlantic Shoreline/North_Atlantic_Shoreline_NAD83UTM18.shp")
shore_clip=spsample(Spatial(bbox=bbox(template)),type="random")
bbox(template)
bbox(shore)
