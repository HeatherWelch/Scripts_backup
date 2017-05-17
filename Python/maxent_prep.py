######script to prepare remote-sensing data for maxent

import arcpy, arcinfo
from arcpy import env
import os
from arcpy.sa import *

##############################01. define months
# months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]
# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters"
# for m in months:
	# pth="F:\\SDM_paper\\maxent\\rs_rasters\\"+m
	# os.makedirs(pth)


##############################02. fix 10m layer names from 0000m to 0010m
# env.workspace="F:\\Remote Sensing Data\\Maxent"
# for file in arcpy.ListFiles():
	# if "_10m" in file:
		# print(file)
		# env.workspace="F:\\Remote Sensing Data\\Maxent\\"+file
		# for raster in arcpy.ListRasters():
			# new_name=raster.replace("0000m","0010m")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
	# else:
		# pass

##############################03. fix all names to match variables in metadata3 while keeping time in name
#####variable names
# env.workspace="F:\\Remote Sensing Data\\Maxent"
# for file in arcpy.ListFiles():
	# env.workspace="F:\\Remote Sensing Data\\Maxent\\"+file
	# for raster in arcpy.ListRasters():
		# if "aqua_" in raster:
			# print(raster)
			# new_name=raster.replace("aqua_","")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# if "chl_chlor_a" in raster:
			# print(raster)
			# new_name=raster.replace("chl_chlor_a","chl_a")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# elif "nsst_l3m_data" in raster:
			# print(raster)
			# new_name=raster.replace("nsst_l3m_data","MODIS_sst")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# elif "salinity" in raster:
			# print(raster)
			# new_name=raster.replace("salinity","sal")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# elif "temperature" in raster:
			# print(raster)
			# new_name=raster.replace("temperature","t")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# else:
			# pass
			
#####statistic names
# env.workspace="F:\\Remote Sensing Data\\Maxent"
# for file in arcpy.ListFiles():
	# env.workspace="F:\\Remote Sensing Data\\Maxent\\"+file
	# for raster in arcpy.ListRasters():
		# if "standard deviation" in raster:
			# print(raster)
			# new_name=raster.replace("standard deviation","sdv")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# else:
			# pass
			
#####month names so all are "_mxx"		
# env.workspace="F:\\Remote Sensing Data\\Maxent"
# for file in arcpy.ListFiles():
	# env.workspace="F:\\Remote Sensing Data\\Maxent\\"+file
	# for raster in arcpy.ListRasters():
		# if "_month" in raster:
			# print(raster)
			# new_name=raster.replace("_month","_m")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# elif "ghrsst_" in raster:
			# print(raster)
			# new_name=raster.replace("ghrsst_","ghrsst_m")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# else:
			# pass
			
			
#####depth names			
# env.workspace="F:\\Remote Sensing Data\\Maxent"
# for file in arcpy.ListFiles():
	# env.workspace="F:\\Remote Sensing Data\\Maxent\\"+file
	# for raster in arcpy.ListRasters():
		# if "0000m" in raster:
			# print(raster)
			# new_name=raster.replace("0000m","0")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# elif "0010m" in raster:
			# print(raster)
			# new_name=raster.replace("0010m","1")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# elif "20000m" in raster:
			# print(raster)
			# new_name=raster.replace("20000m","2")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# elif "btm" in raster:
			# print(raster)
			# new_name=raster.replace("btm","2")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# else:
			# pass
			
#####statistic names again
# env.workspace="F:\\Remote Sensing Data\\Maxent"
# for file in arcpy.ListFiles():
	# env.workspace="F:\\Remote Sensing Data\\Maxent\\"+file
	# for raster in arcpy.ListRasters():
		# if "mean" in raster:
			# print(raster)
			# new_name=raster.replace("mean","m")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# elif "sdv" in raster:
			# print(raster)
			# new_name=raster.replace("sdv","sd")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# else:
			# pass
			
#####variable names again
# env.workspace="F:\\Remote Sensing Data\\Maxent"
# for file in arcpy.ListFiles():
	# env.workspace="F:\\Remote Sensing Data\\Maxent\\"+file
	# for raster in arcpy.ListRasters():
		# if "temperature" in raster:
			# print(raster)
			# new_name=raster.replace("temperature","t")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# elif "MODIS_sst" in raster:
			# print(raster)
			# new_name=raster.replace("MODIS_sst","modSST")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# else:
			# pass
			
			
#####variable names again
# env.workspace="F:\\Remote Sensing Data\\Maxent"
# for file in arcpy.ListFiles():
	# env.workspace="F:\\Remote Sensing Data\\Maxent\\"+file
	# for raster in arcpy.ListRasters():
		# if "modSST" in raster:
			# print(raster)
			# new_name=raster.replace("modSST","mSST")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# elif "chl_a" in raster:
			# print(raster)
			# new_name=raster.replace("chl_a","chla")
			# print(new_name)
			# arcpy.Rename_management(raster,new_name)
		# else:
			# pass
			
			
##############################04. extract to regional extent, snap raster and cell size to GHRSST layers	

###mumbo jumbo to get powershell to recognize spatial analyst liscense.
##won't run thru powershell w/o data interperobility tools
# class LicenseError(Exception):
    # pass

# try:
    # if arcpy.CheckExtension("DataInteroperability") == "Available":
        # arcpy.CheckOutExtension("DataInteroperability")
        # print "Checked out \"DataInteroperability\" Extension"
    # else:
        # raise LicenseError
# except LicenseError:
    # print "Data Interoperability license is unavailable"
# except:
    # print arcpy.GetMessages(2)
# ###end mumbo jumbo

env.workspace="F:\\Remote Sensing Data\\Maxent-Copy_reprojected_NAD"
extract_layer="F:\\SDM_paper\\regional_extent\\rs_extent"
months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]
# arcpy.CheckOutExtensions("Spatial")
# arcpy.CheckOutExtension("DataInteroperability")
for file in arcpy.ListFiles():
			env.workspace="F:\\Remote Sensing Data\\Maxent-Copy_reprojected_NAD\\"+file
			print(env.workspace)
			for raster in arcpy.ListRasters():
				for m in months:
					if m in raster:
						print(m)
						print(raster)
						out_workspace="F:\\SDM_paper\\maxent\\rs_rasters\\"+m
						EMsave=os.path.join(out_workspace,raster)
						if arcpy.Exists(EMsave):
							print("already exists")
						else:
							arcpy.env.snapRaster="F:\\SDM_paper\\regional_extent\\rs_extent"
							arcpy.env.cellSize="F:\\SDM_paper\\regional_extent\\rs_extent"
							print(out_workspace)
							print("Extracting by mask")
							EM=ExtractByMask(raster,extract_layer) ####Extracts each copied raster using "extract_layer", saves as an object **spatial analyst tools require a .save command to make layers permanent**
							EMsave=os.path.join(out_workspace,raster) ####Define object with new pathway and name for extract by mask product
							print(EMsave)
							EM.save(EMsave) ####call the save function (required for spatial analyst) ####save object (layer) to make it permanent**
					else:
						pass
						

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
##############################01. put asciis in month folders
# env.workspace="F:\\Remote Sensing Data\\Maxent"
# for m in months:
	# for file in arcpy.ListFiles():
		# print(file)
		# env.workspace="F:\\Remote Sensing Data\\Maxent\\"+file
		# print(env.workspace)
		# for ras in arcpy.ListRasters():
			# if m in ras:
				# arcpy.CopyRaster_management