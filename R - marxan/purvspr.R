#### marxan

library(marxan)


setwd("F:/SDM_paper/maxent/Maxent_run/marxan/run1/SR_scenario1/purvspr")
x=read.csv("purvspr.txt")
names(x)
y=x[,c(2:4)]
names(y)
y$amount=y$RASTERVALU
y$pu=y$POINTID
head(y)
z=y[,c(3,5,4)]
head(z)
tail(z)

t=z[order(z$pu),]
head(t)
tail(t)
d=t[d$species!=-9999.0,]
nrow(d)
nrow(t)

library(plyr)
m=d[revalue(d$species,c("m01_sr"="1"))

levels(d$species)[levels(d$species)=="m01_sr"]="1"
levels(d$species)[levels(d$species)=="m02_sr"]="2"
levels(d$species)[levels(d$species)=="m03_sr"]="3"
levels(d$species)[levels(d$species)=="m04_sr"]="4"
levels(d$species)[levels(d$species)=="m05_sr"]="5"
levels(d$species)[levels(d$species)=="m06_sr_d2a"]="6"
levels(d$species)[levels(d$species)=="m07_sr_d2a"]="7"
levels(d$species)[levels(d$species)=="m08_sr_d2a"]="8"
levels(d$species)[levels(d$species)=="m09_sr_d2a"]="9"
levels(d$species)[levels(d$species)=="m10_sr"]="10"
levels(d$species)[levels(d$species)=="m11_sr"]="11"
levels(d$species)[levels(d$species)=="m12_sr"]="12"
d$species=as.numeric(d$species)
head(d)

write.csv(d,"F:/SDM_paper/maxent/Maxent_run/marxan/run1/SR_scenario1/input1/purvspr.csv",row.names = FALSE)


y=x[,c(2:4)]
head(y)
write.csv(y,"purvspr2.csv",row.names=FALSE)
write.table(y,"purvspr3.txt",sep="\t",row.names=FALSE)

y$amount=11136
head(y)

setwd("F:/SDM_paper/maxent/Maxent_run/marxan/run1/scenario1/input4")
d=read.table("spec.dat")
head(d)
write.csv(d,"F:/SDM_paper/maxent/Maxent_run/marxan/run1/scenario1/input5/spec.csv",row.names = FALSE)

e=read.table("purvspr.dat",header=FALSE)
head(e)

setwd("F:/SDM_paper/maxent/Maxent_run/marxan/run1/scenario1/input7")
d=read.table("purvspr.dat")
head(d)
x=as.data.frame(d)
head(x)
x[order(x,2)]
head(x)
colnames(x)=x[1,]
head(x)
colnames(x[1,])="species"
head(x)
d=read.csv("purvspr.csv",sep="\t")
head(d)
d[order(d,2)]
tail(d)
levels(d$species)
summary(d$species)
x=d[d$species!=-9999.0,]
summary(x$species)
head(x)
tail(x)
t=x[order(x$pu),]

write.csv(t,"purvspr2.csv",sep="\t",row.names = FALSE)

library(rgdal)
VTR=readOGR(dsn="F:/SDM_paper/maxent/Maxent_run/marxan/run1/gis_layers",layer="pu_prj")
plot(VTR)
summary(VTR)
VTR=readOGR(dsn="F:/SDM_paper/maxent/Maxent_run/marxan/run1/gis_layers",layer="point")
plot(VTR)

setwd("F:/SDM_paper/maxent/Maxent_run/marxan/run1/gis_layers")
library(raster)
list.files()
ras=raster("raster")
plot(ras)
head(ras@data)
y=as.matrix(ras)
head(y)
tail(y)

e=extent(ras)
plot(e)
head(e)

####################### turning into rasters
library(raster)
library(rgdal)
VTR=readOGR(dsn="F:/SDM_paper/maxent/Maxent_run/marxan/run1/gis_layers",layer="point")
plot(VTR)
setwd("F:/SDM_paper/maxent/Maxent_run/marxan/run1/duel_scenario1/output1")
best=read.csv("output_best.txt")
head(best)
colnames(best)[1]="POINTID"
sums=read.csv("output_ssoln.txt")
head(sums)
colnames(sums)[1]="POINTID"
head(sums)

join_best=merge(VTR,best,by="POINTID")
head(join)
summary(join)
join_sums=merge(VTR,sums,by="POINTID")

a=rasterFromXYZ(as.data.frame(join_best)[,c("POINT_X","POINT_Y","solution")])
plot(a)
proj4string(a)="+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0"
writeRaster(a,"output_best",format="GTiff",bylayer=TRUE)
b=rasterFromXYZ(as.data.frame(join_sums)[,c("POINT_X","POINT_Y","number")])
plot(b)
summary(b)
proj4string(b)="+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0"
writeRaster(b,"output_ssoln",format="GTiff",bylayer=TRUE)
############################### turning into rasters

setwd("F:/SDM_paper/maxent/Maxent_run/marxan/run1/duel_scenario1/input9_assemblages")
x=read.csv("spec.dat",sep="\t")
names(x)
y=x[,c(1,3:4)]
names(y)
y$amount=y$RASTERVALU
y$pu=y$POINTID
head(y)
z=y[,c(3,5,4)]
head(z)
tail(z)

t=z[order(z$pu),]
head(t)
tail(t)
d=t[d$amount==1,]
nrow(d)
nrow(t)

library(plyr)
m=d[revalue(d$species,c("m01_sr"="1"))
    
    levels(d$species)[levels(d$species)=="m01_r"]="1"
    levels(d$species)[levels(d$species)=="m02_r"]="2"
    levels(d$species)[levels(d$species)=="m03_r"]="3"
    levels(d$species)[levels(d$species)=="m04_r"]="4"
    levels(d$species)[levels(d$species)=="m05_r"]="5"
    levels(d$species)[levels(d$species)=="m06_r"]="6"
    levels(d$species)[levels(d$species)=="m07_r"]="7"
    levels(d$species)[levels(d$species)=="m08_r"]="8"
    levels(d$species)[levels(d$species)=="m09_r"]="9"
    levels(d$species)[levels(d$species)=="m10_r"]="10"
    levels(d$species)[levels(d$species)=="m11_r"]="11"
    levels(d$species)[levels(d$species)=="m12_r"]="12"
    d$species=as.numeric(d$species)
    head(d)
    tail(d)
    write.csv(d,"F:/SDM_paper/maxent/Maxent_run/marxan/run1/SR_scenario2/input1/purvspr.csv",row.names = FALSE)
    
    
setwd("F:/SDM_paper/maxent/Maxent_run/marxan/run1/duel_scenario1/input9_assemblages")
ass_x=read.csv("spec.dat",sep="\t")
names(ass_x)
ass_y=x[,c(1,3:4)]
names(ass_y)
head(y)
tail(y)

setwd("F:/SDM_paper/maxent/Maxent_run/marxan/run1/duel_scenario1/input1_SR")
sr_x=read.csv("spec.dat",sep="\t")
names(sr_x)
head(sr_x)
sr_x$id=as.factor(sr_x$id)
levels(sr_x$id)[levels(sr_x$id)=="1"]="90"
levels(sr_x$id)[levels(sr_x$id)=="2"]="91"
levels(sr_x$id)[levels(sr_x$id)=="3"]="92"
levels(sr_x$id)[levels(sr_x$id)=="4"]="93"
levels(sr_x$id)[levels(sr_x$id)=="5"]="94"
levels(sr_x$id)[levels(sr_x$id)=="6"]="95"
levels(sr_x$id)[levels(sr_x$id)=="7"]="96"
levels(sr_x$id)[levels(sr_x$id)=="8"]="97"
levels(sr_x$id)[levels(sr_x$id)=="9"]="98"
levels(sr_x$id)[levels(sr_x$id)=="10"]="99"
levels(sr_x$id)[levels(sr_x$id)=="11"]="100"
levels(sr_x$id)[levels(sr_x$id)=="12"]="101"

d=rbind(ass_y,sr_x)
write.csv(d,"F:/SDM_paper/maxent/Maxent_run/marxan/run1/duel_scenario1/input/spec.dat",row.names = FALSE)

setwd("F:/SDM_paper/maxent/Maxent_run/marxan/run1/duel_scenario1/input9_assemblages")
ass_x=read.csv("purvspr2.dat",sep=",")
head(ass_x)

setwd("F:/SDM_paper/maxent/Maxent_run/marxan/run1/duel_scenario1/input1_SR")
sr_x=read.csv("purvspr.dat",sep=",")
head(sr_x)

sr_x$species=as.factor(sr_x$species)
levels(sr_x$species)[levels(sr_x$species)=="1"]="90"
levels(sr_x$species)[levels(sr_x$species)=="2"]="91"
levels(sr_x$species)[levels(sr_x$species)=="3"]="92"
levels(sr_x$species)[levels(sr_x$species)=="4"]="93"
levels(sr_x$species)[levels(sr_x$species)=="5"]="94"
levels(sr_x$species)[levels(sr_x$species)=="6"]="95"
levels(sr_x$species)[levels(sr_x$species)=="7"]="96"
levels(sr_x$species)[levels(sr_x$species)=="8"]="97"
levels(sr_x$species)[levels(sr_x$species)=="9"]="98"
levels(sr_x$species)[levels(sr_x$species)=="10"]="99"
levels(sr_x$species)[levels(sr_x$species)=="11"]="100"
levels(sr_x$species)[levels(sr_x$species)=="12"]="101"

sr_x$species=as.character(sr_x$species)
sr_x$species=as.numeric(sr_x$species)

write.csv(sr_x,"F:/SDM_paper/maxent/Maxent_run/marxan/run1/duel_scenario1/input/purvspr_SR.dat",row.names = FALSE)
d=rbind(sr_x,ass_x)
t=d[order(d$pu),]
write.csv(t,"F:/SDM_paper/maxent/Maxent_run/marxan/run1/duel_scenario1/input/purvspr.dat",row.names = FALSE)


setwd("F:/SDM_paper/extracted_variables")
a=read.csv("Habitat_variables5_filled.csv")
