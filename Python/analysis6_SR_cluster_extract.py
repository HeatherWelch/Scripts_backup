##script to subset species richness rasters by monthly cluster subsets

import arcpy
from arcpy import env
import os
from arcpy.sa import *



env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\clusters\\"
months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]

raster_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\"
out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\extracted_rasters"

for m in months:
	raster=raster_workspace+m+"_sr"
	for shape in arcpy.ListFeatureClasses():
		print (shape)
		if m in shape:
			bname=arcpy.Describe(shape).basename
			EM=ExtractByMask(raster,shape)
			EMsave=os.path.join(out_workspace,bname)
			print(EMsave)
			EM.save(EMsave)
		else:
			pass