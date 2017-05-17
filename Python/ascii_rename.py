##renaming asciis in the monthly projections folders post-maxent run because like a dumbass i fucked it up

import arcpy, arcinfo
from arcpy import env
import os
from arcpy.sa import *

# env.workspace="F:\\SDM_paper\\maxent\\extracted_rasters\\static_modeling\\asciis"
# for raster in arcpy.ListRasters():
		# if "btm_rug_n3gc" in raster:
			# name=raster.replace("_n3gc","_n3")
			# arcpy.Rename_management(raster,name)
		# elif "fracgrav_01" in raster:
			# name=raster.replace("fracgrav_01","fracgrav_0")
			# arcpy.Rename_management(raster,name)
		# elif "fracsand_01" in raster:
			# name=raster.replace("fracsand_01","fracsand_0")
			# arcpy.Rename_management(raster,name)
		# else:
			# pass

# for file in arcpy.ListFiles():
	# env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\projections\\"+file
	# for raster in arcpy.ListRasters():
		# if "btm_rug_n3gc" in raster:
			# name=raster.replace("_n3gc","_n3")
			# arcpy.Rename_management(raster,name)
		# elif "fracgrav_01" in raster:
			# name=raster.replace("fracgrav_01","fracgrav_0")
			# arcpy.Rename_management(raster,name)
		# elif "fracsand_01" in raster:
			# name=raster.replace("fracsand_01","fracsand_0")
			# arcpy.Rename_management(raster,name)
		# else:
			# pass
			
###copy problem rasters			
#asciis=["btm_rug_n3","crm_rs_001","crm_slp_gc","fracgrav_0","fracmud_01","fracsand_0"]

# env.workspace="F:\\SDM_paper\\maxent\\rs_rasters\\m01"
# out="F:\\SDM_paper\\maxent\\extracted_rasters\\static_modeling\\"
# for ascii in asciis:
	# for raster in arcpy.ListRasters():
		# if ascii in raster:
			# out_file=out+raster
			# arcpy.CopyRaster_management(raster,out_file,"","","","NONE","NONE","","NONE","NONE")
			
			
###convert to asciis
			
# extract_layer="F:\\SDM_paper\\maxent\\rs_rasters\\m01\\ghrsst_m01"			
# env.workspace="F:\\SDM_paper\\maxent\\extracted_rasters\\static_modeling\\"
# out="F:\\SDM_paper\\maxent\\extracted_rasters\\static_modeling\\extract"
# for raster in arcpy.ListRasters():
	# arcpy.env.snapRaster="F:\\SDM_paper\\maxent\\rs_rasters\\m01\\ghrsst_m01"
	# arcpy.env.cellSize="F:\\SDM_paper\\maxent\\rs_rasters\\m01\\ghrsst_m01"
	# EM=ExtractByMask(raster,extract_layer) 
	# EMsave=os.path.join(out,raster) 
	# print(EMsave)
	# EM.save(EMsave)
	
#move into monthly projections forlder
env.overwriteOutput=True
env.workspace="F:\\SDM_paper\\maxent\\extracted_rasters\\static_modeling\\asciis"
rasters=arcpy.ListRasters()
env.workspace=r"F:\SDM_paper\maxent\Maxent_run\projections"
for raster in rasters:
	for file in arcpy.ListFiles():
		raster_full="F:\\SDM_paper\\maxent\\extracted_rasters\\static_modeling\\asciis\\"+raster
		out_file="F:\\SDM_paper\\maxent\\Maxent_run\\projections\\"+file+"\\"+raster
		arcpy.Copy_management(raster_full,out_file)
	