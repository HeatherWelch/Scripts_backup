###GAMS in R so I can get this fucking job in Hawaii

setwd("F:/Climate_paper/maxent_trial")
list.files()

records=read.csv("records.csv")
head(records)


library(maptools)
data(wrld_simpl)
plot(wrld_simpl)



################removing dupliate records
names(records)
dups=duplicated(records[,4:8,10:17])
summary(dups)
head(dups)
nodups=records[dups,]
summary(records)


#####plotting relationships between envt vars
pairs(nodups[,10:17],cex=0.1,fig=TRUE)



###models

####making some dummy presence absence datasets
code=subset(nodups,SCINAME=="GADUS MORHUA") ##presences
lobster=subset(nodups,SCINAME=="HOMARUS AMERICANUS") ##absences
lob=gsub("HOMARUS AMERICANUS","0",lobster)
x=lobster[lobster=="HOMARUS AMERICANUS"]==0

lobster$SCINAME=as.character(lobster$SCINAME)
lobster$SCINAME[lobster$SCINAME=="HOMARUS AMERICANUS"]="0"
lobster$SCINAME=as.numeric(lobster$SCINAME)
lobster$SCINAME[is.na(lobster$SCINAME)]=0

code$SCINAME=as.numeric(code$SCINAME)
code$SCINAME[is.na(code$SCINAME)]=0
code$SCINAME[code$SCINAME==0]=1

cod=rbind(code,lobster)
cod$SCINAME=as.numeric(cod$SCINAME)

write.csv(cod, file="F:/Climate_paper/maxent_trial/cod.csv")
cod=read.csv("cod.csv")

####modeling for real#################GLM

as.numeric(levels(code[,10:17]))
m1=glm(SCINAME~ph+pp+o2+CL+bt+bs+ss+st,data=cod) ###presence and absence only...1s and 0s dinkus
class(m1)
summary(m1)
#response(m1)

###read in rasters
library(raster)
setwd("F:/Climate_paper/climate_data/final_layers")
ph=raster("ph_AMJ_FF.tif")
pp=raster("pp_AMJ_FF.tif")
o2=raster("o2_AMJ_FF.tif")
CL=raster("CL_AMJ_FF.tif")
bt=raster("bt_AMJ_FF.tif")
bs=raster("bs_AMJ_FF.tif")
ss=raster("ss_AMJ_FF.tif")
st=raster("st_AMJ_FF.tif")

setwd("F:/Climate_paper/maxent_trial/variables")
writeRaster(ph,"ph",format="GTiff",bylayer=TRUE,overwrite=TRUE)
writeRaster(pp,"pp",format="GTiff",bylayer=TRUE,overwrite=TRUE)
writeRaster(o2,"o2",format="GTiff",bylayer=TRUE,overwrite=TRUE)
writeRaster(CL,"CL",format="GTiff",bylayer=TRUE,overwrite=TRUE)
writeRaster(bt,"bt",format="GTiff",bylayer=TRUE,overwrite=TRUE)
writeRaster(bs,"bs",format="GTiff",bylayer=TRUE,overwrite=TRUE)
writeRaster(ss,"ss",format="GTiff",bylayer=TRUE,overwrite=TRUE)
writeRaster(st,"st",format="GTiff",bylayer=TRUE,overwrite=TRUE)

ph=raster("ph.tif")
pp=raster("pp.tif")
o2=raster("o2.tif")
CL=raster("CL.tif")
bt=raster("bt.tif")
bs=raster("bs.tif")
ss=raster("ss.tif")
st=raster("st.tif")

env_var=stack(ph,pp,o2,CL,bt,bs,ss,st)

###predict that shit
p=predict(env_var,m1)
plot(p)



#####new GLM terms
m2=glm(SCINAME~ph+pp+o2+CL+bt+bs+ss+st,family=binomial(link="logit"),data=cod) ###presence and absence only...1s and 0s dinkus
p2=predict(env_var,m2)
plot(p2)


############### GAMS
library(mgcv)
#library(gam)

###### good resource: http://plantecology.syr.edu/fridley/bio793/gam.html
##### use tp as smoothing term (default) https://stat.ethz.ch/R-manual/R-devel/library/mgcv/html/smooth.terms.html
### family=binomial (MGET documentation) in modeling p/a log link function (http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0142628)
### family=poisson (MGET doc) if modeling count or rate
## Automated model selection method : https://stat.ethz.ch/R-manual/R-devel/library/mgcv/html/gam.selection.html
# "lambda (upside down Y) is a non-negative smoothing parameter that must be choses by the data analyst. It governs the tradeoff between the goodness of fit to the data and the wiggleness of the function" http://www.d.umn.edu/math/Technical%20Reports/Technical%20Reports%202007-/TR%202007-2008/TR_2008_8.pdf

gm1=gam(SCINAME~ph+pp+o2+CL+bt+bs+ss+st,family=binomial,data=cod)
summary(gm1)
#gm1=gam(SCINAME~s(ph),family=binomial,data=cod)
#gm1=gam(SCINAME~s(ph+pp),family=binomial,data=cod)
gm1=gam(SCINAME>0~s(ph),family=binomial,data=cod)
gm2=gam(SCINAME>0~s(ph)+s(pp),family=binomial,data=cod)
gm5=gam(SCINAME>0~s(ph)+s(pp)+te(ph,pp),family=binomial,data=cod) ###use this to look at the interactions between pp and ph (i.e. whether ph all of a sudden matters at a specief pp....the te term is supposed to be best when vars are on different scales according to the reference above)

pred=predict(env_var,gm5)
plot(gm5,residuals=T,trans=function(x)exp(x)/(1+exp(x)),shade=T)


####https://books.google.com/books?id=xhPNBQAAQBAJ&pg=PA213&lpg=PA213&dq=model+smoothness+estimation&source=bl&ots=b5vk9ZCCpC&sig=3SqudeWH7LDpt9Nep8qPDc4UAq4&hl=en&sa=X&ved=0ahUKEwjb4cTtxK_MAhVHej4KHYCUDK4Q6AEIYzAJ#v=onepage&q=model%20smoothness%20estimation&f=false
#mgcv automatic smoothness estimation
##gamma of 1.4 for slightly smoother models

####automatic smoother estimation and term selection in mgcv: http://www.inside-r.org/r-doc/mgcv/step.gam
####gam.selction: https://stat.ethz.ch/R-manual/R-devel/library/mgcv/html/gam.selection.html
###gam.check https://statistique.cuso.ch/fileadmin/statistique/document/part-3.pdf

gm4=gam(SCINAME~s(ph,bs="ts")+s(pp,bs="ts")+s(o2,bs="ts")+s(CL,bs="ts")+s(bt,bs="ts")+s(bs,bs="ts")+s(ss,bs="ts")+s(st,bs="ts"),family=binomial,data=cod)

gm6=gam(SCINAME~s(ph,bs="ts")+s(pp,bs="ts")+s(o2,bs="ts")+s(CL,bs="ts")+s(bt,bs="ts")+s(bs,bs="ts")+s(ss,bs="ts")+s(st,bs="ts"),family=binomial,data=cod)
pred=predict(env_var,gm6)
AIC(gm6)
extractAIC((gm6))
gam.check(gm6)
p=predict(gm6,type="terms")
summary(gm6)$dev.expl


gm7=gam(SCINAME~s(ph)+s(pp)+s(o2)+s(CL)+s(bt)+s(bs)+s(ss)+s(st),family=binomial,data=cod,select=TRUE)

gm8=gam(SCINAME~s(ph)+s(pp)+s(o2)+s(CL)+s(bt)+s(bs)+s(ss)+s(st),family=binomial,data=cod)


#### AUC
##http://stackoverflow.com/questions/18449013/r-logistic-regression-area-under-curver
# 1. read in data
# 2. run gam
# 3. predict response

library(pROC)
prob=predict(ACIPENSER_OXYRHYNCHUS,type=c("response"))
