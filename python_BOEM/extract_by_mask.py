##script to subset species richness rasters by monthly cluster subsets

import arcpy
from arcpy import env
import os
from arcpy.sa import *



#env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\clusters\\"
WEA=["DE","MS","NC","NJ","NY","RI","VA"]
#WEA=["MS","NJ","NY","RI","VA"]
#WEA=["DE","MS","NJ","NY","RI",]

env.workspace="E:\\Latest_BOEM_Data\\WEA_Rim_Lease_Blocks\\"
out_workspace="F:\\BOEM final report\\GIS_data\\"
raster="F:\\BOEM final report\\Regional_layers\\Sediments\\us_am_s_e"
#clipf="F:\\BOEM final report\\Regional_layers\\CRM_and_derived\\30m_contour_rg.shp"

for a in WEA:
	for shape in arcpy.ListFeatureClasses():
		print (shape)
		if a in shape:
			#bname=arcpy.Describe(shape).basename
			# name="aspect_crm_"+a+".shp"
			name="us_am_s_e_"+a
			print(name)
			EM=ExtractByMask(raster,shape)
			out=out_workspace+a+"\\Sediment\\"+name
			# out=out_workspace+a+"\\CRM_derived_products\\"
			print(out)
			# EMsave=os.path.join(out,name)
			#print(EMsave)
			EM.save(out)
			arcpy.ImportMetadata_conversion(raster, "FROM_ARCGIS", out)
			# arcpy.Clip_analysis(clipf,shape,out,"")
		else:
			pass