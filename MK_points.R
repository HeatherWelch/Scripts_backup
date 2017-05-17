##### some basic spatial commands for points

########  1. reading in points
### first, read in as data.frame
setwd("F:/xxxx")
records=read.csv("points.csv",header=TRUE, sep=",")

### make is spatial by defining coordinates
library(sp)
coordinates(records)=~GIS_LONHB+GIS_LATHB # ~ long+lat ##note this will 'delete' your lat/long columns, you might want to copy them before you make the points spatial
plot(records)

########  2. reasons your points might be in the wrong place
### longitude is not negative (for the western hemisphere, GIS likes long to be neg)
records$GIS_LONHB=records$GIS_LONHB*-1

### points might have the wrong geographic/projected coordinate system
## do you know about these from arcgis? :http://resources.esri.com/help/9.3/arcgisengine/dotnet/89b720a5-7339-44b0-8b58-0f5bf2843393.htm
summary(records)  ## see what projection your points are in (proj4string)
bbox(records) ## see where in the world your points are (also available in summary)
library(raster)
proj4string(records) ## another way to see what projection your points are in


## change/ define projection
## R wants projection information in proj4 format for some unknown dumbass reason (different than GIS format)
## 1. determine what projection your points need to be in, e.g. WGS 1984
## 2. look up proj4 equivalent: http://spatialreference.org/ref/?&search=WGS
  ## e.g. WGS is "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
myproj="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
proj4string(records)=CRS(myproj) ## project records
summary(records)


########  2. adding some background layers
## for more detail see: https://cran.r-project.org/web/packages/maps/maps.pdf
library(maps)
map(database="world")
plot(records,add=TRUE)

map(database="usa")
plot(records,add=TRUE)

map(database="state")
plot(records,add=TRUE)

map(database="state",regions="New Jersey",fill=TRUE,col="red")
plot(records,add=TRUE,col="blue")

axis(1) ## add long lines
axis(2) ## add lat lines


########  Another way
library(ggmap)
map=get_map(location="New Jersey",zoom=4) ### more detailed background layers

### for more information: https://www.nceas.ucsb.edu/~frazier/RSpatialGuides/ggmap/ggmapCheatsheet.pdf
location=bbox(records)
map=get_map(location=location,source="google",maptype="satellite")
records2=read.csv("points.csv",header=TRUE, sep=",") ##read in, don't make spatial
ggmap(map)+geom_point(aes(x=GIS_LONHB,y=GIS_LATHB),data=records2,color="red")

########  3. some basic spatial operations

## A. subset points (just like a normal data frame, but add @data argument)
subset_records=records[records@data$month==12,] ## grab points from december

## B. subset points spatially
## i.e. say you only want points that fall within a certain polygon (e.g. a certain state)
library(rgdal)
library(raster)
polygon=readOGR(dsn="F:/VMS/VTR",layer="Statistical_Areas_2010") ## polygon that you want to define point extent, layer is a pre-existing GIS shapefile 
plot(polygon)
plot(records,add=TRUE)
proj4string(polygon)=CRS(myproj) ## make sure polygon and points have same projection
clip=crop(records,polygon) ## more information: http://www.inside-r.org/packages/cran/raster/docs/crop
plot(clip)


