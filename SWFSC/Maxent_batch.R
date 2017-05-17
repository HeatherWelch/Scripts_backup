#####code for running maxent from raw csvs to final asciis
####prequisets
#1. Asciis for each environmental variable in folders 'project/month' within wd
#2. SWD csvs (records pre-associated with ambient env.vars)

setwd("F:/SDM_paper/maxent/Maxent_run")


###########01. batch read in SWDs
######Place all SDW csvs in the same directory
######Saves all csvs as objects called by their original name

library(tools)

for (csv in list.files(getwd(),pattern=".csv$")){ #for all the csv files in a given directory
  no_extention=file_path_sans_ext(csv) #grab the file name, drop the .csv extension
  name=paste(no_extention,sep="")
  table=read.csv(paste(getwd(),"/",csv,sep="")) #read in the csv
  assign(name,table) #save the read in csv as a new object name "original_csv_name_copy" (you can get rid of the copy if you want)
}


###########02. Convert CSVS to long - one df at a time
library(tidyr) ## rearrange the dataset using the gather function from the tidyr library, where the function format is gather(df_wide,key, value, V1:V...)
WH_trawl_long <- gather(WH_trawl_habvars, species_name, presence, d1:d897) ##reorganizes csv, last two columns will be species_name and presence

  
###########03. Move last two columns "species_name", "presence" to front of dataframe
library(dplyr)
for (i in ls(pattern="WH_trawl_long*")) { #use pattern arg to stratify objects
  dat=get(i) #grab the data behind the object
  reorder=select(dat,species_name,presence,everything()) #place these two columns in front of all data
  assign(i,reorder) #give the object it's original name back
}
  
 
###########04. Subset by species and put records in unique species folders  - one df at a time
df="WH_trawl_long" #it will be one of the read in data.frames
models=paste(getwd(),"/models",sep="");#dir.create(models) ##create a new directory 'models' to work from
survey=paste(getwd(),"/models/",df,sep="");#dir.create(survey) ##create a new directory for each survey csv (in this case 'WH_trawl_long')

species=levels(WH_trawl_long$species_name) #grab the names of each species
for (spp in species){ ###making folders for each species and writing out records  - one df at a time
  spp.folder = paste(getwd(),"/models/",df,"/",spp,"/",sep="");#dir.create(spp.folder) #new folder for each species
  out.folder=paste(spp.folder,"/","weather","/",sep="");#dir.create(out.folder) #folder called 'weather' within each species folder for model outputs
  dat=WH_trawl_long[WH_trawl_long$species_name==spp,] #new object for each species subset
  name=paste(spp,"_records",sep="") #rename object as species*name_records
  assign(name,dat) #rename object as species*name_records
  #write.csv(WH_trawl_long[WH_trawl_long$species_name==spp,],paste(spp.folder,name,".csv",sep=""),row.names=F,na="") #write out csv of records for each species in species folder
}


###########05. Take species subsets and divide them into presences and absences  - one df at a time
species=levels(WH_trawl_long$species_name)
for (spp in species){
  name=paste(spp,"_records",sep="")
  object=ls(pattern=name) #identify the object for each species subset of records
  dat=get(object) #grab data behind object
  spp.folder = paste(getwd(),"/models/",df,"/",spp,"/",sep="") #identify correct species folder to put following csvs in
  abs=dat[dat$presence==0,] #remove presence column
  a_remove=abs[,-2]#remove presence column
  write.csv(a_remove,paste(spp.folder,"weather.bkgd.csv",sep=""),row.names=FALSE,na="") #write out absences
  pres=dat[dat$presence>0,]#remove presence column
  p_remove=pres[,-2]#remove presence column
  write.csv(p_remove,paste(spp.folder,"weather.occur.csv",sep=""),row.names=FALSE,na="") #write out presences
  }


###########06. Run maxent - one df at a time
species=levels(WH_trawl_long$species_name) #identify species
for (spp in species){
  max_out=paste(getwd(),"/models/",df,"/",spp,"/weather",sep="") #define folder for model outputs
  presence=paste(getwd(),"/models/",df,"/",spp,"/weather.occur.csv",sep="") #define presence csvs
  bkgd=paste(getwd(),"/models/",df,"/",spp,"/weather.bkgd.csv",sep="") #define absence csvs
  run=paste("java -mx1024m -jar maxent.jar responsecurves=true environmentallayers=",bkgd," samplesfile=",presence," outputdirectory=",max_out," addsamplestobackground=false nowarnings notooltips redoifexists novisible autorun",sep="")
  print(run)
  system(command=paste(run))
}
	

########06.5 Grabbing AUCs for each model and combining them into one dataset. 
species=levels(WH_trawl_long$species_name) #identify species
AUC<-NULL
for (spp in species){
  AUC[[spp]]<-read.csv(paste(getwd(),"/models/",df,"/",spp,"/weather","/maxentResults.csv",sep=""))
}

AUC_table<- do.call(rbind,AUC)
write.csv(AUC_table,file="maxentResults_compiled.csv")

	
###########07. Project models onto monthly environmental layers - one df at a time
maxentResults_compiled_high_AUCs=read.csv("maxentResults_compiled_high_AUCs.csv")#read in the maxent results csv, contains a list of species w ones w AUCs <.7 removed
species=levels(maxentResults_compiled_high_AUCs$Species)
project.list = list.files(paste(getwd(),"/projections/",sep=""),full.names=TRUE) ##identify folders with the asciis with pathways
month.list=list.files(paste(getwd(),"/projections/",sep="")) #grab list of months
#species = levels(df$species_name) #identify species
for (spp in species){
  lambdas=paste(getwd(),"/models/",df,"/",spp,"/weather/",spp,".lambdas",sep="") #grab each lambdas file (describes each model built in step 06)
  for (month in month.list){
    grid.dir=paste(getwd(),"/projections/",month,sep="")
    out.dir=paste(getwd(),"/models/",df,"/",spp,"/weather/",spp,"_",month,sep="");#dir.create(out.dir)
    run=paste("java -cp maxent.jar density.Project ",lambdas," ",grid.dir," ",out.dir," togglelayerselected=presence grd nowarnings notooltips redoifexists novisible autorun",sep="")
    system(command=paste(run))
  }
}

	

