#tool to calculate focal statistics for each of the class probability bands to assess cluster success


import arcpy
from arcpy import env
import os
from arcpy.sa import *

# env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters\\class_probability\\"
# out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters\\class_probability\\zonal\\"
# #months=["m01_cpc","m02_cpc","m03_cpc","m04_cpc","m05_cpc","m06_cpc","m07_cpc","m08_cpc","m09_cpc","m10_cpc","m11_cpc","m12_cpc"]
# months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]

# for raster in arcpy.ListRasters():
	# for month in months:
		# if month in raster:
			# bname=arcpy.Describe(raster).basename
			# zonal="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters\\"+month+"_edit"
			# out_file=out_workspace+bname
			# outtable=ZonalStatisticsAsTable(zonal,"VALUE",raster,out_file,"DATA","ALL")
			# arcpy.AddField_management(outtable,"CP_Layer","TEXT","","","","","","")
			# arcpy.CalculateField_management(outtable,"CP_Layer",'[CP_Layer]=bname',"VB")
		# else:
			# pass
			
# months=["m01_cpc","m02_cpc","m03_cpc","m04_cpc","m05_cpc","m06_cpc","m07_cpc","m08_cpc","m09_cpc","m10_cpc","m11_cpc","m12_cpc"]
# env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters\\class_probability\\zonal\\"
# out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters\\class_probability\\zonal\\aggregated\\"
# for month in months:
	# wildcard=month+"*"
	# list=arcpy.ListTables(wildcard, "INFO")
	# output=out_workspace+month
	# arcpy.Merge_management(list,output)
	
	
	
######second pass for the del2a filled layers
# env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters_del2a\\class_probability\\"
# out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters_del2a\\class_probability\\zonal\\"
# #months=["m01_cpc","m02_cpc","m03_cpc","m04_cpc","m05_cpc","m06_cpc","m07_cpc","m08_cpc","m09_cpc","m10_cpc","m11_cpc","m12_cpc"]
# months=["m01","m02","m03","m04","m05","m06","m07","m08","m09","m10","m11","m12"]

# for raster in arcpy.ListRasters():
	# for month in months:
		# if month in raster:
			# bname=arcpy.Describe(raster).basename
			# zonal="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters_del2a\\"+month+"_edit_d2a"
			# out_file=out_workspace+bname
			# outtable=ZonalStatisticsAsTable(zonal,"VALUE",raster,out_file,"DATA","ALL")
			# arcpy.AddField_management(outtable,"CP_Layer","TEXT","","","","","","")
			# expression="[CP_layer]="+bname
			# arcpy.CalculateField_management(outtable,"CP_Layer",expression,"VB")
		# else:
			# pass
			
			
			
months=["m06_d2acpc","m07_d2acpc","m08_d2acpc","m09_d2acpc"]
env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters_del2a\\class_probability\\zonal\\"
out_workspace="F:\\SDM_paper\\maxent\\Maxent_run\\PCAs\\clusters\\remapped_clusters_del2a\\class_probability\\zonal\\aggregated\\"
for month in months:
	wildcard=month+"*"
	list=arcpy.ListTables(wildcard, "INFO")
	output=out_workspace+month
	arcpy.Merge_management(list,output)