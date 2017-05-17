import arcpy
from arcpy import env
import os
from arcpy.sa import *

env.workspace="F:\\Remote Sensing Data\\Bottom_hycom_bottom_temp_U\\rasters"
#out_workspace= NA
coor_sys_ras="F:\\Remote Sensing Data\\HYCOM_climatology_dir_surface_mean\\dir\\Monthly_Climatology\\Depth_0000m\\dir_0000m_month01_mean.img"
dscrb=arcpy.Describe(coor_sys_ras)
coord_sys=dscrb.spatialReference

for raster in arcpy.ListRasters():
	print(raster)
	arcpy.DefineProjection_management(raster,coord_sys)
	print(arcpy.GetMessages(0))
