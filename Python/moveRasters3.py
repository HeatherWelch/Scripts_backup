# move rasters from 1 location to a folder based on its month - Chevrier 9/25/2015

import os.path
import arcpy
from arcpy import env
from arcpy.sa import *
months=['m01','m02','m03','m04','m05','m06','m07','m08','m09','m10','m11','m12']
month = ''
# set workspace to the folder with your rasters
env.workspace=r'F:\Remote Sensing Data\Maxent-Copy_reprojected_NAD\temp_0_clim_mean'
# set outputLocation to 
outputLocation = r'F:\NOAA_gis_support\trial'
env.overwriteOutput=True
extract_layer="F:\\SDM_paper\\regional_extent\\rs_extent_-38"
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
                arcpy.env.snapRaster="F:\\SDM_paper\\regional_extent\\rs_extent_-38"
                arcpy.env.cellSize="F:\\SDM_paper\\regional_extent\\rs_extent_-38"
                #arcpy.env.nodata="MINIMUM"
                EM=ExtractByMask(raster,extract_layer)
                EM.save(outFile)
                #arcpy.gp.ExtractByMask_sa(raster,extract_layer,outFile)
                print raster + " copied to " + out
        else:
                out = outputLocation + "\\misc"
                if not os.path.exists(out):
                        os.makedirs(out)
                outFile = out + "\\" + raster
                arcpy.CopyRaster_management(raster,outFile)
                print raster + " copied to " + out
			
