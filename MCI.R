
data=read.csv("F:/IMCC4/MCI/mpas.csv")
names(data)
d2=data[,c(2,4,6,7)]
d=d2[d2$Category=="effective",]
d3=d[,c(1:3)]
fit=princomp(d3,cor=TRUE)
summary(fit)
plot(fit,type="lines")
biplot(fit)
fit$scores
fit2=prcomp(d3,cor=TRUE)
biplot(fit2)

dat=data[,c(1:2,4,6:7)]
rownames(data)=data[,1]
fit3=princomp(~nta.area+total.area+age,data=dat,cor=TRUE)
biplot(fit3)

dat
nrow(dat)
fit4=princomp(~nta.area+total.area+age,data=d,cor=TRUE)
biplot(fit4)


library(vegan)
x=dist(data)
names(d3)
x
dt=data[,c(2,4,6)]
x=dist(dt)
head(x)
nmds=nmds(x)
n=metaMDS(x)
plot(n,type="t")

dt
d=dt[c(1:4,6:20),]
d
x=dist(d)
n=metaMDS(x)
plot(n,type="p")
points(n,display="")

d=dt[c(1:4,6:20),]
fit4=princomp(~nta.area+total.area+age,data=data,cor=TRUE)
biplot(fit4)

d=data[c(1:22,25:28),]
fit5=princomp(~nta.area+total.area+age,data=d,cor=TRUE)
biplot(fit5)

d2=data[data$Citation=="Lester et al",]
fit5=princomp(~nta.area+total.area+age,data=d2,cor=TRUE,scores=TRUE)
biplot(fit5)
plot(fit5$x[,1],fit5$x[,2])
plot(fit5)
plot(fit5$Comp.1,fit5$Comp.2)
fit5$loadings$Comp.1
