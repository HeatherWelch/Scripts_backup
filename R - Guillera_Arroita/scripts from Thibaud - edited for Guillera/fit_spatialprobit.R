###############################################################################################
### Function for fitting a spatial probit model using a composite likelihood function
###############################################################################################

library(mvtnorm)

fitspatialprobit <- function(formula, data, coord, u = 0.2, nmax = 1e+05, int = c(1e-04, 1000)) {
	# formula is a regression formula (see glm.fit)
	# data is the data.frame of the data
	# coord is the matrix of coordinates
	# u is the threshold for the selection of the pairs: the likelihood use only the pairs for which the distance is smaller than the u quantile of the distances
	# nmax is the maximum of pairs used in the likelihood: selected at random after the selection by the criterion u
	# int is the interval for the optimization

	n <- nrow(data)

	x <- coord[, 1]
	y <- coord[, 2]

	# calculate pairs and distances
	pair <- expand.grid(1:n, 1:n)
	pair <- pair[, 2:1]
	pair <- pair[pair[, 1] < pair[, 2], ]
	pair <- matrix(c(pair[[1]], pair[[2]]), ncol = 2)
	cx <- t(x)
	cy <- t(y)
	pcx <- matrix(cx[, pair], ncol = 2)
	pcy <- matrix(cy[, pair], ncol = 2)
	dx <- pcx[, 1] - pcx[, 2]
	dy <- pcy[, 1] - pcy[, 2]

	# choose a subset of pairs
	I <- which(sqrt(dx^2 + dy^2) < quantile(sqrt(dx^2 + dy^2), u))
	if (length(I) > nmax) {
		J <- sample(1:length(I), nmax)
		I <- I[J]
	}

	# independent GLM (probit) for the regression parameters
	fit.probit <- glm(sqr.formula, data = data, family = binomial("probit"))
	coefficients(fit.probit)
	Y <- data[, 1]
	Xbeta <- qnorm(fit.probit$fitted.value)
	
	# M is the matrix of the data used for the likelihood
	M <- cbind(Y[pair[I, 1]], Y[pair[I, 2]], Xbeta[pair[I, 1]], Xbeta[pair[I, 2]], sqrt(dx^2 + dy^2)[I])

	# negative log-likelihood function for the spatial probit
	nllik <- function(par) {
		# par is the range parameter
		
		# different contributions for pairs 0-0, 0-1, 1-0 or 1-1
		I11 <- which((M[, 1] == 1) & (M[, 2] == 1))
		I01 <- which((M[, 1] == 0) & (M[, 2] == 1))
		I10 <- which((M[, 1] == 1) & (M[, 2] == 0))
		I00 <- which((M[, 1] == 0) & (M[, 2] == 0))

		pmvnorm2 <- function(m) {
			set.seed(1)
			pmvnorm(upper = c(m[1], m[2]), mean = c(0, 0), sigma = matrix(c(1, exp(-m[3]/par), exp(-m[3]/par), 1), ncol = 2))[1]
		}

		# likelihood contributions
		l11 <- sum(log(apply(M[I11, c(3, 4, 5)], 1, pmvnorm2)))
		l01 <- sum(log(pnorm(M[I01, c(4)]) - apply(M[I01, c(3, 4, 5)], 1, pmvnorm2)))
		l10 <- sum(log(pnorm(M[I10, c(3)]) - apply(M[I10, c(3, 4, 5)], 1, pmvnorm2)))
		l00 <- sum(log(1 - pnorm(M[I00, c(3)]) - pnorm(M[I00, c(4)]) + apply(M[I00, c(3, 4, 5)], 1, pmvnorm2)))

		l <- -1 * (l11 + l01 + l10 + l00)
		return(l)
	}

	# optimization with respect to the range parameter
	opt <- optimize(f = nllik, interval = int)

	# return results
	z <- list()
	z$par <- opt$minimum
	z$llik <- -opt$objective
	z$eff.range <- -opt$minimum * log(0.05)
	return(z)
}
###############################################################################################
