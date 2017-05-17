#####some random patches of code

#batch reading in csvs, new method
setwd("")

filename=list.files(pattern=".csv")
library(tools)
lapply(
	filenames,
	fcn)
fcn=function(x){object=(x);names=file_path_sans_ext(x);table=read.csv(x);assign(names,table)}


filename=list.files(pattern=".csv")
library(tools)
invisible(lapply(
	filenames,
	function(x)
	{
		object=filename[[x]]
		names=file_path_sans_ext(filename[[x]])
		table=read.csv(filename[[x]])
		assign(names,table)
	}
))


invisible(lapply(
	filenames,
	function(x)
	{
		read.csv
		assign(file_path_sans_ext)
	}
))

fcn=function(x){
	object=(x)
	names=file_path_sans_ext(x)
	table=read.csv(x)
	assign(names,table)
	}
	
data=lapply(filename,fcn)

############################
fcn=function(x){
	object=(x)
	names=file_path_sans_ext(x)
	table=read.csv(x)
	assign(names,table)
	}
	
data=invisible(lapply(filename,function(x) read.csv))
names=lapply(data,function(x) file_path_sans_ext[[x]])
rename=lapply(names,data,function(x),assign)
