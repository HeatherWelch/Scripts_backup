import arcpy
from arcpy import env
import os
from arcpy.sa import *

prjfile = "C:\User\<username>\AppData\Roaming\ESRI\Desktop10.3\ArcMap\Coordinate Systems\NAD 83.prj"
## note that for this to work in Arc 10.3, the coordinate system in question needs to be added to your favorites list in ArcMap. 

env.workspace = "YOUR WORKSPACE GOES HERE"
for raster in arcpy.ListRasters():
    print raster
    arcpy.DefineProjection_management(raster, prjfile)
    print "defined projection"
print "done"
    