###06. tool to extract temporally-explicit env values to biotic points
###first divide trawl points into individual .shp for each time-stamp using the Subset fields tool
	#save each subset as hydro_m%value%
	#will have to go thru and add 0s to <10 months

import arcpy, arcinfo
from arcpy import env
import os
from arcpy.sa import *

#this script is silly complicated, use the one below
#env.workspace="F:\\Remote Sensing Data\\Bottom_hycom_bottom_temp_U\\rasters"
#points="F:\\Extracting Abioticto Biota\\DistOffshore_And_Angle\\Adding Hydro\\SST_SAL\\all_hydro_stat_3Copy2.shp"
#list=[1,2,3,4,5,6,7,9,10]
#ExtractMultiValuesToPoints(points,[["t_btm_m01_m","btm"]],"NONE")

# env.workspace="F:\\SDM_paper\\regional_trawl\\trawl_subsets" #location with  your subset time stamps
# for shape in arcpy.ListFeatureClasses(): #i.e. for each time stamp
	# month=shape[6:9] #identify month
	# print(month)
	# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters" #change the workspace to where the remote sensing rasters are
	# for file in arcpy.ListFiles(): #for each monthly folder
		# if month in file:
			# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\"+month #set env.workspace to each monthly folder
			# print(env.workspace)
			# for raster in arcpy.ListRasters():#list the rasters in each monthly folder
				# #print(raster)
				# if month in raster: #if the raster is for the time-stamp we're working with
					# n="_"+month
					# fieldname=raster.replace(n,"") #create a new name to represent the field by deleting the month
					# print(fieldname)
					# shp="F:\\SDM_paper\\regional_trawl\\trawl_subsets\\"+shape 
					# #ExtractMultiValuesToPoints(shp,[[raster,fieldname]],"NONE")
			# else:
				# pass
		# else:
			# print("no "+month)
			
###this script works						
env.workspace="F:\\SDM_paper\\regional_trawl\\trawl_subsets_clim\\hycom_GLBu0.08_vars" #location with  your subset time stamps
for shape in arcpy.ListFeatureClasses(): #i.e. for each time stamp
	print(shape)
	month=shape[6:9] #identify month
	print(month)
	env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\"+month #change the workspace to where the remote sensing rasters are
	for raster in arcpy.ListRasters():#list the rasters in each monthly folder
		name=arcpy.Describe(raster).basename
		print(name)
		n="_"+month
		print(n)
		fieldname=name.replace(n,"") #create a new name to represent the field by deleting the month
		print(fieldname)
		shp="F:\\SDM_paper\\regional_trawl\\trawl_subsets_clim\\hycom_GLBu0.08_vars\\"+shape
		print(shp)
		print("Extracting "+shape+" points from "+raster+" and putting them in attribute field name "+fieldname)
		ExtractMultiValuesToPoints(shp,[[raster,fieldname]],"NONE")

	

###this script is the version of the one above adapted for just m10 and m11 because I accidently deleted them like a bonehead
# m=['m10','m11']
# env.workspace="F:\\SDM_paper\\regional_trawl\\trawl_subsets_clim" #location with  your subset time stamps
# for shape in arcpy.ListFeatureClasses(): #i.e. for each time stamp
	# print(shape)
	# month=shape[6:9] #identify month
	# mnth=str(month)
	# if "m10" in mnth: #only work with m10 and m11, else do nothing
		# print(month)
		# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\"+month #change the workspace to where the remote sensing rasters are
		# for raster in arcpy.ListRasters():#list the rasters in each monthly folder
			# name=arcpy.Describe(raster).basename
			# print(name)
			# n="_"+month
			# print(n)
			# fieldname=name.replace(n,"") #create a new name to represent the field by deleting the month
			# print(fieldname)
			# shp="F:\\SDM_paper\\regional_trawl\\trawl_subsets_clim\\"+shape
			# print(shp)
			# print("Extracting "+shape+" points from "+raster+" and putting them in attribute field name "+fieldname)
			# ExtractMultiValuesToPoints(shp,[[raster,fieldname]],"NONE")
	# elif "m11" in mnth: #only work with m10 and m11, else do nothing
		# print(month)
		# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\"+month #change the workspace to where the remote sensing rasters are
		# for raster in arcpy.ListRasters():#list the rasters in each monthly folder
			# name=arcpy.Describe(raster).basename
			# print(name)
			# n="_"+month
			# print(n)
			# fieldname=name.replace(n,"") #create a new name to represent the field by deleting the month
			# print(fieldname)
			# shp="F:\\SDM_paper\\regional_trawl\\trawl_subsets_clim\\"+shape
			# print(shp)
			# print("Extracting "+shape+" points from "+raster+" and putting them in attribute field name "+fieldname)
			# ExtractMultiValuesToPoints(shp,[[raster,fieldname]],"NONE")
	# else:
		# pass
		