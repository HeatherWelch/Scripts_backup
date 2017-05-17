####ignore this shit

occur.file = 'SWD_no_velocity_for_modelling.csv' ; occur = read.csv(occur.file)
occur = occur[,c(1,4:15)]
bkgd = occur
bkgd[,1] = "bkgd"
bkgd = unique(bkgd)
write.csv(bkgd, "weather.bkgd.csv",row.names=F)
species = levels(occur$Common_name)

for (spp in species) {
  spp.folder = paste(spp,"/",sep="");dir.create(spp.folder)
  out.folder=paste(spp.folder,"/","weather","/",sep="");dir.create(out.folder)
  write.csv(occur[occur$Common_name==spp,],paste(spp.folder,'weather.occur.csv',sep=''),row.names=F,na='')
  
}
##########
setwd("B:BOEM_data/BOEM_Methods_Trials/Heather_working/blackseabass")
work.dir=getwd()
work.dir

#######FUNKY STUFF THAT NO LONGER WORKS

#####this works, but will need some further work to make it batch
#set wd to folder with maxent jar and csvs
#maxent jar and csvs are in folder maxent_4jen already, only needs to be unzipped
setwd("Pathway/maxent_4jen")


for (folder in list.files(pattern="outputs")){
  max_out=paste(folder,"/","output11",sep="");dir.create(max_out)
  run=paste("java -mx1024m -jar maxent.jar jackknife=true environmentallayers=blackseabass_absence_clean_chla_sal.csv samplesfile=blackseabass_prensce_chla_sal.csv outputdirectory=",max_out,"projectionlayers="folder,"nowarnings notooltips redoifexists novisible autorun",sep="")
  print(run)

#call maxent with desired arguments
system(command=paste("java -mx1024m -jar maxent.jar jackknife=true environmentallayers=blackseabass_absence_clean_chla_sal.csv  samplesfile=blackseabass_prensce_chla_sal.csv outputdirectory=",maxentout," projectionlayers=",projection," nowarnings notooltips redoifexists novisible autorun"))
}


#explanation
#system(command=paste()) will allow R to subrun other applications
#java calls java
#-mx1024m tells maxent how much memory it gets to use, if this crashes on your computer change it to -mx512m
#-jar maxent.jar tells maxent where it's executable jar file lives...in this case it's already in the working directory so we don't need a pathway
#jackknife=true tells maxent to use jackknifing to measure variable importance
#environmentallayers=blackseabass_absence_clean.csv points maxent to our absences (we're using a weird method so that we can define true absences, normally maxent will randomly sample absences from environmental layers)
#samplesfile=blackseabass_presence.csv points maxent to blackseabass presence records
#outputdirectory=outputs tells maxent to save all outputs in the outputs folder (bascially maxent knows where it's jar file is, so all other locations need only to be directed to in reference to the jar file. that's why we don't need a pathway, because the jar file and the outputs folder are in the same place)
#nowarnings notooltips novisible all tell maxent not to make popups with various messages..only purpose is to evenutally allow us to batch without having to sit there and manually accept warnings
#redoifexists will rewrite any maxent files already in the outputs folder so this same command can be run multiple times with changes if need be
#autorun will automatically launch maxent without someone having to manually click run, again, allowing us to batch


####WORKING SCRIPT

for (folder in list.files(pattern="outputs")){
  max_out=paste(folder,"/","output19",sep="");dir.create(max_out)
  run=paste("java -mx1024m -jar maxent.jar jackknife=true environmentallayers=blackseabass_absence_clean_chla_sal.csv samplesfile=blackseabass_prensce_chla_sal.csv outputdirectory=",max_out," projectionlayers=",folder," nowarnings notooltips redoifexists novisible autorun",sep="")
  print(run)
  system(command=paste(run))

}
####data prep

#####copying asc to various project folders
####only ascii files that begin with sal
###deleting wrong ascii files
ascii=list.files('B:/BOEM_Data/BOEM_Methods_Trials/Heather_working/maxent/project',pattern="^sal.+[.]asc$")
ascii
for (folder in list.files(pattern="outputs")){
  file.copy(ascii,paste(getwd(),"/",folder,sep=""))
  unlink(paste(getwd(),"/",folder,"/","chl_a.asc",sep=""))
}


#####deleting all .asci in folders
for (folder in list.files(pattern="outputs")){
  unlink(paste(getwd(),"/",folder,"/","*.asc",sep=""))
}

####copying all files from a directory, deleting chl-afiles
#projfiles=list.files('B:/BOEM_Data/BOEM_Methods_Trials/Heather_working/maxent/project',full.names=TRUE)
#projdirs=list.dirs('B:/BOEM_Data/BOEM_Methods_Trials/Heather_working/maxent/project')
allfiles=dir('B:/BOEM_Data/BOEM_Methods_Trials/Heather_working/maxent/project',full.names=TRUE)
for (folder in list.files(pattern="outputs")){
  #file.copy(projfiles,paste(getwd(),"/",folder,sep=""))
  file.copy(allfiles,paste(getwd(),"/",folder,sep=""))
  unlink(paste(getwd(),"/",folder,"/","chl_a*",sep=""))
  unlink(paste(getwd(),"/",folder,"/","Chl_A*",sep=""))
}
warnings()

##############################################################STEP ONE
#manipulating csvs for maxent (when you have just one species)
file=read.csv("WH_BTS_Count_habvars_joined_full.csv")
head(file)
colnames(file)
subset=file[c(1,29:70)]
head(subset)
colnames(subset)
subset1=subset[c(-11)]
head(subset1)

###absense file
absence=subset(subset1,BlackseaBass==0)
head(absence)
absence[,1] = "blackseabass"
write.csv(absence,file="B:/BOEM_data/BOEM_Methods_Trials/Heather_working/blackseabass/csv_trials/seabass_absence.csv",row.names=FALSE)

####presence file
presence=subset(subset1,BlackseaBass>0)
head(presence)
presence[,1] = "blackseabass"
write.csv(presence,file="B:/BOEM_data/BOEM_Methods_Trials/Heather_working/blackseabass/csv_trials/seabass_presence.csv",row.names=FALSE)


########################################TRIALS for MULTIPLE SPECIES

####Make some dummy files with two species

### 01. read in two csvs at once
library(tools)
for (csv in list.files('B:/BOEM_Data/BOEM_Methods_Trials/Heather_working/blackseabass/csv_trials',pattern=".csv$")){ #for all the csv files in a given directory
  no_extention=file_path_sans_ext(csv) #grab the file name, drop the .csv extension
  name=paste(no_extention,"_copy",sep="") #add "_copy" to the file name
  table=read.csv(paste("B:/BOEM_Data/BOEM_Methods_Trials/Heather_working/blackseabass/csv_trials/",csv,sep="")) #read in the csv
  assign(name,table) #save the read in csv as a new object name "original_csv_name_copy" (you can get rid of the copy if you want)
}

####append two csvs to create a dummy file
#rename a column in multiple loaded csv objects

for (i in ls(pattern="seabass*")) {
  dat=get(i)
  colnames(dat)[1]<-"species_name"
  assign(i,dat)
}

###change the species in the _copy csvs (rechange colname to species_name)
for (i in ls(pattern="*_copy")) {
  dat=get(i)
  dat[,1]<-"dolphins"
  colnames(dat)[1]<-"species_name"
  assign(i,dat)
}

####merge dat shit
species_absence=rbind(seabass_absence,seabass_absence_copy)
head(species_absence)
dim(species_absence)
levels(species_absence$species_name)

species_presence=rbind(seabass_presence,seabass_presence_copy)
head(species_presence)
dim(species_presence)
levels(species_presence$species_name)

####write out deez csvs
for (i in ls(pattern="species*")) {
  dat=get(i)
  write.csv(dat,paste(getwd(),"/csv_trials/",i,".csv",sep=""))
}


#######################figure out how to run two species in maxent

####removing all files from folders
for (folder in list.files(pattern="outputs")){
  file.remove(list.files(path=paste(getwd(),"/",folder,sep=""),full.names=TRUE))
  unlink(list.dirs(path=paste(getwd(),"/",folder,sep="")),recursive=TRUE)
}
####this also deletes the parent folders themselves as well as all the files in them!!!

###create some new directories
months=cbind("august_outputs","september_outputs","october_outputs")
months
for (i in months){
  dir.create(paste(getwd(),"/",i,sep=""))
}

###create seperate output folders for each species
#read in presence/absence csv using script 01.

##grab species from csv, create folders in monthly output folders for each species
species=levels(species_presence$species_name)
for (folder in list.files(pattern="outputs")){ 
  for (sp in species){
    dir.create(paste(getwd(),"/",folder,"/",sp,sep=""))
  }
  }

##put a copy of the project folder in each month (pretending it contains unique asciis for each month all by the same name)
directory=list.dirs('B:/BOEM_Data/BOEM_Methods_Trials/Heather_working/maxent',recursive=FALSE)
project=directory[2]
for (folder in list.files(pattern="outputs",full.names=TRUE)){
  file.copy(project,folder,recursive=TRUE)
}

##subsetting absences by species
species=levels(species_absence$species_name)
for (sp in species){
  csv=subset(species_absence,species_name==sp)
  csv[,1] = "bkgd"
  name=paste("bkgd_",sp,sep="")
  assign(name,csv)
  write.csv(csv,paste(getwd(),"/csv_trials/",name,".csv",sep=""),row.names=FALSE)
  
}

##run maxent! KEEP PLAYING WITH THIS
species=levels(species_absence$species_name) #get each species as a factor
bkgd=list.files(paste(getwd(),"/csv_trials/",sep=""),pattern="bkgd*",full.names=TRUE) #identify background csvs ##don't need this
for (folder in list.files(pattern="outputs")){ #for each month
  for (sp in species){
    max_out=paste(folder,"/",species,sep="") #output folder is species folder in each month folder
    absence=paste(getwd(),"/csv_trials/bkgd_",species,"_sal.csv",sep="")
    project=paste(folder,"/project",sep="")
    run=paste("java -mx1024m -jar maxent.jar jackknife=true environmentallayers=",absence," samplesfile=species_prensce_sal.csv outputdirectory=",max_out," projectionlayers=",project," nowarnings notooltips redoifexists novisible autorun",sep="")
    print(run)
    system(command=paste(run))
  
}
}

##############################################################################################new tactic, species by months
###first build models, then project models
models=paste(getwd(),"/models",sep="");dir.create(models) ##create a new directory to work from

occur.file = 'species_presence_sal.csv' ; occur = read.csv(paste(getwd(),"/csv_trials/",occur.file,sep="")) ##read in the occurrences
species = levels(occur$species_name) #identify the species in the occur file
species

for (spp in species){ ###making folders for each species and writing out occurrences
  spp.folder = paste(getwd(),"/models/",spp,"/",sep="");dir.create(spp.folder)
  out.folder=paste(spp.folder,"/","weather","/",sep="");dir.create(out.folder)
  write.csv(occur[occur$species_name==spp,],paste(spp.folder,'weather.occur.csv',sep=''),row.names=F,na='')
}

##now do the same for bkgd points
##organize code to extract bkgd points from raw csvs, this assumes absences are already in seperate csv from presences
absence.file = 'species_absence_sal1.csv' ; absence = read.csv(paste(getwd(),"/csv_trials/",absence.file,sep="")) ##read in the absences
species = levels(absence$species_name) #identify the species in the absence file
species

for (spp in species){ ### for each species and writing out absences
  spp.folder = paste(getwd(),"/models/",spp,"/",sep="")
  write.csv(absence[absence$species_name==spp,],paste(spp.folder,'weather.bkgd.csv',sep=''),row.names=F,na='')
}

###set up the maxent run
species = levels(absence$species_name) #identify species
for (spp in species){
  max_out=paste(getwd(),"/models/",spp,"/weather",sep="")
  presence=paste(getwd(),"/models/",spp,"/weather.occur.csv",sep="")
  bkgd=paste(getwd(),"/models/",spp,"/weather.bkgd.csv",sep="")
  run=paste("java -mx1024m -jar maxent.jar jackknife=true environmentallayers=",bkgd," samplesfile=",presence," outputdirectory=",max_out," nowarnings notooltips redoifexists novisible autorun",sep="")
  print(run)
  system(command=paste(run))
}

###now project the models
project.list = list.files(paste(getwd(),"/projections/",sep=""),full.names=TRUE) ##identify folders with the asciis
month.list=list.files(paste(getwd(),"/projections/",sep=""))
species = levels(absence$species_name) #identify species
file.copy("maxent.jar",paste(getwd(),"/models/",sep=""),recursive=TRUE)
for (spp in species){
  lambdas=paste(getwd(),"/models/",spp,"/weather/",spp,".lambdas",sep="")
  for (month in month.list){
    grid.dir=paste(getwd(),"/projections/",month,sep="")
    out.dir=paste(getwd(),"/models/",spp,"/weather/",spp,"_",month,sep="");#dir.create(out.dir)
    run=paste("java -cp maxent.jar density.Project ",lambdas," ",grid.dir," ",out.dir," fadebyclamping grd nowarnings notooltips redoifexists novisible autorun",sep="")
    system(command=paste(run))
  }
}

