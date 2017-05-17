#######################################################################################
### van Proosdij, A.S.J., Sosef, M.S.M., Wieringa, J.J. and Raes, N. 2015.
### Minimum required number of specimen records to develop accurate species distribution
### models
### Ecography, DOI: 10.1111/ecog.01509
### Appendix 8: R script with null-model tests for the virtual and for the real African
### study area.
#######################################################################################

#######################################################################################
#########################  NULL MODEL FUNCTIONS  ######################################
#######################################################################################

#######################################################################################
#######################################################################################
###  Written by André S.J. van Proosdij (1,2) & Niels Raes (2), 2015
###  1 Biosystematics Group, Wageningen University, the Netherlands
###  2 Naturalis Biodiversity Center (Botany section), Leiden, the Netherlands
###  Corresponding author: André S.J. van Proosdij, andrevanproosdij at hotmail dot com
#######################################################################################
#######################################################################################

# DESCRIPTION
# The functions nullModelvirtual() and nullModelreal() are based on the function
# nullRandom() ('dismo' package, Heijmans & al., 2013) and adapted to our study. In the
# function, MaxEnt species distribution models are generated based on presences that
# are randomly selected from the entire study area. The MaxEnt AUC value of a species
# model is added to the 99 (or 999) null model AUC values. When ranked, a species model
# is regarded to significantly deviate from random expectation if its rank number
# exceeds 95 (in case of 99 null models) or 950 (in case of 999 null models).

# ARGUMENTS
# x    - Dataframe with for each raster cell (row) the values of the environmental
#        variables (columns).
# n    - The sample size.
# rep  - The number of repetitions, usually 99 or 999.

#######################################################################################
# Function for a virtual study area.
#######################################################################################
nullModelvirtual <- function (x, n, rep) {
  AUC <- list()
  for (r in 1:rep) {
    q <- sample(nrow(x), n) # Randomly sample n rows --> random presences
    # Create SWD files for presences and for background as input for MaxEnt. Note:
    # samples are added to background data, similar to the default setting of MaxEnt.
    pres <- x[q, ] # Presence data
    absc <- x[-q,] # background data
    # Limit the number of background data to 10000.
    if (nrow(absc) > 10000) absc <- absc[sample(nrow(absc), 10000), ] else absc <- absc
    nmpredictordata <- rbind(pres, absc) # rbind all presence and background data
    # Create a vector with 0/1 to identify presences and background.
    nmPAidentifier <- c(rep(1, nrow(pres)), rep(0, nrow(absc)))
    # Execute the maxent() function. By specifying the path, output files are stored. By
    # specifying the projection layers a prediction file "species_layers.asc" is generated.
    m <- maxent(nmpredictordata,
                nmPAidentifier,
                path = "D:/R/Virtualworld/outputsnm",
                args = c("projectionlayers=layers", "redoifexists", "notooltips", "noautofeature", "linear", "quadratic", "nohinge", "noproduct", "nothreshold", "l2lqthreshold=1"))
    # Read and store AUC values of the null models.
    maxentResults <- read.csv("D:/R/Virtualworld/outputsnm/maxentResults.csv")
    AUC[[r]] <- maxentResults$Training.AUC
    cat("-")
    if (r%%50 == 0) 
      cat(" ", r, "\n")
    flush.console()
  }
  if (r%%50 != 0) {
    cat(" ", r, "\n")
  }
  else {
    cat("\n")
  }
  AUC
}


#######################################################################################
# Function for a real African study area.
#######################################################################################
nullModelreal <- function (x, n, rep) {
  AUC <- list()
  for (r in 1:rep) {
    q <- sample(nrow(x), n) # Randomly sample n rows --> random presences
    # Create SWD files for presences and for background as input for MaxEnt. Note:
    # samples are added to background data, similar to the default setting of MaxEnt.
    pres <- x[q, ] # Presence data
    absc <- x[-q,] # background data
    # Limit the number of background data to 10000.
    if (nrow(absc) > 10000) absc <- absc[sample(nrow(absc), 10000), ] else absc <- absc
    nmpredictordata <- rbind(pres, absc) # rbind all presence and background data
    # Create a vector with 0/1 to identify presences and background.
    nmPAidentifier <- c(rep(1, nrow(pres)), rep(0, nrow(absc)))
    # Execute the maxent() function. By specifying the path, output files are stored. By
    # specifying the projection layers a prediction file "species_layers.asc" is generated.
    m <- maxent(nmpredictordata,
                nmPAidentifier,
                path = "D:/R/Realworld/outputsnm",
                args = c("projectionlayers=layers", "redoifexists", "notooltips", "noautofeature", "linear", "quadratic", "nohinge", "noproduct", "nothreshold", "l2lqthreshold=1"))
    # Read and store AUC values of the null models.
    maxentResults <- read.csv("D:/R/Realworld/outputsnm/maxentResults.csv")
    AUC[[r]] <- maxentResults$Training.AUC
    cat("-")
    if (r%%50 == 0) 
      cat(" ", r, "\n")
    flush.console()
  }
  if (r%%50 != 0) {
    cat(" ", r, "\n")
  }
  else {
    cat("\n")
  }
  AUC
}

#######################################################################################
#########################  END OF CODE  ###############################################
#######################################################################################