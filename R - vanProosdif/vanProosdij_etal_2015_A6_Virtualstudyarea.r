#######################################################################################
### van Proosdij, A.S.J., Sosef, M.S.M., Wieringa, J.J. and Raes, N. 2015.
### Minimum required number of specimen records to develop accurate species distribution
### models
### Ecography, DOI: 10.1111/ecog.01509
### Appendix 6: R script for virtual study area definition and analysis.
#######################################################################################

#######################################################################################
#########################  VIRTUAL STUDY AREA SIMULATION  #############################
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
#########################  Index  #####################################################
#######################################################################################
# 1. Load functions and packages
# 2. Preparation of environmental variables
# 3. Settings of the analysis
# 4. Running the analysis
# 5. Null models
# 6. Summarize the results
# 7. Read the minimum sample sizes
#######################################################################################

#######################################################################################
#########################  1. Load functions and packages  ############################
#######################################################################################

# Set the working directory. Create 5 folders: 'layers', 'outputs', 'outputsnm',
# 'presence', and 'projection'. Place the maxent.jar file in the library/dismo/java
# folder in C:/Program Files.
rm(list = ls(all = TRUE))
setwd("D:/R/Virtualworld")
getwd()
dir.create("D:/R/Virtualworld")
dir.create("D:/R/Virtualworld/layers")
dir.create("D:/R/Virtualworld/outputs")
dir.create("D:/R/Virtualworld/outputsnm")
dir.create("D:/R/Virtualworld/presence")
dir.create("D:/R/Virtualworld/projection")
library(raster) # for reading and writing rasters
library(stats) # for cor() function
library(mvtnorm) # for dmvnorm() function
library(SDMTools) # for write.asc(), asc2dataframe(), and pnt.in.poly() functions
library(dismo) # for evaluate() and maxent() functions
library(phyloclim) # for niche.overlap() function
library(plotrix) # for rescale() function
library(scales) # for rescale() function
library(ellipse) # for ellipse() function
removeTmpFiles(0)
source("D:/R/vanProosdij_etal_2015_A4_species_presence.R")
source("D:/R/vanProosdij_etal_2015_A7_nullmodel.R")

#######################################################################################
#########################  2. Preparation of environmental variables  #################
#######################################################################################

# Define two orthogonal gradients with values ranging from -1 to 1.
r.var2 <- r.var1 <- raster(nrows = 100, ncols = 100, xmn = 0, xmx = 100, ymn = 0, ymx = 100)
values(r.var1) <- rep(x = seq(from = -1, to = 1, length = 100), times = 100) # All values in each row
values(r.var2) <- rep(x = seq(from = -1, to = 1, length = 100), each = 100) # Each value 1 row

# Create the RasterStack 'z' by stacking the two RasterLayers.
z <- stack(r.var1, r.var2)

# Write the 2 RasterLayers to the 3 relevant folders.
for(i in 1 : nlayers(z)){
  r.pred <- raster(z, layer = i)
  write.asc(
    x    = asc.from.raster(r.pred),
    file = paste("layers/var", i, ".asc", sep = ""))
  write.asc(
    x    = asc.from.raster(r.pred),
    file = paste("projection/var", i, ".asc", sep = ""))
  write.asc(
    x    = asc.from.raster(r.pred),
    file = paste("presence/var", i, ".asc", sep = ""))
}


#######################################################################################
#########################  3. Settings of the analysis  ###############################
#######################################################################################

# The species prevalence is defined: the fraction of cells where the species is present.
prevalence.class <- c(0.05, 0.1, 0.2, 0.3, 0.4, 0.5)

# The species' optimum or the peak of its bivariate normal response is defined.
means <- c(0, 0)

# Sample sizes with which the modelling will be done are defined.
sample_size <- c(3:20, 25, 30, 35, 40, 45, 50)

# The number of repetitions is defined.
repetition <- c(1:100)

# The results of the analysis are placed in the vector 'joined_data'.
joined_data <- c()

# The predictor files are placed in a dataframe.
predictor.files <- list.files('D:/R/Virtualworld/layers', pattern='.asc', full.names = TRUE)
predictor.names <- unlist(strsplit(basename(predictor.files), ".asc")) # Variable names
predictors.df <- asc2dataframe(predictor.files, varnames = predictor.names)


#######################################################################################
#########################  4. Running the analysis  ###################################
#######################################################################################

for(y in prevalence.class) {
  # A loop is used to converge the prevalence to predefined values. Prevalence depends
  # on the width of the ecological niche, which is set by the size of the standard
  # deviation of the species' bivariate normal function to 2 orthogonal environmental
  # variables. The loop starts with an initial, small value of sd ('start.sd'), which
  # is increased until the predefined prevalence is reached. The increase of start.sd
  # is relative to the difference between the realised and the desired prevalence.
  if (y == 0.05)
    prevalencethreshold <- 0.03
  if (y == 0.1)
    prevalencethreshold <- 0.02
  if (y == 0.2)
    prevalencethreshold <- 0.01
  if (y == 0.3)
    prevalencethreshold <- 0.005
  if (y == 0.4)
    prevalencethreshold <- 0.002
  if (y == 0.5)
    prevalencethreshold <- 0.001
  
  # Start a loop to converge the prevalence towards the desired value of prevalence.
  start.sd <- 0.01
  repeat {
    
    #######################################################################################
    # Define the habitat suitability and presence/absence of the simulated species by
    # running the species.presence() function.
    #######################################################################################
    
    # Sigma is the variance-covariance matrix of the bivariate normal distribution used to
    # define the habitat suitability. Sigma includes the standard deviation of each variable
    # (SD1 = SD2), covariance is 0 as the two variables are orthogonal.
    # Sigma = matrix(11, 12, 21, 22), with 11 = SD1, 12 = 21 = covarSD1*SD2, 22 = SD2.
    sigma <- matrix(
      data = c(start.sd, 0, 0, start.sd),
      nrow = 2,
      ncol = 2)
    
    # Run the species.presence() function on the environmental variables, means and sigma.
    true_presences <- species.presence(
      z     = z,
      means = means,
      sigma = sigma)
    
    # Retrieve the defined habitat suitability and presences from the species.presence output.
    suitability1 <- true_presences$suitability
    true_presences <- true_presences$presence
    
    # Convert the defined habitat suitability and true presence RasterLayers to vectors.
    suitability <- values(suitability1) # As vector, compare later with MaxEnt output
    pres <- na.omit(values(true_presences)) # Omit NA's, not present in virtual study area
    
    # Calculate the realised prevalence of the species based on the SD of the predictors.
    prevalence <- length(pres[pres == 1]) / length(pres)
    
    # Check if the realised prevalence is aproximating the desired prevalence class value.
    h <- (y - prevalence)/y # Difference between realised prevalence and prevalence class
    if(h > prevalencethreshold | h < -prevalencethreshold)
      start.sd <- start.sd + h*start.sd # Adjust start.sd and repeat the loop
    if(h >= -prevalencethreshold & h <= prevalencethreshold)
      break; # End the loop and continue with the next section
    
    # Save the defined presence/absence and habitat suitability for the simulated species.
    write.asc(
      x    = asc.from.raster(true_presences),
      file = "D:/R/Virtualworld/presence/true_presences.asc");
    write.asc(
      x    = asc.from.raster(suitability1),
      file = "D:/R/Virtualworld/presence/suitability.asc")
    
    # Objects to use in the rest of the analysis:
    #    prevalence: the realised prevalence value
    #    suitability: vector with defined habitat suitability
    #    true_presences: RasterLayer with defined presences and absences
  } # End of repeat function
  
  plot(true_presences) # Plot the given presences to check for errors
  
  for(w in repetition) {
    for(x in sample_size) {
      
      # Read the predictor files, given suitability and given presences in one dataframe.
      # These are read all together from file to assure identical treatment of data.
      predictor.files2 <- list.files('D:/R/Virtualworld/presence', pattern='.asc', full.names = TRUE)
      predictor.names2 <- unlist(strsplit(basename(predictor.files2), ".asc")) # Variable names
      predictors.df2 <- asc2dataframe(predictor.files2, varnames = predictor.names2)
      
      #######################################################################################
      # Sample the required number of records from the defined presences.
      #######################################################################################
      
      # Check if the number of given presences is larger than the required sample size.
      stopifnot(x < sum(predictors.df2$true_presences))
      
      # Add a column with ID numbers to identify rows.
      predictors.df2$ID <- c(1:nrow(predictors.df2))
      # Make a subset with given absences only.
      df2.absc <- predictors.df2[which(predictors.df2$true_presences == 0), ]
      # Make a subset with given presences only.
      df2.pres <- predictors.df2[which(predictors.df2$true_presences == 1), ]
      # Make a subset with sampled presences only. Sample the number of rows equal to the
      # sample size, habitat suitability is used as sampling probability.
      df2.presselect <- df2.pres[sample(nrow(df2.pres), x, prob = df2.pres$suitability), ]
      # Subtract the sampled presences from all given presences.
      df2.nonpres <- df2.pres[ !(df2.pres$ID %in% df2.presselect$ID), ]
      # Add the non-sampled given presences to the given absences.
      df2.pseudoabsc <- rbind(df2.nonpres, df2.absc)
      
      #######################################################################################
      # Run the function maxent() ('dismo' package, Hijmans & al., 2013)
      #######################################################################################
      
      # Create SWD files for presences and for background data as input for MaxEnt. Note:
      # By default, MaxEnt adds samples to background data.
      keeps2 <- c("var1", "var2") # Keep only the predictor variables
      pres <- df2.presselect[,(names(df2.presselect) %in% keeps2)] # Presence data
      absc <- df2.pseudoabsc[,(names(df2.pseudoabsc) %in% keeps2)] # background data
      # Limit the number of background data to 10000.
      if (nrow(absc) > 10000) absc <- absc[sample(nrow(absc), 10000), ] else absc <- absc
      predictordata <- rbind(pres, absc) # rbind all presence and background data
      # Create a vector with 0/1 to identify presences and background.
      PAidentifier <- c(rep(1, nrow(pres)), rep(0, nrow(absc)))
      
      # Execute the maxent() function. By specifying the path, output files are stored. By
      # specifying the projection layers a prediction file "species_layers.asc" is generated.
      m <- maxent(predictordata,
                  PAidentifier,
                  path = "D:/R/Virtualworld/outputs",
                  args = c("projectionlayers=layers", "redoifexists", "notooltips", "noautofeature", "linear", "quadratic", "nohinge", "noproduct", "nothreshold", "l2lqthreshold=1"))
      
      #######################################################################################
      # Get the MaxEnt AUC
      #######################################################################################
      
      # Read the MaxEnt training AUC value from the maxentResults file.
      maxentResults <- read.csv("D:/R/Virtualworld/outputs/maxentResults.csv")
      MaxentAUC <- maxentResults$Training.AUC
      
      #######################################################################################
      # Calculate real AUC with the function evaluate() ('dismo' package, Hijmans & al., 2013)
      #######################################################################################
      
      # Real AUC is calculated using MaxEnt prediction values of given presences vs. given
      # absences. Data are in "predictedsuitability.v", "true_presences" identifies P/A's.
      realAUC.file <- 'D:/R/Virtualworld/outputs/species_layers.asc'
      realAUC.names <- unlist(strsplit(basename(realAUC.file), ".asc")) # Variable names
      predictedsuitability.df <- asc2dataframe(realAUC.file, varnames = realAUC.names)
      
      # Concatenate objects with defined presences and absences and predicted suitability.
      allpoints <- cbind(predictors.df2, predictedsuitability.df)
      keeps3 <- c("true_presences", "species_layers")
      allpoints <- allpoints[,(names(allpoints) %in% keeps3)]
      pres.predictions <- allpoints[which(allpoints$true_presences == 1),2] # Select given P
      absc.predictions <- allpoints[which(allpoints$true_presences == 0),2] # Select given A
      # AUC functions can't handle very large data sets. For data sets > 10000, reduce the
      # number of presences and background data. This does not affect the result.
      if (length(absc.predictions) > 10000) {
        pres.predictions <- sample(pres.predictions, 0.1*length(pres.predictions))
        absc.predictions <- sample(absc.predictions, 0.1*length(absc.predictions))
      }
      AUCreal <- evaluate(p = pres.predictions, a = absc.predictions)@auc
      
      #######################################################################################
      # Calculate Spearman rank correlation using the function cor() ('stats' package,
      # R Core Team, 2014)
      #######################################################################################
      
      # Calculate the Spearman rank correlation of predicted vs. given habitat suitability.
      Spearman.files <- c("D:/R/Virtualworld/outputs/species_layers.asc", "D:/R/Virtualworld/presence/suitability.asc")
      Spearman.names <- unlist(strsplit(basename(Spearman.files), ".asc")) # Variable names
      predictors.Spearman <- asc2dataframe(Spearman.files, varnames = Spearman.names)
      predictedsuitability.v <- predictors.Spearman$species_layers
      givensuitability.v <- predictors.Spearman$suitability
      Spearman.cor <- cor(predictedsuitability.v, givensuitability.v, method = "spearman")
      
      #######################################################################################
      # Calculate niche overlap using the function niche.overlap() ('phyloclim' package, 
      # Heibl & Calenge, 2013)
      #######################################################################################
      
      # The niche overlap between the given habitat suitability and the habitat suitability
      # predicted by MaxEnt is calculated using Schoener's D (Schoener, 1968) and Hellinger
      # distance I (van der Vaart, 1998).
      nicheoverlap.files <- c("D:/R/Virtualworld/presence/suitability.asc", "D:/R/Virtualworld/outputs/species_layers.asc")
      NO <- niche.overlap(nicheoverlap.files)
      SchoenerD <- NO[1,2] # Value of Schoener's D
      HellingerI <- NO[2,1] # Value of Hellinger distance I
      
      #######################################################################################
      # Output
      #######################################################################################
      
      # The results are stored in a vector.
      a <- c(y, prevalence, x, w, start.sd, Spearman.cor, MaxentAUC, AUCreal, SchoenerD, HellingerI, means[1], means[2])
      joined_data <- append(x = joined_data, values = a)
    }
  }
}

# Transform the vector 'joined_data' with output to a dataframe and name the columns.
joined_data <- matrix(
  data  = joined_data,
  byrow = TRUE,
  ncol  = 12)
joined_data <- data.frame(joined_data)

colnames(joined_data) <- c("prevalence", "true.prevalence", "sample.size", "repetition", "start.sd", "Spearman.cor", "Maxent.AUC", "AUCreal", "SchoenerD", "HellingerI", "means1", "means2")


#######################################################################################
#########################  5. Null models  ############################################
#######################################################################################
# Run null models to test for significant deviance from chance (Raes & ter Steege, 2007).

# Get the unique sample sizes.
joined_data2 <- joined_data
records <- unique(joined_data2$sample.size)

# Prepare the environmental data.
x <- predictors.df # Predictor files as created above
drops2 <- c("y", "x")
x <- x[,!(names(x) %in% drops2)]

# Run the loop for all unique sample sizes.
nullAUC <- list() # Create an empty list to store the results
for (n in records) {
  a <- nullModelvirtual(x, n, rep = 99)
  nullAUC[[n]] <- a # Store the null AUC values for each sample size
}

# Replace NULL with NA for sample sizes that are not present.
for (i in 1:length(nullAUC)) {
  if (is.null(nullAUC[[i]]) == TRUE) {nullAUC[[i]] <- NA}
}

# Turn nullAUC into a data.frame with all AUC values for a sample size in one column.
nullAUC <- do.call(cbind, nullAUC)
nullAUCdataframe <- as.data.frame(nullAUC)

# For each model, get the rank number of the real AUC compared to null model AUC's.
rankAUCreal <- list() # Create an empty vector to store everything
joined_data2 <- as.matrix(joined_data)
for (i in 1:nrow(joined_data2)) { # For each unique repetition...
  j <- as.numeric(as.character(joined_data2[i,3])) # ...get the sample size
  k <- nullAUCdataframe[,j] # ...get the null model AUC values of that sample size
  l <- joined_data2[i,8] # ...get the AUCreal value of that sample size
  m <- c(as.numeric(as.character(l)), as.numeric(as.character(k))) # ...place all in 1 list
  n <- rank(m) # ...rank them
  o <- n[1] # ...get the rank of the AUCreal
  rankAUCreal[i] <- o # ...and store the rank of AUCreal
}
rankAUCrealunlist <- unlist(rankAUCreal) # Unlist rankAUCreal before cbinding
joined_data3 <- cbind(joined_data2, rankAUCrealunlist) # Attach the column with rank numbers
colnames(joined_data3)[13] <- "rankAUCreal" # Name the column

# For each model, get the rank number of the AUCMaxEnt compared to null model AUC's.
rankAUCMaxent <- list() # Create an empty vector to store everything
for (i in 1:nrow(joined_data3)) { # For each unique repetition...
  j <- as.numeric(as.character(joined_data3[i,3])) # ...get the sample size
  k <- nullAUCdataframe[,j] # ...get the null model AUC values of that sample size
  l <- joined_data3[i,7] # ...get the AUCMaxEnt value of that sample size
  m <- c(as.numeric(as.character(l)), as.numeric(as.character(k))) # ...place all in 1 list
  n <- rank(m) # ...rank them
  o <- n[1] # ...get the rank of the AUCMaxEnt
  rankAUCMaxent[i] <- o # ...and store the rank of AUCMaxEnt
}
rankAUCMaxentunlist <- unlist(rankAUCMaxent) # Unlist rankAUCMaxent before cbinding
joined_data4 <- cbind(joined_data3, rankAUCMaxentunlist) # Attach the column with rank numbers
colnames(joined_data4)[14] <- "rankAUCMaxent" # Name the column

# For each model calculate the difference between the rank of real AUC and MaxEnt AUC.
diff.rank.AUC.real.Maxent <- list() # Create an empty vector to store everything
for (i in 1:nrow(joined_data4)) { # For each unique repetition...
  p <- as.numeric(as.character(joined_data4[i,13])) # ...load the rank of the real AUC
  q <- as.numeric(as.character(joined_data4[i,14])) # ...load the rank of the MAxEnt AUC
  diff.rank.AUC.real.Maxent[i] <- p-q # ... and calculate the difference
}
diff.rank.AUC.real.Maxent.unlist <- unlist(diff.rank.AUC.real.Maxent) # Unlist before cbinding it
joined_data5 <- cbind(joined_data4, diff.rank.AUC.real.Maxent.unlist) # Attach the column with the difference in rank numbers between the AUCreal and AUCMaxent
colnames(joined_data5)[15] <- "diffrankAUCrealMaxent"


#######################################################################################
#########################  6. Summarize the results  ##################################
#######################################################################################

# For each prevalence class and each sample size, get the lower and upper limit of the
# upper 95% range of the values. This effectively excludes the 5% worst performing models.

# Remove all rows which contain NA's.
joined_data6 <- as.data.frame(joined_data5)
joined_data6 <- na.omit(joined_data6)

# Spearman rank correlation
summarySpearmanvirtual <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- joined_data6[(joined_data6$prevalence == i), ]
  for (j in sample_size) { # For each sample size
    abc2 <- abc[(abc$sample.size == j), ]
    datasort <- sort(abc2$Spearman.cor) # Sort the values increasing
    lowerlimit <- datasort[6] # Get the lower limit of the upper 95% range of values
    upperlimit <- max(datasort) # Get the upper limit
    abc3 <- cbind(i, j, lowerlimit, upperlimit) # Prevalence, sample size, lower and upper limit
    summarySpearmanvirtual <- rbind(summarySpearmanvirtual, abc3)
  }
}
colnames(summarySpearmanvirtual) <- c("prevalence", "sample.size", "Spearmanll", "Spearmanul")
write.csv(x = summarySpearmanvirtual, file = "D:/R/Virtualworld/summarySpearmanvirtual.csv")

# MaxEnt AUC values
summaryMaxEntAUCvirtual <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- joined_data6[(joined_data6$prevalence == i), ]
  for (j in sample_size) { # For each sample size
    abc2 <- abc[(abc$sample.size == j), ]
    datasort <- sort(abc2$Maxent.AUC) # Sort the values increasing
    lowerlimit <- datasort[6] # Get the lower limit of the upper 95% range of values
    upperlimit <- max(datasort) # Get the upper limit
    abc3 <- cbind(i, j, lowerlimit, upperlimit) # Prevalence, sample size, lower and upper limit
    summaryMaxEntAUCvirtual <- rbind(summaryMaxEntAUCvirtual, abc3)
  }
}
colnames(summaryMaxEntAUCvirtual) <- c("prevalence", "sample.size", "MaxEntAUCll", "MaxEntAUCul")
write.csv(x = summaryMaxEntAUCvirtual, file = "D:/R/Virtualworld/summaryMaxEntAUCvirtual.csv")

# Real AUC values
summaryrealAUCvirtual <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- joined_data6[(joined_data6$prevalence == i), ]
  for (j in sample_size) { # For each sample size
    abc2 <- abc[(abc$sample.size == j), ]
    datasort <- sort(abc2$AUCreal) # Sort the values increasing
    lowerlimit <- datasort[6] # Get the lower limit of the upper 95% range of values
    upperlimit <- max(datasort) # Get the upper limit
    abc3 <- cbind(i, j, lowerlimit, upperlimit) # Prevalence, sample size, lower and upper limit
    summaryrealAUCvirtual <- rbind(summaryrealAUCvirtual, abc3)
  }
}
colnames(summaryrealAUCvirtual) <- c("prevalence", "sample.size", "realAUCll", "realAUCul")
write.csv(x = summaryrealAUCvirtual, file = "D:/R/Virtualworld/summaryrealAUCvirtual.csv")

# MaxEnt AUC rank values
summaryrankMaxEntAUCvirtual <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- joined_data6[(joined_data6$prevalence == i), ]
  for (j in sample_size) { # For each sample size
    abc2 <- abc[(abc$sample.size == j), ]
    datasort <- sort(abc2$rankAUCMaxent) # Sort the values increasing
    lowerlimit <- datasort[6] # Get the lower limit of the upper 95% range of values
    upperlimit <- max(datasort) # Get the upper limit
    abc3 <- cbind(i, j, lowerlimit, upperlimit) # Prevalence, sample size, lower and upper limit
    summaryrankMaxEntAUCvirtual <- rbind(summaryrankMaxEntAUCvirtual, abc3)
  }
}
colnames(summaryrankMaxEntAUCvirtual) <- c("prevalence", "sample.size", "rankMaxEntAUCll", "rankMaxEntAUCul")
write.csv(x = summaryrankMaxEntAUCvirtual, file = "D:/R/Virtualworld/summaryrankMaxEntAUCvirtual.csv")

# Real AUC rank values
summaryrankrealAUCvirtual <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- joined_data6[(joined_data6$prevalence == i), ]
  for (j in sample_size) { # For each sample size
    abc2 <- abc[(abc$sample.size == j), ]
    datasort <- sort(abc2$rankAUCreal) # Sort the values increasing
    lowerlimit <- datasort[6] # Get the lower limit of the upper 95% range of values
    upperlimit <- max(datasort) # Get the upper limit
    abc3 <- cbind(i, j, lowerlimit, upperlimit) # Prevalence, sample size, lower and upper limit
    summaryrankrealAUCvirtual <- rbind(summaryrankrealAUCvirtual, abc3)
  }
}
colnames(summaryrankrealAUCvirtual) <- c("prevalence", "sample.size", "rankrealAUCll", "rankrealAUCul")
write.csv(x = summaryrankrealAUCvirtual, file = "D:/R/Virtualworld/summaryrankrealAUCvirtual.csv")

# Schoener's D values
summarySchoenerDvirtual <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- joined_data6[(joined_data6$prevalence == i), ]
  for (j in sample_size) { # For each sample size
    abc2 <- abc[(abc$sample.size == j), ]
    datasort <- sort(abc2$SchoenerD) # Sort the values increasing
    lowerlimit <- datasort[6] # Get the lower limit of the upper 95% range of values
    upperlimit <- max(datasort) # Get the upper limit
    abc3 <- cbind(i, j, lowerlimit, upperlimit) # Prevalence, sample size, lower and upper limit
    summarySchoenerDvirtual <- rbind(summarySchoenerDvirtual, abc3)
  }
}
colnames(summarySchoenerDvirtual) <- c("prevalence", "sample.size", "SchoenerDll", "SchoenerDul")
write.csv(x = summarySchoenerDvirtual, file = "D:/R/Virtualworld/summarySchoenerDvirtual.csv")

# Hellinger I values
summaryHellingerIvirtual <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- joined_data6[(joined_data6$prevalence == i), ]
  for (j in sample_size) { # For each sample size
    abc2 <- abc[(abc$sample.size == j), ]
    datasort <- sort(abc2$HellingerI) # Sort the values increasing
    lowerlimit <- datasort[6] # Get the lower limit of the upper 95% range of values
    upperlimit <- max(datasort) # Get the upper limit
    abc3 <- cbind(i, j, lowerlimit, upperlimit) # Prevalence, sample size, lower and upper limit
    summaryHellingerIvirtual <- rbind(summaryHellingerIvirtual, abc3)
  }
}
colnames(summaryHellingerIvirtual) <- c("prevalence", "sample.size", "HellingerIll", "HellingerIul")
write.csv(x = summaryHellingerIvirtual, file = "D:/R/Virtualworld/summaryHellingerIvirtual.csv")


#######################################################################################
# Fitting curves on the data
#######################################################################################
# To mask out small stochastic effects, per prevalence class, smooth the lower and upper
# limits of the upper 95% range of the model performance values using the loess() function
# ('stats' package, R Core Team, 2014).

# Spearman rank values.
summarySpearmanvirtual <- as.data.frame(summarySpearmanvirtual)
summarySpearmanvirtual2 <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- summarySpearmanvirtual[(summarySpearmanvirtual$prevalence == i), ]
  Spearmanll.loess <- loess(Spearmanll ~ sample.size, data = abc) # Fit a curve
  Spearmanul.loess <- loess(Spearmanul ~ sample.size, data = abc) # Fit a curve
  Spearmanllsmooth <- predict(Spearmanll.loess) # Get the smoothed values
  Spearmanulsmooth <- predict(Spearmanul.loess) # Get the smoothed values
  abc2 <- cbind(abc$prevalence, abc$sample.size, Spearmanllsmooth, Spearmanulsmooth)
  summarySpearmanvirtual2 <- rbind(summarySpearmanvirtual2, abc2)
}
colnames(summarySpearmanvirtual2) <- c("prevalence", "sample.size", "Spearmanllsmooth", "Spearmanulsmooth")
summarySpearmanvirtual2 <- as.data.frame(summarySpearmanvirtual2)
summarySpearmanvirtual2$Spearmanllsmooth[summarySpearmanvirtual2$Spearmanllsmooth > 1] <- 1 # Truncate all Spearmanllsmooth values > 1 to 1
summarySpearmanvirtual2$Spearmanulsmooth[summarySpearmanvirtual2$Spearmanulsmooth > 1] <- 1 # Truncate all Spearmanulsmooth values > 1 to 1

# MaxEnt AUC values.
summaryMaxEntAUCvirtual <- as.data.frame(summaryMaxEntAUCvirtual)
summaryMaxEntAUCvirtual2 <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- summaryMaxEntAUCvirtual[(summaryMaxEntAUCvirtual$prevalence == i), ]
  MaxEntAUCll.loess <- loess(MaxEntAUCll ~ sample.size, data = abc) # Fit a curve
  MaxEntAUCul.loess <- loess(MaxEntAUCul ~ sample.size, data = abc) # Fit a curve
  MaxEntAUCllsmooth <- predict(MaxEntAUCll.loess) # Get the smoothed values
  MaxEntAUCulsmooth <- predict(MaxEntAUCul.loess) # Get the smoothed values
  abc2 <- cbind(abc$prevalence, abc$sample.size, MaxEntAUCllsmooth, MaxEntAUCulsmooth)
  summaryMaxEntAUCvirtual2 <- rbind(summaryMaxEntAUCvirtual2, abc2)
}
colnames(summaryMaxEntAUCvirtual2) <- c("prevalence", "sample.size", "MaxEntAUCllsmooth", "MaxEntAUCulsmooth")
summaryMaxEntAUCvirtual2 <- as.data.frame(summaryMaxEntAUCvirtual2)
summaryMaxEntAUCvirtual2$MaxEntAUCllsmooth[summaryMaxEntAUCvirtual2$MaxEntAUCllsmooth > 1] <- 1 # Truncate all MaxEntAUCllsmooth values > 1 to 1
summaryMaxEntAUCvirtual2$MaxEntAUCulsmooth[summaryMaxEntAUCvirtual2$MaxEntAUCulsmooth > 1] <- 1 # Truncate all MaxEntAUCulsmooth values > 1 to 1

# Real AUC values.
summaryrealAUCvirtual <- as.data.frame(summaryrealAUCvirtual)
summaryrealAUCvirtual2 <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- summaryrealAUCvirtual[(summaryrealAUCvirtual$prevalence == i), ]
  realAUCll.loess <- loess(realAUCll ~ sample.size, data = abc) # Fit a curve
  realAUCul.loess <- loess(realAUCul ~ sample.size, data = abc) # Fit a curve
  realAUCllsmooth <- predict(realAUCll.loess) # Get the smoothed values
  realAUCulsmooth <- predict(realAUCul.loess) # Get the smoothed values
  abc2 <- cbind(abc$prevalence, abc$sample.size, realAUCllsmooth, realAUCulsmooth)
  summaryrealAUCvirtual2 <- rbind(summaryrealAUCvirtual2, abc2)
}
colnames(summaryrealAUCvirtual2) <- c("prevalence", "sample.size", "realAUCllsmooth", "realAUCulsmooth")
summaryrealAUCvirtual2 <- as.data.frame(summaryrealAUCvirtual2)
summaryrealAUCvirtual2$realAUCllsmooth[summaryrealAUCvirtual2$realAUCllsmooth > 1] <- 1 # Truncate all realAUCllsmooth values > 1 to 1
summaryrealAUCvirtual2$realAUCulsmooth[summaryrealAUCvirtual2$realAUCulsmooth > 1] <- 1 # Truncate all realAUCulsmooth values > 1 to 1

# MaxEnt AUC rank values.
summaryrankMaxEntAUCvirtual <- as.data.frame(summaryrankMaxEntAUCvirtual)
summaryrankMaxEntAUCvirtual2 <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- summaryrankMaxEntAUCvirtual[(summaryrankMaxEntAUCvirtual$prevalence == i), ]
  rankMaxEntAUCll.loess <- loess(rankMaxEntAUCll ~ sample.size, data = abc) # Fit a curve
  rankMaxEntAUCul.loess <- loess(rankMaxEntAUCul ~ sample.size, data = abc) # Fit a curve
  rankMaxEntAUCllsmooth <- predict(rankMaxEntAUCll.loess) # Get the smoothed values
  rankMaxEntAUCulsmooth <- predict(rankMaxEntAUCul.loess) # Get the smoothed values
  abc2 <- cbind(abc$prevalence, abc$sample.size, rankMaxEntAUCllsmooth, rankMaxEntAUCulsmooth)
  summaryrankMaxEntAUCvirtual2 <- rbind(summaryrankMaxEntAUCvirtual2, abc2)
}
colnames(summaryrankMaxEntAUCvirtual2) <- c("prevalence", "sample.size", "rankMaxEntAUCllsmooth", "rankMaxEntAUCulsmooth")
summaryrankMaxEntAUCvirtual2 <- as.data.frame(summaryrankMaxEntAUCvirtual2)
summaryrankMaxEntAUCvirtual2$rankMaxEntAUCllsmooth[summaryrankMaxEntAUCvirtual2$rankMaxEntAUCllsmooth > 100] <- 100 # Truncate all rankMaxEntAUCllsmooth values > 100 to 100
summaryrankMaxEntAUCvirtual2$rankMaxEntAUCulsmooth[summaryrankMaxEntAUCvirtual2$rankMaxEntAUCulsmooth > 100] <- 100 # Truncate all rankMaxEntAUCulsmooth values > 100 to 100

# Real AUC rank values.
summaryrankrealAUCvirtual <- as.data.frame(summaryrankrealAUCvirtual)
summaryrankrealAUCvirtual2 <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- summaryrankrealAUCvirtual[(summaryrankrealAUCvirtual$prevalence == i), ]
  rankrealAUCll.loess <- loess(rankrealAUCll ~ sample.size, data = abc) # Fit a curve
  rankrealAUCul.loess <- loess(rankrealAUCul ~ sample.size, data = abc) # Fit a curve
  rankrealAUCllsmooth <- predict(rankrealAUCll.loess) # Get the smoothed values
  rankrealAUCulsmooth <- predict(rankrealAUCul.loess) # Get the smoothed values
  abc2 <- cbind(abc$prevalence, abc$sample.size, rankrealAUCllsmooth, rankrealAUCulsmooth)
  summaryrankrealAUCvirtual2 <- rbind(summaryrankrealAUCvirtual2, abc2)
}
colnames(summaryrankrealAUCvirtual2) <- c("prevalence", "sample.size", "rankrealAUCllsmooth", "rankrealAUCulsmooth")
summaryrankrealAUCvirtual2 <- as.data.frame(summaryrankrealAUCvirtual2)
summaryrankrealAUCvirtual2$rankrealAUCllsmooth[summaryrankrealAUCvirtual2$rankrealAUCllsmooth > 100] <- 100 # Truncate all rankrealAUCllsmooth values > 100 to 100
summaryrankrealAUCvirtual2$rankrealAUCulsmooth[summaryrankrealAUCvirtual2$rankrealAUCulsmooth > 100] <- 100 # Truncate all rankrealAUCulsmooth values > 100 to 100

# Schoener's D values.
summarySchoenerDvirtual <- as.data.frame(summarySchoenerDvirtual)
summarySchoenerDvirtual2 <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- summarySchoenerDvirtual[(summarySchoenerDvirtual$prevalence == i), ]
  SchoenerDll.loess <- loess(SchoenerDll ~ sample.size, data = abc) # Fit a curve
  SchoenerDul.loess <- loess(SchoenerDul ~ sample.size, data = abc) # Fit a curve
  SchoenerDllsmooth <- predict(SchoenerDll.loess) # Get the smoothed values
  SchoenerDulsmooth <- predict(SchoenerDul.loess) # Get the smoothed values
  abc2 <- cbind(abc$prevalence, abc$sample.size, SchoenerDllsmooth, SchoenerDulsmooth)
  summarySchoenerDvirtual2 <- rbind(summarySchoenerDvirtual2, abc2)
}
colnames(summarySchoenerDvirtual2) <- c("prevalence", "sample.size", "SchoenerDllsmooth", "SchoenerDulsmooth")
summarySchoenerDvirtual2 <- as.data.frame(summarySchoenerDvirtual2)
summarySchoenerDvirtual2$SchoenerDllsmooth[summarySchoenerDvirtual2$SchoenerDllsmooth > 1] <- 1 # Truncate all SchoenerDllsmooth values > 1 to 1
summarySchoenerDvirtual2$SchoenerDulsmooth[summarySchoenerDvirtual2$SchoenerDulsmooth > 1] <- 1 # Truncate all SchoenerDulsmooth values > 1 to 1

# Hellinger I values.
summaryHellingerIvirtual <- as.data.frame(summaryHellingerIvirtual)
summaryHellingerIvirtual2 <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- summaryHellingerIvirtual[(summaryHellingerIvirtual$prevalence == i), ]
  HellingerIll.loess <- loess(HellingerIll ~ sample.size, data = abc) # Fit a curve
  HellingerIul.loess <- loess(HellingerIul ~ sample.size, data = abc) # Fit a curve
  HellingerIllsmooth <- predict(HellingerIll.loess) # Get the smoothed values
  HellingerIulsmooth <- predict(HellingerIul.loess) # Get the smoothed values
  abc2 <- cbind(abc$prevalence, abc$sample.size, HellingerIllsmooth, HellingerIulsmooth)
  summaryHellingerIvirtual2 <- rbind(summaryHellingerIvirtual2, abc2)
}
colnames(summaryHellingerIvirtual2) <- c("prevalence", "sample.size", "HellingerIllsmooth", "HellingerIulsmooth")
summaryHellingerIvirtual2 <- as.data.frame(summaryHellingerIvirtual2)
summaryHellingerIvirtual2$HellingerIllsmooth[summaryHellingerIvirtual2$HellingerIllsmooth > 1] <- 1 # Truncate all HellingerIllsmooth values > 1 to 1
summaryHellingerIvirtual2$HellingerIulsmooth[summaryHellingerIvirtual2$HellingerIulsmooth > 1] <- 1 # Truncate all HellingerIulsmooth values > 1 to 1

#######################################################################################
# Export the summarized results.
#######################################################################################

write.csv(x = summarySpearmanvirtual2, file = "D:/R/Virtualworld/summarySpearmanvirtual2.csv")
write.csv(x = summaryMaxEntAUCvirtual2, file = "D:/R/Virtualworld/summaryMaxEntAUCvirtual2.csv")
write.csv(x = summaryrealAUCvirtual2, file = "D:/R/Virtualworld/summaryrealAUCvirtual2.csv")
write.csv(x = summaryrankMaxEntAUCvirtual2, file = "D:/R/Virtualworld/summaryrankMaxEntAUCvirtual2.csv")
write.csv(x = summaryrankrealAUCvirtual2, file = "D:/R/Virtualworld/summaryrankrealAUCvirtual2.csv")
write.csv(x = summarySchoenerDvirtual2, file = "D:/R/Virtualworld/summarySchoenerDvirtual2.csv")
write.csv(x = summaryHellingerIvirtual2, file = "D:/R/Virtualworld/summaryHellingerIvirtual2.csv")


#######################################################################################
#########################  7. Read the minimum required sample sizes  #################
#######################################################################################

# Identify the minimum sample size for which the lower limit of the upper 95% range of
# the model performance values exceeds the defined critical value.

# Lower limit of the upper 95% range of Spearman rank correlation values > 0.9.
summarySpearmanvirtual2 <- as.data.frame(summarySpearmanvirtual2)
minimumrecordsSpearmanvirtual <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- summarySpearmanvirtual2[(summarySpearmanvirtual2$prevalence == i), ]
  dataselect <- abc[(abc$Spearmanllsmooth > 0.9), ]
  criticalsamplesize <- min(dataselect$sample.size)
  abc2 <- c(i, criticalsamplesize)
  minimumrecordsSpearmanvirtual <- rbind(minimumrecordsSpearmanvirtual, abc2)
}
colnames(minimumrecordsSpearmanvirtual) <- c("prevalence", "minimumrecords")
minimumrecordsSpearmanvirtual

# Lower limit of the upper 95% range of real AUC values > 0.9.
summaryrealAUCvirtual2 <- as.data.frame(summaryrealAUCvirtual2)
minimumrecordsrealAUCvirtual <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- summaryrealAUCvirtual2[(summaryrealAUCvirtual2$prevalence == i), ]
  dataselect <- abc[(abc$AUCllsmooth > 0.9), ]
  criticalsamplesize <- min(dataselect$sample.size)
  abc2 <- c(i, criticalsamplesize)
  minimumrecordsrealAUCvirtual <- rbind(minimumrecordsrealAUCvirtual, abc2)
}
colnames(minimumrecordsrealAUCvirtual) <- c("prevalence", "minimumrecords")
minimumrecordsrealAUCvirtual

# Lower limit of the upper 95% range of MaxEnt AUC rank values > 95.
summaryrankMaxEntAUCvirtual2 <- as.data.frame(summaryrankMaxEntAUCvirtual2)
minimumrecordsrankMaxEntAUCvirtual <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- summaryrankMaxEntAUCvirtual2[(summaryrankMaxEntAUCvirtual2$prevalence == i), ]
  dataselect <- abc[(abc$rankAUCllsmooth > 95), ]
  criticalsamplesize <- min(dataselect$sample.size)
  abc2 <- c(i, criticalsamplesize)
  minimumrecordsrankMaxEntAUCvirtual <- rbind(minimumrecordsrankMaxEntAUCvirtual, abc2)
}
colnames(minimumrecordsrankMaxEntAUCvirtual) <- c("prevalence", "minimumrecords")
minimumrecordsrankMaxEntAUCvirtual

# Lower limit of the upper 95% range of real AUC rank values > 95.
summaryrankrealAUCvirtual2 <- as.data.frame(summaryrankrealAUCvirtual2)
minimumrecordsrankrealAUCvirtual <- c()
for (i in prevalence.class) { # For each prevalence class
  abc <- summaryrankrealAUCvirtual2[(summaryrankrealAUCvirtual2$prevalence == i), ]
  dataselect <- abc[(abc$rankAUCllsmooth > 95), ]
  criticalsamplesize <- min(dataselect$sample.size)
  abc2 <- c(i, criticalsamplesize)
  minimumrecordsrankrealAUCvirtual <- rbind(minimumrecordsrankrealAUCvirtual, abc2)
}
colnames(minimumrecordsrankrealAUCvirtual) <- c("prevalence", "minimumrecords")
minimumrecordsrankrealAUCvirtual

#######################################################################################
#######################################################################################
#########################  END OF CODE  ###############################################
#######################################################################################
#######################################################################################