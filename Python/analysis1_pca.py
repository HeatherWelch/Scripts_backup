##tool to compute PCAs for each monthly set of SDMs

import arcpy
from arcpy import env
import os
from arcpy.sa import *

# env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\"
# months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]
# for m in months:
	# os.makedirs("F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\"+m)

#months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]

env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\extracted_rasters\\"
for file in arcpy.ListFiles():
	env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\extracted_rasters\\"+file
	print(env.workspace)
	rasters=arcpy.ListRasters()
	outfile="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\"+file
	PCA=file+"_15"
	text=file+"_15.txt"
	outtext=os.path.join(outfile,text)
	outPCsave=os.path.join(outfile,PCA)
	print(outPCsave)
	outPC=PrincipalComponents(rasters,15,outtext)
	outPC.save(outPCsave)