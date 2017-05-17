######### LM learning

setwd("F:/Climate_paper/maxent_trial")
list.files()

records=read.csv("records.csv")

results = lm( o2 ~ bs + ss, data=records)
results2 = lm( o2 ~ bs, data=records)
anova(results,results2)


head(records)
records$o2=""

a=predict(results2,records)
plot(results2)
records$o2_pred=predict(results2,records)

#####instructions: http://scc.stat.ucla.edu/page_attachments/0000/0140/reg_2.pdf

setwd("F:/SDM_paper/extracted_variables")
rec=read.csv("Habitat_variables5_filled_modeling.csv")
rec2=rec[,c(1:7)]
plot(rec[,c(4:9)])
new=rec[complete.cases(rec),]

model=lm(chla_rt ~ mSST_rt+sal_1_rt+t_1_rt+u_1_rt,data=new)
summary(model)

d=data.frame(new,fitted.values=fitted(model),residual=resid(model))
anova(model)
c=predict(model,interval = "confidence")###UNCERTAINTY ABOUT REGRESSION LINE
p=predict(model,interval = "prediction")####UNCERTAINTY ABOUT FUTURE OBSERVATIONS

#######CHECKING ASSUMPTIONS
##residuals vs. predictors
plot(resid(model)~mSST_rt,data=new,ylab="Residuals")
plot(resid(model)~sal_1_rt,data=new,ylab="Residuals")
plot(model,which=1:4)


####non-constant variance
plot(resid(model)~fitted(model),xlab="Fitted values",ylab="Residuals",main="Original Data")
##transformations
new$sqrtchla=sqrt(new$chla_rt)
model_sq=lm(sqrtchla ~ mSST_rt+sal_1_rt+t_1_rt+u_1_rt,data=new)
plot(resid(model_sq)~fitted(model_sq),xlab="Fitted values",ylab="Residuals",main="Original Data")

###http://r-statistics.co/Assumptions-of-Linear-Regression.html

#Assumption 1: The regression model is linear in parameters
#??? don't worry about it

#Assumption 2: The mean of residuals is zero
mean(model$residuals)

#Assumption 3: Homoscedasticity of residuals or equal variance
par(mfrow=c(2,2))
plot(model)

#plot # 1, line should be flat (homogeneous residuals)
#plot#2, same, checks same thing

#Assumption 4: no autocorrelation of residuals
library(ggplot2)
acf(model$residuals)

"The X axis corresponds to the lags of the residual, 
increasing in steps of 1. The very first line (to the left) shows the correlation 
of residual with itself (Lag0), therefore, it will always be equal to 1.

If the residuals were not autocorrelated, 
the correlation (Y-axis) from the immediate next line onwards will drop 
to a near zero value below the dashed blue line (significance level). 
Clearly, this is not the case here. 
So we can conclude that the residuals are autocorrelated.
"

runs.test(model$residuals)

#Assumption 5
#The X variables and residuals are uncorrelated
cor.test(new$mSST_rt,model$residuals)


#Assumption 6
#The x values must not all be the same or close
var(new$mSST_rt)

#Assumption 7
#no perfect multicollinearity
library(car)
vif(model)
new2=new[,5:13]
library(Correlplot)
correlogram(new2,labs=colnames(new2))

library(gvlma)
gvlma(model)
#remote outliers
neww=new[-c(2626,2656,4425),]
newww=neww[-c(2626,2656,4425),]
nw=new[c(1:1000),]
model1=lm(chla_rt ~ mSST_rt+sal_1_rt+t_1_rt+u_1_rt,data=newww)
par(mfrow=c(2,2))
plot(model2)
model2=lm(chla_rt ~ mSST_rt+sal_1_rt+t_1_rt+u_1_rt,data=new[-c(571,590,890),])

new=nw[c(1:440,442:570,572:589,591:1000),]

######normality of residuals
hist(model2$residuals)
curve(dnorm,add=TRUE)

##boom: http://www.statmethods.net/stats/rdiagnostics.html
library(car)
outlierTest(model2)
qqPlot(model2, main="QQ Plot")
leveragePlots(model2) # leverage plots 

##########nevermind its  a glm
help("family")
setwd("F:/dad")
data=read.csv("Data.csv")
dt=data[complete.cases(data),]
lm=glm(newsize~race+dxyear+stage+survivalmonths+vitalstatus,data=dt,family=poisson)
plot(lm)

#see how many nas there are in each column
age=sum(is.na(data$age))
race=sum(is.na(data$race))
dxyear=sum(is.na(data$dxyear))
registry=sum(is.na(data$registry))
stage=sum(is.na(data$stage))
survivalmonths=sum(is.na(data$survivalmonths))
vitalstatus=sum(is.na(data$vitalstatus))
newsize=sum(is.na(data$newsize))

###modellign
data[data=="Unknown"]=NA
dt2=data[complete.cases(data),]
lm2=glm(newsize~age+race+dxyear+registry+stage+survivalmonths+vitalstatus,data=dt2,family=poisson)
lm3=glm(newsize~age+race+dxyear+registry+stage+survivalmonths,data=dt2,family=poisson)
lm4=glm(newsize~age+race+dxyear+registry+stage,data=dt2,family=poisson)
lm5=glm(newsize~age+race+dxyear+registry,data=dt2,family=poisson)
lm6=glm(newsize~age+race+dxyear,data=dt2,family=poisson)
lm7=glm(newsize~age+race,data=dt2,family=poisson)

x=anova(lm2,lm3,lm4,lm5,lm6,lm7)

library(bestglm)
dt3=dt2[,c(2:ncol(dt2))]
test=bestglm(dt3,IC="AIC")

library(MASS)
lm2=glm(newsize~age+race+dxyear+registry+stage+survivalmonths+vitalstatus,data=dt3)
step <- stepAIC(lm2, direction="both")
step$anova # display results
summary(lm2)

####http://stats.stackexchange.com/questions/61217/transforming-variables-for-multiple-regression-in-r
library(car)
boxCox(lm2,family="yjPower",plotit=TRUE)
depvar=yjPower(dt3$newsize,lambda=.7)
lm8=glm(newsize~age+race+dxyear+registry+stage+survivalmonths+vitalstatus,data=dt3)
lm9=glm(sqrt(newsize)~age+race+dxyear+registry+stage+survivalmonths+vitalstatus,data=dt3)
plot(lm9)
anova(lm8,lm9)
residualPlots(lm8) #http://www.sagepub.com/sites/default/files/upm-binaries/38503_Chapter6.pdf
marginalModelPlots(lm8)
r2=cor(dt3$newsize,predict(lm8))^2
##checking asusmptions: http://www.r-bloggers.com/checking-glm-model-assumptions-in-r/
x=predict(lm8,)
##################


##################################

##   FOR REAL

#1. clean data in excel, names w.o spaces, all unknowns to blanks
#2 read in data
setwd("F:/dad")
data=read.csv("data2.csv")
dt=data[complete.cases(data),]
dt2=dt[,c(2:ncol(dt))]

#2.1 separate into two csvs, newsize w data and newsize blank
full=data[(data$newsize %in% c(1,2,3,4,5)),]
blank=data[!(data$newsize %in% c(1,2,3,4,5)),]

#3. linearity
#####not so useful for discrete data
library(car)
pairs(~newsize+age+race+dxyear+registry+stage+survivalmonths+vitalstatus,data=dt2)
pairs(dt2)

#4. figure out distribution
##http://stats.stackexchange.com/questions/132652/how-to-determine-which-distribution-fits-my-data-best
library(fitdistrplus)
descdist(full$newsize,discrete=TRUE,boot = 1000)
fit.beta=fitdist(full$newsize,"weibull")
fit.uni=fitdist(full$newsize,"uniform")
fit.norm=fitdist(full$newsize,"norm")
fit.log=fitdist(full$newsize,"logis",method="mme")
plot(fit.norm)
plot(fit.log)
plot(fit.beta)
fit.norm$aic #want lower aic
fit.log$aic
fit.beta$aic

#4. step-wise model selection
library(MASS)
lm=glm(newsize~age+race+dxyear+registry+stage+survivalmonths+vitalstatus,data=full)
step <- stepAIC(lm, direction="both")
step$anova # display results

#https://rstudio-pubs-static.s3.amazonaws.com/2897_9220b21cfc0c43a396ff9abf122bb351.html
library(bestglm)
test=bestglm(full,IC="AIC")
test$BestModels
summary(test$BestModel)

#trying again
lm2=glm(newsize~age+race+dxyear+registry+stage+survivalmonths+vitalstatus,data=full,family=poisson())
full$pred_newsize3=predict(lm2,type="response")
cor(full$newsize,full$pred_newsize3)
      
#5. summary gam, predict
summary(lm)
library(car)
boxCox(lm,family="yjPower",plotit=TRUE)
depvar=yjPower(full$newsize,lambda=.7)
plot(lm)
anova(lm)
residualPlots(lm) #http://www.sagepub.com/sites/default/files/upm-binaries/38503_Chapter6.pdf
marginalModelPlots(lm)
#r2=cor(dt3$newsize,predict(lm8))^2
##checking asusmptions: http://www.r-bloggers.com/checking-glm-model-assumptions-in-r/


full$pred_newsize=predict(lm,type="response")
plot(full$newsize,full$pred_newsize)
x=cor(full$newsize,full$pred_newsize)
full$pred_newsize2=predict(lm)

hist(full$newsize)
hist(log(full$newsize))

head(blank)
blank$pred_newsize=predict(lm,blank,type="response")
sub_blank=blank[blank$dxyear==1975,]
sub_blank$newsize=sub_blank$pred_newsize
sub_full=full[full$dxyear==1975,]
b=sub_blank[,c(3,8)]
f=sub_full[,c(3,8)]
combine=rbind(b,f)

hist(b$newsize,main="Histogram of unknown size from 1975")
hist(f$newsize,main="Histogram of known size from 1975")
hist(combine$newsize, main="Histogram of known and unknown size from 1975")

jpeg("ECDF.jpg")
plot(ecdf(f$newsize), col='red', ylab='CDF', main='Q-Q adjustment of known and unknown size from 1975')
lines(ecdf(b$newsize), col='black')
legend('topleft', c('Known size','Unknown size'), lty=1, col=c('red','black'))
dev.off()
