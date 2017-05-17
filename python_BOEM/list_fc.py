##script to subset species richness rasters by monthly cluster subsets

import arcpy
from arcpy import env
import os
from arcpy.sa import *



#env.workspace="F:\\SDM_paper\\maxent\\Maxent_run\\Species_richness\\clusters\\"
WEA=["DE","MS","NC","NJ","NY","RI","VA"]
#WEA=["MS","NJ","NY","RI","VA"]
#WEA=["DE","MS","NJ","NY","RI",]

env.workspace="F:\\BOEM final report\\GIS_data"

for root, dirs, files in os.walk("F:\\BOEM final report\\GIS_data"):
    for f in files:
		if f.endswith('.aux.xml'):
			print os.path.join(root, f)