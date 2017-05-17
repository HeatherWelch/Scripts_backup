#####delecting HYCOM GLBa0.08 layers from rs_rasters and projections folder
##GLBa0.08 only spans from 2008 onwards, going instead to use GLBu0.08, which spans from the 90s. Integrates both u and a to make a long timeseries
#need to clean out folders to get ready for new layers

import arcpy, arcinfo
from arcpy import env
import os
from arcpy.sa import *

##01. delete rasters

# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters"


# for file in arcpy.ListFiles():
	# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\"+file
	# for raster in arcpy.ListRasters():
		# raster_full="F:\\SDM_paper\\maxent\\rs_rasters\\"+file+"\\"+raster
		# if "t_0" in raster:
			# arcpy.Delete_management(raster_full)
		# elif "t_1" in raster:
			# arcpy.Delete_management(raster_full)
		# elif "t_2" in raster:
			# arcpy.Delete_management(raster_full)
		# elif "u_0" in raster:
			# arcpy.Delete_management(raster_full)
		# elif "v_0" in raster:
			# arcpy.Delete_management(raster_full)
		# elif "v_1" in raster:
			# arcpy.Delete_management(raster_full)
		# elif "u_1" in raster:
			# arcpy.Delete_management(raster_full)
		# elif "v_2" in raster:
			# arcpy.Delete_management(raster_full)
		# elif "u_2" in raster:
			# arcpy.Delete_management(raster_full)
		# elif "sal_" in raster:
			# arcpy.Delete_management(raster_full)
		# else:
			# pass
			
			

##02. delete asciis			
env.workspace="F:\\SDM_paper\\maxent\\projections"


for file in arcpy.ListFiles():
	env.workspace="F:\\SDM_paper\\maxent\\projections\\"+file
	for raster in arcpy.ListFiles():
		raster_full="F:\\SDM_paper\\maxent\\projections\\"+file+"\\"+raster
		if "t_0" in raster:
			arcpy.Delete_management(raster_full)
		elif "t_1" in raster:
			arcpy.Delete_management(raster_full)
		elif "t_2" in raster:
			arcpy.Delete_management(raster_full)
		elif "u_0" in raster:
			arcpy.Delete_management(raster_full)
		elif "v_0" in raster:
			arcpy.Delete_management(raster_full)
		elif "v_1" in raster:
			arcpy.Delete_management(raster_full)
		elif "u_1" in raster:
			arcpy.Delete_management(raster_full)
		elif "v_2" in raster:
			arcpy.Delete_management(raster_full)
		elif "u_2" in raster:
			arcpy.Delete_management(raster_full)
		elif "sal_" in raster:
			arcpy.Delete_management(raster_full)
		else:
			pass