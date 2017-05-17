setwd("")

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

###only finds common columns and merges them
csv1=WH_BTS_reduced
csv2=WH_BTS_reduced1
csv3=WH_BTS_reduced2

common_cols=intersect(colnames(csv1),colnames(csv2))
trial=rbind(
  subset(WH_BTS_reduced,select=common_cols),
  subset(WH_BTS_reduced1,select=common_cols)
)


###this one works
#first read in all occurrence csvs

#simplify object names, or skip, whatever
csv1=WH_BTS_reduced
csv2=WH_BTS_reduced1
csv3=WH_BTS_reduced2

x=merge(csv2,csv1,all.x=TRUE,all.y=TRUE) #all.x and all.y says keep rows and columns even if they don't match in other csv
y=merge(x,csv3,all.x=TRUE,all.y=TRUE)
#replicate to match number of occurence csvs

write.csv(y,file="append.csv")


###expanding presences
csv.expanded=rand[rep(row.names(rand),rand$Blackseabass),1:ncol(rand)]
write.csv(csv.expanded,file="expand_rand.csv")

###now for multiple species, on df at a time
rand_mult=read.csv("WH_BTS_reduced_rand_multiple.csv")
# nrow(rand_mult)
# headers=rand_mult[-c(1:nrow(rand_mult)),] #make this keep zeros
# 
# colnames(rand_mult)
# species=colnames(rand_mult[,23:ncol(rand_mult)])
# 
# for (column in names(rand_mult[,23:ncol(rand_mult)])){
#   spp=rand_mult[column]
#   csv.expanded=rand_mult[rep(row.names(rand_mult),spp),1:ncol(rand_mult)]
#   merge(headers,csv.expanded,all.x=TRUE,all.y=TRUE)
# }
# 
# for (column in colnames(rand_mult[,23:ncol(rand_mult)])){
#   col=paste("rand_mult$",column,sep="")
#   csv.expanded=rand_mult[rep(row.names(rand_mult),col),1:ncol(rand_mult)]
#   merge(headers,csv.expanded,all.x=TRUE,all.y=TRUE)
# }
# 
# trial=rand_mult[rep(seq(rand_mult[,1:ncol(rand_mult)],rand_mult$count)
# 
# for (row in row.names(rand_mult)){
#   select=rand_mult[row,]
#   freq=select$count
#   expand=rep(select,freq)
# }


###start in long format                    
rand_mult=read.csv("WH_BTS_reduced_rand_multiple.csv")                   
csv.expanded=rand_mult[rep(row.names(rand_mult),rand_mult$count),1:ncol(rand_mult)] #repeat each row the number of times specified in the 'count' column
csv.zeros=rand_mult[rand_mult$count==0,] #subset the csv to collect only the absences (otherwise these are lost)
merged=merge(csv.zeros,csv.expanded,all.x=TRUE,all.y=TRUE);write.csv(merged,file="merged.csv") #merge absences and expanded occurences, write out



#########useful code tidbits from Edith et al 2015 MaxEnt modeling in R

#subset a csv to grab only records that have lat and long (or data in other columns)
object=subset(csv.object,!is.na(colname) & !is.na(colname2))

##running a GLM on spinydogfish using WH data
setwd("C:/Users/Heather.Welch/Desktop/a8_24_15")
install.packages(c('raster','rgdal','rJava'))
library(dismo)
library(raster)
library(rgdal)
library(rJava)
dog=read.csv("WH_BTS_spinydogfish.csv") #regular WH csv, except col spinydogfi is binary 0,1 indicating presence absence
colnames(dog)
glm_dog=glm(spinydogfi~btm_sal+sfc_sal+sfc_temp+btm_sal_me+Chl_a_clim_mean,family=gaussian(link="identity"),data=dog) #define model, fit dependent and independent variables
summary(glm_dog)
testpres=subset(dog,spinydogfi==1)
testbackg=subset(dog,spinydogfi==0)
eval=evaluate(testpres,testbackg,glm_dog)#gives you the AUC
plot(glm_dog)
glm_dog

##now compare with maxent
###absense file
absence=subset(dog,spinydogfi==0)
head(absence)
absence[,1] = "spinydogfi"
write.csv(absence,file=paste(getwd(),"/spiny_absence.csv",sep=""),row.names=FALSE)

####presence file
presence=subset(dog,spinydogfi>0)
head(presence)
presence[,1] = "spinydogfi"
write.csv(presence,file=paste(getwd(),"/spiny_presence.csv",sep=""),row.names=FALSE)


####run maxent
max_out=getwd() #output folder is species folder in each month folder
bkgd=paste(getwd(),"/spiny_absence.csv",sep="")
presence=paste(getwd(),"/spiny_presence.csv",sep="")
run=paste("java -mx1024m -jar maxent.jar responsecurves=true jackknife=true environmentallayers=",bkgd," samplesfile=",presence," outputdirectory=",max_out," nowarnings notooltips redoifexists novisible autorun",sep="")
print(run)
system(command=paste(run))


##running a GLM on multiple species using WH data
######################keep working on this!!!!!
# setwd("C:/Users/Heather.Welch/Desktop/a8_24_15")
# install.packages(c('raster','rgdal','rJava'))
# library(dismo)
# library(raster)
# library(rgdal)
# library(rJava)
# dog=read.csv("WH_BTS_spinydogfish.csv") #regular WH csv, except col spinydogfi is binary 0,1 indicating presence absence
colnames(dog)

#first create binary presence/absence
for (column in dog[,6:10]){
  presence=subset(dog,column>0)
  head(presence)
  presence[,column]==1
}



glm_dog=glm(spinydogfi~btm_sal+sfc_sal+sfc_temp+btm_sal_me+Chl_a_clim_mean,family=gaussian(link="identity"),data=dog) #define model, fit dependent and independent variables
summary(glm_dog)
testpres=subset(dog,spinydogfi==1)
testbackg=subset(dog,spinydogfi==0)
eval=evaluate(testpres,testbackg,glm_dog)#gives you the AUC

#####################code above is incomplete, needs more work!


######snippeds from guillera_arroita et al 2014
length(df.object) #number of columns in df
length(df.object[[1]]) # number of rows in df, not including header (technically length of column 1)

