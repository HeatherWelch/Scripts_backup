### / ncdf

seagate_netcdf="/Volumes/SeaGate/ERD_DOM/ncdf"
timemachine_netcdf="/Volumes/TimeMachine/SeaGateBackUp_HW/ncdf"

seagatelist=list.files(seagate_netcdf)

copy_file=function(x){
print(x)
if(!file.exists(paste0(timemachine_netcdf,"/",x))){
  file.copy(paste0(seagate_netcdf,"/",x),paste0(timemachine_netcdf,"/",x))
}
}

lapply(seagatelist,FUN = copy_file)


### / netcdf2015

seagate_netcdf="/Volumes/SeaGate/ERD_DOM/ncdf_2015"
timemachine_netcdf="/Volumes/TimeMachine/SeaGateBackUp_HW/ncdf_2015"

seagatelist=list.files(seagate_netcdf)
lapply(seagatelist,FUN = copy_file)

### copy over the grids

seagate_grids="/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite"
dropbox_grids="~/Dropbox/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite"

year_folders=list.files(seagate_grids)

#dir.create(paste0(dropbox_grids,"/",year_folders[1]))

copyDIR=function(x){
if(!file.exists(paste0(dropbox_grids,"/",x))){
print(x)
file.copy(paste0(seagate_grids,"/",x),paste0(dropbox_grids,"/"),recursive = T)
}
}

lapply(year_folders,FUN=copyDIR)


### make sure the grids are there

seagate_grids="/Volumes/SeaGate/ERD_DOM/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite"
dropbox_grids="~/Dropbox/EcoCast_CodeArchive/SpatialPredictions_EnvData/Satellite"

year_folders=list.files(seagate_grids)

for(year in year_folders){
  path=paste0(seagate_grids,"/",year,"/")
  for(fille in list.files(path)){
    if(!file.exists(paste0(dropbox_grids,"/",year,"/",fille))){
      print(paste0(seagate_grids,"/",year,"/",fille))}}}
  