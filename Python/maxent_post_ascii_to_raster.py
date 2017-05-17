####script to take maxent output asciis and convert them to arcGRIDS
#deals with both raw and clamped asciis



import arcpy
from arcpy import env
import os
from arcpy.sa import *

#env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\rasters\\"
months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]
# for m in months:
	# os.makedirs("F:\\SDM_paper\\maxent\\Maxent_run\\rasters\\"+m)

env.workspace="F:\SDM_paper\maxent\Maxent_run\models\WH_trawl_long\\"
out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\rasters\\"

# env.workspace="F:\\SDM_paper\\maxent_trial\\models\\WH_trawl_long"
species=arcpy.ListFiles()
env.overwriteOutput=True
for sp in species:
	env.workspace="F:\SDM_paper\maxent\Maxent_run\models\WH_trawl_long\\"+sp+"\\weather\\"
	for ras in arcpy.ListRasters():
		raster="F:\SDM_paper\maxent\Maxent_run\models\WH_trawl_long\\"+sp+"\\weather\\"+ras
		if "clamping" in raster:
			# bname=arcpy.Describe(raster).basename
			# short=bname.replace("clamping","c")
			# OUTRAS=os.path.join(out_workspace,short)
			# #INRAS=os.path.join(env.workspace,raster)
			# print(INRAS)
			# print(OUTRAS)
			# arcpy.ASCIIToRaster_conversion(raster,OUTRAS,"FLOAT")
			pass
		else:
			for m in months:
				if m in raster:
					bname=arcpy.Describe(raster).basename
					out_save=out_workspace+m
					OUTRAS=os.path.join(out_save,bname)
					if arcpy.Exists(OUTRAS):
						print(OUTRAS+ "already exists")
					else:	
						#INRAS=os.path.join(env.workspace,raster)
						print(bname)
						print(OUTRAS)
						arcpy.ASCIIToRaster_conversion(raster,OUTRAS,"FLOAT")
				else:
					pass

					
					
# for file in arcpy.ListFiles("*.asc"):
	# print(file)
	# outras=arcpy.Describe(file).basename
	# print(outras)
	# if "temperature" in outras:
		# var=outras.replace("temperature","t")
	# else:
		# var=outras
	# print(var)
	# month=var.replace("month","m")
	# print(month)
	# if "mean" in month:
		# stat=month.replace("mean","m")
	# else:
		# stat=month.replace("standard_deviation","sd")
	# print(stat)
	# depth=stat.replace("20000m","btm")
	# print(depth)
	# OUTRAS=os.path.join(out_workspace,depth)
	# print(OUTRAS)
	# INRAS=os.path.join(env.workspace,file)
	# print(INRAS)
	# arcpy.ASCIIToRaster_conversion(INRAS,OUTRAS,"FLOAT")