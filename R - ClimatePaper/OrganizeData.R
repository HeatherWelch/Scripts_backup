#script to process observer data

setwd("F:/Climate_paper/Observer_data")


library(tools)

for (csv in list.files(getwd(),pattern=".csv$")){ #for all the csv files in a given directory
  no_extention=file_path_sans_ext(csv) #grab the file name, drop the .csv extension
  name=paste(no_extention,sep="")
  table=read.csv(paste(getwd(),"/",csv,sep="")) #read in the csv
  assign(name,table) #save the read in csv as a new object name "original_csv_name_copy" (you can get rid of the copy if you want)
}

for (i in ls(pattern="ObserverData*")) { #use pattern arg to stratify objects
  dat=get(i) #grab the data behind the object
  subset1=dat[,c(31,34,35,52,53,54,59)] #drop all columns but these ones
  assign(i,subset1) #give the object it's original name back
}

library(stringr)
library(dplyr)

#library(reshape)
#y=colsplit(subset1$DATEHBEG,split=" ",c("date","time"))
#x=transform(y,DATEHBEG=paste0(date," ",time))
#m=merge(x,subset1,by="DATEHBEG")
#d=subset(subset1,nchar(DATEHBEG)==18)###


for (i in ls(pattern="ObserverData*")) { #use pattern arg to stratify objects
  dat=get(i) #grab the data behind the object
  dat[]=lapply(dat,as.character) #rewrite as character
  subset1=subset(dat,nchar(DATEHBEG)==18)#delet rows where date column is messed up
  subset1[]=lapply(subset1,as.character)
  sepA=do.call(rbind,strsplit(subset1$DATEHBEG," ")) #split the data column around the space
  as.data.frame(sepA) #possibly not needed
  colnames(sepA)=c("date","time") #rename the two new columns
  comb=cbind(subset1,sepA) #combine the two new columns with the orignial data frame
  sepB=do.call(rbind,strsplit(as.character(comb$date),"-")) #split the date column around the date
  colnames(sepB)=c("day","month","year") #rename the three new columns
  head(sepB)
  comb2=cbind(comb,sepB) #combind the two new data frames
  comb3=comb2[,c(2,3,4,5,6,7,8,9,10,11,12)] #grab the columns we want into a new dataframe
  comb3[]=lapply(comb3,as.factor)
  levels(comb3$month)=(c(levels(comb3$month),"01","02","03","04","05","06","07","08","09","10","11","12")) #change the levels to get ready for month change
  comb3$month[comb3$month=="JAN"]="01"
  comb3$month[comb3$month=="FEB"]="02"
  comb3$month[comb3$month=="MAR"]="03"
  comb3$month[comb3$month=="APR"]="04"
  comb3$month[comb3$month=="MAY"]="05"
  comb3$month[comb3$month=="JUN"]="06"
  comb3$month[comb3$month=="JUL"]="07"
  comb3$month[comb3$month=="AUG"]="08"
  comb3$month[comb3$month=="SEP"]="09"
  comb3$month[comb3$month=="OCT"]="10"
  comb3$month[comb3$month=="NOV"]="11"
  comb3$month[comb3$month=="DEC"]="12" #replacing text month w numeric
  reorder=select(comb3,COMNAME,SCINAME,everything())
  reorder2=reorder[,c(1,2,3,4,5,6,7,10,11)]
  reorder3=reorder2[,c(1,2,3,4,5,7,8,9,6)]
  reorder3$season[comb3$month=="01"]="JFM"
  reorder3$season[comb3$month=="02"]="JFM"
  reorder3$season[comb3$month=="03"]="JFM"
  reorder3$season[comb3$month=="04"]="AMJ"
  reorder3$season[comb3$month=="05"]="AMJ"
  reorder3$season[comb3$month=="06"]="AMJ"
  reorder3$season[comb3$month=="07"]="JAS"
  reorder3$season[comb3$month=="08"]="JAS"
  reorder3$season[comb3$month=="09"]="JAS"
  reorder3$season[comb3$month=="10"]="OND"
  reorder3$season[comb3$month=="11"]="OND"
  reorder3$season[comb3$month=="12"]="OND" #adding season to match climate data
  reorder4=reorder3[,c(1,2,3,4,5,6,7,8,10,9)]
  assign(i,reorder4) #give the object it's original name back
}

for (i in ls(pattern="ObserverData*")) { #use pattern arg to stratify objects
  dat=get(i) #grab the data behind the object
  file_name=paste(getwd(),"/Cleaned/",i,".csv",sep="")
  write.csv(dat, file=file_name)
}

# ####adding fishing gear fields fields
# setwd("F:/Climate_paper/Observer_data")
# 
# 
# library(tools)
# 
# for (csv in list.files(getwd(),pattern=".csv$")){ #for all the csv files in a given directory
#   no_extention=file_path_sans_ext(csv) #grab the file name, drop the .csv extension
#   name=paste(no_extention,sep="")
#   table=read.csv(paste(getwd(),"/",csv,sep="")) #read in the csv
#   assign(name,table) #save the read in csv as a new object name "original_csv_name_copy" (you can get rid of the copy if you want)
# }
# 
# names(ObserverData2003)
# 
# for (i in ls(pattern="ObserverData*")) { #use pattern arg to stratify objects
#   dat=get(i) #grab the data behind the object
#   subset1=dat[,c(3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,41,48,49,50,59)] #drop all columns but these ones
#   assign(i,subset1) #give the object it's original name back
# }
# 
# for (i in ls(pattern="ObserverData*")) { #use pattern arg to stratify objects
#   dat=get(i) #grab the data behind the object
#   file_name=paste(getwd(),"/fishing_fields/",i,".csv",sep="")
#   write.csv(dat, file=file_name)
# }


#####grabbing species codes (another field)
###read in fiels w species field
setwd("F:/Climate_paper/Observer_data/")
for (csv in list.files(getwd(),pattern=".csv$")){ #for all the csv files in a given directory
  no_extention=file_path_sans_ext(csv) #grab the file name, drop the .csv extension
  name=paste("old_",no_extention,sep="")
  table=read.csv(paste(getwd(),"/",csv,sep="")) #read in the csv
  assign(name,table) #save the read in csv as a new object name "original_csv_name_copy" (you can get rid of the copy if you want)
}

setwd("F:/Climate_paper/Observer_data/Cleaned/")
###read in files w/o species field
for (csv1 in list.files(pattern=".csv$")){ #for all the csv files in a given directory
  no_extention=file_path_sans_ext(csv1) #grab the file name, drop the .csv extension
  name=paste("cleaned_",no_extention,sep="")
  table=read.csv(paste(getwd(),"/",csv1,sep="")) #read in the csv
  assign(name,table) #save the read in csv as a new object name "original_csv_name_copy" (you can get rid of the copy if you want)
}

#####merge files from each year by acronym
years=c("2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014")
for (year in years){
  df1=paste("old_ObserverData",year,sep="")
  datadf1=get(df1)
  df2=paste("cleaned_ObserverData",year,sep="")
  datadf2=get(df2)
  merged=merge(datadf1,datadf2,all.x=FALSE,all.y=TRUE,by="Acronym")
  name=paste("species_codes",year,sep="")
  assign(name,merged)
}

for (i in ls(pattern="species_codes*")) { #use pattern arg to stratify objects
  dat=get(i) #grab the data behind the object
  subset1=dat[,c(52,1)] #drop all columns but these ones
  assign(i,subset1) #give the object it's original name back
}


for (i in ls(pattern="species_codes*")) { #use pattern arg to stratify objects
    dat=get(i) #grab the data behind the object
    file_name=paste(getwd(),"/species_codes/",i,".csv",sep="")
    write.csv(dat, file=file_name)
  }

old=read.csv("ObserverData2014.csv",header=TRUE,sep=",")
head(old)
merged=merge(old,cleaned_ObserverData2014,all.x=FALSE,all.y=TRUE,by="Acronym")
subset1=merged[,c(52,1)] #drop all columns but these ones
write.csv(subset1,file="F:/Climate_paper/Observer_data/species_codes/species_codes2014.csv")

