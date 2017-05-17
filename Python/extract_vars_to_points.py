###tool to extract temporally-explicit env values to biotic points
###first divide biotic points into individual .shp for each time-stamp using the Subset fields tool

import arcpy, arcinfo
from arcpy import env
import os
from arcpy.sa import *

#env.workspace="F:\\Remote Sensing Data\\Bottom_hycom_bottom_temp_U\\rasters"
#points="F:\\Extracting Abioticto Biota\\DistOffshore_And_Angle\\Adding Hydro\\SST_SAL\\all_hydro_stat_3Copy2.shp"
#list=[1,2,3,4,5,6,7,9,10]
#ExtractMultiValuesToPoints(points,[["t_btm_m01_m","btm"]],"NONE")

env.workspace="F:\\Remote Sensing Data\\Bottom_hycom_bottom_temp_U\\Extract_points" #location with  your subset time stamps
for shape in arcpy.ListFeatureClasses(): #i.e. for each time stamp
	month=shape[5:7] #identify month
	print(month)
	env.workspace="F:\\Remote Sensing Data\\Bottom_hycom_bottom_temp_U\\rasters" #change the workspace to where the remote sensing rasters are
	for raster in arcpy.ListRasters():
		print(raster)
		if month in raster: #if the raster is for the time-stamp we're working with
			fieldname=raster[:5]+raster[9:] #create a new name to represent the field
			print(fieldname)
			shp="F:\\Remote Sensing Data\\Bottom_hycom_bottom_temp_U\\Extract_points\\"+shape 
			ExtractMultiValuesToPoints(shp,[[raster,fieldname]],"NONE")
		else:
			print("no")