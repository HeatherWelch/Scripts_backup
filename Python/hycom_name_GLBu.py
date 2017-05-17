####cleaning up hycom data downloaded at hom

#####copying mean surface salinity rasters to new locations
import arcpy
from arcpy import env
import os
from arcpy.sa import *

# env.workspace="F:\\hycom_GLBu0.08\\Depth_0010m_sal"

# for raster in arcpy.ListRasters():
	# if "mean" in raster:
		# arcpy.CopyRaster_management(raster,"F:\\hycom_GLBu0.08\\Depth_0000m_sal\\"+raster+".img","","","","NONE","NONE","","NONE","NONE")
	# else:
		# pass
		
#####deleting mean surface salinity rasters from 10m salinity folder
# env.workspace="F:\\hycom_GLBu0.08\\Depth_0010m_sal"

# for raster in arcpy.ListRasters():
	# if "mean" in raster:
		# arcpy.Delete_management(raster)
	# else:
		# pass

		
#####renaming rasters by depth
# env.workspace="F:\\hycom_GLBu0.08"
# for file in arcpy.ListFiles():
	# if "_0010m" in file:
		# env.workspace="F:\\hycom_GLBu0.08\\"+file
		# for raster in arcpy.ListRasters():
				# new_name=raster.replace("_0000m_","_0010m_")
				# print(new_name)
				# arcpy.Rename_management(raster,new_name)
	# else:
		# pass
		
#just newest ones		
# env.workspace="F:\\hycom_GLBu0.08_download1\\New9_23_15\\temp_10m_mean"
# for raster in arcpy.ListRasters():
	# new_name=raster.replace("_0000m_","_0010m_")
	# print(new_name)
	# arcpy.Rename_management(raster,new_name)

# env.workspace="F:\\hycom_GLBu0.08_download1\\New9_23_15\\Depth_20000m_t\\"
# for raster in arcpy.ListRasters():
	# # if "mean" in raster:
		# # arcpy.CopyRaster_management(raster,"F:\\hycom_GLBu0.08_clean2\\u_20000m_m\\"+raster,"","","","NONE","NONE","","NONE","NONE")
	# if "standard" in raster:
		# arcpy.CopyRaster_management(raster,"F:\\hycom_GLBu0.08_clean2\\t_20000m_sd\\"+raster,"","","","NONE","NONE","","NONE","NONE")
	# else:
		# pass
		
		
env.workspace="F:\\hycom_GLBu0.08_reprojected"
for file in arcpy.ListFiles():
	env.workspace="F:\\hycom_GLBu0.08_reprojected\\"+file
	for raster in arcpy.ListRasters():
		if ".img" in raster:
			print(raster)
			new_name=raster.replace(".img","")
			print(new_name)
			#path_old="F:\\hycom_GLBu0.08_reprojected\\"+file+"\\"+raster
			#path_new="F:\\hycom_GLBu0.08_reprojected\\"+file+"\\"+new_name
			#print(path_old)
			#print(path_new)
			arcpy.Rename_management(raster,new_name)
		else:
			pass	
	
