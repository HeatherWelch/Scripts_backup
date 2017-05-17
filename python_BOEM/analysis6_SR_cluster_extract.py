##script to subset species richness rasters by monthly cluster subsets

import arcpy
from arcpy import env
import os
from arcpy.sa import *



#env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\clusters\\"
#WEA=["DE","MS","NC","NJ","NY","RI","VA"]
#WEA=["MS","NJ","NY","RI","VA"]
#WEA=["DE","MS","NJ","NY","RI",]
#WEA=["MS","NJ","NY","RI","VA"]
WEA=["DE","NC","VA"]

arcpy.env.workspace="E:\\Latest_BOEM_Data\\WEA_Rim_Lease_Blocks\\"
out_workspace="F:\\BOEM final report\\GIS_data\\"
#raster="F:\\BOEM final report\\Regional_layers\\RV_Henry_Bigelow\\aspect_crm"
clipf="F:\\BOEM final report\\Regional_layers\\Sediments\\HB1505_CTD.shp"

for a in WEA:
	for shape in arcpy.ListFeatureClasses():
		print (shape)
		if a in shape:
			#bname=arcpy.Describe(shape).basename
			# name="aspect_crm_"+a+".shp"
			name="HB1505_CTD_"+a+".shp"
			print(name)
			#EM=ExtractByMask(raster,shape)
			out=out_workspace+a+"\\RV_Henry_Bigelow\\"+name
			# out=out_workspace+a+"\\CTD\\"
			print(out)
			# EMsave=os.path.join(out,name)
			#print(EMsave)
			#EM.save(out)
			arcpy.Clip_analysis(clipf,shape,out,"")
		else:
			pass