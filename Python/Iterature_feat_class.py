####Iterate feature classes, clip each feature class
####import local environments
import arcpy
from arcpy import env
import os

####set local variables
env.workspace="F:/trial"
out_workspace="F:/trial/outputz"
clip_feature="F:/trial/clip_feature.shp"

####set up iteration
for fc in arcpy.ListFeatureClasses("*copy*"): ####for each feature class found by the ListFeatureClasses function in the env.workspace...
	outfc=arcpy.Describe(fc).basename + "_clip" ####grab the basename (excludes the .shp) and add "_clip"
	output=os.path.join(out_workspace,outfc) ####output is a join between out_workspace and outfc, e.g.; "D:/data/python/fc1_clip"
	arcpy.Clip_analysis(fc,clip_feature,output,0.1) ####call clip tool,( define input feature class, clip feature, output feature class, xy tollerance)