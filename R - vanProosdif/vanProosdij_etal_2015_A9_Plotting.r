#######################################################################################
### van Proosdij, A.S.J., Sosef, M.S.M., Wieringa, J.J. and Raes, N. 2015.
### Minimum required number of specimen records to develop accurate species distribution
### models
### Ecography, DOI: 10.1111/ecog.01509
### Appendix 9: R script for graphical presentation of the results.
#######################################################################################

#######################################################################################
#########################  PLOTTING FUNCTIONS  ########################################
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
#########################  Load functions and packages  ###############################
#######################################################################################

# Set the working directory and load libraries.
rm(list = ls(all = TRUE))
setwd("D:/R/Virtualworld")
getwd()
library(raster) # for reading and writing rasters
library(stats) # for cor() function
library(mvtnorm) # for dmvnorm() function
library(SDMTools) # for write.asc(), asc2dataframe(), and pnt.in.poly() functions
library(dismo) # for evaluate() and maxent() functions
library(phyloclim) # for niche.overlap() function
library(plotrix) # for rescale() function
library(scales) # for rescale() function
library(ellipse) # for ellipse() function
library(ggplot2) # for ggplot() function
library(doBy)
library(grid)

#######################################################################################
#########################  Ploting the results  #######################################
#######################################################################################

# Read the summarized data from the real African study area.
summarySpearmanreal2 <- read.csv("D:/R/realworld/summarySpearmanreal2.csv")
summaryMaxEntAUCreal2 <- read.csv("D:/R/realworld/summaryMaxEntAUCreal2.csv")
summaryrealAUCreal2 <- read.csv("D:/R/realworld/summaryrealAUCreal2.csv")
summaryrankMaxEntAUCreal2 <- read.csv("D:/R/realworld/summaryrankMaxEntAUCreal2.csv")
summaryrankrealAUCreal2 <- read.csv("D:/R/realworld/summaryrankrealAUCreal2.csv")
summarySchoenerDreal2 <- read.csv("D:/R/realworld/summarySchoenerDreal2.csv")
summaryHellingerIreal2 <- read.csv("D:/R/realworld/summaryHellingerIreal2.csv")

# Read the summarized data from the virtual study area.
summarySpearmanvirtual2 <- read.csv("D:/R/Virtualworld/summarySpearmanvirtual2.csv")
summaryMaxEntAUCvirtual2 <- read.csv("D:/R/Virtualworld/summaryMaxEntAUCvirtual2.csv")
summaryrealAUCvirtual2 <- read.csv("D:/R/Virtualworld/summaryrealAUCvirtual2.csv")
summaryrankMaxEntAUCvirtual2 <- read.csv("D:/R/Virtualworld/summaryrankMaxEntAUCvirtual2.csv")
summaryrankrealAUCvirtual2 <- read.csv("D:/R/Virtualworld/summaryrankrealAUCvirtual2.csv")
summarySchoenerDvirtual2 <- read.csv("D:/R/Virtualworld/summarySchoenerDvirtual2.csv")
summaryHellingerIvirtual2 <- read.csv("D:/R/Virtualworld/summaryHellingerIvirtual2.csv")

#######################################################################################
# Add columns that identify the variable and unify the names of the variables.
#######################################################################################

# Rank AUC real and rank AUC MaxEnt.
summaryrankrealAUCreal2$ID <- "realworldAUCrealrank"
names(summaryrankrealAUCreal2)[names(summaryrankrealAUCreal2) == 'rankrealAUCllsmooth'] <- 'rankAUCllsmooth'
names(summaryrankrealAUCreal2)[names(summaryrankrealAUCreal2) == 'rankrealAUCulsmooth'] <- 'rankAUCulsmooth'
summaryrankrealAUCvirtual2$ID <- "virtualworldAUCrealrank"
names(summaryrankrealAUCvirtual2)[names(summaryrankrealAUCvirtual2) == 'rankrealAUCllsmooth'] <- 'rankAUCllsmooth'
names(summaryrankrealAUCvirtual2)[names(summaryrankrealAUCvirtual2) == 'rankrealAUCulsmooth'] <- 'rankAUCulsmooth'
summaryrankMaxEntAUCreal2$ID <- "realworldAUCMaxEntrank"
names(summaryrankMaxEntAUCreal2)[names(summaryrankMaxEntAUCreal2) == 'rankMaxEntAUCllsmooth'] <- 'rankAUCllsmooth'
names(summaryrankMaxEntAUCreal2)[names(summaryrankMaxEntAUCreal2) == 'rankMaxEntAUCulsmooth'] <- 'rankAUCulsmooth'
summaryrankMaxEntAUCvirtual2$ID <- "virtualworldAUCMaxEntrank"
names(summaryrankMaxEntAUCvirtual2)[names(summaryrankMaxEntAUCvirtual2) == 'rankMaxEntAUCllsmooth'] <- 'rankAUCllsmooth'
names(summaryrankMaxEntAUCvirtual2)[names(summaryrankMaxEntAUCvirtual2) == 'rankMaxEntAUCulsmooth'] <- 'rankAUCulsmooth'
rankAUCtotal <- rbind(summaryrankrealAUCreal2, summaryrankrealAUCvirtual2, summaryrankMaxEntAUCreal2, summaryrankMaxEntAUCvirtual2)
str(rankAUCtotal)

# AUC MaxEnt and AUC real.
summaryrealAUCreal2$ID <- "realworldAUCreal"
names(summaryrealAUCreal2)[names(summaryrealAUCreal2) == 'realAUCllsmooth'] <- 'AUCllsmooth'
names(summaryrealAUCreal2)[names(summaryrealAUCreal2) == 'realAUCulsmooth'] <- 'AUCulsmooth'
summaryrealAUCvirtual2$ID <- "virtualworldAUCreal"
names(summaryrealAUCvirtual2)[names(summaryrealAUCvirtual2) == 'realAUCllsmooth'] <- 'AUCllsmooth'
names(summaryrealAUCvirtual2)[names(summaryrealAUCvirtual2) == 'realAUCulsmooth'] <- 'AUCulsmooth'
summaryMaxEntAUCreal2$ID <- "realworldAUCMaxEnt"
names(summaryMaxEntAUCreal2)[names(summaryMaxEntAUCreal2) == 'MaxEntAUCllsmooth'] <- 'AUCllsmooth'
names(summaryMaxEntAUCreal2)[names(summaryMaxEntAUCreal2) == 'MaxEntAUCulsmooth'] <- 'AUCulsmooth'
summaryMaxEntAUCvirtual2$ID <- "virtualworldAUCMaxEnt"
names(summaryMaxEntAUCvirtual2)[names(summaryMaxEntAUCvirtual2) == 'MaxEntAUCllsmooth'] <- 'AUCllsmooth'
names(summaryMaxEntAUCvirtual2)[names(summaryMaxEntAUCvirtual2) == 'MaxEntAUCulsmooth'] <- 'AUCulsmooth'
AUCtotal <- rbind(summaryrealAUCreal2, summaryrealAUCvirtual2, summaryMaxEntAUCreal2, summaryMaxEntAUCvirtual2)
str(AUCtotal)

# Spearman rank correlation.
summarySpearmanreal2$ID <- "realSpearman"
summarySpearmanvirtual2$ID <- "virtualSpearman"
Spearmantotal <- rbind(summarySpearmanreal2, summarySpearmanvirtual2)
str(Spearmantotal)

# Schoener's D and Hellinger I.
summarySchoenerDreal2$ID <- "realSchoenerD"
names(summarySchoenerDreal2)[names(summarySchoenerDreal2) == 'SchoenerDllsmooth'] <- 'SChoHellllsmooth'
names(summarySchoenerDreal2)[names(summarySchoenerDreal2) == 'SchoenerDulsmooth'] <- 'SChoHellulsmooth'
summaryHellingerIreal2$ID <- "realHellingerI"
names(summaryHellingerIreal2)[names(summaryHellingerIreal2) == 'HellingerIllsmooth'] <- 'SChoHellllsmooth'
names(summaryHellingerIreal2)[names(summaryHellingerIreal2) == 'HellingerIulsmooth'] <- 'SChoHellulsmooth'
summarySchoenerDvirtual2$ID <- "virtualSchoenerD"
names(summarySchoenerDvirtual2)[names(summarySchoenerDvirtual2) == 'SchoenerDllsmooth'] <- 'SChoHellllsmooth'
names(summarySchoenerDvirtual2)[names(summarySchoenerDvirtual2) == 'SchoenerDulsmooth'] <- 'SChoHellulsmooth'
summaryHellingerIvirtual2$ID <- "virtualHellingerI"
names(summaryHellingerIvirtual2)[names(summaryHellingerIvirtual2) == 'HellingerIllsmooth'] <- 'SChoHellllsmooth'
names(summaryHellingerIvirtual2)[names(summaryHellingerIvirtual2) == 'HellingerIulsmooth'] <- 'SChoHellulsmooth'
SchoenerHellingertotal <- rbind(summarySchoenerDreal2, summaryHellingerIreal2, summarySchoenerDvirtual2, summaryHellingerIvirtual2)
str(SchoenerHellingertotal)

#######################################################################################
# Make subsets for selected prevalence classes only.
#######################################################################################

keep4 <- c(0.05, 0.10, 0.20, 0.30, 0.40, 0.50) # Define prevalence classes to keep
Spearmantotalselect <- Spearmantotal[which(Spearmantotal$prevalence %in% keep4), ]
AUCtotalselect <- AUCtotal[which(AUCtotal$prevalence %in% keep4), ]
rankAUCtotalselect <- rankAUCtotal[which(rankAUCtotal$prevalence %in% keep4), ]
SchoenerHellingertotalselect <- SchoenerHellingertotal[which(SchoenerHellingertotal$prevalence %in% keep4), ]

#######################################################################################
# Plot the figures for selected prevalence classes.
#######################################################################################
# In ggplot() arguments were used from the scale_manual() group. In these, the labels
# and values are based on the specified breaks. The legend order is specified by the
# breaks argument.

#######################################################################################
# Plot the Spearman rank correlation values for the virtual and the African study area.
plot.Spearmansmooth <- ggplot(data = Spearmantotalselect, aes(x = sample.size, y = Spearmanllsmooth)) + theme_bw()
plot.Spearmansmooth +
  # Add the threshold level
  geom_line(aes(y = 0.9), size = 1, linetype = "solid", color = "red") +
  # Add a line with the mean values for each group
  geom_line(aes(color = ID, linetype = ID), size = 0.75) +
  # Add a ribbon with the confidence intervals for both groups
  geom_ribbon(aes(ymin = Spearmanllsmooth, ymax = Spearmanulsmooth, fill = ID), alpha = 0.30) +
  guides(colour = guide_legend(override.aes = list(size = 0))) +
  # Define the layout: facets, facet titles, axis scales, axis titles
  facet_wrap(~prevalence, ncol = 3, scales = "free_x") +
  theme(strip.text.x = element_text(size = 12, face = "bold")) +
  scale_y_continuous('Spearman rank correlation', expand = c(0,0.005), limits = c(0.5, 1), breaks = seq(from = 0, to = 1, by = 0.05)) +
  scale_x_continuous('Sample size', expand = c(0,0), limits = c(2, 51), breaks = seq(from = 0, to = 50, by = 5)) +
  theme(axis.title = element_text(colour = "black", size = 12, face = "bold")) +
  # Add a legend
  scale_color_manual(name = "Study area type",
                     values = c("Grey50", "Black"),
                     breaks = c("virtualSpearman", "realSpearman"),
                     labels = c("Virtual study area", "African study area")) +
  scale_fill_manual(name = "Study area type",
                    values = c("Grey50", "Black"),
                    breaks = c("virtualSpearman", "realSpearman"),
                    labels = c("Virtual study area", "African study area")) +
  scale_linetype_manual(name = "Study area type",
                        values = c("solid", "dashed"),
                        breaks = c("virtualSpearman", "realSpearman"),
                        labels = c("Virtual study area", "African study area")) +
  theme(legend.title = element_blank()) +
  theme(legend.background = element_blank()) +
  theme(legend.text = element_text(colour = "black", size = 10, face = "bold")) +
  theme(legend.position = c(.20, .7)) +
  theme(legend.key = element_rect(fill = 'white')) +
  coord_fixed(ratio = 60)

#######################################################################################
# Plot the MaxEnt and real AUC values for the virtual and the African study area.
# Define the values, labels and breaks of the plot elements.
labelsAUC <- c("virtualworldAUCreal" = "virtual study area real AUC", "virtualworldAUCMaxEnt" = "virtual study area MaxEnt AUC", "realworldAUCreal" = "African study area real AUC", "realworldAUCMaxEnt" = "African study area MaxEnt AUC")
valuesAUCcolour <- c("virtualworldAUCreal" = "Green", "virtualworldAUCMaxEnt" = "Purple", "realworldAUCreal" = "Grey50", "realworldAUCMaxEnt" = "Black")
valuesAUClinetype <- c("virtualworldAUCreal" = "dashed", "virtualworldAUCMaxEnt" = "dashed", "realworldAUCreal" = "solid", "realworldAUCMaxEnt" = "solid")
# Plot the figure.
plot.AUC.smooth <- ggplot(data = AUCtotalselect, aes(x = sample.size, y = AUCllsmooth)) + theme_bw()
plot.AUC.smooth +
  # Add the threshold level
  geom_line(aes(y = 1-(prevalence/2)), size = 1, linetype = "solid", color = "red") +
  # Add a line with the mean values for each group
  geom_line(aes(color = ID, linetype = ID), size = 0.75) +
  # Add a ribbon with the confidence intervals for both groups
  geom_ribbon(aes(ymin = AUCllsmooth, ymax = AUCulsmooth, fill = ID), alpha = 0.20) +
  # Define the layout: facets, facet titles, axis scales, axis titles
  facet_wrap(~prevalence, ncol = 3, scales = "free_x") +
  theme(strip.text.x = element_text(size = 12, face = "bold")) +
  scale_y_continuous('AUC', expand = c(0,0.01), limits = c(0.62, 1), breaks = seq(from = 0, to = 1, by = 0.05)) +
  scale_x_continuous('Sample size', expand = c(0,0), limits = c(2, 51), breaks = seq(from = 0, to = 50, by = 5)) +
  theme(axis.title = element_text(colour = "black", size = 12, face = "bold")) +
  # Add a legend
  scale_color_manual(name = "Study area type",
                     values = valuesAUCcolour,
                     breaks = c("virtualworldAUCreal", "virtualworldAUCMaxEnt", "realworldAUCreal", "realworldAUCMaxEnt"),
                     labels = labelsAUC) +
  scale_fill_manual(name = "Study area type",
                    values = valuesAUCcolour,
                    breaks = c("virtualworldAUCreal", "virtualworldAUCMaxEnt", "realworldAUCreal", "realworldAUCMaxEnt"),
                    labels = labelsAUC) +
  scale_linetype_manual(name = "Study area type",
                        values = valuesAUClinetype,
                        breaks = c("virtualworldAUCreal", "virtualworldAUCMaxEnt", "realworldAUCreal", "realworldAUCMaxEnt"),
                        labels = labelsAUC) +
  theme(legend.title = element_blank()) +
  theme(legend.background = element_blank()) +
  theme(legend.text = element_text(colour = "black", size = 10, face = "bold")) +
  theme(legend.position = c(.20, .7)) +
  theme(legend.key = element_rect(fill = NA))+
  coord_fixed(ratio = 100)

#######################################################################################
# Plot the rank numbers of the MaxEnt and real AUC rank values for the virtual and the
# African study area.
# Define the values, labels and breaks of the plot elements.
labelsrankAUC <- c("virtualworldAUCrealrank" = "virtual study area real AUC", "virtualworldAUCMaxEntrank" = "virtual study area MaxEnt AUC", "realworldAUCrealrank" = "African study area real AUC", "realworldAUCMaxEntrank" = "African study area MaxEnt AUC")
valuesrankAUCcolour <- c("virtualworldAUCrealrank" = "Green", "virtualworldAUCMaxEntrank" = "Purple", "realworldAUCrealrank" = "Grey50", "realworldAUCMaxEntrank" = "Black")
valuesrankAUClinetype <- c("virtualworldAUCrealrank" = "dashed", "virtualworldAUCMaxEntrank" = "dashed", "realworldAUCrealrank" = "solid", "realworldAUCMaxEntrank" = "solid")
# Plot the figure.
plot.rankAUC.smooth <- ggplot(data = rankAUCtotalselect, aes(x = sample.size, y = rankAUCllsmooth)) + theme_bw()
plot.rankAUC.smooth +
  # Add the threshold level
  geom_line(aes(y = 95), size = 1, linetype = "solid", color = "red") +
  # Add a line with the mean values for each group
  geom_line(aes(color = ID, linetype = ID), size = 0.75) +
  # Add a ribbon with the confidence intervals for both groups
  geom_ribbon(aes(ymin = rankAUCllsmooth, ymax = rankAUCulsmooth, fill = ID), alpha = 0.20) +
  # Define the layout: facets, facet titles, axis scales, axis titles
  facet_wrap(~prevalence, ncol = 3, scales = "free_x") +
  theme(strip.text.x = element_text(size = 12, face = "bold")) +
  scale_y_continuous('Rank AUC', expand = c(0,0), limits = c(37, 102), breaks = seq(from = 0, to = 100, by = 5)) +
  scale_x_continuous('Sample size', expand = c(0,0), limits = c(2, 51), breaks = seq(from = 0, to = 50, by = 5)) +
  theme(axis.title = element_text(colour = "black", size = 12, face = "bold")) +
  # Add a legend
  scale_colour_manual(name = "Study area type",
                      values = valuesrankAUCcolour,
                      breaks = c("virtualworldAUCrealrank", "virtualworldAUCMaxEntrank", "realworldAUCrealrank", "realworldAUCMaxEntrank"),
                      labels = labelsrankAUC) +
  scale_fill_manual(name = "Study area type",
                    values = valuesrankAUCcolour,
                    breaks = c("virtualworldAUCrealrank", "virtualworldAUCMaxEntrank", "realworldAUCrealrank", "realworldAUCMaxEntrank"),
                    labels = labelsrankAUC) +
  scale_linetype_manual(name = "Study area type",
                        values = valuesrankAUClinetype,
                        breaks = c("virtualworldAUCrealrank", "virtualworldAUCMaxEntrank", "realworldAUCrealrank", "realworldAUCMaxEntrank"),
                        labels = labelsrankAUC) +
  theme(legend.title = element_blank()) +
  theme(legend.background = element_blank()) +
  theme(legend.text = element_text(colour = "black", size = 10, face = "bold")) +
  theme(legend.position = c(.20, .7)) +
  theme(legend.key = element_rect(fill = NA))+
  coord_fixed(ratio = 0.45)

#######################################################################################
# Plot the Schoener's D and Hellinger I values for the virtual and African study are.
# Define the values, labels and breaks of the plot elements.
labelsSchoener <- c("virtualSchoenerD" = "virtual study area Schoener's D", "virtualHellingerI" = "virtual study area Hellinger I", "realSchoenerD" = "African study area Schoener's D", "realHellingerI" = "African study area Hellinger I")
valuesSchoenercolour <- c("virtualSchoenerD" = "Green", "virtualHellingerI" = "Purple", "realSchoenerD" = "Grey50", "realHellingerI" = "Black")
valuesSchoenerlinetype <- c("virtualSchoenerD" = "dashed", "virtualHellingerI" = "dashed", "realSchoenerD" = "solid", "realHellingerI" = "solid")
# Plot the figure.
plot.SchoenerDHellingerI.smooth <- ggplot(data = SchoenerHellingertotalselect, aes(x = sample.size, y = SChoHellllsmooth)) + theme_bw()
plot.SchoenerDHellingerI.smooth +
  # Add a line with the mean values for each group
  geom_line(aes(color = ID, linetype = ID), size = 0.75) +
  # Add a ribbon with the confidence intervals for both groups
  geom_ribbon(aes(ymin = SChoHellllsmooth, ymax = SChoHellulsmooth, fill = ID), alpha = 0.20) +
  # Define the layout: facets, facet titles, axis scales, axis titles
  facet_wrap(~prevalence, ncol = 3, scales = "free_x") +
  theme(strip.text.x = element_text(size = 12, face = "bold")) +
  scale_y_continuous('Schoeners D / Hellinger I', expand = c(0,0), limits = c(0, 1), breaks = seq(from = 0, to = 1, by = 0.1)) +
  scale_x_continuous('Sample size', expand = c(0,0), limits = c(2, 51), breaks = seq(from = 0, to = 50, by = 5)) +
  theme(axis.title = element_text(colour = "black", size = 12, face = "bold")) +
  # Add a legend
  scale_colour_manual(name = "Study area type",
                      values = valuesSchoenercolour,
                      breaks = c("virtualSchoenerD", "virtualHellingerI", "realSchoenerD", "realHellingerI"),
                      labels = labelsSchoener) +
  scale_fill_manual(name = "Study area type",
                    values = valuesSchoenercolour,
                    breaks = c("virtualSchoenerD", "virtualHellingerI", "realSchoenerD", "realHellingerI"),
                    labels = labelsSchoener) +
  scale_linetype_manual(name = "Study area type",
                        values = valuesSchoenerlinetype,
                        breaks = c("virtualSchoenerD", "virtualHellingerI", "realSchoenerD", "realHellingerI"),
                        labels = labelsSchoener) +
  theme(legend.title = element_blank()) +
  theme(legend.background = element_blank()) +
  theme(legend.text = element_text(colour = "black", size = 10, face = "bold")) +
  theme(legend.position = c(.83, .14)) +
  theme(legend.key = element_rect(fill = NA))+
  coord_fixed(ratio = 0.45)

#######################################################################################
#######################################################################################
#########################  END OF CODE  ###############################################
#######################################################################################
#######################################################################################