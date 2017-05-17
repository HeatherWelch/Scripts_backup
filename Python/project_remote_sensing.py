import arcpy
from arcpy import env
import os
from arcpy.sa import *

env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\rasters\\"
#out_workspace= NA
coor_sys_ras="F:\\Remote Sensing Data\\Maxent-Copy_reprojected_NAD\\GHRSST_clim\\ghrsst_m01"
dscrb=arcpy.Describe(coor_sys_ras)
coord_sys=dscrb.spatialReference

# for file in arcpy.ListFiles():
	# env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\rasters\\"+file
	# print(env.workspace)
	# for raster in arcpy.ListRasters():
		# print(raster)
		# arcpy.DefineProjection_management(raster,coord_sys)
		# print("projecting "+raster+" to NAD83")
		# print(arcpy.GetMessages(0))

#only need to do m11 and m12
files=["m11","m12"]
for file in files:
	env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\rasters\\"+file
	print(env.workspace)
	for raster in arcpy.ListRasters():
		print(raster)
		arcpy.DefineProjection_management(raster,coord_sys)
		print("projecting "+raster+" to NAD83")
		print(arcpy.GetMessages(0))
			
			
			
###single raster test			
# env.workspace="F:\\trial"
# coor_sys_ras="F:\\Remote Sensing Data\\Maxent-Copy_reprojected_NAD\\GHRSST_clim\\ghrsst_m01"
# dscrb=arcpy.Describe(coor_sys_ras)
# coord_sys=dscrb.spatialReference
# raster="F:\\trial\\sal_0_m01_m.tif"
# arcpy.DefineProjection_management(raster,coord_sys)