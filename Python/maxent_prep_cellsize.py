##########01. script to cycle through jenn's static layers, check cell size, covert if necessary, and distribute them to raster folders

import arcpy, arcinfo
from arcpy import env
import os
from arcpy.sa import *


env.workspace="F:\\Pass to Heather"
extract_layer="F:\\SDM_paper\\regional_extent\\rs_extent"
#object=arcpy.GetRasterProperties_management(extract_layer,"CELLSIZEX") #get the cell size of the rs_extent
#value=object.getOutput(0)
#print(value)


##this is the good one
# for raster in arcpy.ListRasters():
			# print(raster)
			# raster_full="F:\\Pass to Heather\\"+raster
			# object_ras=arcpy.GetRasterProperties_management(raster_full,"CELLSIZEX") #get the cell size of the rs_extent
			# value_ras=object_ras.getOutput(0)
			# print(value_ras)
			# if value_ras==value:
				# print("Cell size is correct for raster "+raster)
				# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters"
				# for file in arcpy.ListFiles():
					# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\"+file
					# EM=ExtractByMask(raster_full,extract_layer) ####Extracts each copied raster using "extract_layer", saves as an object **spatial analyst tools require a .save command to make layers permanent**
					# EMsave=os.path.join(env.workspace,raster) ####Define object with new pathway and name for extract by mask product
					# print(EMsave)
					# EM.save(EMsave)
			# elif value_ras!=value:
				# arcpy.env.snapRaster="F:\\SDM_paper\\regional_extent\\rs_extent"
				# arcpy.env.cellSize="F:\\SDM_paper\\regional_extent\\rs_extent"
				# print("Cell size is NOT correct for raster "+raster)
				# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters"
				# for file in arcpy.ListFiles():
					# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\"+file
					# EM=ExtractByMask(raster_full,extract_layer) ####Extracts each copied raster using "extract_layer", saves as an object **spatial analyst tools require a .save command to make layers permanent**
					# EMsave=os.path.join(env.workspace,raster) ####Define object with new pathway and name for extract by mask product
					# print(EMsave)
					# EM.save(EMsave)
			# else:
				# pass
				
				
				
#to grab fracgrav_01				
for raster in arcpy.ListRasters():
	if "fracgrav" in raster:
		print(raster)
		raster_full="F:\\Pass to Heather\\"+raster
		env.workspace="F:\\SDM_paper\\maxent\\rs_rasters"
		for file in arcpy.ListFiles():
			env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\"+file
			EM=ExtractByMask(raster_full,extract_layer) ####Extracts each copied raster using "extract_layer", saves as an object **spatial analyst tools require a .save command to make layers permanent**
			EMsave=os.path.join(env.workspace,raster) ####Define object with new pathway and name for extract by mask product
			print(EMsave)
			EM.save(EMsave)
	else:
		pass
		