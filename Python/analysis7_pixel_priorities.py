##script to reclassify cluster SR subsets as above or below the mean to explore spatial options to meet objectives to protect >mean values

import arcpy
from arcpy import env
import os
from arcpy.sa import *



env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\extracted_rasters\\"
#months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]

raster_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\"
out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\extracted_rasters\\reclassified\\"
arcpy.env.overwriteOutput=True

for raster in arcpy.ListRasters():
	getmean=arcpy.GetRasterProperties_management(raster,"MEAN")
	mean=getmean.getOutput(0)
	fmean=float(mean)
	print("mean of "+raster+" is "+mean)
	outreclass=Reclassify(raster,"Value", RemapRange([[0,fmean,0],[fmean,5,1]]),"NODATA")
	outsave=out_workspace+raster
	print(outsave)
	outreclass.save(outsave)
	