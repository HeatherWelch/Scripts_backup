####Iterate rasters, copy each raster to new location
####import local environments
import arcpy
from arcpy import env
import os

####set local variables
env.workspace="D:/data"
out_workspace="D:/data/python"

####set up iterartion
for raster in arcpy.ListRaster(): ###for each raster found by the ListRaster function in the env.workspace...
	output=os.path.join(out_workspace,raster) ####output is a join between out_workspace and raster, e.g.; "D:/data/python/raster1"
	arcpy.CopyRaster_management(raster,output,"","","","NONE","NONE","32_BIT_SIGNED") ####call copy raster tool, define input raster, output raster, and other tool parameters (see tool documentation)
####to alter the name of each raster, modify line 2 as such: output=os.path.join(out_workspace,raster + "_namechange")


####Iterate feature classes, clip each feature class
####import local environments
import arcpy
from arcpy import env
import os

####set local variables
env.workspace="D:/data"
out_workspace="D:/data/python"

####set up iteration
for fc in arcpy.ListFeatureClasses(): ####for each feature class found by the ListFeatureClasses function in the env.workspace...
	outfc=arcpy.Describe(fc).basename + "_clip" ####grab the basename (excludes the .shp) and add "_clip"
	output=os.path.join(out_workspace,outfc) ####output is a join between out_workspace and outfc, e.g.; "D:/data/python/fc1_clip"
	arcpy.Clip_analysis(fc,"clip_feature",output,0.1) ####call clip tool,( define input feature class, clip feature, output feature class, xy tollerance)
	

####feature classes####
####completing multiple functions within a for loop
####E.g.; clip feature class, THEN copy to new location

####import local environments
import arcpy
from arcpy import env
import os

####set local variables
env.workspace="D:/data"
out_workspace="D:/data/python"

####set up iteration
for fc in arcpy.ListFeatureClasses(): ####for each feature class found by the ListFeatureClasses function in the env.workspace...
	outfc=arcpy.Describe(fc).basename + "_clip" ####grab the basename (excludes the .shp) and add "_clip"
	output=os.path.join(out_workspace,outfc) ####output is a join between out_workspace and outfc, e.g.; "D:/data/python/fc1_clip"
	clip=arcpy.Clip_analysis(fc,"clip_feature",output,0.1) ####define function as an object, call clip tool, (define input feature class, clip feature, output feature class, xy tollerance)
	
	###2nd function, CopyFeatureClass
	outputclip=os.path.join(env.workspace,outfc)####output is a join between env.workspace and outfc, both defined above
	arcpy.CopyFeatures_management(clip,outputclip)####call copy features tool, input feature is the output of the clip function (above), output is defined in the preceeding line


####cell statistics on many rasters in the same directory
####import local environments
import arcpy
from arcpy import env
import os
from arcpy.sa import *

####set local variables
env.workspace="D:\\data" ####for some reason occasionally need '\\' as opposed to '\'
rasters=arcpy.ListRasters() ####lists rasters in working directory and saves them as an object, can use wild card e.g.; ("*raster") includes only rasters whose names end in 'raster'

####set up call statistics
outcell=arcpy.sa.CellStastics([rasters],"DATA TYPE","DATA OR NODATA") ####see documentation for required fields
outcell.save("D:\\data\\python\\raster_name") ####permanently saves object created in the proceeding line, GRID format does not need extension, but e.g. IMAGINE, .img


####rasters####
####completing multiple functions within a for loop
####E.g.; copy raster, then extract by mask

####import local environments
import arcpy
from arcpy import env
import os
from arcpy.sa import *

####set local variables
env.workspace="D:/data"
out_workspace="D:/data/python"

####set up iteration
for raster in arcpy.ListRasters("wildcard*"): ####lists rasters in working directory, can use wild card e.g.; ("*raster") includes only rasters whose names end in 'raster'
	outraster=os.path.join(out_workspace,raster+"_copy4") ####output is a join between out_workspace and raster_copy4, e.g.; "D:/data/python/raster_copy4"
	copy=arcpy.CopyRaster_management(raster,outraster,"","","","NONE","NONE","32_BIT_FLOAT") ####copies raster to new location with new name, saves as an object for use in the next function
	EM=ExtractByMask(copy,"extract_layer") ####Extracts each copied raster using "extract_layer", saves as an object **spatial analyst tools require a .save command to make layers permanent**
	EMsave=os.path.join(out_workspace,raster+"_xx") ####Define object with new pathway and name for extract by mask product
	EM.save(EMsave) ####call the save function (required for spatial analyst) ####save object (layer) to make it permanent**
	
	
####rasters####
####iteration to convert krig outputs to GRID, extract by mask####

####import local environments
import arcpy
from arcpy import env
import os
from arcpy.sa import *

####set local variables
env.workspace="D://data"
mask="D://data/mask.shp"
mxd=arcpy.mapping.MapDocument"D://data/mapname.mxd"

####set up iteration
for lyr in arcpy.mapping.ListLayers(mxd,"*wildcard*"):
	print("Converting kriging layer to raster")
	GALayer=arcpy.GALayerToGrid_ga(lyr,"B:\\Arc Tools\\trial\d1","cell size","1","1")
	print("Extracting by mask")
	EM=ExtractByMask(GALayer,mask)
	EMsave=os.path.join(env_workspace,lyr.name)
	EM.save(EMsave)
	print("Deleting intermediate data")
	arcpy.Delete_management("B:\\Arc Tools\\trial\d1")

	
####rasters####
####iterative extract by mask with 1 raster and multiple masks####

####import local environments
import arcpy
from arcpy import env
import os
from arcpy.sa import *

####set local variables
env.workspace="D://data"
raster="D://data/raster"

####set up iteration
for fc in arcpy.ListFeatureClasses():
	em=ExtractByMask(raster,fc)
	outrast=arcpy.Describe(fc).basename+"_clip" ####names each extracted raster "outrast" as name of mask'+'clip
	emsave=os.path.join(env.workspace,outrast) 
	em.save(emsave)
