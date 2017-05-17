##script to take model rasters and clip to final extent (1km from land, 450m contour, waters east of minimum bounding geometry of species records)

import arcpy
from arcpy import env
import os
from arcpy.sa import *

#env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\extracted_rasters\\"
#months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]
#for m in months:
	#os.makedirs("F:\\SDM_paper\\maxent\\Maxent_run\\extracted_rasters\\"+m)
	

env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\rasters\\"
extract_layer="F:\\SDM_paper\\regional_extent\\rs_final_erase.shp"
months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]
for m in months:
	env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\rasters\\"+m
	out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\extracted_rasters\\"+m
	for raster in arcpy.ListRasters():
		EM=ExtractByMask(raster,extract_layer)
		EMsave=os.path.join(out_workspace,raster)
		print(EMsave)
		EM.save(EMsave)