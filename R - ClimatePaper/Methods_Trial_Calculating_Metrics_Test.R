### trialing 
# 5. Calculating a number of landscape metrics from the SDM Toolbox.

# Outputs derived from the ClassStat function form SDM Toolbox
# [1] "X"                       "name"                    "class"                   "n.patches"
# [5] "total.area"              "prop.landscape"          "patch.density"           "total.edge"
# [9] "edge.density"            "landscape.shape.index"   "largest.patch.index"     "mean.patch.area"
# [13] "sd.patch.area"           "min.patch.area"          "max.patch.area"          "perimeter.area.frac.dim"
# [17] "mean.perim.area.ratio"   "sd.perim.area.ratio"     "min.perim.area.ratio"    "max.perim.area.ratio"
# [21] "mean.shape.index"        "sd.shape.index"          "min.shape.index"         "max.shape.index"
# [25] "mean.frac.dim.index"     "sd.frac.dim.index"       "min.frac.dim.index"      "max.frac.dim.index"
# [29] "total.core.area"         "prop.landscape.core"     "mean.patch.core.area"    "sd.patch.core.area"
# [33] "min.patch.core.area"     "max.patch.core.area"     "prop.like.adjacencies"   "aggregation.index"
# [37] "lanscape.division.index" "splitting.index"         "effective.mesh.size"     "patch.cohesion.index"

## A. first turn rasters into p/a
## trial species: bp131, threshold: 0.759674821355943 (from Jenn's online script)

Thresh=0.759674821355943
rc_fun <- function(x) {ifelse(x <=  Thresh,0,ifelse(x >  Thresh, 1, NA)) }

spp_dir="/Volumes/SeaGate/ClimatePaperCM2.6/Species_Projections_all";setwd(spp_dir)
file_list=list.files(pattern="bp131") ## start with one

for(files in file_list){
  path=paste(spp_dir,"/",files,"/",sep="")
  pa_sp_dir=paste("/Volumes/SeaGate/ClimatePaperCM2.6/P_A/",files,"/",sep="");dir.create(pa_sp_dir)
  for(raster in list.files(path)){
    print(raster)
    dat=raster(paste(path,raster,sep=""))
    reclass=calc(dat,fun = rc_fun)
    writeRaster(reclass,paste(pa_sp_dir,raster,sep=""),format="GTiff")
    
  }
}

PA_raster_dir=pa_sp_dir
#bringing in rasters and then calculating landscape metrics via for loop
setwd(PA_raster_dir)
folders<-list.files();folders
Class_Stats<-as.data.frame(NULL)
for (folder in folders) {
  print(paste("Starting ",folder,sep=""))
  setwd(paste(PA_raster_dir,"/",folder,sep=""))
  raster_data<-list.files(pattern=".tif")
  rs_stk<-stack(raster_data)
  for (i in 1:nlayers(rs_stk)) {
    tryCatch({
      print(paste("Starting loop of ",names(rs_stk[[i]]),sep=""))
      layer=rs_stk[[i]]
      name<-names(rs_stk[[i]])
      stat<-as.data.frame(ClassStat(layer,cellsize = 8904, bkgd = NA, latlon = TRUE))
      stat_P<-as.data.frame(cbind(name,stat))
      print(paste("Compiling output stats for ", names(rs_stk[[i]]),sep=""))
      Class_Stats<-rbind(Class_Stats,stat_P)},error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  }
}

xx=Class_Stats[Class_Stats$class==1,]
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

xx$name=as.character(xx$name)
xx$TemporalOrder=substrRight(xx$name, 8)
xx$TemporalOrder=gsub("m","",xx$TemporalOrder)
xx$TemporalOrder=gsub("_","-",xx$TemporalOrder)
xx$TemporalOrder=paste("01-",xx$TemporalOrder,sep="")
xx$TemporalOrder=as.Date(xx$TemporalOrder,format="%d-%m-%Y")
head(xx)
plot(xx$TemporalOrder,xx$n.patches)
par(new=TRUE)
library(ggplot2)
library(grid)
library(gridExtra)
install.packages("gridExtra")
jpeg('bp1006.jpg')
p1 = qplot(a$TemporalOrder,a$n.patches)
p2 = qplot(a$TemporalOrder,a$total.area)
p3 = qplot(a$TemporalOrder,a$patch.density)
p4 = qplot(a$TemporalOrder,a$largest.patch.index)
p5 = qplot(a$TemporalOrder,a$total.edge)
p6 = qplot(a$TemporalOrder,a$prop.landscape)
p7 = qplot(a$TemporalOrder,a$mean.perim.area.ratio)
p8 = qplot(a$TemporalOrder,a$mean.shape.index)
grid.arrange(p1+stat_smooth(), p2+stat_smooth(), p3+stat_smooth(), p4+stat_smooth(), p5+stat_smooth(), p6+stat_smooth(), p7+stat_smooth(), p8+stat_smooth(), ncol = 2, top = "bp1006 landscape metrics")
dev.off()

##https://anomaly.io/seasonal-trend-decomposition-in-r/
install.packages("fpp")
library(fpp)
plot(as.ts(a$total.area))
install.packages("forecast")
library(forecast)

##### addative
trend = ma(a$total.area, order = 4, centre = T)
plot(as.ts(a$total.area))
lines(trend)
plot(as.ts(trend))
detrend = a$total.area - trend
plot(as.ts(detrend))

##### multiplicative
trend = ma(a$total.area, order = 12, centre = T) ## 12 for monthly
plot(as.ts(a$total.area))
lines(trend)
plot(as.ts(trend))
detrend = a$total.area - trend
plot(as.ts(detrend))

trend2=ma(detrend,order=12,centre=T)
lines(trend2)
plot(as.ts(trend))

