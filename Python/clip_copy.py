import arcpy
from arcpy import env
import os

####set local variables
env.workspace="F:/trial"
out_workspace="F:/trial/xxx"
clip_feature="F:/trial/clip_feature.shp"

for fc in arcpy.ListFeatureClasses(): ####for each feature class found by the ListFeatureClasses function in the env.workspace...
	outfc=arcpy.Describe(fc).basename + "_clip" ####grab the basename (excludes the .shp) and add "_clip"
	output=os.path.join(out_workspace,outfc) ####output is a join between out_workspace and outfc, e.g.; "D:/data/python/fc1_clip"
	clip=arcpy.Clip_analysis(fc,clip_feature,output,0.1) ####define function as an object, call clip tool, (define input feature class, clip feature, output feature class, xy tollerance)
	
	###2nd function, CopyFeatureClass
	outputclip=os.path.join(env.workspace,outfc)####output is a join between env.workspace and outfc, both defined above
	arcpy.CopyFeatures_management(clip,outputclip)####call copy features tool, input feature is the output of the clip function (above), output is defined in the preceeding line
