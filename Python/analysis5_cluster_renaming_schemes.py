#tool to rename clusters to the same north to south naming scheme


import arcpy
from arcpy import env
import os
from arcpy.sa import *

env.workspace="F:\\parent_folder\\rasters\\"
out_workspace="F:\\wherever\\"
rename_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters_del2a\\remapped_del2a_and_other\\renaming_schemes\\"
sig_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters_del2a\\del2a_and_other_sigs\\"
months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]

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
	