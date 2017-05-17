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