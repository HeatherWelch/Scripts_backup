## Batch GAMs
# Prepare species records for modeling, fit models, extract summary statistics to evaluate models
# environmental variables abbreviations: s/bt: surface/bottom temp, s/bs: surface/bottom salinity, sh: surface height

library(stringr)
library(dplyr)
library(tools)
library(mgcv)
library(pROC)

# 1. Read in all species records
setwd("G:/Scripts/SWFSC") # directory where sp_records.csv sits
records=read.csv("sp_records.csv")

# 2. Convert to p/a, write out seperate record csv for each species
species=levels(records$Species)
spp_dir=paste(getwd(),"/Species_CSVs",sep="");dir.create(spp_dir)

for(sp in species){
  print(sp)
  presence=subset(records,records$Species==sp) # presences
  absence=subset(records,records$Species!=sp)
  abs=distinct(absence,m_unique,.keep_all=TRUE) #abs=absence%>%distinct(m_unique) # http://stackoverflow.com/questions/25571547/select-unique-values-with-select-function-in-dplyr-library
  ab=abs[!(abs$m_unique %in% presence$m_unique),] #final absences, unique, no points from presence
  presence$p_a=1 #binary
  ab$p_a=0 #binary
  complete=rbind(presence,ab)
  output=paste(sp,".csv",sep="")
  write.csv(complete,file=paste(spp_dir,"/",output,sep=""))
}  

# 3. Read in individual species records
setwd(spp_dir)
for (csv in list.files(getwd(),pattern=".csv$")){ #for all the csv files in a given directory
    no_extention=file_path_sans_ext(csv) #grab the file name, drop the .csv extension
    name=paste(no_extention,sep="")
    table=read.csv(paste(getwd(),"/",csv,sep="")) #read in the csv
    assign(name,table) #save the read in csv as a new object 
  }

# 4. Run GAMs
output_dir=paste(getwd(),"/Model_Outputs",sep="");dir.create(output_dir)
setwd(output_dir)
Summary_Stats_Compiled<-NULL #For Summary Statistics

#Running the gam model for each species, extracting summary statistics
for (spp in species){
  dat=get(spp)
  dat=dat[complete.cases(dat),]
  fit=gam(p_a ~s(Depth,bs="ts")+s(Rugosity,bs="ts")+s(st,bs="ts")+s(SS,bs="ts")+s(bs,bs="ts")+s(bt,bs="ts")+s(sh,bs="ts"),family=binomial("logit"),scale=0,data=dat,method="GCV.Cp") #shrinking splines to shrink the influence of terms to zero, GCV to evaluate appropriate smoothness of terms
  print(paste(spp," model fit done",sep=""))
  
  #Making a summary statistics table for outputting
  Spp_name<-spp
  Pres_Records<-sum(subset(dat$p_a,dat$p_a>0))
  Model_Exp_Dev<-(fit$null.deviance-fit$deviance)/fit$null.deviance
  Model_Rsqd<-summary(fit)$r.sq
  Model_Pvalue<-summary(fit)$p.pv
  GCV<-fit$gcv 
  s.table<-as.data.frame(t(summary(fit)$s.table))#putting out pvalues, chi-squared values, edf, and ref.dfs from the statistics table
  Pvalues<-s.table[4,];colnames(Pvalues)<-paste("Pval",colnames(Pvalues),sep="_")
  Chi.sq<-s.table[3,];rownames(Chi.sq)<-NULL;colnames(Chi.sq)<-paste("Chi",colnames(Chi.sq),sep="_")
  edf<-s.table[1,];rownames(edf)<-NULL;colnames(edf)<-paste("edf",colnames(edf),sep="_")
  
  #pulling out information on concurvity, or the effect of multicolinearity on the model terms
  #according to the concurvity() tool from mgcv library, concurvity increases between 0-1.
  #meaning that values closer to 1 indicate a high influence of multicolinearity. 
  Con<-concurvity(fit,full=TRUE);colnames(Con)[1]<-c("Concurvity_para")
  Con_Est<-t(as.data.frame(Con[3,]));rownames(Con_Est)<-NULL;colnames(Con_Est)<-paste("Conc",colnames(Con_Est),sep="_")
  
  #generating the AUC for the model statistic output
  prob<-predict(fit,type=c("response"))
  dat$prob=prob
  AUC<-roc(p_a ~ prob,data=dat)
  Model_AUC<-AUC$auc
  Summary_Stats<-cbind(Spp_name,Pres_Records,Model_Exp_Dev,Model_Rsqd,Model_Pvalue,Model_AUC,GCV,Pvalues,Chi.sq,edf,Con_Est);rownames(Summary_Stats)<-NULL
  Summary_Stats_Compiled<-rbind(Summary_Stats_Compiled,Summary_Stats)
  write.table(Summary_Stats,file=paste("GAM_Output_",spp,".txt",sep=""),sep="\t",col.names=TRUE)
  
  #exporting the partial residual plots
  jpeg(paste(spp,"_partial_residual_plots.jpeg",sep=""))
  plot.gam(fit,residuals=TRUE,se=TRUE,pages=1,scale=0,shade=TRUE,shade.col='green',seWithMean=TRUE)
  dev.off()
  
  #exporting the AUC plots for each species
  jpeg(paste(spp,"_AUC.jpeg",sep=""))
  plot(AUC,main=paste(spp,"_AUC",sep=""))
  dev.off()
  print(paste(spp," summary stats done",sep=""))
} 

write.csv(Summary_Stats_Compiled,file="Summary_Stats_Compiled.csv") 

