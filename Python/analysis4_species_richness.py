#tool to calculate species richness as the average of all SDMs for a given month

import arcpy
from arcpy import env
import os
from arcpy.sa import *

env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\extracted_rasters\\"
out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\"
for file in arcpy.ListFiles():
	env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\extracted_rasters\\"+file
	rasters=arcpy.ListRasters()
	cellstats=CellStatistics(rasters,"MEAN","DATA")
	outfile=out_workspace+file+"_SR"
	cellstats.save(outfile)