#tool to create a list of all rasters within a directory (including sub folders)
import arcpy
import os
from arcpy import env
from arcpy.sa import *

workspace = "F:/SDM_paper/maxent/Maxent_run/extracted_rasters" ## alter based on what the season is.
mxd=arcpy.mapping.MapDocument("F:\\open house\\y2016\\video2.mxd")
df = arcpy.mapping.ListDataFrames(mxd)[0]

species=['pb131','bp15','d103','d139','d141','e301','p135']

#create a list of all rasters 
for sp in species:
	for dirpath, dirnames, filenames in arcpy.da.Walk(workspace,topdown=True,datatype="RasterDataset"):
		for filename in filenames:
			if sp in filename:
				file=os.path.join(dirpath,filename)
				result = arcpy.MakeRasterLayer_management(file, filename)
				layer = result.getOutput(0)
				arcpy.mapping.AddLayer(df,layer,"BOTTOM")
			else:
				pass

	
