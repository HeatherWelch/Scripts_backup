############################making a gam results dataframe
#############section 1. will need to be updated to grab stats for more than one variable
## 1. extract test statistics
species=file_path_sans_ext(list.files()) ## get list of species (this will be a folder w all the csvs for each species)
dataF=data.frame() # create empty data frame
for(sp in species){
  dat=get(sp)
  summ=summary(dat)$s.table
  df=data.frame(matrix(unlist(summ),nrow=1,byrow=T))
  df$spp=sp # add new column for species name
  dataF=rbind(dataF,df) # iteratively update dataframe
}
write.csv(dataF,file="test_stats.csv")


## 2. read data back in, objects replaced by gams
setwd("F:/Climate_paper/GAM_trial/species_SSS")
library(tools)
for(csv in list.files(pattern="*.csv$")){
  no_extention=file_path_sans_ext(csv)
  name=paste(no_extention,"_df",sep="")
  temp=read.csv(csv,header=TRUE,sep=",")
  assign(name,temp)
}

## 3. extracting numbers of presence/absences
setwd("F:/Climate_paper/GAM_trial/species_SSS")
species=file_path_sans_ext(list.files()) ## get list of species
dataframes=ls(pattern="*_df")
for(sp in species){
  for(df in dataframes){
    if(grepl(sp,df)==TRUE){
      dat=get(df)
      pres=length(which(dat[,10]==1)) #update to p_a column position as needed
      abs=length(which(dat[,10]==0)) #update to p_a column position as needed
      dataF$presence[which(dataF$spp==sp)]=pres #presence column for each species
      dataF$absence[which(dataF$spp==sp)]=abs #absence column for each specie
    }
  }
}

## 4. calculating AUCS
library(pROC)
for(sp in species){
  dataframe=paste(sp,"_df",sep="")
  dataS=get(dataframe)
  dat=dataS[complete.cases(dataS),]
  gm=get(sp)
  prob=predict(gm,type=c("response"))
  dat$prob=prob
  g=roc(p_a~prob,data=dat)
  name=paste(sp,"_AUC",sep="")
  assign(name,g)
}

## 5. adding AUCs to dataF
for(file in ls(pattern="*_AUC")){
  sp=gsub("_AUC","",file)
  dat=get(file)
  auc=as.numeric(dat["auc"])
  dataF$auc[which(dataF$spp==sp)]=auc
}

