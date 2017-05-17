####Maxent prep for GHRSST_SD

import arcpy, arcinfo
from arcpy import env
import os
from arcpy.sa import *

###renaming

# env.workspace="F:\\GHRSST_SD"
# for raster in arcpy.ListRasters():
	# #new_name=raster.replace("JPL-L4UHfnd-GLOB-v01-fv03-MUR-analysed_sst-","ghrsst_")
	# #new_name=raster.replace("month","m")
	# new_name=raster.replace("-standard deviation","_sd")
	# print(new_name)
	# arcpy.Rename_management(raster,new_name)

	
####extracting by mask
#####################still creates nonsensical nodata values!!
# env.workspace="F:\\GHRSST_SD"
# extract_layer="F:\\SDM_paper\\regional_extent\\rs_extent"
# months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]
# arcpy.env.overwriteOutput=True
# # arcpy.CheckOutExtensions("Spatial")
# # arcpy.CheckOutExtension("DataInteroperability")
# for raster in arcpy.ListRasters():
	# for m in months:
		# if m in raster:
			# print(m)
			# print(raster)
			# out_workspace="F:\\SDM_paper\\maxent\\rs_rasters\\"+m
			# #out_workspace="F:\\SDM_paper\\maxent\\extracted_rasters\\"+m
			# #EMsave=os.path.join(out_workspace,raster)
			# #if arcpy.Exists(EMsave):
				# #print("already exists")
			# #else:
			# arcpy.env.snapRaster="F:\\SDM_paper\\regional_extent\\rs_extent"
			# #arcpy.env.cellSize="F:\\SDM_paper\\regional_extent\\rs_extent"
			# print(out_workspace)
			# print("Extracting by mask")
			# EM=ExtractByMask(raster,extract_layer) ####Extracts each copied raster using "extract_layer", saves as an object **spatial analyst tools require a .save command to make layers permanent**
			# EMsave=os.path.join(out_workspace,raster) ####Define object with new pathway and name for extract by mask product
			# print(EMsave)
			# EM.save(EMsave) ####call the save function (required for spatial analyst) ####save object (layer) to make it permanent**
		# else:
			# pass

######now copying them to monthly folders and overwriting pre-existing files
# months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]
# env.workspace="F:\\GHRSST_SD\\all\\"
# arcpy.env.overwriteOutput=True
# for m in months:
	# for raster in arcpy.ListRasters():
		# if m in raster:
			# #full="F:\\SDM_paper\\maxent\\extracted_rasters\\all\\"+raster
			# out="F:\\SDM_paper\\maxent\\rs_rasters\\"+m
			# out_file=os.path.join(out,raster)
			# arcpy.CopyRaster_management(raster,out_file,"","","","NONE","NONE","","NONE","NONE")
		# else:
			# pass
			
			
###now extracting GHRSST_SD to points					
env.workspace="F:\\SDM_paper\\regional_trawl\\trawl_subsets_clim\\GHRSST_SD" #location with  your subset time stamps
for shape in arcpy.ListFeatureClasses(): #i.e. for each time stamp
	print(shape)
	month=shape[6:9] #identify month
	print(month)
	env.workspace="F:\\GHRSST_SD\\all\\" #change the workspace to where the remote sensing rasters are
	for raster in arcpy.ListRasters():#list the rasters in each monthly folder
		if month in raster:
			name=arcpy.Describe(raster).basename
			print(name)
			n="_"+month
			print(n)
			fieldname=name.replace(n,"") #create a new name to represent the field by deleting the month
			print(fieldname)
			shp="F:\\SDM_paper\\regional_trawl\\trawl_subsets_clim\\GHRSST_SD\\"+shape
			print(shp)
			print("Extracting "+shape+" points from "+raster+" and putting them in attribute field name "+fieldname)
			ExtractMultiValuesToPoints(shp,[[raster,fieldname]],"NONE")
		else:
			pass