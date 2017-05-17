##renaming NWA files

import arcpy, arcinfo
from arcpy import env
import os
from arcpy.sa import *

env.workspace="F:\\Climate_paper\\NWA _clims\\clipped_downloads\\sal_clip"
for raster in arcpy.ListFeatureClasses():
		if "mn04" in raster:
			name=raster.replace("mn04","")
			arcpy.Rename_management(raster,name)
		else:
			pass

# for file in arcpy.ListFiles():
	# env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\projections\\"+file
	# for raster in arcpy.ListRasters():
		# if "btm_rug_n3gc" in raster:
			# name=raster.replace("_n3gc","_n3")
			# arcpy.Rename_management(raster,name)
		# elif "fracgrav_01" in raster:
			# name=raster.replace("fracgrav_01","fracgrav_0")
			# arcpy.Rename_management(raster,name)
		# elif "fracsand_01" in raster:
			# name=raster.replace("fracsand_01","fracsand_0")
			# arcpy.Rename_management(raster,name)
		# else:
			# pass
			
