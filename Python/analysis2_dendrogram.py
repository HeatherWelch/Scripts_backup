#tool to create dendrograms from all the .gsgs from the cluster analysis


import arcpy
from arcpy import env
import os
from arcpy.sa import *

# env.workspace=r"F:\SDM_paper\maxent\Maxent_run\PCAs\clusters"
# out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\Dendrograms_60clusters\\"
# for file in arcpy.ListFiles("*.gsg"):
	# bname=arcpy.Describe(file).basename
	# outfile=out_workspace+bname+".txt"
	# Dendrogram(file,outfile,"VARIANCE","")
	
	
	
###second pass w the filled del2a clusters for months 5-9	
env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\del2a_fill\\"
out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\Dendrograms_60cluster_del2a_fill\\"
for file in arcpy.ListFiles("*.gsg"):
	bname=arcpy.Describe(file).basename
	outfile=out_workspace+bname+".txt"
	Dendrogram(file,outfile,"VARIANCE","")