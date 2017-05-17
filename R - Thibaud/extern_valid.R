###############################################################################################
### function to evaluate the performance of the techniques on other landscapes
###############################################################################################

# this function opens the file of a simulated species and its associated 8 datasets files, replaces the test samples in the datasets by other test samples taken in the new region 

extern_valid <- function(name, pred_ext) {

	R1 <- 10 # number of (independent) presence/absence simulations
	R2 <- 5 # number of sampling patterns

	n1 <- 100 # first sample size
	n2 <- 500 # second sample size

	load(paste(path.species, "/", name, sep = "")) # load the simulated species in VD (L, ident, fit.probit and i.missing if ident$missing=='T')

	# calculate the distribution of the simulated species in the new region
	Lnew <- list()
	Lnew$coord <- pred_ext[, c(1:2)]
	z_sim <- predict(fit.probit, type = "link", newdata = data.frame(pred_ext[, -c(1:2)])) # use the fitted probit to predict the species in the new region
	Lnew$resp <- z_sim

	rm(L)

	# if missing=='T', we remove the i.missing predictor
	if (ident$missing == "F") {
		Lnew$pred <- pred_ext[, -c(1, 2)]
	} else {
		Lnew$pred <- pred_ext[, -c(1, 2, 2 + i.missing)]
	}

	# create test samples in the new region: open the original datasets, keep the training samples, and replace the test samples
	for (SAC in c("F", "T")) { # loop over SAC (dispersal)

		# load original datasets (combinations of sample size and sampling bias) and store them in new matrices
		# (M correspond to training samples, MT to test samples)

		# n1-F
		name.ds <- paste(sub(pattern = ".Rdata", replacement = "", x = name), "_", SAC, "_", n1, "_", "F", ".Rdata", sep = "")
		load(file = paste(path.datasets, "/", name.ds, sep = ""))
		Mn1F <- M

		# n1-T
		name.ds <- paste(sub(pattern = ".Rdata", replacement = "", x = name), "_", SAC, "_", n1, "_", "T", ".Rdata", sep = "")
		load(file = paste(path.datasets, "/", name.ds, sep = ""))
		Mn1T <- M

		# n2-F
		name.ds <- paste(sub(pattern = ".Rdata", replacement = "", x = name), "_", SAC, "_", n2, "_", "F", ".Rdata", sep = "")
		load(file = paste(path.datasets, "/", name.ds, sep = ""))
		Mn2F <- M

		# n2-T
		name.ds <- paste(sub(pattern = ".Rdata", replacement = "", x = name), "_", SAC, "_", n2, "_", "T", ".Rdata", sep = "")
		load(file = paste(path.datasets, "/", name.ds, sep = ""))
		Mn2T <- M

		# create new test samples from external data
		MTn1F <- list()
		MTn1T <- list()
		MTn2F <- list()
		MTn2T <- list()
		for (i in 1:R1) {
			MTn1F[[i]] <- list()
			MTn1T[[i]] <- list()
			MTn2F[[i]] <- list()
			MTn2T[[i]] <- list()
		}

		t <- 5000 # size of test samples
		E.test <- matrix(ncol = R2, nrow = 4 * t)

		for (i in 1:R1) {

			for (k in 1:R2) { # for each of the R2 samplings, for each combination of sample size and sampling bias, sample t locations for test samples
				m <- nrow(Lnew$coord)
				J_n1_F <- sample((1:m), size = t) # test sample for n=n1 and bias='F'
				J_n1_T <- sample((1:m), size = t)
				J_n2_F <- sample((1:m), size = t)
				J_n2_T <- sample((1:m), size = t)
				S.test <- c(J_n1_F, J_n1_T, J_n2_F, J_n2_T)
				E.test[, k] <- S.test
			}

			Ind.test <- unique(c(E.test))

			# calculate the theoretical presence probabilities for test samples	
			P <- rep(NA, nrow(Lnew$coord))
			P[Ind.test] <- pnorm(Lnew$resp[Ind.test], 0, 1)

			# generate 0-1 for test samples
			PA.test <- rep(NA, nrow = nrow(Lnew$coord))
			s <- rnorm(length(Ind.test), 0, 1) # using independent normal variables (no SAC in test samples)
			x <- Lnew$resp[Ind.test] + s
			PA.test[Ind.test] <- 1 * (x > 0) + 0 * (x <= 0) # 0-1 with probit link

			# extract data from PA.test to create the new test samples MT
			for (k in 1:R2) {
				S.test <- E.test[(0 * t + 1):(1 * t), ]
				MTn1F[[i]][[k]] <- data.frame(Lnew$coord[S.test[, k], ], Lnew$pred[S.test[, k], ], prob = P[S.test[, k]], pa = PA.test[S.test[, k]])
			}
			for (k in 1:R2) {
				S.test <- E.test[(1 * t + 1):(2 * t), ]
				MTn1T[[i]][[k]] <- data.frame(Lnew$coord[S.test[, k], ], Lnew$pred[S.test[, k], ], prob = P[S.test[, k]], pa = PA.test[S.test[, k]])
			}
			for (k in 1:R2) {
				S.test <- E.test[(2 * t + 1):(3 * t), ]
				MTn2F[[i]][[k]] <- data.frame(Lnew$coord[S.test[, k], ], Lnew$pred[S.test[, k], ], prob = P[S.test[, k]], pa = PA.test[S.test[, k]])
			}
			for (k in 1:R2) {
				S.test <- E.test[(3 * t + 1):(4 * t), ]
				MTn2T[[i]][[k]] <- data.frame(Lnew$coord[S.test[, k], ], Lnew$pred[S.test[, k], ], prob = P[S.test[, k]], pa = PA.test[S.test[, k]])
			}

		} # end of the loop over the R1 simulations

		# save M & MT in files		
		c1 <- SAC

		# n1-F
		c2 <- n1
		c3 <- "F"
		name.ds <- paste(sub(pattern = ".Rdata", replacement = "", x = name), "_", c1, "_", c2, "_", c3, ".Rdata", sep = "")
		ident$SAC <- c1
		ident$samplesize <- c2
		ident$samplingbias <- c3
		M <- Mn1F
		MT <- MTn1F
		save(M, MT, ident, file = paste(path.datasets_ext, "/", name.ds, sep = ""))

		# n1-T
		c2 <- n1
		c3 <- "T"
		name.ds <- paste(sub(pattern = ".Rdata", replacement = "", x = name), "_", c1, "_", c2, "_", c3, ".Rdata", sep = "")
		ident$SAC <- c1
		ident$samplesize <- c2
		ident$samplingbias <- c3
		M <- Mn1T
		MT <- MTn1T
		save(M, MT, ident, file = paste(path.datasets_ext, "/", name.ds, sep = ""))

		# n2-F
		c2 <- n2
		c3 <- "F"
		name.ds <- paste(sub(pattern = ".Rdata", replacement = "", x = name), "_", c1, "_", c2, "_", c3, ".Rdata", sep = "")
		ident$SAC <- c1
		ident$samplesize <- c2
		ident$samplingbias <- c3
		M <- Mn2F
		MT <- MTn2F
		save(M, MT, ident, file = paste(path.datasets_ext, "/", name.ds, sep = ""))

		# n2-T
		c2 <- n2
		c3 <- "T"
		name.ds <- paste(sub(pattern = ".Rdata", replacement = "", x = name), "_", c1, "_", c2, "_", c3, ".Rdata", sep = "")
		ident$SAC <- c1
		ident$samplesize <- c2
		ident$samplingbias <- c3
		M <- Mn2T
		MT <- MTn2T
		save(M, MT, ident, file = paste(path.datasets_ext, "/", name.ds, sep = ""))
	}
}
