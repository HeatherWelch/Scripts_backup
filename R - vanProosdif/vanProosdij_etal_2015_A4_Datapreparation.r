#######################################################################################
### van Proosdij, A.S.J., Sosef, M.S.M., Wieringa, J.J. and Raes, N. 2015.
### Minimum required number of specimen records to develop accurate species distribution
### models
### Ecography, DOI: 10.1111/ecog.01509
### Appendix 4: R script for data preparation for the real African study area.
#######################################################################################

#######################################################################################
#########################  DATA PREPARATION FUNCTION  #################################
#######################################################################################

#######################################################################################
#######################################################################################
###  Written by André S.J. van Proosdij (1,2) & Niels Raes (2), 2015
###  1 Biosystematics Group, Wageningen University, the Netherlands
###  2 Naturalis Biodiversity Center (Botany section), Leiden, the Netherlands
###  Corresponding author: André S.J. van Proosdij, andrevanproosdij at hotmail dot com
#######################################################################################
#######################################################################################

#######################################################################################
# This script is used to prepare data files with spatial environmental data. Separate
# sections are written for climatic, soil and altitudinal data sets. A final section
# deals with analysis of multicollinearity, selection of variables and the preparation
# of PCA axes based on selected variables.
#######################################################################################

#######################################################################################
#########################  Index  #####################################################
#######################################################################################
# 1. Load packages.
# 2. Soil data from the Harmonized World Soil Database.
# 3. Climate and altitude data from WORLDCLIM.
# 4. Altitude data at 90 m spatial resolution.
# 5. Analysis of multicollinearity & selection of variables.
# 6. Preparing PCA axes as input variables for analysis.
# 7. Create a mask file for Gabon plus a buffer. 
#######################################################################################

#######################################################################################
#########################  1. Load packages  ##########################################
#######################################################################################

rm(list = ls(all = TRUE))
setwd("D:/R")
getwd()
library(raster) # stack(), scale(), crop(), writeRaster(), raster(), aggregate(), raster(), mask(), and mosaic() functions
library(rgdal)
library(dismo)
library(SDMTools) # asc2dataframe() function
library(sp)
library(adehabitatHS)
library(plyr) # joining df
library(scales) # rescale() function
require(maptools) # readShapeSpatial() function
require(rgeos) # gBuffer() function
library(Hmisc) # rcorr() function
library(ade4) # dudi.pca() function
data(wrld_simpl)

# Define the extent of the study area: lon 18W 43E; lat 15N 19S
ext.CAfr <- extent(-18, 43, -19, 15)

#######################################################################################
#########################  2. Soil data from the Harmonized World Soil Database  ######
#######################################################################################

# Download soil data from the Harmonized World Soil Database website (FAO/IIASA/ISRIC/
# ISSCAS/JRC, 2012. HWSD (version 1.2). FAO, Rome, Italy and IIASA, Laxenburg, Austria.)
# http://webarchive.iiasa.ac.at/Research/LUC/External-World-soil-database/HTML/
# Download and store the .bil and .mdb file.

setwd("D:/HWSD")
getwd()

# Read the .bil file and crop it to the spatial extent of the study area.
hwsd.files <- list.files("D:/HWSD", pattern = "[.]bil", full.names = TRUE)
hwsd.CAfr <- crop((raster(hwsd.files)), ext.CAfr)
# Export as .asc file, first set the directory, otherwise writeRaster will not work.
setwd ("D:/HWSD")
writeRaster(hwsd.CAfr,
            filename  = paste(c("D:/HWSD/", "hwsd_CAfr"), collapse = ""),
            format    = "ascii",
            NAflag    = -9999,
            overwrite = TRUE)

# Create a dataframe from the .asc file containing only x, y, and MU_GLOBAL.
# MU_GLOBAL relates the .asc file to the .mdb file with the soil data.
HWSD.CAfr.df <- asc2dataframe("D:/HWSD/hwsd_CAfr.asc", varnames = "MU_GLOBAL")

# Open the .mdb file in Access, save the HWSD_DATA sheet as .csv file and read it here.
HWSD.mdb <- read.table("D:/HWSD/HWSD_DATA.csv", header = TRUE, sep = ',')
HWSD.mdb <- subset(HWSD.mdb, (HWSD.mdb$SEQ == 1)) # Select dominant soil type only
HWSD.mdb <- subset(HWSD.mdb, (HWSD.mdb$ISSOIL == 1)) # Exclude cells without soil
HWSD.mdb <- HWSD.mdb[ ,1:40] # Exclude subsoil data
HWSD.mdb <- HWSD.mdb[ ,-(3:13)] # Exclude columns with variables that are not used
# Define the soil parameters to keep.
keep <- c("y", "x", "MU_GLOBAL", "T_TEXTURE", "DRAINAGE", "REF_DEPTH", "AWC_CLASS", "T_GRAVEL", "T_SAND", "T_SILT", "T_CLAY", "T_BULK_DENSITY", "T_OC", "T_PH_H2O", "T_CEC_CLAY", "T_CEC_SOIL", "T_BS", "T_TEB", "T_CACO3", "T_CASO4", "T_ESP", "T_ECE")
HWSD.mdb <- HWSD.mdb[ ,(colnames(HWSD.mdb) %in% keep)]
HWSD.mdb.names <- colnames(HWSD.mdb) # Get the column names
HWSD.mdb.names <- HWSD.mdb.names[-1] # Exclude MU_GLOBAL from the list of column names

# dataframe2asc() ('SDMTools' package, VanDerWal & al., 2014) errouneously adds 1
# row and 1 column too many to the .asc file. Below the adjusted function df2asc.
df2asc <- function (tdata, filenames = NULL, outdir = getwd(), gz = FALSE) 
{
  if (is.null(filenames)) {
    filenames = colnames(tdata)[3:length(tdata)]
  }
  else {
    if (length(filenames) != length(3:length(tdata))) 
      stop("variable names must be the same length as the files vector")
    filenames = as.character(filenames)
  }
  for (ii in 3:(length(tdata))) {
    lats = unique(tdata[, 1])
    lats = sort(lats)
    longs = unique(tdata[, 2])
    longs = sort(longs)
    cellsize = min(c(diff(lats), diff(longs)))
    # nc = ceiling((max(lats) - min(lats))/cellsize) + 1
    nc = ceiling((max(lats) - min(lats))/cellsize)
    # nr = ceiling((max(longs) - min(longs))/cellsize) + 1
    nr = ceiling((max(longs) - min(longs))/cellsize)
    out.asc = as.asc(matrix(NA, nr = nr, nc = nc), xll = min(longs), yll = min(lats), cellsize = cellsize)
    out.asc = put.data(tdata[, c(2:1, ii)], out.asc)
    write.asc(out.asc, paste(outdir, "/", filenames[ii - 2], sep = ""), gz = gz)
  }
}

# The soil data from 'HWSD.mdb' are linked to the spatial coordinates using "MU_GLOBAL"
# as link and exported as .asc files with names listed in 'HWSD.mdb.names'. Separate
# .asc files are generated for each column. Note: the dataframe should have y and x
# coordinates (or lat,lon) and columns for the data and these MUST be in that order.
for (i in HWSD.mdb.names) {
  keep2 <- c("y", "x", "MU_GLOBAL", i) # Define desired column
  HWSD.mdb2 <- HWSD.mdb[ ,(colnames(HWSD.mdb) %in% keep2)] # Select desired column
  # Join the 2 data.frames using "MU_GLOBAL" as link.
  hwsd.CAfr.merge <- merge(HWSD.CAfr.df, HWSD.mdb2, by = "MU_GLOBAL")
  # Select the desired column and keep the 'y' and 'x' coordinates.
  keep <- c("y", "x", i)
  hwsd.CAfr.merge <- hwsd.CAfr.merge[ ,(colnames(hwsd.CAfr.merge) %in% keep)]
  # Export the selected column as .asc file.
  df2asc(hwsd.CAfr.merge, outdir = "D:/HWSD/30sec/cutlayers")
}

# Aggregate each .asc file to the required spatial resolution:
# 30 arcsec to 5 arcmin -> factor 10, 30 arcsec to 2.5 arcmin -> factor 5.
HWSD.files <- list.files("D:/HWSD/30sec/cutlayers", pattern = "[.]asc", full.names = FALSE)
# Aggregate each file and export it as .asc file.
for(i in HWSD.files) {
  setwd("D:/HWSD/30sec/cutlayers")
  raster <- raster(i)
  hwsd.5arcmin <- aggregate(raster, fact = 10, fun = mean, expand = FALSE, na.rm = TRUE, overwrite = TRUE)
  exportname <- strsplit(basename(i), ".asc")
  # First set the directory, otherwise writeRaster will not work.
  setwd("D:/HWSD/5min/aggregatelayers")
  writeRaster(hwsd.5arcmin,
              filename  = paste("D:/HWSD/5min/aggregatelayers/", exportname, "_5min_CAfr", sep = ""),
              format    = 'ascii',
              NAflag    = -9999,
              overwrite = TRUE)
}


#######################################################################################
#########################  3. Climate and altitude data from WORLDCLIM  ###############
#######################################################################################

# Download climate data from the WORLDCLIM site: www.worldclim.org (Hijmans & al., 2005).

setwd ("D:/Worldclim/5min")
getwd()

# Read each .bil file and crop it to the spatial extent of the study area.
Worldclim.files <- list.files("D:/Worldclim/5min", pattern = "[.]bil", full.names = TRUE)
for(i in Worldclim.files) {
  Worldclim.CAfr <- crop((raster(i)), ext.CAfr)
  exportname <- strsplit(basename(i), ".bil")
  # Export as .asc file, first set the directory, otherwise writeRaster will not work.
  setwd ("D:/Worldclim/5min/cutlayers")
  writeRaster(Worldclim.CAfr,
              filename  = paste(c("D:/Worldclim/5min/cutlayers/", exportname, "CAfr_5min"), collapse = ""),
              format    = "ascii",
              NAflag    = -9999,
              overwrite = TRUE)
}

# Prepare the Potential Evapotranspiration (PET) ratio (Anderson & al., 2002). PET is
# calculated by dividing the mean annual biotemperature (degrees C) by the total annual
# precipitation (mm) and multiplying the result by an empirical derived constant of 60
# (Holdridge et al., 1971).
BIO1 <- raster("D:/Worldclim/5min/cutlayers/bio1CAfr_5min.asc") # Note: temp is in C*10
BIO12 <- raster("D:/Worldclim/5min/cutlayers/bio12CAfr_5min.asc")
PET <- ((BIO1/10)/BIO12)*60 # Calculate the PET ratio for each raster cell
writeRaster(PET,
            filename  = "D:/Worldclim/5min/cutlayers/PET.asc",
            format    = 'ascii',
            NAflag    = -9999,
            overwrite = TRUE)


#######################################################################################
#########################  4. Altitude data at 3 arcsec spatial resolution  ###########
#######################################################################################

# Download altitude data at 3 arcsec spatial resolution (approx. 90 m at the equator)
# from the SRTM site: http://srtm.csi.cgiar.org/index.asp

setwd ("D:/DEM")
getwd()

DEM.files <- list.files("D:/DEM", pattern = "[.]asc", full.names = FALSE)

#######################################################################################
# Calculate the standard deviation of altitude.
#######################################################################################
# Based on the data at 3 arcsec spatial resolution, calculate the standard deviation of
# altitude at a coarser spatial resolution. # Aggregate each .asc file to the required
# spatial resolution: 3 arcsec to 5 arcmin -> factor 100, 3 arcsec to 2.5 arcmin ->
# factor 50, 3 arcsec to 30 arcsec -> factor 10.
for(i in DEM.files)  {
  setwd("D:/DEM")
  raster <- raster(i)
  DEM.5arcmin <- aggregate(raster, fact = 100, fun = sd, expand = FALSE, na.rm = TRUE, overwrite = TRUE)
  exportname <- strsplit(basename(i), ".asc")
  setwd("D:/DEM/5min/sd") # Set the directory, otherwise writeRaster will not work
  writeRaster(DEM.5arcmin,
              filename  = paste("D:/DEM/5min/sd/", exportname, "_5min", sep = ""),
              format    = 'ascii',
              NAflag    = -9999,
              overwrite = TRUE)
}

# Merge / mosaic the files. Take 1 file and mosaic each following file to it.
setwd("D:/DEM/5min/sd")
DEM.5min.sd.files <- list.files("D:/DEM/5min/sd", pattern = "[.]asc", full.names = FALSE)
DEM.5min.sd.files2 <- DEM.5min.sd.files[-1]
x <- raster(DEM.5min.sd.files[1])
for(i in DEM.5min.sd.files2) {
  y <- raster(i)
  z <- mosaic(x, y, fun = mean)
  x <- z
}
setwd("D:/DEM/5min/sd")
writeRaster(x,
            filename  = paste("D:/DEM/5min/DEM_sd_5min_mosaic"),
            format    = 'ascii',
            NAflag    = -9999,
            overwrite = TRUE)
# Crop the mosaiced file to the extent of the study area and export as .asc file.
DEM.sd.CAfr <- crop(x, ext.CAfr)
writeRaster(DEM.sd.CAfr,
            filename  = "D:/DEM/5min/DEM_sd_5min_CAfr",
            format    = "ascii",
            NAflag    = -9999,
            overwrite = TRUE)

#######################################################################################
# Calculate the range of altitude.
#######################################################################################
# Based on the data at 3 arcsec spatial resolution, calculate the range of altitude
# (maximum-minimum) at a coarser spatial resolution. # Aggregate each .asc file to the
# required spatial resolution: 3 arcsec to 5 arcmin -> factor 100, 3 arcsec to 2.5
# arcmin -> factor 50, 3 arcsec to 30 arcsec -> factor 10.
for(i in DEM.files)  {
  setwd("D:/DEM")
  raster <- raster(i)
  DEMmax.5arcmin <- aggregate(raster, fact = 100, fun = max, expand = FALSE, na.rm = TRUE, overwrite = TRUE)
  # Aggregate the raster
  setwd("D:/DEM/5min/max") # Set the directory, otherwise writeRaster will not work
  writeRaster(DEMmax.5arcmin,
              filename  = paste("D:/DEM/5min/max/", i, "_5min", sep = ""),
              format    = 'ascii',
              NAflag    = -9999,
              overwrite = TRUE)
  DEMmin.5arcmin <- aggregate(raster, fact = 100, fun = min, expand = FALSE, na.rm = TRUE, overwrite = TRUE)
  # Aggregate the raster
  setwd("D:/DEM/5min/min")
  writeRaster(DEMmin.5arcmin,
              filename  = paste("D:/DEM/5min/min/", i, "_5min", sep = ""),
              format    = 'ascii',
              NAflag    = -9999,
              overwrite = TRUE)
  # Calculate the range: max-min.
  DEMmaxmin.5arcmin <- DEMmax.5arcmin - DEMmin.5arcmin
  setwd("D:/DEM/5min/maxmin") # Set the directory, otherwise writeRaster will not work
  writeRaster(DEMmaxmin.5arcmin,
              filename  = paste("D:/DEM/5min/maxmin/", i, "_5min", sep = ""),
              format    = 'ascii',
              NAflag    = -9999,
              overwrite = TRUE)
}

# Merge / mosaic the files. Take 1 file and mosaic each following file to it.
setwd("D:/DEM/5min/maxmin")
DEM.maxmin.5min.files <- list.files("D:/DEM/5min/maxmin", pattern="[.]asc", full.names = FALSE)
DEM.maxmin.5min.files2 <- DEM.maxmin.5min.files[-1]
x <- raster(DEM.maxmin.5min.files[1])
for(i in DEM.maxmin.5min.files2) {
  y <- raster(i)
  z <- mosaic(x, y, fun = mean)
  x <- z
}
setwd("D:/DEM/5min") # Set the directory, otherwise writeRaster will not work
writeRaster(x,
            filename  = paste("D:/DEM/5min/DEM_maxmin_5min_mosaic"),
            format    = 'ascii',
            NAflag    = -9999,
            overwrite = TRUE)
# Crop the mosaiced file to the extent of the study area and export as .asc file.
DEM.max.CAfr <- crop(x, ext.CAfr)
writeRaster(DEM.max.CAfr,
            filename  = "D:/DEM/5min/DEM_maxmin_5min_CAfr",
            format    = "ascii",
            NAflag    = -9999,
            overwrite = TRUE)


#######################################################################################
#########################  5. Analysis of multicollinearity & selection of variables ##
#######################################################################################

# Environmental variables are often highly correlated. To prevent errors caused by this
# multicollinearity, all variables are tested on collinearity using Spearman rank
# correlation test. From each group of correlated predictors, 1 predictor is selected.

setwd ("D:/Files")
getwd()

#######################################################################################
# Calculate Spearman rank correlation for all environmental variables.
#######################################################################################
# Load all environmental variables (predictors) as .asc files.
files.CAfr <- list.files('D:/Files/Cropped', pattern = '.asc', full.names = TRUE)
files.CAfr.stack <- stack(files.CAfr)
files.CAfr.names <- names(files.CAfr.stack) # Get the predictor names

# Convert to dataframe, NA's are omitted, then to matrix, required by fucntion rcorr().
files.CAfr.df <- asc2dataframe(files.CAfr, varnames = files.CAfr.names)
files.CAfr.matrix <- as.matrix(files.CAfr.df)
files.CAfr.matrix <- files.CAfr.matrix[,-(1:2)] # Remove x and y columns
colnames(files.CAfr.matrix)

# Calculate the Spearman rank correlation between all variables.
setwd ("D:/Files/Multicollinearity")
all.rcorr <- rcorr(files.CAfr.matrix, type = "spearman")
# Export the Spearman r values and significance levels.
write.table(all.rcorr$r,
            file = "all_Spearman_r.txt",
            sep = ",",
            quote = FALSE,
            append = FALSE,
            na = "NA",
            qmethod = "escape")
write.table(all.rcorr$P,
            file = "all_Spearman_significance.txt",
            sep = ",",
            quote = FALSE,
            append = FALSE,
            na = "NA",
            qmethod = "escape")

# Outside R, identify groups of correlated predictors based on Spearman rank > 0.7.
# Groups of correlated environmental variables are assessed usign the code below.

#######################################################################################
# Calculate PCA for groups of correlated environmental variables.
#######################################################################################
varnames <- colnames(files.CAfr.matrix)
varnames

# Define group 1 of collinear variables.
keep.preds1 <- c("altcafr_5min", "bio10cafr_5min", "bio11cafr_5min", "bio1cafr_5min", "bio6cafr_5min", "bio8cafr_5min", "bio9cafr_5min")
files.CAfr.preds1 <- files.CAfr.matrix[,(colnames(files.CAfr.matrix) %in% keep.preds1)]
# Standardize data, required for PCA analysis
files.CAfr.preds1.scale <- scale(files.CAfr.preds1, center = TRUE, scale = TRUE)
# Calculate PCA for groups of correlated predictors.
pc.preds1 <- dudi.pca(files.CAfr.preds1.scale, center = TRUE, scale = TRUE, scannf = FALSE, nf = 4)
pc.preds1$co # the column coordinates, which is the same as vector load for each PC
write.csv(pc.preds1$co, file = "D:/Files/Multicollinearity/pc_preds1_co_CAfr.csv")
pc.preds1$eig # the eigenvalues of the PC's
barplot(pc.preds1$eig)
var1 <- pc.preds1$eig[1]/sum(pc.preds1$eig)
var1

# Define group 2 of collinear variables.
keep.preds2 <- c("bio12cafr_5min", "bio14cafr_5min", "bio15cafr_5min", "bio17cafr_5min", "bio19cafr_5min", "bio3cafr_5min", "bio4cafr_5min", "bio7cafr_5min")
files.CAfr.preds2 <- files.CAfr.matrix[,(colnames(files.CAfr.matrix) %in% keep.preds2)]
# Standardize data, required for PCA analysis
files.CAfr.preds2.scale <- scale(files.CAfr.preds2, center = TRUE, scale = TRUE)
# Calculate PCA for groups of correlated predictors.
pc.preds2 <- dudi.pca(files.CAfr.preds2.scale, center = TRUE, scale = TRUE, scannf = FALSE, nf = 4)
pc.preds2$co # the column coordinates, which is the same as vector load for each PC
write.csv(pc.preds2$co, file = "D:/Files/Multicollinearity/pc_preds2_co_CAfr.csv")

# Define group 3 of collinear variables.
keep.preds3 <- c("bio12cafr_5min", "bio13cafr_5min", "bio16cafr_5min", "pet")
files.CAfr.preds3 <- files.CAfr.matrix[,(colnames(files.CAfr.matrix) %in% keep.preds3)]
# Standardize data, required for PCA analysis
files.CAfr.preds3.scale <- scale(files.CAfr.preds3, center = TRUE, scale = TRUE)
# Calculate PCA for groups of correlated predictors.
pc.preds3 <- dudi.pca(files.CAfr.preds3.scale, center = TRUE, scale = TRUE, scannf = FALSE, nf = 4)
pc.preds3$co # the column coordinates, which is the same as vector load for each PC
write.csv(pc.preds3$co, file = "D:/Files/Multicollinearity/pc_preds3_co_CAfr.csv")

# Define group 4 of collinear variables.
keep.preds4 <- c("bio12cafr_5min", "bio18cafr_5min", "bio5cafr_5min")
files.CAfr.preds4 <- files.CAfr.matrix[,(colnames(files.CAfr.matrix) %in% keep.preds4)]
# Standardize data, required for PCA analysis
files.CAfr.preds4.scale <- scale(files.CAfr.preds4, center = TRUE, scale = TRUE)
# Calculate PCA for groups of correlated predictors.
pc.preds4 <- dudi.pca(files.CAfr.preds4.scale, center = TRUE, scale = TRUE, scannf = FALSE, nf = 4)
pc.preds4$co # the column coordinates, which is the same as vector load for each PC
write.csv(pc.preds4$co, file = "D:/Files/Multicollinearity/pc_preds4_co_CAfr.csv")

# Define group 7 of collinear variables.
keep.preds7 <- c("T_CEC_SOIL.asc_5min_CAfr", "T_CLAY.asc_5min_CAfr", "T_SAND.asc_5min_CAfr", "T_SILT.asc_5min_CAfr", "T_TEB.asc_5min_CAfr", "T_TEXTURE.asc_5min_CAfr")
files.CAfr.preds7 <- files.CAfr.matrix[,(colnames(files.CAfr.matrix) %in% keep.preds7)]
# Standardize data, required for PCA analysis
files.CAfr.preds7.scale <- scale(files.CAfr.preds7, center = TRUE, scale = TRUE)
# Calculate PCA for groups of correlated predictors.
pc.preds7 <- dudi.pca(files.CAfr.preds7.scale, center = TRUE, scale = TRUE, scannf = FALSE, nf = 4)
pc.preds7$co # the column coordinates, which is the same as vector load for each PC
write.csv(pc.preds7$co, file = "D:/Files/Multicollinearity/pc_preds7_co_CAfr.csv")

# Define group 8 of collinear variables.
keep.preds8 <- c("T_BS.asc_5min_CAfr", "T_CACO3.asc_5min_CAfr", "T_CEC_SOIL.asc_5min_CAfr", "T_PH_H2O.asc_5min_CAfr", "T_TEB.asc_5min_CAfr")
files.CAfr.preds8 <- files.CAfr.matrix[,(colnames(files.CAfr.matrix) %in% keep.preds8)]
# Standardize data, required for PCA analysis
files.CAfr.preds8.scale <- scale(files.CAfr.preds8, center = TRUE, scale = TRUE)
# Calculate PCA for groups of correlated predictors.
pc.preds8 <- dudi.pca(files.CAfr.preds8.scale, center = TRUE, scale = TRUE, scannf = FALSE, nf = 4)
pc.preds8$co # the column coordinates, which is the same as vector load for each PC
write.csv(pc.preds8$co, file = "D:/Files/Multicollinearity/pc_preds8_co_CAfr.csv")

# Outside R: For each group of correlated predictors, select 1 predictor which has the
# highest vector load (pc$co) in the group or is the most relevant for the study area.


#######################################################################################
#########################  6. Preparing PCA axes as input variables for analysis  #####
#######################################################################################

# Based on the selection of environmental variables described above, a set of
# uncorrelated (Spearman rho < 0.7) is identified. On these predictors, we perform a
# PCA and export the first 2 PCA axes as .asc files.

# Select the uncorrelated environmental variables in 1 matrix.
keep.combined <- c("altcafr_5min", "dem_sd_5min_cafr", "bio2cafr_5min", "bio12cafr_5min", "bio15cafr_5min", "bio18cafr_5min", "AWC_CLASS_5min_CAfr", "DRAINAGE_5min_CAfr", "REF_DEPTH_5min_CAfr", "T_BULK_DENSITY_5min_CAfr", "T_ESP_5min_CAfr", "T_GRAVEL_5min_CAfr", "T_OC_5min_CAfr", "T_SAND_5min_CAfr", "T_PH_H2O_5min_CAfr")
files.CAfr.combined.final.matrix <- files.CAfr.matrix[,(colnames(files.CAfr.matrix) %in% keep.combined)]

# Standardize data, required for PCA analysis.
files.CAfr.combined.final.matrix.scale <- scale(files.CAfr.combined.final.matrix, center = TRUE, scale = TRUE) 

# Perform the PCA using the dudi.pca() function.
pc.combined.final <- dudi.pca(files.CAfr.combined.final.matrix, center = TRUE, scale = TRUE, scannf = FALSE, nf = 4)
# Get the vector loads for each PC.
pc.combined.final$co
write.csv(pc.combined.final$co, file = "D:/Files/Multicollinearity/pc_co_CAfr.csv")
# Get the PC values for each raster cell.
PCexport.combined.final <- cbind(files.CAfr.df$y, files.CAfr.df$x, pc.combined.final$li)
colnames(PCexport.combined.final) <- c("y", "x", "PCA1", "PCA2", "PCA3", "PCA4")
PCexport.combined.final$PCA1 <- rescale(PCexport.combined.final$PCA1, to=c(0,1))
PCexport.combined.final$PCA2 <- rescale(PCexport.combined.final$PCA2, to=c(0,1))
# In this study area, a small number of raster cells has exceltional values for PCA2.
# These cells are not in or near Gabon. We set the values fo these cells to NA.
PCexport.combined.final$PCA2[PCexport.combined.final$PCA2 < 0.5] <- NA
summary(PCexport.combined.final)
PCexport.combined.final$PCA2 <- rescale(PCexport.combined.final$PCA2, to=c(0,1))
summary(PCexport.combined.final)
PCexport.combined.final$PCA3 <- rescale(PCexport.combined.final$PCA3, to=c(0,1))
PCexport.combined.final$PCA4 <- rescale(PCexport.combined.final$PCA4, to=c(0,1))
summary(PCexport.combined.final)

# Export individual columns of the df as .asc files with the function df2asc(). # Note:
# the df has y, x coordinates (or lat,lon) and data columns in exacyly that exact order.
df2asc(PCexport.combined.final, outdir = "D:/Files/Multicollinearity")

barplot(pc.combined.final$eig)
var1 <- pc.combined.final$eig[1]/sum(pc.combined.final$eig) # eigenvalue for PCA 1st axis
var1
var2 <- pc.combined.final$eig[2]/sum(pc.combined.final$eig) # eigenvalue for PCA 2nd axis
var2
var1+var2 # variance explained by first 2 axes
var3 <- pc.combined.final$eig[3]/sum(pc.combined.final$eig) # eigenvalue for PCA 3rd axis
var3
var4 <- pc.combined.final$eig[4]/sum(pc.combined.final$eig) # eigenvalue for PCA 4th axis
var4
var1 + var2 + var3 # variance explained by first 3 axes
var1 + var2 + var3 + var4 # variance explained by first 4 axes


#######################################################################################
#########################  7. Create a mask file for Gabon plus a buffer  #############
#######################################################################################

# Here, we create a mask file using Gabone country borders to which we add a buffer of
# 5 arc degrees, approx. 560 km on the equator. The area inside the buffered polygon is
# exported as mask file. Use the mask() function ('raster' package, Hijmans, 2014).

setwd ("D:/Files")
getwd()

# Read the shape file defining the country borders of Gabon.
Gabonshp <- readShapeSpatial("D:/Worldclim Admin/Gab_adm0.shp", proj4string = CRS("+proj=longlat +ellps=clrk66"))
GabonSLDF <- as(Gabonshp, "SpatialLinesDataFrame") # Convert to SpatialLinesDataFrame
# Add a buffer to the country borders of 5 units = 5 degrees.
GabonSLDFbuffer <- gBuffer(GabonSLDF, width = 5)
# Rasterize the SpatialLineDataFrame using a target raster, here PCA2.
PCA2 <- raster("D:/Files/Multicollinearity/PCA2.asc")
Gabonrasterbuffer <- rasterize(GabonSLDFbuffer, PCA2)
# Create a mask file using the buffered Gabon object. Use the PCA2 object as template.
Gabonbuffermask <- mask(x = PCA2, mask = Gabonrasterbuffer)
Gabonbuffermask[Gabonbuffermask > 0] <- 1 # Set all non-NA values to 1
plot(PCA2)
plot(Gabonbuffermask, add = TRUE)
plot(wrld_simpl, add = TRUE)
# Export the mask file as .asc file
writeRaster(Gabonmask, file = "D:/Files/buffer.asc", overwrite = TRUE)


#######################################################################################
#######################################################################################
#########################  END OF CODE  ###############################################
#######################################################################################
#######################################################################################
