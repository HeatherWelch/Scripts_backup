#tool to edit the .gsgs signature files from the cluster analysis following remap files


import arcpy
from arcpy import env
import os
from arcpy.sa import *
	

env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\Extracted_PCs\\del2a_fill\\"
sig_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\del2a_fill\\"
remap_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remaps_del2a\\"
out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters_del2a\\"
months=["m06","m07","m08","m09"]

for month in months:
	mon=month+"*"
	rasters=arcpy.ListRasters(mon)
	print(rasters)
	sig=sig_workspace+month+"_d2a.gsg"
	remap=remap_workspace+month+"_d2a.txt"
	print(remap)
	outsig=out_workspace+month+"_edit_d2a.gsg"
	print(outsig)
	EditSignatures(rasters,sig,remap,outsig,"")
	