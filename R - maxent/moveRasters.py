# move rasters from 1 location to a folder based on its month - Chevrier 9/25/2015

import os.path
import arcpy
from arcpy import env
months=['m01','m02','m03','m04','m05','m06','m07','m08','m09','m10','m11','m12']
month = ''
# set workspace to the folder with your rasters
env.workspace=r'F:\Documents\GIS\SandyHookRasterProblem\test_python'
# set outputLocation to 
outputLocation = r'F:\Documents\GIS\SandyHookRasterProblem\test_python\output'
env.overwriteOutput=True
rasters = arcpy.ListRasters()
for raster in rasters:
        month = ''
        for m in months:
                if m in raster:
                        month = m
                        break

        if len(month) > 0:
                out = outputLocation + "\\" + month
                if not os.path.exists(out):
                        os.makedirs(out)
                outFile = out + "\\" + raster
                arcpy.CopyRaster_management(raster,outFile)
                print raster + " copied to " + out
        else:
                out = outputLocation + "\\misc"
                if not os.path.exists(out):
                        os.makedirs(out)
                outFile = out + "\\" + raster
                arcpy.CopyRaster_management(raster,outFile)
                print raster + " copied to " + out
			
