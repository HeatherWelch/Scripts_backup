#tool to calculate species richness as the average of all SDMs for a given month

import arcpy
from arcpy import env
import os
from arcpy.sa import *

env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\Extracted_PCs\\del2a_fill\\"
out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\del2a_fill\\"
months=["m06","m07","m08","m09"]

for month in months:
	mon=month+"*"
	rasters=arcpy.ListRasters(mon)
	print(rasters)
	sig=out_workspace+month+"_d2a.gsg"
	print(sig)
	cluster=out_workspace+month+"_d2a"
	print(cluster)
	outcluster=IsoClusterUnsupervisedClassification(rasters,60,20,10,sig)
	outcluster.save(cluster)