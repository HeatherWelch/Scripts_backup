#tool to calculate the class probabilities of the edited clusters


import arcpy
from arcpy import env
import os
from arcpy.sa import *
	

env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\Extracted_PCs\\del2a_fill\\"
out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters_del2a\\"
CP_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters_del2a\\class_probability\\"
months=["m06","m07","m08","m09"]

for month in months:
	mon=month+"*"
	rasters=arcpy.ListRasters(mon)
	print(rasters)
	outsig=out_workspace+month+"_edit_d2a.gsg"
	print(outsig)
	outCP=CP_workspace+month+"_d2acp"
	print(outCP)
	ClassProp=ClassProbability(rasters,outsig,100,"SAMPLE","")
	ClassProp.save(outCP)
	