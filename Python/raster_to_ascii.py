####convert rasters in 4 folders to asciis

import arcpy
from arcpy import env
import os
from arcpy.sa import *

env.workspace="F:\\Remote Sensing Data\\Bottom_hycom_bottom_temp_U"
dirs=os.listdir(env.workspace) #see what directories are in the workspace
out_directory="F:\\Remote Sensing Data\\Bottom_hycom_bottom_temp_U\\asciis"
print(dirs)

for d in arcpy.ListWorkspaces("Depth*"): #see what directories are in the workspace
	print(d)
	env.workspace=d
	for file in arcpy.ListRasters():
		print("file equals",file)
		outasc=arcpy.Describe(file).basename+".asc"
		print("outasc equals",outasc)
		outASCII=os.path.join(out_directory,outasc)
		print("outASCII equals",outASCII)
		arcpy.RasterToASCII_conversion(file,outASCII)
		