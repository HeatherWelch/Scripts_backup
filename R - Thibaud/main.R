###############################################################################################
### Main script for the calculation of the relative importance of the factors
###############################################################################################

### Library
library(mvtnorm)
library(fields)
library(gam)
library(ROCR) # for AUC
library(ltm) # for point biserial correlation
library(randomForest)
library(RandomFields)
library(dismo) # for MaxEnt
library(snowfall) # for parallel computing
library(nlme) # for fitting linear mixed-effects model

### Source files containning fonctions to run the simulations 
source("functionsFI.R")
source("plot_results.R")
source("anova.R")
source("save_matrixresults.R")
source("factor_importance_R2.R")

### Paths
path.main <- ".../FactorImportance" # main directory with R script files and data files
path.species <- ".../FactorImportance/SpeciesSimulations" # directory to save the files of virtual species
path.datasets <- ".../FactorImportance/DataSets" # directory to save the files of datasets
path.results <- ".../FactorImportance/Results" # directory to save the files of the results

### Load data
load(paste(path.main,"/pred_VD.Rdata",sep='')) # matrix with the 5 predictors in VD
load(paste(path.main,"/datasp_VD.Rdata",sep='')) # data of the 10 real species in VD
load(paste(path.main,"/distroad_VD.Rdata",sep='')) # distance to roads (VD)


###############################################################################################
### Run the simulation and analysis of the results in VD
###############################################################################################

### Create virtual species
source("create_species.R")

### Create datasets
listfiles <- dir(path.species)
lapply(listfiles,create_datasets,range.sac=0.5,vbias=distroad_VD)

### Apply techniques
listfiles <- dir(path.datasets)
lapply(listfiles,fit_glm) # GLM
lapply(listfiles,fit_gam) # GAM
lapply(listfiles,fit_rf) # RF
lapply(listfiles,fit_maxent) # MaxEnt

# ### ----- Using snowfall (parallel computing) -----
# sfInit(parallel=TRUE, cpus=8) # parallel computing on 8 cpus

# ### Export all the variables to the cpus
# sfExportAll()

# ### Export these library to the cpus
# sfLibrary(mvtnorm)
# sfLibrary(fields)
# sfLibrary(gam)
# sfLibrary(ROCR)
# sfLibrary(ltm)
# sfLibrary(randomForest)
# sfLibrary(RandomFields)
# sfLibrary(dismo)
# sfLibrary(snowfall)

# ### Create datasets
# listfiles <- dir(path.species)
# sfLapply(listfiles,create_datasets,range.sac=0.5,vbias=distroad_VD)

# ### Apply techniques
# listfiles <- dir(path.datasets)
# sfLapply(listfiles,fit_glm)
# sfLapply(listfiles,fit_gam)
# sfLapply(listfiles,fit_rf)
# sfLapply(listfiles,fit_maxent)

# sfStop()
# ### ----- End of snowfall -----

### Results
# CreateMatResults(path.res=path.results,file.res='FI-VD.Rdata') # create the matrix of the results by reading the files in path.results
load(file='FI-VD.Rdata') # load the results discussed in the paper

### Analyze the results
plot_results(file='FI-VD.Rdata', dest='.../VD-') # create some graphs as in the paper (graphs will be saved in the directory dest)
anova.FI(file='FI-VD.Rdata', tex='ANOVA_VD.txt') # table of ANOVA
factor_importance_R2(file='FI-VD.Rdata',tex='R2_VD.txt') # calculate the coefficients of determination R2
factor_importance_llik(file='/Users/emeric/Dropbox/R outputs/FI-VD.Rdata') # calculate the log-likelihood differences



###############################################################################################
### Supporting Information: varying the strenght of SAC (5, 10 and 15 km)
###############################################################################################

### The code below does not use snowfall

path.results <- ".../FactorImportance/variousSAC/Results"
path.datasets <- ".../FactorImportance/variousSAC/DataSets"

### Create Datasets
listfiles <- dir(path.species)
# range.sac=1.67 corresponds to 5 km
# range.sac=3.34 corresponds to 10 km
# range.sac=5 corresponds to 15 km
lapply(listfiles,create_datasets,range.sac=1.67,vbias=distroad_VD) # for 5 km

### Apply techniques
listfiles <- dir(path.datasets)
lapply(listfiles,fit_glm) #GLM
lapply(listfiles,fit_gam) #GAM
lapply(listfiles,fit_rf) #RF
lapply(listfiles,fit_maxent) #MaxEnt

# CreateMatResults(path.res=path.results,file.res='FI-VD5.Rdata')
anova.FI(file='FI-VD5.Rdata')
factor_importance_R2(file='FI-VD5.Rdata')
factor_importance_llik(file='FI-VD5.Rdata')

# Results for 10 km and 15 km are in 'FI-VD10.Rdata' and 'FI-VD15.Rdata'.


###############################################################################################
### Supporting Information: validation in TI, EN and NE
###############################################################################################
source("/Users/emeric/Dropbox/Phd/R/FactorImportance/extern_valid.R")

##############
##### TI #####
##############
load(paste(path.main,"/pred_TI.Rdata",sep='')) # load the predictors for TI
path.datasets_ext <- ".../FactorImportance/External/TI/DataSets" # directory to save the datasets
path.results_ext <- ".../FactorImportance/External/TI/Results" # directory to save the results

sfInit(parallel=TRUE, cpus=8)
sfExportAll()

sfLibrary(mvtnorm)
sfLibrary(fields)
sfLibrary(gam)
sfLibrary(ROCR)
sfLibrary(ltm)
sfLibrary(randomForest)
sfLibrary(RandomFields)
sfLibrary(dismo)
sfLibrary(snowfall)

listfiles <- dir(path.species)
sfLapply(listfiles,extern_valid,pred_ext=pred_TI)

listfiles <- dir(path.datasets_ext)
sfLapply(listfiles,fit_glm)
sfLapply(listfiles,fit_gam)
sfLapply(listfiles,fit_rf)
sfLapply(listfiles,fit_maxent)

sfStop()

### Results
# CreateMatResults(path.res=path.results_ext,file.res='FI-VD-extTI.Rdata')
anova.FI(file='FI-VD-extTI.Rdata')
factor_importance_R2(file='FI-VD-extTI.Rdata')
factor_importance_llik(file='FI-VD-extTI.Rdata')

##############
##### EN #####
##############
load(paste(path.main,"/pred_EN.Rdata",sep='')) # load the predictors for EN
path.datasets_ext <- ".../FactorImportance/External/EN/DataSets" # directory to save the datasets
path.results_ext <- ".../FactorImportance/External/EN/Results" # directory to save the results

sfInit(parallel=TRUE, cpus=8)
sfExportAll()

sfLibrary(mvtnorm)
sfLibrary(fields)
sfLibrary(gam)
sfLibrary(ROCR)
sfLibrary(ltm)
sfLibrary(randomForest)
sfLibrary(RandomFields)
sfLibrary(dismo)
sfLibrary(snowfall)

listfiles <- dir(path.species)
sfLapply(listfiles,extern_valid,pred_ext=pred_EN)

listfiles <- dir(path.datasets_ext)
sfLapply(listfiles,fit_glm)
sfLapply(listfiles,fit_gam)
sfLapply(listfiles,fit_rf)
sfLapply(listfiles,fit_maxent)

sfStop()

### Results
# CreateMatResults(path.res=path.results_ext,file.res='FI-VD-extEN.Rdata')
anova.FI(file='FI-VD-extEN.Rdata')
factor_importance_R2(file='FI-VD-extEN.Rdata')
factor_importance_llik(file='FI-VD-extEN.Rdata')

##############
##### NE #####
##############
load(paste(path.main,"/pred_NE.Rdata",sep='')) # load the predictors for NE
path.datasets_ext <- ".../FactorImportance/External/NE/DataSets" # directory to save the datasets
path.results_ext <- ".../FactorImportance/External/NE/Results" # directory to save the results

sfInit(parallel=TRUE, cpus=8)
sfExportAll()

sfLibrary(mvtnorm)
sfLibrary(fields)
sfLibrary(gam)
sfLibrary(ROCR)
sfLibrary(ltm)
sfLibrary(randomForest)
sfLibrary(RandomFields)
sfLibrary(dismo)
sfLibrary(snowfall)

listfiles <- dir(path.species)
sfLapply(listfiles,extern_valid,pred_ext=pred_NE)

listfiles <- dir(path.datasets_ext)
sfLapply(listfiles,fit_glm)
sfLapply(listfiles,fit_gam)
sfLapply(listfiles,fit_rf)
sfLapply(listfiles,fit_maxent)

sfStop()

### Results
# CreateMatResults(path.res=path.results_ext,file.res='FI-VD-extNE.Rdata')
anova.FI(file='FI-VD-extNE.Rdata')
factor_importance_R2(file='FI-VD-extNE.Rdata')
factor_importance_llik(file='FI-VD-extNE.Rdata')
