#################
# Switching from wide to long format in r
################

# 1. rearrange your dataset into site information and species information that you want to convert from wide to long
# 2. use the gather functionin the tidyr library to convert species dataframe from wide to long

#reading in your csv
WH_counts_wide<-read.csv("WH_BTS_Count_habvars_joined.csv")
names(WH_counts_wide)

#If necessary, rearrange the csv so that site/environmental information is 
#located together and species info is located together
WH_counts_reorder<-WH_counts_wide[,c(216,1:19,24:28,20:23,212,215,217:229,29:208)]
names(WH_counts_reorder)

spp<-WH_counts_reorder[,c(1,55:224)]
site<-WH_counts_reorder[,c(1:54)]

## rearrange the dataset using the gather function from the tidyr library, where the 
# function format is gather(df_wide,key, value, V1:V...)
library(tidyr)
WH_counts_long <- gather(WH_counts_reorder, species, count, sealamprey:loggerhead)
# reorder by Acronym to sort df by site
library(plyr)
WH_counts_long2<-WH_counts_long[order(WH_counts_long$Acronym),]

##export data as a csv
write.csv(WH_counts_long2, file="new_file_name.csv")