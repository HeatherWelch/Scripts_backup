###############################################################################################
### Virtual species in VD design - Estimation of SAC using a spatial probit model
###############################################################################################

# source the function for fitting the spatial probit model
source(paste(path.main, "/fit_spatialprobit.R", sep = ""))

# load data from 10 real species in Vaud Alps
load(paste(path.main, "/datasp_VD.Rdata", sep = ""))

# fit a GLM with probit link and a spatial probit model to estimate SAC on the data
for (k in 1:10) {
	A <- data.frame(pa = sp_data_VD[, k], pred_data_VD[, 3:7])
	vars <- names(A[, -1])
	sqr.formula <- as.formula(paste("pa~1", paste(vars, collapse = "+"), paste(paste("I(", vars, "^2", ")", sep = ""), 
		collapse = "+"), sep = "+"))
	probit1 <- glm(sqr.formula, data = A, family = binomial("probit"))

	cat(paste("species", k, "\n"))
	sprobit1 <- fitspatialprobit(sqr.formula, A, pred_data_VD[, 1:2], u = 0.05, int = c(0.001, 5))
	cat(paste("range parameter:", sprobit1$par, "\n"))
	cat(paste("effective range:", sprobit1$eff.range, "\n"))
}
