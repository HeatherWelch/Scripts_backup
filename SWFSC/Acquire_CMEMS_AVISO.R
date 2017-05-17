### acquire CMEMS / AVISO

# 1. ########### load the libraries
library(RCurl)
library(R.utils)

# 2. ########### load the functions
### A. Pauses system for a period of time to allow url requests to go through
waitfor <- function(x){
  p1 <- proc.time()
  Sys.sleep(x)
  print(proc.time() - p1) # The cpu usage should be negligible
}

### E. An acquire function to grab envt data from CMEMS and AVISO (these have a slightly different format than erddap and therefore need a seperate download method)
## if you want it to run faster you can remove the waitfor(3) lines, these are just to buy it some time to finish the downloads before starting a new downlaod

acquire_cmems_aviso=function(url,date,userpwd,name){ #name is for the variable name in ERDDAP, final_name is for the final processed layer (e.g. l.blendchla )
  filenames=getURL(url, userpwd = userpwd,
                   ftp.use.epsv = FALSE,ssl.verifypeer = FALSE,dirlistonly = TRUE) ## this is clunky by necessity. The CMEMS files are named by the date they were uploaded to the ftp site, therefore there is no way to predict the actual name of the file for the date we are interested in. So we go a roundabout way:
  waitfor(3)
  list_filenames=unlist(strsplit(filenames,".gz")) ## get a list of all the files in the CMEMS directory
  string=grep(date,list_filenames,value=TRUE)
  if(length(string)>0){
    string=gsub("[^[:alnum:]_.]", "", string) ## it is impossible to get rid of trailing backslashes, therefore this mess
    data=getBinaryURL(paste(url,string,".gz",sep=""),userpwd = userpwd,ftp.use.epsv = FALSE,ssl.verifypeer = FALSE,noprogress=FALSE) # grab data behind url
    waitfor(3)
    con <- file(paste(tmpdir,"/",name,".nc.gz",sep=""), open = "wb") # write data to a file
    writeBin(data,con)
    waitfor(3)
    close(con)
    gunzip(paste(tmpdir,"/",name,".nc.gz",sep=""),ext="gz", FUN=gzfile) # unzip the file
  }
}

# 3. ########### example code for how to run the functions, will need to substitute URLs for the appropriate URLs for the products you would like to download

path = "/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive"
tmpdir=paste(path,"/Real_time_netcdfs_raw/temp_2012-04-14",sep="")

date_range=as.character(seq(from=as.Date("2017-03-14"),to=as.Date("2017-03-16"),by="day"))

for(get_date in date_range){


############ 3. Variable 1: NRT MSLA SSH
  date=paste("h_",gsub("-","",get_date),sep="") # get date in correct format for ftp search
  url <- "ftp://ftp.sltac.cls.fr/Core/SEALEVEL_GLO_SLA_MAP_L4_NRT_OBSERVATIONS_008_026/dataset-duacs-nrt-global-merged-allsat-msla-l4/"
  userpwd <- "hwelch:HeatherCMEMS2016"
  name=paste0(get_date,"_MSLAh")
  acquire_cmems_aviso(url=url,date=date,userpwd=userpwd,name=name)
  
  
  ############ 4. Variables 2&3: NRT MSLA u&v
    date=paste("uv_",gsub("-","",get_date),sep="") # get date in correct format for ftp search
    url <- "ftp://ftp.aviso.altimetry.fr/global/near-real-time/grids/msla/all-sat-merged/uv/"
    userpwd <- "noaa_hwelch:ncm55za9" 
    name=paste0(get_date,"_MSLAuv")
    acquire_cmems_aviso(url=url,date=date,userpwd=userpwd,name=name)
    
}