###############################################################################################
### Calculation of the relative importance of the factors using R2 for linear mixed-effects
### models introduced by Nakagawa S. & Schielzeth H. (2013, A general and simple method for 
### obtaining R2 from generalized linear mixed-effects models, Methods in Ecology and
### Evolution, 4, 133--142)
###############################################################################################

factor_importance_R2 <- function(file, na.method = na.fail, tex = NULL) {

	load(file)

	n <- length(Y_RMSE)

	# blocks of random effects
	# species
	B0 <- as.factor(paste(X$species))
	levels(B0) <- 1:K
	# presences-absences simulations
	B1 <- as.factor(paste(X$random, X$missing, X$SAC))
	levels(B1) <- 1:(R1 * 2 * 2)
	# sampling
	B2 <- as.factor(paste(X$n, X$bias, X$sampling))
	levels(B2) <- 1:(4 * R2)


	### R2 linear mixed-effects models (Nakagawa S. & Schielzeth H., 2013, A general and simple method for obtaining R2 from generalized linear mixed-effects models, Methods in Ecology and Evolution, 4, 133--142)
	Y <- log(Y_RMSE)
	X <- data.frame(X, Y, B0, B1, B2)

	### Fit the linear mixed-effects models using lme. We use optim instead of nlminb: it is faster and sometimes nlminb fails to converge. Sometimes using optim return some warnings but using nlminb in these cases gives no error and the same estimates.
	lme.B2 <- lme(Y ~ missing * SAC * method * n * bias, random = ~1 | B0/B1/B2, data = X, na.action = na.method, control = lmeControl(opt = "optim"))

	### diagnostics
	# plot(lme.B2)
	# plot(lme.B2,B0~resid(., type = "p"))
	# qqnorm(lme.B2,abline=c(0,1))
	# qqnorm(lme.B2,~ resid(., type = "p") | B0,abline=c(0,1))

	# fit lme excluding one factor at a time
	lme.B2.missing <- lme(Y ~ SAC * method * n * bias, random = ~1 | B0/B1/B2, data = X, na.action = na.method, control = lmeControl(opt = "optim"))
	lme.B2.sac <- lme(Y ~ missing * method * n * bias, random = ~1 | B0/B1/B2, data = X, na.action = na.method, control = lmeControl(opt = "optim"))
	lme.B2.n <- lme(Y ~ missing * SAC * method * bias, random = ~1 | B0/B1/B2, data = X, na.action = na.method, control = lmeControl(opt = "optim"))
	lme.B2.bias <- lme(Y ~ missing * SAC * method * n, random = ~1 | B0/B1/B2, data = X, na.action = na.method, control = lmeControl(opt = "optim"))
	lme.B2.method <- lme(Y ~ missing * SAC * n * bias, random = ~1 | B0/B1/B2, data = X, na.action = na.method, control = lmeControl(opt = "optim"))

	# calculate marginal and conditional R2
	Rsquared <- c()
	for (model in list(lme.B2, lme.B2.missing, lme.B2.sac, lme.B2.n, lme.B2.bias, lme.B2.method)) {
		var_fixed <- var(as.vector(fixef(model) %*% t(model.matrix(eval(model$call$fixed)[-2], model$data))))
		var_random <- sum(as.numeric(VarCorr(model)[c(2, 4, 6), 1]))
		var_residuals <- as.numeric(VarCorr(model)[7, 1])
		R2_marginal <- var_fixed/(var_fixed + var_random + var_residuals)
		R2_conditional <- (var_fixed + var_random)/(var_fixed + var_random + var_residuals)
		Rsquared <- rbind(Rsquared, c(R2_marginal, R2_conditional))
	}

	# print marginal and conditional R2
	cat("Marginal R-squared", "\n")
	cat("full model:", Rsquared[1, 1], "\n")
	cat("missing:", Rsquared[2, 1], "\n")
	cat("dispersal:", Rsquared[3, 1], "\n")
	cat("sample size:", Rsquared[4, 1], "\n")
	cat("design:", Rsquared[5, 1], "\n")
	cat("technique:", Rsquared[6, 1], "\n \n")

	cat("Conditional R-squared", "\n")
	cat("full model:", Rsquared[1, 2], "\n")
	cat("missing:", Rsquared[2, 2], "\n")
	cat("dispersal:", Rsquared[3, 2], "\n")
	cat("sample size:", Rsquared[4, 2], "\n")
	cat("design:", Rsquared[5, 2], "\n")
	cat("technique:", Rsquared[6, 2], "\n \n")

	if (!is.null(tex)) {
		sink(tex)

		# print tex for table in file
		cat("\\begin{tabular}{ l rrrrrr}  \n")
		cat("\\hline \n")
		cat("Model & full model & $-$\\emph{missing} & $-$\\emph{dispersal} & $-$\\emph{n} & $-$\\emph{design} & $-$\\emph{technique} \\\\ \n")
		cat("\\hline \n")
		cat("Marginal $\\text{R}^2$", paste(paste("& $", c(c(as.matrix(round(Rsquared[1:6, 1], 3)))), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("Conditional $\\text{R}^2$", paste(paste("& $", c(c(as.matrix(round(Rsquared[1:6, 2], 3)))), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("\\hline \n")
		cat("\\end{tabular} \n")
		sink()
	}

}