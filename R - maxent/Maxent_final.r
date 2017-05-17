#####code for running maxent from raw csvs to final asciis
####prequisets
#1. Asciis for each environmental variable in folders 'project/month' within wd
#2. SWD csvs (records pre-associated with ambient env.vars)
#3. Maxent Executable Jar File in working directory

setwd("B:/BOEM_Data/BOEM_Methods_Trials/Heather_working/blackseabass")


###########01. batch read in SWDs
######Place all SDW csvs in the same directory
######Saves all csvs as objects called by their original name

library(tools)

for (csv in list.files('B:/BOEM_Data/BOEM_Methods_Trials/Heather_working/blackseabass/csv_trials',pattern=".csv$")){ #for all the csv files in a given directory
  no_extention=file_path_sans_ext(csv) #grab the file name, drop the .csv extension
  name=paste(no_extention,sep="")
  table=read.csv(paste("B:/BOEM_Data/BOEM_Methods_Trials/Heather_working/blackseabass/csv_trials/",csv,sep="")) #read in the csv
  assign(name,table) #save the read in csv as a new object name "original_csv_name_copy" (you can get rid of the copy if you want)
}


###########02. Convert CSVS to long - one df at a time
##edit this script as needed for each csv
######keep working on this code
WH_counts_reorder<-WH_counts_wide[,c(216,1:19,24:28,20:23,212,215,217:229,29:208)] ##put env.vars and species.vars together
names(WH_counts_reorder)

library(tidyr) ## rearrange the dataset using the gather function from the tidyr library, where the function format is gather(df_wide,key, value, V1:V...)
WH_counts_long <- gather(WH_counts_reorder, species_name, presence, sealamprey:loggerhead) ##reorganizes csv, last two columns will be species_name and presence

  
###########03. Move last two columns "species_name", "presence" to front of dataframe
library(dplyr)
for (i in ls(pattern="seabass*")) { #use pattern arg to stratify objects
  dat=get(i) #grab the data behind the object
  select(species_name,presence,everything()) #place these two columns in front of all data
  assign(i,dat) #give the object it's original name back
}
  
 
###########04. Subset by species and put records in unique species folders  - one df at a time
df=i #it will be one of the read in data.frames
spp=levels(df$species_name)
models=paste(getwd(),"/models",sep="");dir.create(models) ##create a new directory to work from
survey=paste(getwd(),"/models/",df,sep="");dir.create(survey) ##create a new directory for each survey csv

for (spp in species){ ###making folders for each species and writing out records  - one df at a time
  spp.folder = paste(getwd(),"/models/",df,"/",spp,"/",sep="");dir.create(spp.folder) #new folder for each species
  out.folder=paste(spp.folder,"/","weather","/",sep="");dir.create(out.folder) #folder called 'weather' within each species folder for model outputs
  dat=df[df$species_name==spp,] #new object for each species subset
  name=paste(spp,"_records",sep="") #rename object as species*name_records
  assign(name,dat) #rename object as species*name_records
  write.csv(df[df$species_name==spp,],paste(spp.folder,name,".csv",sep=""),row.names=F,na="") #write out csv of records for each species in species folder
}


###########05. Take species subsets and divide them into presences and absences  - one df at a time
for (i in ls(pattern="*records")){ #use pattern arg to stratify objects
  dat=get(i) #grab data behind object
  write.csv(i[i$presence==0,],paste(spp.folder,"weather.bkgd.csv",sep=""),row.names=FALSE,na="") #write out absences
  write.csv(i[i$presence>0,],paste(spp.folder,"weather.occur.csv",sep=""),row.names=FALSE,na="") #write out presences
  }


###########06. Run maxent - one df at a time
species = levels(df$species_name) #identify species
for (spp in species){
  max_out=paste(getwd(),"/models/",df,"/",spp,"/weather",sep="") #define folder for model outputs
  presence=paste(getwd(),"/models/",df,"/",spp,"/weather.occur.csv",sep="") #define presence csvs
  bkgd=paste(getwd(),"/models/",df,"/",spp,"/weather.bkgd.csv",sep="") #define absence csvs
  run=paste("java -mx1024m -jar maxent.jar jackknife=true environmentallayers=",bkgd," samplesfile=",presence," outputdirectory=",max_out," togglelayerselected=presence nowarnings notooltips redoifexists novisible autorun",sep="")
  print(run)
  system(command=paste(run))
}
	
	
###########07. Project models onto monthly environmental layers - one df at a time
project.list = list.files(paste(getwd(),"/projections/",sep=""),full.names=TRUE) ##identify folders with the asciis with pathways
month.list=list.files(paste(getwd(),"/projections/",sep="")) #grab list of months
species = levels(df$species_name) #identify species
for (spp in species){
  lambdas=paste(getwd(),"/models/",df,"/",spp,"/weather/",spp,".lambdas",sep="") #grab each lambdas file (describes each model built in step 06)
  for (month in month.list){
    grid.dir=paste(getwd(),"/projections/",month,sep="")
    out.dir=paste(getwd(),"/models/",df,"/",spp,"/weather/",spp,"_",month,sep="");#dir.create(out.dir)
    run=paste("java -cp maxent.jar density.Project ",lambdas," ",grid.dir," ",out.dir," togglelayerselected=presence fadebyclamping grd nowarnings notooltips redoifexists novisible autorun",sep="")
    system(command=paste(run))
  }
}

	

