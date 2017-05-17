###############################################################################################
### Create the 10 virtual species in VD with or without a missing covariate
###############################################################################################

Y <- sp_data_VD # matrix of presence/absence data 
X <- pred_data_VD # matrix of predictors for the data
Xnew <- pred_VD # matrix of the predictors for the landscape VD

for (k in 1:10) { # loop for the 10 species

	L <- list() # list to save the simulated species

	A <- data.frame(pa = Y[, k], X[, -c(1:2)]) # data frame with the response and predictors
	vars <- names(A[, -1])
	sqr.formula <- as.formula(paste("pa~1", paste(vars, collapse = "+"), paste(paste("I(", vars, "^2", ")", sep = ""), collapse = "+"), sep = "+")) # formula for the GLM
	fit.probit <- glm(sqr.formula, data = A, family = binomial("probit")) # fit a probit to the data

	z_sim <- predict(fit.probit, type = "link", newdata = data.frame(Xnew[, -c(1:2)])) # prediction of the response on each location of VD
	p_sim <- pnorm(z_sim) # predicted probabilities for VD

	L$coord <- Xnew[, c(1, 2)]
	L$resp <- z_sim

	ident <- list() # the list ident contain the values of the factors
	ident$num <- formatC(k, width = 2, flag = 0) # number of the species

	###########################
	### 1: no missing predictor
	###########################
	missing <- "F"
	name <- paste(formatC(k, width = 2, flag = 0), "_", missing, ".Rdata", sep = "") # name of the file in which to save the simulated species
	ident$missing <- missing
	L$pred <- Xnew[, -c(1, 2)] # predictors (without the 2 columns that correspond to the coordinates)
	save(L, ident, fit.probit, file = paste(path.species, "/", name, sep = "")) # save the results
	###########################
	
	ident$missing <- NULL
	L$pred <- NULL

	######################################################################
	### 2: a missing predictor: delete the second most important predictor
	######################################################################
	missing <- "T"
	name <- paste(formatC(k, width = 2, flag = 0), "_", missing, ".Rdata", sep = "") # name of the file in which to save the simulated species
	ident$missing <- missing

	l <- c()
	# remove each predictor, one at a time, and fit a GLM to measure which predictor is the most important in terms of likelihood differences
	I <- sample(1:nrow(Xnew), min(20000, nrow(Xnew))) # choose 20000 locations (at random) to fit the GLMs (not possible to fit the GLM to too many points)
	for (i in 1:(ncol(Xnew) - 2)) { # loop over the predictors
		A <- data.frame(pa = p_sim[I], Xnew[I, -c(1:2)]) # new data frame of the response of predictors
		vars <- names(A[, -c(1, 1 + i)])
		sqr.formula <- as.formula(paste("pa~1", paste(vars, collapse = "+"), paste(paste("I(", vars, "^2", ")", sep = ""), collapse = "+"), sep = "+")) # new formula with one predictor missing
		fit.probit2 <- glm(sqr.formula, data = A, family = binomial("probit")) # fit probit
		l <- c(l, as.numeric(logLik(fit.probit2))) # save the log-likelihood
	}
	i.missing <- which(l == sort(l)[2]) # which predictor leads to the second most important loss in terms of likelihood
	L$pred <- Xnew[, -c(1, 2, 2 + i.missing)] # predictors (without the coordinates and the missing predictor)
	save(L, ident, i.missing, fit.probit, file = paste(path.species, "/", name, sep = "")) # save the results
}
