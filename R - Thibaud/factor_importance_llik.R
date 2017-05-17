###############################################################################################
### Calculation of the log likelihoods
###############################################################################################

factor_importance_llik <- function(file, na.method = na.fail, tex = NULL) {

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


	Y <- log(Y_RMSE)
	X <- data.frame(X, Y, B0, B1, B2)

	### Fit the linear mixed-effects models using lme with maximum likelihood.
	lme.B2 <- lme(Y ~ missing * SAC * method * n * bias, random = ~1 | B0/B1/B2, data = X, na.action = na.method, control = lmeControl(opt = "optim"), method = 'ML')

	# fit lme excluding one factor at a time
	lme.B2.missing <- lme(Y ~ SAC * method * n * bias, random = ~1 | B0/B1/B2, data = X, na.action = na.method, control = lmeControl(opt = "optim"), method = 'ML')
	lme.B2.sac <- lme(Y ~ missing * method * n * bias, random = ~1 | B0/B1/B2, data = X, na.action = na.method, control = lmeControl(opt = "optim"), method = 'ML')
	lme.B2.n <- lme(Y ~ missing * SAC * method * bias, random = ~1 | B0/B1/B2, data = X, na.action = na.method, control = lmeControl(opt = "optim"), method = 'ML')
	lme.B2.bias <- lme(Y ~ missing * SAC * method * n, random = ~1 | B0/B1/B2, data = X, na.action = na.method, control = lmeControl(opt = "optim"), method = 'ML')
	lme.B2.method <- lme(Y ~ missing * SAC * n * bias, random = ~1 | B0/B1/B2, data = X, na.action = na.method, control = lmeControl(opt = "optim"), method = 'ML')

	# print llik differences
	LLIKdiff <- c(lme.B2$logLik,lme.B2$logLik-lme.B2.missing$logLik,lme.B2$logLik-lme.B2.sac$logLik,lme.B2$logLik-lme.B2.n$logLik,lme.B2$logLik-lme.B2.bias$logLik,lme.B2$logLik-lme.B2.method$logLik)
	cat("logLik differences", "\n")
	cat("full model:", LLIKdiff[1], "\n")
	cat("missing:", LLIKdiff[2], "\n")
	cat("dispersal:", LLIKdiff[3], "\n")
	cat("sample size:", LLIKdiff[4], "\n")
	cat("design:", LLIKdiff[5], "\n")
	cat("method:", LLIKdiff[6], "\n \n")

	if (!is.null(tex)) {
		sink(tex)

		# print tex for table in file
		cat("\\begin{tabular}{ l rrrrrr}  \n")
		cat("\\hline \n")
		cat("Model & full model & $-$\\emph{missing} & $-$\\emph{dispersal} & $-$\\emph{n} & $-$\\emph{design} & $-$\\emph{technique} \\\\ \n")
		cat("\\hline \n")
		cat("logLik differences", paste(paste("& $", c(c(as.matrix(round(LLIKdiff[1:6], 0)))), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("\\hline \n")
		cat("\\end{tabular} \n")
		sink()
	}

}