##script to mosaic reclassified rasters back to the monthly level

import arcpy
from arcpy import env
import os
from arcpy.sa import *



env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\extracted_rasters\\reclassified\\"
months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]

raster_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\"
out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\extracted_rasters\\reclassified\\mosaic\\"
arcpy.env.overwriteOutput=True

for m in months:
	wc=m+"*"
	raster=arcpy.ListRasters(wc)
	print(raster)
	name=m+"_mosaic"
	print(name)
	arcpy.MosaicToNewRaster_management(raster,out_workspace,name,"","32_BIT_FLOAT","",1,"FIRST","FIRST")