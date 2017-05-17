###############################################################################################
### Main functions (create_datasets, fit_glm, fit_gam, fit_rf, fit_maxent)
###############################################################################################

#---------------------------------------------------------------------------------------------------------
# Create datasets files
#---------------------------------------------------------------------------------------------------------
create_datasets <- function(name, range.sac, vbias) {
	# range.sac is the range parameter for the simulation of SAC using a Gaussian process (dispersal)
	# vbias is the covariate used for the sampling design (or sampling bias)

	# number of replicates
	R1 <- 10 # number of (independent) presence/absence simulations
	R2 <- 5 # number of sampling patterns

	# two sample sizes n1 and n2
	n1 <- 100
	n2 <- 500

	# load species file
	load(paste(path.species, "/", name, sep = ""))

	# scale the vbias vector to be in [0,1]
	vbias <- (vbias - min(vbias))/(max(vbias) - min(vbias)) 

	for (SAC in c("F", "T")) { # loop over the factor SAC (dispersal)

		# initialisation
		Mn1F <- list()
		Mn1T <- list()
		Mn2F <- list()
		Mn2T <- list()
		MTn1F <- list()
		MTn1T <- list()
		MTn2F <- list()
		MTn2T <- list()

		for (i in 1:R1) {
			Mn1F[[i]] <- list()
			Mn1T[[i]] <- list()
			Mn2F[[i]] <- list()
			Mn2T[[i]] <- list()
			MTn1F[[i]] <- list()
			MTn1T[[i]] <- list()
			MTn2F[[i]] <- list()
			MTn2T[[i]] <- list()
		}

		t <- 5000 # size of test samples (limited for memory reasons)
		E.train <- matrix(ncol = R2, nrow = 2 * n1 + 2 * n2)
		E.test <- matrix(ncol = R2, nrow = 4 * t)

		for (i in 1:R1) { # loop over the simulations

			for (k in 1:R2) { # built the R2 samplings

				m <- nrow(L$coord)

				# training samples
				I_n1_F <- sample(x = m, size = n1) # no bias
				I_n1_T <- sample(x = m, size = n1, prob = vbias) # bias: sampled for probability vbias
				I_n2_F <- sample(x = m, size = n2)
				I_n2_T <- sample(x = m, size = n2, prob = vbias)
				S.train <- c(I_n1_F, I_n1_T, I_n2_F, I_n2_T)

				# test samples (no bias for test samples)
				J_n1_F <- sample((1:m)[-I_n1_F], size = t)
				J_n1_T <- sample((1:m)[-I_n1_T], size = t)
				J_n2_F <- sample((1:m)[-I_n2_F], size = t)
				J_n2_T <- sample((1:m)[-I_n2_T], size = t)
				S.test <- c(J_n1_F, J_n1_T, J_n2_F, J_n2_T)

				E.train[, k] <- S.train
				E.test[, k] <- S.test
			}

			Ind.train <- unique(c(E.train))
			Ind.test <- unique(c(E.test))

			# marginal probabilities of presence: probit link p=pnorm(X*beta, 0, 1)
			P <- rep(NA, nrow(L$coord))
			P[unique(c(E.train, E.test))] <- pnorm(L$resp[unique(c(E.train, E.test))], 0, 1)

			# simulation of the presences-absences at each location of the training sample
			PA.train <- rep(NA, nrow(L$coord))

			if (SAC == "T") {
				
				# simulate SAC only at the locations of the training sample (no SAC for the test samples)
				coord_sac <- L$coord[Ind.train, ]

				# simulation of a Gaussian random field using the Choleski decomposition (very slow if nrow(coord_sac) is large)
				s <- t(chol(exp(-as.matrix(dist(coord_sac))/range.sac))) %*% rnorm(length(Ind.train), 0, 1)

				# use the Gaussian field s to simulate correlated presences and absences
				x <- L$resp[Ind.train] + s
				PA.train[Ind.train] <- 1 * (x > 0) + 0 * (x <= 0)
			}

			if (SAC == "F") {
				
				# simulate independent normal variables
				s <- rnorm(length(Ind.train), 0, 1)
				x <- L$resp[Ind.train] + s
				PA.train[Ind.train] <- 1 * (x > 0) + 0 * (x <= 0)
			}

			# simulation of presences and absences for the test sample (data of the test sample must be independent of the training data)
			PA.test <- rep(NA, nrow(L$coord))

			s <- rnorm(length(Ind.test), 0, 1)
			x <- L$resp[Ind.test] + s
			PA.test[Ind.test] <- 1 * (x > 0) + 0 * (x <= 0)

			# extract data from PA.train and PA.test to create M (matrix of training data) and MT (matrix of test data)
			# indices corresponding to each configuration of sample size and sampling bias
			In1F <- 1:n1
			In1T <- (n1 + 1):(2 * n1)
			In2F <- (2 * n1 + 1):(2 * n1 + n2)
			In2T <- (2 * n1 + n2 + 1):(2 * n1 + 2 * n2)

			for (k in 1:R2) {
				S.train <- E.train[In1F, ]
				S.test <- E.test[(0 * t + 1):(1 * t), ]
				Mn1F[[i]][[k]] <- data.frame(L$coord[S.train[, k], ], L$pred[S.train[, k], ], prob = P[S.train[, k]], pa = PA.train[S.train[, k]])
				MTn1F[[i]][[k]] <- data.frame(L$coord[S.test[, k], ], L$pred[S.test[, k], ], prob = P[S.test[, k]], pa = PA.test[S.test[, k]])
			}

			for (k in 1:R2) {
				S.train <- E.train[In1T, ]
				S.test <- E.test[(1 * t + 1):(2 * t), ]
				Mn1T[[i]][[k]] <- data.frame(L$coord[S.train[, k], ], L$pred[S.train[, k], ], prob = P[S.train[, k]], pa = PA.train[S.train[, k]])
				MTn1T[[i]][[k]] <- data.frame(L$coord[S.test[, k], ], L$pred[S.test[, k], ], prob = P[S.test[, k]], pa = PA.test[S.test[, k]])
			}

			for (k in 1:R2) {
				S.train <- E.train[In2F, ]
				S.test <- E.test[(2 * t + 1):(3 * t), ]
				Mn2F[[i]][[k]] <- data.frame(L$coord[S.train[, k], ], L$pred[S.train[, k], ], prob = P[S.train[, k]], pa = PA.train[S.train[, k]])
				MTn2F[[i]][[k]] <- data.frame(L$coord[S.test[, k], ], L$pred[S.test[, k], ], prob = P[S.test[, k]], pa = PA.test[S.test[, k]])
			}

			for (k in 1:R2) {
				S.train <- E.train[In2T, ]
				S.test <- E.test[(3 * t + 1):(4 * t), ]
				Mn2T[[i]][[k]] <- data.frame(L$coord[S.train[, k], ], L$pred[S.train[, k], ], prob = P[S.train[, k]], pa = PA.train[S.train[, k]])
				MTn2T[[i]][[k]] <- data.frame(L$coord[S.test[, k], ], L$pred[S.test[, k], ], prob = P[S.test[, k]], pa = PA.test[S.test[, k]])
			}

		} # end of the loop over the R1 simulations

		# save M & MT in files
		c1 <- SAC

		#n1-F
		c2 <- n1
		c3 <- "F"
		name.ds <- paste(sub(pattern = ".Rdata", replacement = "", x = name), "_", c1, "_", c2, "_", c3, ".Rdata", sep = "")
		ident$SAC <- c1
		ident$samplesize <- c2
		ident$samplingbias <- c3
		M <- Mn1F
		MT <- MTn1F
		save(M, MT, ident, file = paste(path.datasets, "/", name.ds, sep = ""))

		#n1-T
		c2 <- n1
		c3 <- "T"
		name.ds <- paste(sub(pattern = ".Rdata", replacement = "", x = name), "_", c1, "_", c2, "_", c3, ".Rdata", sep = "")
		ident$SAC <- c1
		ident$samplesize <- c2
		ident$samplingbias <- c3
		M <- Mn1T
		MT <- MTn1T
		save(M, MT, ident, file = paste(path.datasets, "/", name.ds, sep = ""))

		#n2-F
		c2 <- n2
		c3 <- "F"
		name.ds <- paste(sub(pattern = ".Rdata", replacement = "", x = name), "_", c1, "_", c2, "_", c3, ".Rdata", sep = "")
		ident$SAC <- c1
		ident$samplesize <- c2
		ident$samplingbias <- c3
		M <- Mn2F
		MT <- MTn2F
		save(M, MT, ident, file = paste(path.datasets, "/", name.ds, sep = ""))

		#n2-T
		c2 <- n2
		c3 <- "T"
		name.ds <- paste(sub(pattern = ".Rdata", replacement = "", x = name), "_", c1, "_", c2, "_", c3, ".Rdata", sep = "")
		ident$SAC <- c1
		ident$samplesize <- c2
		ident$samplingbias <- c3
		M <- Mn2T
		MT <- MTn2T
		save(M, MT, ident, file = paste(path.datasets, "/", name.ds, sep = ""))
	}

	rm(L)
}

#---------------------------------------------------------------------------------------------------------
# GLM (probit)
#---------------------------------------------------------------------------------------------------------
fit_glm <- function(name) {	
	# fit a GLM with the probit link to each dataset contained in the file "name"
	
	# load datasets
	load(paste(path.datasets, "/", name, sep = ""))
	R1 <- length(M)
	R2 <- length(M[[1]])

	# number of covarites depends on the factor missing (true or false)
	if (ident$missing == "F") {
		p <- 5
	} else {
		p <- 4
	}

	# return AUC, COR and RMSE
	AUC <- matrix(NA, ncol = R1, nrow = R2)
	COR <- matrix(NA, ncol = R1, nrow = R2)
	RMSE <- matrix(NA, ncol = R1, nrow = R2)
	
	for (k in 1:R1) {
		for (r in 1:R2) {
			
			A <- data.frame(pa = M[[k]][[r]]$pa, M[[k]][[r]][3:(2 + p)]) # depends on p
			vars <- names(A[, -1])
			sqr.formula <- as.formula(paste("pa~1", paste(vars, collapse = "+"), paste(paste("I(", vars, "^2", ")", sep = ""), collapse = "+"), sep = "+"))
			fit1 <- glm(sqr.formula, data = A, family = binomial("probit"))

			newpred <- predict(fit1, type = "response", newdata = MT[[k]][[r]])
			AUC[r, k] <- performance(prediction(newpred, labels = MT[[k]][[r]]$pa), measure = "auc")@y.values[[1]]
			COR[r, k] <- biserial.cor(x = newpred, y = MT[[k]][[r]]$pa, use = "all.obs", level = 2)
			RMSE[r, k] <- sqrt(mean((newpred - MT[[k]][[r]]$prob)^2))
		}
	}
	
	ident$technique <- "GLM"
	name.new <- paste(ident$num, "_", ident$missing, "_", ident$SAC, "_", ident$technique, "_", ident$samplesize, "_", ident$samplingbias, ".Rdata", sep = "")
	save(AUC, RMSE, COR, ident, file = paste(path.results, "/", name.new, sep = ""))
	return(sum(is.na(AUC)))
}

#---------------------------------------------------------------------------------------------------------
# GAM (probit)
#---------------------------------------------------------------------------------------------------------
fit_gam <- function(name) {
	# fit a GAM with the probit link to each dataset contained in the file "name"

	load(paste(path.datasets, "/", name, sep = ""))
	R1 <- length(M)
	R2 <- length(M[[1]])

	if (ident$missing == "F") {
		p <- 5
	} else {
		p <- 4
	}

	AUC <- matrix(NA, ncol = R1, nrow = R2)
	COR <- matrix(NA, ncol = R1, nrow = R2)
	RMSE <- matrix(NA, ncol = R1, nrow = R2)

	for (k in 1:R1) {
		for (r in 1:R2) {

			A <- data.frame(pa = M[[k]][[r]]$pa, M[[k]][[r]][3:(2 + p)])
			vars <- names(A[, -1])
			sqr.formula <- as.formula(paste("pa~", paste(paste("s(", vars, ")", sep = ""), collapse = "+"), sep = ""))
			cc <- try(fit1 <- gam(sqr.formula, data = A, family = binomial("probit")), silent = TRUE) # to avoid the function stops if there is an error

			if (!is(cc, "try-error")) {
				newpred <- predict(fit1, type = "response", newdata = MT[[k]][[r]][, 3:7])
				AUC[r, k] <- performance(prediction(newpred, labels = MT[[k]][[r]]$pa), measure = "auc")@y.values[[1]]
				COR[r, k] <- biserial.cor(x = newpred, y = MT[[k]][[r]]$pa, use = "all.obs", level = 2)
				RMSE[r, k] <- sqrt(mean((newpred - MT[[k]][[r]]$prob)^2))
			}
		}
	}

	ident$technique <- "GAM"
	name.new <- paste(ident$num, "_", ident$missing, "_", ident$SAC, "_", ident$technique, "_", ident$samplesize, "_", ident$samplingbias, ".Rdata", sep = "")
	save(AUC, RMSE, COR, ident, file = paste(path.results, "/", name.new, sep = ""))
	return(sum(is.na(AUC)))
}

#---------------------------------------------------------------------------------------------------------
# RF
#---------------------------------------------------------------------------------------------------------
fit_rf <- function(name) {
	# fit a random forest to each dataset contained in the file "name"

	load(paste(path.datasets, "/", name, sep = ""))
	R1 <- length(M)
	R2 <- length(M[[1]])

	if (ident$missing == "F") {
		p <- 5
	} else {
		p <- 4
	}

	AUC <- matrix(NA, ncol = R1, nrow = R2)
	COR <- matrix(NA, ncol = R1, nrow = R2)
	RMSE <- matrix(NA, ncol = R1, nrow = R2)

	for (k in 1:R1) {
		for (r in 1:R2) {

			A <- data.frame(pa = as.factor(M[[k]][[r]]$pa), M[[k]][[r]][3:(2 + p)])
			cc <- try(fit1 <- randomForest(pa ~ ., data = A), silent = TRUE)

			if (!is(cc, "try-error")) {
				newpred <- predict(fit1, type = "prob", newdata = MT[[k]][[r]])[, 2]
				AUC[r, k] <- performance(prediction(newpred, labels = MT[[k]][[r]]$pa), measure = "auc")@y.values[[1]]
				COR[r, k] <- biserial.cor(x = newpred, y = MT[[k]][[r]]$pa, use = "all.obs", level = 2)
				RMSE[r, k] <- sqrt(mean((newpred - MT[[k]][[r]]$prob)^2))
			}
		}
	}
	ident$technique <- "RF"
	name.new <- paste(ident$num, "_", ident$missing, "_", ident$SAC, "_", ident$technique, "_", ident$samplesize, "_", ident$samplingbias, ".Rdata", sep = "")
	save(AUC, RMSE, COR, ident, file = paste(path.results, "/", name.new, sep = ""))
	return(sum(is.na(AUC)))
}

#---------------------------------------------------------------------------------------------------------
# MaxEnt
#---------------------------------------------------------------------------------------------------------
fit_maxent <- function(name) {
	# fit MaxEnt (library dismo) to each dataset contained in the file "name"

	load(paste(path.datasets, "/", name, sep = ""))
	R1 <- length(M)
	R2 <- length(M[[1]])

	if (ident$missing == "F") {
		p <- 5
	} else {
		p <- 4
	}

	AUC <- matrix(NA, ncol = R1, nrow = R2)
	COR <- matrix(NA, ncol = R1, nrow = R2)
	RMSE <- matrix(NA, ncol = R1, nrow = R2)

	for (k in 1:R1) {
		for (r in 1:R2) {

			A <- data.frame(pa = M[[k]][[r]]$pa, M[[k]][[r]][, 3:(2 + p)])
			cc <- try(fit1 <- maxent(x = A[, -1], p = A[, 1]), silent = TRUE)

			if (!is(cc, "try-error")) {
				newpred <- predict(fit1, x = MT[[k]][[r]])# Defaut output for maxent is logistic. Can be specified using: args="outputformat=logistic"
				AUC[r, k] <- performance(prediction(newpred, labels = MT[[k]][[r]]$pa), measure = "auc")@y.values[[1]]
				COR[r, k] <- biserial.cor(x = newpred, y = MT[[k]][[r]]$pa, use = "all.obs", level = 2)
				RMSE[r, k] <- sqrt(mean((newpred - MT[[k]][[r]]$prob)^2))
			}
		}
	}

	ident$technique <- "MaxEnt"
	name.new <- paste(ident$num, "_", ident$missing, "_", ident$SAC, "_", ident$technique, "_", ident$samplesize, "_", ident$samplingbias, ".Rdata", sep = "")
	save(AUC, RMSE, COR, ident, file = paste(path.results, "/", name.new, sep = ""))
	return(sum(is.na(AUC)))
}

