###grab all the pca reports and copy to new location to zip for Jenn

import arcpy
from arcpy import env
import os
from arcpy.sa import *
import copy
import shutil

#create new location
env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\"
#os.makedirs("F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\Data_files")

for dirpath, dirnames, filenames in arcpy.da.Walk(env.workspace, topdown=True, datatype="Text"):
	for filename in filenames:
		path=dirpath+".txt"
		outpath="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\Data_files\\"+filename+".txt"
		shutil.copy(path,outpath)