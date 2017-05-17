####### Automated GAM Script
#https://cran.r-project.org/web/packages/gam/gam.pdf

#NEEDS TO FINISH THE SCRIPT
# 2. Adjust all predictor variables to make sure everything references the correc variable. 
# 3. Fix cross-validation portion to be sure there are some presences being considered in each. 
# 4. Make sure the projecting script is ready, i.e., reflecting the appropriate number of months. 


###########################################################################################################
# 1. Removes everything in the working environment

rm(list=ls()) 

###########################################################################################################
# 2. Set the primary working directories

primary_dir=paste("I:/MidAtlantic_GOM_Work/Climate_SDM_Paper/Second_Test_Run_PA_GAM");setwd(primary_dir)# swap folder names if necessary

spp_dir=paste(primary_dir,"/Species_CSVs",sep="");dir.create(spp_dir) # swap folder name if necessary
output_dir=paste(primary_dir,"/Model_Outputs",sep="");dir.create(output_dir)
plots_dir=paste(primary_dir,"/Model_Plots/",sep="");dir.create(plots_dir)
raster_dir=paste(primary_dir,"/Predictor_Rasters/",sep="");dir.create(raster_dir)

###########################################################################################################
# 3. Upload Species Data

#libraries needed
library(dplyr)
library(doBy)

######
# #IF data is in one csv, then will need to break it down into separate csvs by species. 
# #set directory to where the full dataset resides
# setwd(primary_dir)
# data<-read.csv("")
# 
# #splitting data by species and create a new csv for each in a new species csv directory 
# setwd(spp_dir)
# spp<-unique(data$Species)
# X<-split(data,data$Species)
# names(X)<-spp
# lapply(names(X),function(x){write.csv(X[[x]],file=paste("NES_",x,"_records.csv",sep=""))}) #change the name of the species output file names, if desired

######
#IF data is already in multiple species CSVs, then bring in data using:
#set the directory
setwd(spp_dir)
#read in all csvs in the directory
temp = list.files(pattern="0.csv")  # fix when ready to run the whole dataset. Added a 0 to keep the numbers low initially.
for (i in 1:length(temp)) {assign(temp[i], read.csv(temp[i]))}

# combine the list of species dataframes to extract the species levels and environmental variable info
data<-rbind_all(mget(temp))
names(data)

#reorganize the dataset so that only the most important info is present
data<-data[c(2:8,21,12:13,10:11,14:18)];names(data)

colnames(data)[7]<-c("Species") # check to make sure the 6 column is correct
data$Species<-as.factor(data$Species)


###########################################################################################################
# 4: Evaluate multicoliniearity 

#libraries needed
library(usdm)
library(base)
#http://www.inside-r.org/packages/cran/usdm/docs/vif
# https://jonlefcheck.net/2012/12/28/dealing-with-multicollinearity-using-variance-inflation-factors/

#scatterplot matrices and correlation coefficients
names(data)
summary(data)
env<-as.data.frame(data[c(11:17)]) # check to make sure the correct columns are selected

#plotting and saving the scatterplot matrix of environmental predictors
#set the directory
setwd(plots_dir)
jpeg('Scatterplot_of_Environmental_Predictors.jpeg')
pairs(env)
dev.off()

#correlation matrix
cor(env)

#Variance Inflation Factor test
col<-vif(env)

#conclusion: need to decide between bottom or surface values, because its causing concurvity effects.
# perhaps the solution is to run the models with an interaction between surface and bottom salinity
# or to just remove the one with the highest value. 
# Some sources recommend removing anything higher than 10 VIF.

#quick script to print with variables to retain
col$retain<-NA
for (i in 1:nrow(col)){
  if (col[i,2]>10){
    col[i,3]=c("No")
    print("remove");print(col[i,1])}
  else 
    if (col[i,2]<10){
      col[i,3]=c("Yes")
      print("keep");print(col[i,1])}}

#Output the variance inflation factor results to an "output" directory
#set the directory
setwd(output_dir)
write.csv(col,file="VIF_Collinearity_test.csv")


###########################################################################################################
# 5.Run GCV smoothing, shrinkage, and fitting - one species df at a time

#libraries needed
library(utils)
library(mgcv)
library(pROC)

#set the directory
setwd(spp_dir)

#look at the variable names to see if you need to change anything. 
names(data)

#the following script runs a generalized additive model on presence absence data for each species 
# and exports the statistics from the each model. Before running, check that the environmental variables are correct
#species levels
species<-levels(data$Species) 
Summary_Stats_Compiled<-NULL 
for (spp in species){
  setwd(spp_dir)
  #bringing in data to fit the model.
  dat<-read.csv(paste(spp,"_records.csv",sep=""))
  #removing the species name column just for the run.
  dat<-dat[-6] #make sure this number is correct.
  dat=dat[complete.cases(dat),]
  #fitting the model. Note that will need to change the environmental varaibles based on what the inputs will be.
  fit=gam(PA ~s(Depth,bs="ts")+s(Rugosity,bs="ts")+s(st,bs="ts")+s(SS,bs="ts")+s(bs,bs="ts")+s(bt,bs="ts"),family=binomial("logit"),scale=0,select=TRUE,data=dat,method="GCV.Cp")
  #Making a summary statistics table for outputting
  Spp_name<-spp
  Model_Exp_Dev<-(fit$null.deviance-fit$deviance)/fit$null.deviance
  Model_Rsqd<-summary(fit)$r.sq
  Model_Pvalue<-summary(fit)$p.pv
  GCV<-fit$gcv 
  #putting out pvalues, chi-squared values, edf, and ref.dfs from the statistics table. 
  s.table<-as.data.frame(t(summary(fit)$s.table))
  Pvalues<-s.table[4,];colnames(Pvalues)<-paste("Pval",colnames(Pvalues),sep="_")
  Chi.sq<-s.table[3,];rownames(Chi.sq)<-NULL;colnames(Chi.sq)<-paste("Chi",colnames(Chi.sq),sep="_")
  edf<-s.table[1,];rownames(edf)<-NULL;colnames(edf)<-paste("edf",colnames(edf),sep="_")
  ref.df<-s.table[1,];rownames(ref.df)<-NULL;colnames(ref.df)<-paste("ref_df",colnames(ref.df),sep="_")
  #pulling out information on concurvity, or the effect of multicolinearity on the model terms
  #according to the concurvity() tool from mgcv library, concurvity increases between 0-1.
  #meaning that values closer to 1 indicate a high influence of multicolinearity. 
  Con<-concurvity(fit,full=TRUE);colnames(Con)[1]<-c("Concurvity_para")
  Con_Est<-t(as.data.frame(Con[3,]));rownames(Con_Est)<-NULL;colnames(Con_Est)<-paste("Conc",colnames(Con_Est),sep="_")
  #generating the AUC for the model statistic output
  final_object<-gam(PA ~s(Depth,bs="ts")+s(Rugosity,bs="ts")+s(st,bs="ts")+s(SS,bs="ts")+s(bs,bs="ts")+s(bt,bs="ts"),family=binomial("logit"),scale=0,select=TRUE,data=dat,method="GCV.Cp")
  prob<-predict(final_object,type=c("response"))
  dat$prob=prob
  AUC<-roc(PA ~ prob,data=dat)
  Model_AUC<-AUC$auc
  Summary_Stats<-cbind(Spp_name,Model_Exp_Dev,Model_Rsqd,Model_Pvalue,Model_AUC,GCV,Pvalues,Chi.sq,edf,ref.df,Con_Est);rownames(Summary_Stats)<-NULL
  Summary_Stats_Compiled<-rbind(Summary_Stats_Compiled,Summary_Stats)
  setwd(output_dir)
  write.table(Summary_Stats,file=paste("GAM_Output_",spp,".txt",sep=""),sep="\t",col.names=TRUE)
  #exporting the partial residual plots
  setwd(plots_dir)
  jpeg(paste(spp,"_partial_residual_plots.jpeg",sep=""))
  plot.gam(fit,residuals=TRUE,se=TRUE,pages=1,scale=0,shade=TRUE,shade.col='green',seWithMean=TRUE)
  dev.off()
  #exporting the AUC plots for each species
  jpeg(paste(spp,"_AUC.jpeg",sep=""))
  plot(AUC,main=paste(spp,"_AUC",sep=""))
  dev.off()
  print(spp);print("done")
} 


# Output the compiled list of statistics to an "output" directory
#set the directory 
setwd(output_dir)
write.csv(Summary_Stats_Compiled,file="Compiled_Summary_Statistics.csv")
write.table(Summary_Stats_Compiled,file="Compiled_Summary_Statistics.txt",sep="\t")

########################################################################################################
# 6. Run explained deviance calculations for each model. 

#libraries needed
library(utils)
library(mgcv)
library(pROC)
library(plyr)

#setting the working directory to df
setwd(spp_dir) 

#species levels
species<-levels(data$Species) 

#Deviance Partitioning
Exp_Dev_Output<-data.frame(NULL)
for (spp in species){
  Spp_name<-spp
  #bringing in data to fit the model.
  dat<-read.csv(paste(spp,"_records.csv",sep=""))
  #removing the species name column just for the run.
  dat<-dat[-6] #make sure this number is correct.
  dat=dat[complete.cases(dat),]
  #fitting a model for each predictor variable to assess independent explained variance. 
  #Note that we will need to change the environmental varaibles based on what the inputs will be.
  D<-gam(PA~s(Depth,bs="ts"),family=binomial("logit"),scale=0,data=dat,method="GCV.Cp")
  D_ind_exp_dev<-(D$null.deviance-D$deviance)/D$null.deviance
  R<-gam(PA~s(Rugosity,bs="ts"),family=binomial("logit"),scale=0,data=dat,method="GCV.Cp")
  R_ind_exp_dev<-(R$null.deviance-R$deviance)/R$null.deviance
  ST<-gam(PA~s(st,bs="ts"),family=binomial("logit"),scale=0,data=dat,method="GCV.Cp")
  ST_ind_exp_dev<-(ST$null.deviance-ST$deviance)/ST$null.deviance
  BT<-gam(PA~s(bt,bs="ts"),family=binomial("logit"),scale=0,data=dat,method="GCV.Cp")
  BT_ind_exp_dev<-(BT$null.deviance-BT$deviance)/BT$null.deviance
  SS<-gam(PA~s(SS,bs="ts"),family=binomial("logit"),scale=0,data=dat,method="GCV.Cp")
  SS_ind_exp_dev<-(SS$null.deviance-SS$deviance)/SS$null.deviance 
  BS<-gam(PA~s(bs,bs="ts"),family=binomial("logit"),scale=0,data=dat,method="GCV.Cp")
  BS_ind_exp_dev<-(BS$null.deviance-BS$deviance)/BS$null.deviance
  ##systematically refitting the full model minus each term to figure out the partial effect
  #Note that we will need to change the environmental varaibles based on what the inputs will be.
  #fitting the full model
  full<-gam(PA ~ s(Depth,bs="ts")+s(Rugosity,bs="ts")+s(st,bs="ts")+s(SS,bs="ts")+s(bs,bs="ts")+s(bt,bs="ts"),family=binomial("logit"),scale=0,select=TRUE,data=dat,method="GCV.Cp")
  #fitting the null model, i.e., a model with no predictors to evaluate explained variance. 
  null<-gam(PA ~ 1 ,family=binomial("logit"),scale=0,select=TRUE,data=dat,method="GCV.Cp")
  #calculating partial deviance for each predictor
  D_partial_exp_dev<-(deviance(D)-deviance(full))/deviance(null)
  R_partial_exp_dev<-(deviance(R)-deviance(full))/deviance(null)
  ST_partial_exp_dev<-(deviance(ST)-deviance(full))/deviance(null)
  BT_partial_exp_dev<-(deviance(BT)-deviance(full))/deviance(null)
  SS_partial_exp_dev<-(deviance(SS)-deviance(full))/deviance(null)
  BS_partial_exp_dev<-(deviance(BS)-deviance(full))/deviance(null)
  Combined_Exp_Dev<-cbind(Spp_name,D_ind_exp_dev,R_ind_exp_dev,ST_ind_exp_dev,BT_ind_exp_dev,SS_ind_exp_dev,BS_ind_exp_dev,D_partial_exp_dev,R_partial_exp_dev,ST_partial_exp_dev,BT_partial_exp_dev,SS_partial_exp_dev,BS_partial_exp_dev)
  Exp_Dev_Output<-rbind(Combined_Exp_Dev,Exp_Dev_Output)}

# Output the compiled list of deviance partitioning statistics to an "output" directory
#set the directory 
setwd(output_dir)
Summary_Stats_Deviance_Part<-join(Summary_Stats_Compiled,Exp_Dev_Output,by="Spp_name")
write.csv(Summary_Stats_Deviance_Part,file="Summary_Stats_and_Deviance_Partitioning.csv")  


############################################################################################################  
# 7. Crossvalidate each model using kfold cross validation 

#libraries needed
library(mgcv)
library(pROC)
library(base)
library(caTools)
library(DiceEval)

#setting the directory
setwd(spp_dir) 

#species levels
species<-levels(data$Species) 

#Running k-fold cross-validation
Compiled_CV_Output=as.data.frame(NULL)
for (spp in species){
  #bringing in data to fit the model.
  dat<-read.csv(paste(spp,"_records.csv",sep=""))
  #removing the species name column just for the run.
  dat=dat[-6] #make sure this number is correct.
  dat=dat[complete.cases(dat),]
  CV_Output=as.data.frame(NULL)
  K_Fold<-1:10  # this can be jacked up as much as we want. It will take longer, but will ultimately smooth out the errors.
  print(spp) 
  for (k in K_Fold){
    Fold_num=k
    #splitting the presences into 75% training data and 25% testing data
    dat_cv_pres=subset(dat,dat$PA>0)
    dat_cv_abs=subset(dat,dat$PA==0)
    #Presences
    #75% training data 25% testing data
    sample=floor(0.75*nrow(dat_cv_pres))
    train_ind<-sample(seq_len(nrow(dat_cv_pres)),size=sample)
    #training presence data
    train_pres<-dat_cv_pres[train_ind,]
    #testing presence data
    test_pres<-dat_cv_pres[-train_ind,]
    # #Absences
    #75% training data 25% testing data
    sample=floor(0.75*nrow(dat_cv_abs))
    train_ind<-sample(seq_len(nrow(dat_cv_abs)),size=sample)
    #training presence data
    train_abs<-dat_cv_abs[train_ind,]
    #testing presence data
    test_abs<-dat_cv_abs[-train_ind,]
    #Joining PA data for training and testing
    train<-rbind(train_pres,train_abs)
    test<-rbind(test_pres,test_abs)
    #fitting the training model
    train_fit<-gam(PA ~s(Depth,bs="ts")+s(Rugosity,bs="ts")+s(st,bs="ts")+s(SS,bs="ts")+s(bs,bs="ts")+s(bt,bs="ts"),family=binomial("logit"),data=train,method="GCV.Cp")
    train_predict<-predict.gam(train_fit,type=c("response"),se.fit=TRUE)
    train<-cbind(train,train_predict)
    AUC_train<-roc(PA~fit,data=train)
    AUC_train<-as.numeric(AUC_train$auc)
    #fitting predicting with testing data
    test_predict<-predict.gam(train_fit,test,type=c("response"),se.fit=TRUE)
    test<-cbind(test,test_predict)
    AUC_test<-roc(PA ~ fit,data=test)
    AUC_test=as.numeric(AUC_test$auc)
    #getting a predictive r-squared
    Predictive_Power=R2(test$PA,test$fit)
    Output=as.data.frame(cbind(spp,Fold_num,AUC_train,AUC_test,Predictive_Power))
    CV_Output<-rbind(Output,CV_Output)
    print("done")
  }
  Compiled_CV_Output<-rbind(CV_Output,Compiled_CV_Output)
  print(spp);print("done")
}


# Extract the mean, stdev, and SE for cross-valdiation statistics
#convert to a useable numeric format
CV_Output=Compiled_CV_Output
CV_Output$AUC_test<-as.numeric(levels(CV_Output$AUC_test)[CV_Output$AUC_test])
CV_Output$AUC_train<-as.numeric(levels(CV_Output$AUC_train)[CV_Output$AUC_train])
CV_Output$Predictive_Power<-as.numeric(levels(CV_Output$Predictive_Power)[CV_Output$Predictive_Power])

#Calculate the statistic by species
#mean
test_mean<-tapply(CV_Output$AUC_test,CV_Output$spp,mean)
train_mean<-tapply(CV_Output$AUC_train,CV_Output$spp,mean)
pred_power_mean<-tapply(CV_Output$Predictive_Power,CV_Output$spp,mean)
#variance
test_var<-tapply(CV_Output$AUC_test,CV_Output$spp,var)
train_var<-tapply(CV_Output$AUC_train,CV_Output$spp,var)
pred_power_var<-tapply(CV_Output$Predictive_Power,CV_Output$spp,var)
#stdev
test_stdev<-sqrt(test_var)
train_stdev<-sqrt(train_var)
pred_power_stdev<-sqrt(train_var)
#sample size
n<-max(k)
#standard error
test_se<-test_stdev/sqrt(n)
train_se<-train_stdev/sqrt(n)
pred_power_se<-pred_power_stdev/sqrt(n)

#Compile statistics
Summary_CrossValdiation_Statistics_t<-rbind(train_mean,train_stdev,train_se,test_mean,test_stdev,test_se,pred_power_mean,pred_power_stdev,pred_power_se,n)
Summary_CrossValdiation_Statistics<-as.data.frame(t(Summary_CrossValdiation_Statistics_t))
Summary_CrossValdiation_Statistics$Species<-rownames(Summary_CrossValdiation_Statistics)
rownames(Summary_CrossValdiation_Statistics)<-NULL


#set the directory for output
setwd(output_dir)
write.csv(Summary_CrossValdiation_Statistics,file="Cross_Validation_Outputs.csv")



############################################################################################################
# 8. Project species distributions at monthly and decadal time slices
###NOTE THAT THE PROJECTION SCRIPT STILL NEEDS TO BE ADAPTED. 

#libraries needed
library(raster)

#set the directory
setwd(output_dir)

#species levels
species<-levels(data$Species) 

# time_slice<-c("m01_y2020") ## add in names of the folders containing the decadal time steps

months<-c(01,02,03,04,05,06,07,08,09,10,11,12)

for (spp in species){
  setwd(output_dir)
  Summary_Stats=read.table(paste("GAM_Output_",spp,".txt",sep=""),sep="\t")
  if (Summary_Stats$Model_Exp_Dev>=0.2){ ## set cutoff based on how much explained variance
    setwd(spp_dir)
    dat<-read.csv(paste(spp,"_records.csv",sep=""))
    #make sure to change the predictor variable names here
    final_object<-gam(PA ~s(MAXDEPTH,bs="ts")+s(SURFTEMP,bs="ts")+s(BOTTEMP,bs="ts")+s(SURFSALIN,bs="ts")+s(BOTSALIN,bs="ts"),family=binomial("logit"),scale=0,data=dat,method="GCV.Cp")
      for (season in seasons){
        setwd(raster_dir)
        MAXDEPTH<-raster("crm_rs_01.tif")
        SURFSALIN<-raster("sal_0_m.tif")
        BOTSALIN<-raster("sal_2_m.tif")
        SURFTEMP<-raster("t_0_m.tif")
        BOTTEMP<-raster("t_2_m.tif")
        rasterStack<-stack(MAXDEPTH,SURFSALIN,BOTSALIN,SURFTEMP,BOTTEMP)
        names(rasterStack)<-c("MAXDEPTH","SURFSALIN","BOTSALIN","SURFTEMP","BOTTEMP")
        setwd(paste(dir))
        raster::predict(rasterStack,final_object,filename=paste(spp,"_",season,".tif",sep=""),na.rm=TRUE,overwrite=TRUE) #datatype="LOG1S"
        print(spp);print("done")
      }
  }
  else pass
}
