######script to prepare remote-sensing data for maxent

import arcpy, arcinfo
from arcpy import env
import os
from arcpy.sa import *

##############################05. convert to asciis and put in correct folder in projections folder		
# months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]
# env.workspace="F:\\SDM_paper\\maxent\\projections"

# for file in arcpy.ListFiles():
			# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\"+file
			# print(env.workspace)
			# for raster in arcpy.ListRasters():
				# for m in months:
					# if m in raster:
						# print(m)
						# print(raster)
						# out_workspace="F:\\SDM_paper\\maxent\\projections\\"+m
						# name=arcpy.Describe(raster).basename
						# EMsave=os.path.join(out_workspace,name+".asc")
						# print(EMsave)
						# if arcpy.Exists(EMsave):
							# print("already exists")
						# else:
							# arcpy.RasterToASCII_conversion(raster,EMsave)
							# pass
					# else:
						# pass
						
						
##############################05.5. convert to GLBu0.08 + GHRSST_SD asciis and put in correct folder in projections folder		
# months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]
# env.workspace="F:\\SDM_paper\\maxent\\projections"

# for file in arcpy.ListFiles():
	# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\"+file
	# print(env.workspace)
	# for raster in arcpy.ListRasters():
		# for m in months:
			# if m in raster:
				# print(m)
				# print(raster)
				# out_workspace="F:\\SDM_paper\\maxent\\projections\\"+m
				# name=arcpy.Describe(raster).basename
				# EMsave=os.path.join(out_workspace,name+".asc")
				# print(EMsave)
				# if arcpy.Exists(EMsave):
					# print("already exists")
				# else:
					# arcpy.RasterToASCII_conversion(raster,EMsave)
			# else:
				# pass						
			
			
##############################05a. convert static rasters (btm and crm) to asciis and put in correct folder in projections folder		
#months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]

			
# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\m01"			
# for raster in arcpy.ListRasters():
	# if "crm_" in raster:
		# raster_full="F:\\SDM_paper\\maxent\\rs_rasters\\m01\\"+raster
		# name=arcpy.Describe(raster_full).basename
		# env.workspace="F:\\SDM_paper\\maxent\\projections"
		# for file in arcpy.ListFiles():
			# save_workspace="F:\\SDM_paper\\maxent\\projections\\"+file
			# print(save_workspace)
			# EMsave=os.path.join(save_workspace,name+".asc")
			# print(EMsave)
			# arcpy.RasterToASCII_conversion(raster_full,EMsave)
	# elif "btm_" in raster:
		# raster_full="F:\\SDM_paper\\maxent\\rs_rasters\\m01\\"+raster
		# name=arcpy.Describe(raster_full).basename
		# env.workspace="F:\\SDM_paper\\maxent\\projections"
		# for file in arcpy.ListFiles():
			# save_workspace="F:\\SDM_paper\\maxent\\projections\\"+file
			# print(save_workspace)
			# EMsave=os.path.join(save_workspace,name+".asc")
			# print(EMsave)
			# arcpy.RasterToASCII_conversion(raster_full,EMsave)
	# else:
		# pass
						
						
						
						
##############################05a. convert static rasters (frac) to asciis and put in correct folder in projections folder		
#months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]

			
# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\m01"			
# for raster in arcpy.ListRasters():
	# if "frac" in raster:
		# raster_full="F:\\SDM_paper\\maxent\\rs_rasters\\m01\\"+raster
		# name=arcpy.Describe(raster_full).basename
		# env.workspace="F:\\SDM_paper\\maxent\\projections"
		# for file in arcpy.ListFiles():
			# save_workspace="F:\\SDM_paper\\maxent\\projections\\"+file
			# print(save_workspace)
			# EMsave=os.path.join(save_workspace,name+".asc")
			# print(EMsave)
			# arcpy.RasterToASCII_conversion(raster_full,EMsave)
	# else:
		# pass


#########################06. Delete months from ascii names
months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]
env.workspace="F:\\SDM_paper\\maxent\\projections"

for file in arcpy.ListFiles():
	env.workspace="F:\\SDM_paper\\maxent\\projections\\"+file
	print(env.workspace)
	for raster in arcpy.ListRasters():
		for m in months:
			if m in raster:
				print(m)
				print(raster)
				remove="_"+m
				new_name=raster.replace(remove,"")
				print(new_name)
				arcpy.Rename_management(raster,new_name)
			else:
				pass						
			
		