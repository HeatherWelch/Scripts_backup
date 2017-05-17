###06a. tool to extract static bottom env values to biotic points

import arcpy, arcinfo
from arcpy import env
import os
from arcpy.sa import *

			
##this script works	
shape="F:\\SDM_paper\\regional_trawl\\trawl_subsets_static\\WH_TRAWL_regional_abund_wide_clean.shp"					
env.workspace="F:\\Pass to Heather" #identify static rasters
for raster in arcpy.ListRasters(): #for each new static raster
	print(raster)
	extract_layer="F:\\SDM_paper\\maxent\\rs_rasters\\m01\\"+raster #did not save rasters to any solo folder, will just grab them from one of the monthly folders
	print(extract_layer)
	fieldname=str(raster[0:9])
	print(fieldname)
	print("Extracting all points from "+raster+" and putting them in attribute field name "+fieldname)
	ExtractMultiValuesToPoints(shape,[[raster,fieldname]],"NONE")



	

