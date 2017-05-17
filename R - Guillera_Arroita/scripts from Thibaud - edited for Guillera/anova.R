###############################################################################################
### Anova with all interactions between the fixed factors
###############################################################################################

anova.FI <- function(file, na.rm = FALSE, tex = NULL) {

	# file is the name of the file containing the results (created using the function CreateMatResults)
	# tex is the name of a file to save the latex script for the ANOVA table

	load(file)

	n <- length(Y_RMSE)

	# B0, B1 and B2 are the three blocks of random effects
	B0 <- as.factor(paste(X$species)) 
	levels(B0) <- 1:K

	B1 <- as.factor(paste(X$random, X$missing, X$SAC))
	levels(B1) <- 1:(R1 * 2 * 2)

	B2 <- as.factor(paste(X$n, X$bias, X$sampling))
	levels(B2) <- 1:(2 * 2 * R2)

	# take the log of RMSE
	Yl <- log(Y_RMSE)

	# if na.rm==TRUE: remove missing values
	I <- 1:n
	if (na.rm == TRUE & sum(is.na(Y_RMSE[I])) > 0) {
		I <- I[-which(is.na(Y_RMSE[I]))]
		X <- X[I, ]
		B0 <- B0[I]
		B1 <- B1[I]
		B2 <- B2[I]
		Yl <- log(Y_RMSE[I])
	}


	#---------------------------------------------------------------------------------------------------------
	#------------------------------- ANOVA -------------------------------------------------------------------
	#---------------------------------------------------------------------------------------------------------

	# total sum of squares
	y0 <- rep(mean(Yl), length(Yl))

	##### residuals #####
	yb0 <- tapply(Yl, B0, mean)[B0]
	ssb0 <- sum((yb0 - y0)^2)
	#####################
	
	# missing
	y1 <- tapply(Yl, X$missing, mean)[X$missing]
	ym <- y1 - y0
	ss1 <- sum(ym^2)

	# SAC (or dispersal)
	y2 <- tapply(Yl, X$SAC, mean)[X$SAC]
	ys <- y2 - y0
	ss2 <- sum(ys^2)

	# missing:SAC
	y12 <- tapply(Yl, as.factor(paste(X$missing, X$SAC)), mean)[as.factor(paste(X$missing, X$SAC))]
	yms <- y12 - ym - ys - y0
	ss12 <- sum(yms^2)

	##### residuals #####
	yb1 <- tapply(Yl, as.factor(paste(B0, B1)), mean)[as.factor(paste(B0, B1))]
	ssb1 <- sum((yb1 - y0)^2) - ss12 - ss2 - ss1 - ssb0
	#####################
	
	# n
	y3 <- tapply(Yl, X$n, mean)[X$n]
	yn <- y3 - y0
	ss3 <- sum(yn^2)

	# bias (or design)
	y4 <- tapply(Yl, X$bias, mean)[X$bias]
	yb <- y4 - y0
	ss4 <- sum(yb^2)

	# missing:n
	y13 <- tapply(Yl, as.factor(paste(X$n, X$missing)), mean)[as.factor(paste(X$n, X$missing))]
	ymn <- y13 - ym - yn - y0
	ss13 <- sum(ymn^2)

	# SAC:n
	y23 <- tapply(Yl, as.factor(paste(X$n, X$SAC)), mean)[as.factor(paste(X$n, X$SAC))]
	ysn <- y23 - yn - ys - y0
	ss23 <- sum(ysn^2)

	# missing:bias
	y14 <- tapply(Yl, as.factor(paste(X$missing, X$bias)), mean)[as.factor(paste(X$missing, X$bias))]
	ymb <- y14 - ym - yb - y0
	ss14 <- sum(ymb^2)

	# SAC:bias
	y24 <- tapply(Yl, as.factor(paste(X$bias, X$SAC)), mean)[as.factor(paste(X$bias, X$SAC))]
	ysb <- y24 - yb - ys - y0
	ss24 <- sum(ysb^2)

	# n:bias
	y34 <- tapply(Yl, as.factor(paste(X$bias, X$n)), mean)[as.factor(paste(X$bias, X$n))]
	ynb <- y34 - yn - yb - y0
	ss34 <- sum(ynb^2)

	# missing:SAC:n
	y123 <- tapply(Yl, as.factor(paste(X$missing, X$n, X$SAC)), mean)[as.factor(paste(X$missing, X$n, X$SAC))]
	ymsn <- y123 - ym - ys - yn - yms - ysn - ymn - y0
	ss123 <- sum(ymsn^2)

	# missing:SAC:bias
	y124 <- tapply(Yl, as.factor(paste(X$missing, X$bias, X$SAC)), mean)[as.factor(paste(X$missing, X$bias, X$SAC))]
	ymsb <- y124 - ym - ys - yb - yms - ysb - ymb - y0
	ss124 <- sum(ymsb^2)

	# missing:n:bias
	y134 <- tapply(Yl, as.factor(paste(X$missing, X$n, X$bias)), mean)[as.factor(paste(X$missing, X$n, X$bias))]
	ymnb <- y134 - ym - yn - yb - ymn - ymb - ynb - y0
	ss134 <- sum(ymnb^2)

	# SAC:n:bias
	y234 <- tapply(Yl, as.factor(paste(X$bias, X$n, X$SAC)), mean)[as.factor(paste(X$bias, X$n, X$SAC))]
	ysnb <- y234 - yn - yb - ys - ynb - ysb - ysn - y0
	ss234 <- sum(ysnb^2)

	# missing:SAC:n:bias
	y1234 <- tapply(Yl, as.factor(paste(X$missing, X$bias, X$n, X$SAC)), mean)[as.factor(paste(X$missing, X$bias, X$n, X$SAC))]
	ymsnb <- y1234 - ym - ys - yn - yb - yms - ymn - ymb - ysn - ysb - ynb - ymsn - ymsb - ymnb - ysnb - y0
	ss1234 <- sum(ymsnb^2)

	##### residuals #####
	yb2 <- tapply(Yl, as.factor(paste(B0, B1, B2)), mean)[as.factor(paste(B0, B1, B2))]
	ssb2 <- sum((yb2 - y0)^2) - ss1234 - ss234 - ss134 - ss124 - ss123 - ss34 - ss24 - ss14 - ss23 - ss13 - ss4 - ss3 - ssb1 - ss12 - ss2 - ss1 - ssb0
	#####################
	
	# method (or technique)
	y5 <- tapply(Yl, X$method, mean)[X$method]
	yt <- y5 - y0
	ss5 <- sum(yt^2)

	# missing:method
	y15 <- tapply(Yl, as.factor(paste(X$missing, X$method)), mean)[as.factor(paste(X$missing, X$method))]
	ymt <- y15 - ym - yt - y0
	ss15 <- sum(ymt^2)

	# SAC:method
	y25 <- tapply(Yl, as.factor(paste(X$SAC, X$method)), mean)[as.factor(paste(X$SAC, X$method))]
	yst <- y25 - ys - yt - y0
	ss25 <- sum(yst^2)

	# n:method
	y35 <- tapply(Yl, as.factor(paste(X$n, X$method)), mean)[as.factor(paste(X$n, X$method))]
	ynt <- y35 - yn - yt - y0
	ss35 <- sum(ynt^2)

	# bias:method
	y45 <- tapply(Yl, as.factor(paste(X$method, X$bias)), mean)[as.factor(paste(X$method, X$bias))]
	ybt <- y45 - yb - yt - y0
	ss45 <- sum(ybt^2)

	# missing:SAC:method
	y125 <- tapply(Yl, as.factor(paste(X$missing, X$method, X$SAC)), mean)[as.factor(paste(X$missing, X$method, X$SAC))]
	ymst <- y125 - ym - ys - yt - yms - ymt - yst - y0
	ss125 <- sum(ymst^2)

	# missing:n:method
	y135 <- tapply(Yl, as.factor(paste(X$missing, X$method, X$n)), mean)[as.factor(paste(X$missing, X$method, X$n))]
	ymnt <- y135 - ym - yn - yt - ymn - ymt - ynt - y0
	ss135 <- sum(ymnt^2)

	# SAC:n:method
	y235 <- tapply(Yl, as.factor(paste(X$n, X$method, X$SAC)), mean)[as.factor(paste(X$n, X$method, X$SAC))]
	ysnt <- y235 - ys - yn - yt - ysn - yst - ynt - y0
	ss235 <- sum(ysnt^2)

	# missing:bias:method
	y145 <- tapply(Yl, as.factor(paste(X$missing, X$method, X$bias)), mean)[as.factor(paste(X$missing, X$method, X$bias))]
	ymbt <- y145 - ym - yb - yt - ymb - ymt - ybt - y0
	ss145 <- sum(ymbt^2)

	# SAC:bias:method
	y245 <- tapply(Yl, as.factor(paste(X$bias, X$method, X$SAC)), mean)[as.factor(paste(X$bias, X$method, X$SAC))]
	ysbt <- y245 - ys - yb - yt - ysb - yst - ybt - y0
	ss245 <- sum(ysbt^2)

	# n:bias:method
	y345 <- tapply(Yl, as.factor(paste(X$bias, X$method, X$n)), mean)[as.factor(paste(X$bias, X$method, X$n))]
	ynbt <- y345 - yn - yb - yt - ynb - ynt - ybt - y0
	ss345 <- sum(ynbt^2)

	# missing:SAC:n:method
	y1235 <- tapply(Yl, as.factor(paste(X$missing, X$n, X$method, X$SAC)), mean)[as.factor(paste(X$missing, X$n, X$method, X$SAC))]
	ymsnt <- y1235 - ym - ys - yn - yt - yms - ymn - ymt - ysn - yst - ynt - ymsn - ymst - ymnt - ysnt - y0
	ss1235 <- sum(ymsnt^2)

	# missing:SAC:bias:method
	y1245 <- tapply(Yl, as.factor(paste(X$missing, X$bias, X$method, X$SAC)), mean)[as.factor(paste(X$missing, X$bias, X$method, X$SAC))]
	ymsbt <- y1245 - ym - ys - yb - yt - yms - ymb - ymt - ysb - yst - ybt - ymsb - ymst - ymbt - ysbt - y0
	ss1245 <- sum(ymsbt^2)

	# missing:n:bias:method
	y1345 <- tapply(Yl, as.factor(paste(X$missing, X$n, X$method, X$bias)), mean)[as.factor(paste(X$missing, X$n, X$method, X$bias))]
	ymnbt <- y1345 - ym - yn - yb - yt - ymn - ymb - ymt - ynb - ynt - ybt - ymnb - ymnt - ymbt - ynbt - y0
	ss1345 <- sum(ymnbt^2)

	# SAC:n:bias:method
	y2345 <- tapply(Yl, as.factor(paste(X$SAC, X$n, X$method, X$bias)), mean)[as.factor(paste(X$SAC, X$n, X$method, X$bias))]
	ysnbt <- y2345 - ys - yn - yb - yt - ysn - ysb - yst - ynb - ynt - ybt - ysnb - ysnt - ysbt - ynbt - y0
	ss2345 <- sum(ysnbt^2)

	# missing:SAC:n:bias:method
	y12345 <- tapply(Yl, as.factor(paste(X$missing, X$SAC, X$n, X$method, X$bias)), mean)[as.factor(paste(X$missing, X$SAC, X$n, X$method, X$bias))]
	ymsnbt <- y12345 - ym - ys - yn - yb - yt - yms - ymn - ymb - ymt - ysn - ysb - yst - ynb - ynt - ybt - ymsn - ymsb - ymst - ymnb - ymnt - ymbt - ysnb - ysnt - ysbt - ynbt - ymsnb - ymsnt - ymsbt - ymnbt - ysnbt - y0
	ss12345 <- sum(ymsnbt^2)

	##### residuals #####
	ssb3 <- sum((Yl - y0)^2) - ss12345 - ss2345 - ss1345 - ss1245 - ss1235 - ss345 - ss245 - ss145 - ss235 - ss135 - ss125 - ss45 - ss35 - ss25 - ss15 - ss5 - ssb2 - ss1234 - ss234 - ss134 - ss124 - ss123 - ss34 - ss24 - ss14 - ss23 - ss13 - ss4 - ss3 - ssb1 - ss12 - ss2 - ss1 - ssb0
	#####################
	

	# ANOVA Table
	cSpe1 <- c("residual")
	cSpe2 <- c(K - 1)
	cSpe3 <- c(ssb0)
	cSpe4 <- cSpe3/cSpe2
	cSpe5 <- c(NA)
	cSpe6 <- c(NA)

	cSim1 <- c("missing", "dispersal", "missing:dispersal", "residual")
	cSim2 <- c(1, 1, 1, R1 * K * 4 - (K + 3 * 1))
	cSim3 <- c(ss1, ss2, ss12, ssb1)
	cSim4 <- cSim3/cSim2
	cSim5 <- c(cSim4[-4]/cSim4[4], NA)
	cSim6 <- c(pf(cSim5[-4], cSim2[-4], cSim2[4], lower.tail = FALSE, log = TRUE), NA)

	cSam1 <- c("n", "design", "missing:n", "dispersal:n", "missing:design", "dispersal:design", "n:design", "missing:dispersal:n", "missing:dispersal:design", "missing:n:design", "dispersal:n:design", "missing:dispersal:n:design", "residual")
	cSam2 <- c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, R1 * K * 16 * R2 - (R1 * K * 4 + 12 * 1))
	cSam3 <- c(ss3, ss4, ss13, ss23, ss14, ss24, ss34, ss123, ss124, ss134, ss234, ss1234, ssb2)
	cSam4 <- cSam3/cSam2
	cSam5 <- c(cSam4[-13]/cSam4[13], NA)
	cSam6 <- c(pf(cSam5[-13], cSam2[-13], cSam2[13], lower.tail = FALSE, log = TRUE), NA)

	cWit1 <- c("technique", "missing:technique", "dispersal:technique", "n:technique", "design:technique", "missing:dispersal:technique", "missing:n:technique", "dispersal:n:technique", "missing:design:technique", "dispersal:design:technique", "n:design:technique", "missing:dispersal:n:technique", "missing:dispersal:design:technique", "missing:n:design:technique", "dispersal:n:design:technique", "missing:dispersal:n:design:technique", "residual")
	cWit2 <- c(3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, R1 * R2 * K * 16 * 4 - (R1 * K * 16 * R2 + 16 * 3))
	cWit3 <- c(ss5, ss15, ss25, ss35, ss45, ss125, ss135, ss235, ss145, ss245, ss345, ss1235, ss1245, ss1345, ss2345, ss12345, ssb3)
	cWit4 <- cWit3/cWit2
	cWit5 <- c(cWit4[-17]/cWit4[17], NA)
	cWit6 <- c(pf(cWit5[-17], cWit2[-17], cWit2[17], lower.tail = FALSE, log = TRUE), NA)

	r <- function(x) {
		round(x, 3)
	}

	AOV.Species <- data.frame(Factor = cSpe1, Df = cSpe2, SS = r(cSpe3), MS = r(cSpe4), F = r(cSpe5), log10p = r(cSpe6/log(10)))
	AOV.Simulation <- data.frame(Factor = cSim1, Df = cSim2, SS = r(cSim3), MS = r(cSim4), F = r(cSim5), log10p = r(cSim6/log(10)))
	AOV.Sampling <- data.frame(Factor = cSam1, Df = cSam2, SS = r(cSam3), MS = r(cSam4), F = r(cSam5), log10p = r(cSam6/log(10)))
	AOV.Within <- data.frame(Factor = cWit1, Df = cWit2, SS = r(cWit3), MS = r(cWit4), F = r(cWit5), log10p = r(cWit6/log(10)))

	cat("-----------------------------------------------------------------------------", "\n", " ANOVA TABLE", "\n")
	cat("-----------------------------------------------------------------------------", "\n")
	cat(" BETWEEN SPECIES", "\n")
	print(AOV.Species)
	cat(" SIMULATION WITHIN SPECIES", "\n")
	print(AOV.Simulation)
	cat(" SAMPLING WITHIN SIMULATION", "\n")
	print(AOV.Sampling)
	cat(" REPLICATES WITHIN SAMPLING", "\n")
	print(AOV.Within)
	cat("-----------------------------------------------------------------------------", "\n", " Variance at each level", "\n")
	cat(" Between Species:", r((cSpe4[1] - cSim4[4])/(4 * 2 * 2 * R2 * 2 * 2 * R1)), "\n")
	cat(" Simulation Within Species:", r((cSim4[4] - cSam4[13])/(4 * 2 * 2 * R2)), "\n")
	cat(" Sampling Within Simulation:", r((cSam4[13] - cWit4[17])/(4)), "\n")
	cat(" Replicates Within Sampling:", r(cWit4[17]), "\n")
	cat("-----------------------------------------------------------------------------", "\n", " Sum of SS for each factor and all its interactions with other factors", "\n")
	cat(" missing:", ss1+ss12+ss13+ss14+ss123+ss124+ss134+ss1234+ss15+ss125+ss135+ss145+ss1235+ss1245+ss1345+ss12345 , "\n")
	cat(" dispersal:", ss2+ss12+ss23+ss24+ss123+ss124+ss234+ss1234+ss25+ss125+ss235+ss245+ss1235+ss1245+ss2345+ss12345, "\n")
	cat(" n:", ss3+ss13+ss23+ss34+ss123+ss134+ss234+ss1234+ss35+ss135+ss235+ss345+ss1235+ss1345+ss2345+ss12345, "\n")
	cat(" design:", ss4+ss14+ss24+ss34+ss124+ss134+ss234+ss1234+ss45+ss145+ss245+ss345+ss1245+ss1345+ss2345+ss12345, "\n")
	cat(" technique:", ss5+ss15+ss25+ss35+ss45+ss125+ss135+ss235+ss145+ss245+ss345+ss1235+ss1245+ss1345+ss2345+ss12345, "\n")

	if (!is.null(tex)) { # export the latex for the table
		sink(tex)

		cat("\\begin{tabular}{l  l  r  r  r  r r}  \n")
		cat("\\hline \n")
		cat("Error level & Factor & Df &  Sum Sq & Mean Sq & F-value & $\\log_{10}(p)$ \\\\ \n")
		cat("\\hline \n")
		cat("Species", "&", as.character(AOV.Species[1, 1]), paste(paste("& $", c(as.matrix(AOV.Species[1, 2:4]), c(" ", " ")), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("\\hline \n")
		cat("\\multirow{2}{*}{Simulation in species}", "&", as.character(AOV.Simulation[1, 1]), paste(paste("& $", c(as.matrix(AOV.Simulation[1, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Simulation[2, 1]), paste(paste("& $", c(as.matrix(AOV.Simulation[2, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Simulation[3, 1]), paste(paste("& $", c(as.matrix(AOV.Simulation[3, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Simulation[4, 1]), paste(paste("& $", c(as.matrix(AOV.Simulation[4, 2:4]), c("", "")), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("\\hline \n")
		cat("\\multirow{5}{*}{Sampling in simulation}", "&", as.character(AOV.Sampling[1, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[1, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Sampling[2, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[2, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Sampling[3, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[3, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Sampling[4, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[4, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Sampling[5, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[5, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Sampling[6, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[6, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Sampling[7, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[7, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Sampling[8, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[8, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Sampling[9, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[9, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Sampling[10, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[10, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Sampling[11, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[11, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Sampling[12, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[12, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Sampling[13, 1]), paste(paste("& $", c(as.matrix(AOV.Sampling[13, 2:4]), c("", "")), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("\\hline \n")
		cat("\\multirow{5}{*}{Within sampling}", "&", as.character(AOV.Within[1, 1]), paste(paste("& $", c(as.matrix(AOV.Within[1, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[2, 1]), paste(paste("& $", c(as.matrix(AOV.Within[2, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[3, 1]), paste(paste("& $", c(as.matrix(AOV.Within[3, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[4, 1]), paste(paste("& $", c(as.matrix(AOV.Within[4, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[5, 1]), paste(paste("& $", c(as.matrix(AOV.Within[5, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[6, 1]), paste(paste("& $", c(as.matrix(AOV.Within[6, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[7, 1]), paste(paste("& $", c(as.matrix(AOV.Within[7, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[8, 1]), paste(paste("& $", c(as.matrix(AOV.Within[8, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[9, 1]), paste(paste("& $", c(as.matrix(AOV.Within[9, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[10, 1]), paste(paste("& $", c(as.matrix(AOV.Within[10, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[11, 1]), paste(paste("& $", c(as.matrix(AOV.Within[11, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[12, 1]), paste(paste("& $", c(as.matrix(AOV.Within[12, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[13, 1]), paste(paste("& $", c(as.matrix(AOV.Within[13, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[14, 1]), paste(paste("& $", c(as.matrix(AOV.Within[14, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[15, 1]), paste(paste("& $", c(as.matrix(AOV.Within[15, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[16, 1]), paste(paste("& $", c(as.matrix(AOV.Within[16, -1])), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("&", as.character(AOV.Within[17, 1]), paste(paste("& $", c(as.matrix(AOV.Within[17, 2:4]), c("", "")), sep = ""), "$", sep = ""), "\\\\", "\n")
		cat("\\hline \n")
		cat("\\end{tabular} \n")

		sink()
	}

}
