import arcpy
from arcpy import env
import os
from arcpy.sa import *

out_workspace=env.workspace="F:\\Remote Sensing Data\\Bottom_hycom_bottom_temp_U\\rasters"
env.workspace="F:\\Remote Sensing Data\\Bottom_hycom_bottom_temp_U\\asciis"
for file in arcpy.ListFiles("*.asc"):
	print(file)
	outras=arcpy.Describe(file).basename
	print(outras)
	if "temperature" in outras:
		var=outras.replace("temperature","t")
	else:
		var=outras
	print(var)
	month=var.replace("month","m")
	print(month)
	if "mean" in month:
		stat=month.replace("mean","m")
	else:
		stat=month.replace("standard_deviation","sd")
	print(stat)
	depth=stat.replace("20000m","btm")
	print(depth)
	OUTRAS=os.path.join(out_workspace,depth)
	print(OUTRAS)
	INRAS=os.path.join(env.workspace,file)
	print(INRAS)
	arcpy.ASCIIToRaster_conversion(INRAS,OUTRAS,"FLOAT")