###############################################################################################
### Create matrix of results with RMSE and configurations and save in a file
###############################################################################################

CreateMatResults <- function(path.res, file.res) {
# needs path of the results
# save the matrix of results in file.res

	listfiles <- dir(path.res)

	K <- 10 # number of species in each landscape

	if (length(listfiles) == 640) { # only if no missing file

		load(paste(path.res, "/", listfiles[1], sep = ""))

		# create matrices of results
		
		R1 <- ncol(AUC) #number of simulation
		R2 <- nrow(AUC) #number of sampling

		V_random <- rep(rep(rep(1:R1, each = R2), 64), K)
		V_sampling <- rep(rep(1:R2, R1 * 64), K)
		V_bias <- rep(c(rep(c("F"), R1 * R2), rep(c("T"), R1 * R2)), 2 * 4 * 2 * 2 * K)
		V_n <- rep(c(rep(100, R1 * R2 * 2), rep(500, R1 * R2 * 2)), 4 * 2 * 2 * K)
		V_method <- rep(c(rep("GAM", R1 * R2 * 4), rep("GLM", R1 * R2 * 4), rep("MaxEnt", R1 * R2 * 4), rep("RF", R1 * R2 * 4)), 2 * 2 * K)
		V_SAC <- rep(c(rep(c("F"), R1 * R2 * 16), rep(c("T"), R1 * R2 * 16)), 2 * K)
		V_missing <- rep(c(rep(c("F"), R1 * R2 * 32), rep(c("T"), R1 * R2 * 32)), K)
		V_num <- rep(formatC(1:10, width = 2, flag = 0), each = R1 * R2 * 64)
		X <- data.frame(sampling = V_sampling, random = V_random, bias = V_bias, n = V_n, method = V_method, SAC = V_SAC, missing = V_missing, species = V_num)

		for (i in 1:ncol(X)) {
			X[, i] <- as.factor(X[, i])
		}

		X$method <- relevel(X$method, "GLM")
		X$n <- relevel(X$n, "100")
		X$bias <- relevel(X$bias, "T")
		X$SAC <- relevel(X$SAC, "T")

		Y_AUC <- Y_COR <- Y_RMSE <- c()
		for (name in listfiles) {
			load(paste(path.res, "/", name, sep = ""))
			Y_AUC <- c(Y_AUC, c(AUC))
			Y_COR <- c(Y_COR, c(COR))
			Y_RMSE <- c(Y_RMSE, c(RMSE))
		}

		save(R1, R2, K, X, Y_AUC, Y_COR, Y_RMSE, file = file.res)
	}
}