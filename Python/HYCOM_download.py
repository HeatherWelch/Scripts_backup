##tool to batch the downloading of HYCOM GLBu0.08 climatological rasters

# import arcpy, arcinfo
# from arcpy import env
# import os
# from arcpy.sa import *

# # Load required toolboxes
# arcpy.ImportToolbox("C:/Program Files/GeoEco/ArcGISToolbox/Marine Geospatial Ecology Tools.tbx")

# # Local variables:
# save_workspace = "F:\\Remote Sensing Data\\HYCOM_GLBu0.08"
# HYCOM_GLBu0_08__2_ = save_workspace

# # Process: Create Climatological Rasters for HYCOM GLBu0.08 Equatorial 4D Variable
# #u_0_m
# arcpy.HYCOMGLBu008Equatorial4DCreateClimatologicalArcGISRasters_GeoEco("u", "Mean", "Monthly", save_workspace, "add", "%(VariableName)s;%(ClimatologyBinType)s_Climatology;Depth_%(Depth)04.0fm;%(VariableName)s_%(Depth)04.0fm_%(ClimatologyBinName)s_%(Statistic)s.img", "1", "1", "", "false", "-76 35 -69 42", "Degrees", "0", "0", "1/1/2002", "", "60", "120", "", "true", "false")
# #u_1_m
# #u_2_m
# #u_0_sd
# arcpy.HYCOMGLBu008Equatorial4DCreateClimatologicalArcGISRasters_GeoEco("u", "Standard Deviation", "Monthly", save_workspace, "add", "%(VariableName)s;%(ClimatologyBinType)s_Climatology;Depth_%(Depth)04.0fm;%(VariableName)s_%(Depth)04.0fm_%(ClimatologyBinName)s_%(Statistic)s.img", "1", "1", "", "false", "-76 35 -69 42", "Degrees", "0", "0", "1/1/2002", "", "60", "120", "", "true", "false")
# #u_1_sd
# #u_2_sd

# #v_0_m
# arcpy.HYCOMGLBu008Equatorial4DCreateClimatologicalArcGISRasters_GeoEco("v", "Mean", "Monthly", save_workspace, "add", "%(VariableName)s;%(ClimatologyBinType)s_Climatology;Depth_%(Depth)04.0fm;%(VariableName)s_%(Depth)04.0fm_%(ClimatologyBinName)s_%(Statistic)s.img", "1", "1", "", "false", "-76 35 -69 42", "Degrees", "0", "0", "1/1/2002", "", "60", "120", "", "true", "false")
# #v_1_m
# #v_2_m
# #v_0_sd
# #v_1_sd
# #v_2_sd

# #t_0_m
# arcpy.HYCOMGLBu008Equatorial4DCreateClimatologicalArcGISRasters_GeoEco("temperature", "Mean", "Monthly", save_workspace, "add", "%(VariableName)s;%(ClimatologyBinType)s_Climatology;Depth_%(Depth)04.0fm;%(VariableName)s_%(Depth)04.0fm_%(ClimatologyBinName)s_%(Statistic)s.img", "1", "1", "", "false", "-76 35 -69 42", "Degrees", "0", "0", "1/1/2002", "", "60", "120", "", "true", "false")
# #t_1_m
# #t_2_m
# #t_0_sd
# #t_1_sd
# #t_2_sd

# #sal_0_m
# arcpy.HYCOMGLBu008Equatorial4DCreateClimatologicalArcGISRasters_GeoEco("salinity", "Mean", "Monthly", save_workspace, "add", "%(VariableName)s;%(ClimatologyBinType)s_Climatology;Depth_%(Depth)04.0fm;%(VariableName)s_%(Depth)04.0fm_%(ClimatologyBinName)s_%(Statistic)s.img", "1", "1", "", "false", "-76 35 -69 42", "Degrees", "0", "0", "1/1/2002", "", "60", "120", "", "true", "false")
# #sal_1_m
# #sal_2_m
# #sal_0_sd
# #sal_1_sd
# #sal_2_sd


location=["0","10.0","20000"]
variable=["u","v","salinity","temperature"]
stat=["Mean","Standard Deviation"]

for l in location:
	for v in variable:
		for s in stat:
			#arcpy.HYCOMGLBu008Equatorial4DCreateClimatologicalArcGISRasters_GeoEco(v, s, "Monthly", save_workspace, "add", "%(VariableName)s;%(ClimatologyBinType)s_Climatology;Depth_%(Depth)04.0fm;%(VariableName)s_%(Depth)04.0fm_%(ClimatologyBinName)s_%(Statistic)s.img", "1", "1", "", "false", "-76 35 -69 42", "Degrees", "l", "l", "1/1/2002", "", "60", "120", "", "true", "false")
			print(v+s+l+l)
	
