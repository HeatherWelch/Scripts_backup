###############################################################################################
### function to plot the results from the simulation
###############################################################################################

plot_results <- function(file, dest, mes = "RMSE") {

	# file is the file containing the results
	# dest is the directory to which the graphs will be saved
	# mes is the measure to use for the graphs (RMSE, AUC or COR)

	load(file)

	#---------------------------------------------------------------------------------------------------------
	# RMSE
	#---------------------------------------------------------------------------------------------------------
	if (mes == "RMSE") {
		ns <- length(Y_RMSE)/K
		for (k in 1:K) {
			Ik <- (ns * (k - 1) + 1):(ns * k)
			M.RMSE <- matrix(Y_RMSE[Ik], ncol = ns/(R1 * R2), nrow = R1 * R2)
			RMSE <- data.frame(M.RMSE)
			colnames(RMSE) <- 1:ncol(RMSE)

			pdf(file = paste(dest, "RMSE-", k, ".pdf", sep = ""), width = 6.5, height = 4)
			set.panel(2, 2)
			par(mar = c(3, 2.5, 0.9, 1), mgp = c(1.5, 0.5, 0), font.main = 1, cex = 0.66, cex.main = 1)
			col_box <- 2 * (X$method[Ik] == "GLM") + 3 * (X$method[Ik] == "GAM") + 7 * (X$method[Ik] == "RF") + 8 * (X$method[Ik] == "MaxEnt")
			col_box <- col_box[seq(from = 1, by = R1 * R2, length.out = ns/(R1 * R2))]
			boxplot(RMSE[, 1:16], main = "missing=F, dispersal=F", xlab = "Configurations", ylab = "RMSE", col = col_box[1:16], log = "y", names = 1:16, ylim = range(RMSE, na.rm = TRUE))
			boxplot(RMSE[, 17:32], main = "missing=F, dispersal=T", xlab = "Configurations", ylab = "RMSE", col = col_box[17:32], log = "y", names = 1:16, ylim = range(RMSE, na.rm = TRUE))
			boxplot(RMSE[, 33:48], main = "missing=T, dispersal=F", xlab = "Configurations", ylab = "RMSE", col = col_box[33:48], log = "y", names = 1:16, ylim = range(RMSE, na.rm = TRUE))
			boxplot(RMSE[, 49:64], main = "missing=T, dispersal=T", xlab = "Configurations", ylab = "RMSE", col = col_box[49:64], log = "y", names = 1:16, ylim = range(RMSE, na.rm = TRUE))
			dev.off()
		}
	}

	#---------------------------------------------------------------------------------------------------------
	# AUC
	#---------------------------------------------------------------------------------------------------------
	if (mes == "AUC") {
		ns <- length(Y_AUC)/K
		for (k in 1:K) {
			Ik <- (ns * (k - 1) + 1):(ns * k)
			M.AUC <- matrix(Y_AUC[Ik], ncol = ns/(R1 * R2), nrow = R1 * R2)
			AUC <- data.frame(M.AUC)
			colnames(AUC) <- 1:ncol(AUC)

			pdf(file = paste(dest, "AUC-", k, ".pdf", sep = ""), width = 6.5, height = 4)
			set.panel(2, 2)
			par(mar = c(3, 2.5, 0.9, 1), mgp = c(1.5, 0.5, 0), font.main = 1, cex = 0.66, cex.main = 1)
			col_box <- 2 * (X$method[Ik] == "GLM") + 3 * (X$method[Ik] == "GAM") + 7 * (X$method[Ik] == "RF") + 8 * (X$method[Ik] == "MaxEnt")
			col_box <- col_box[seq(from = 1, by = R1 * R2, length.out = ns/(R1 * R2))]
			boxplot(AUC[, 1:16], main = "missing=F, dispersal=F", xlab = "Configurations", ylab = "AUC", col = col_box[1:16], names = 1:16, ylim = range(AUC, na.rm = TRUE))
			boxplot(AUC[, 17:32], main = "missing=F, dispersal=T", xlab = "Configurations", ylab = "AUC", col = col_box[17:32], names = 1:16, ylim = range(AUC, na.rm = TRUE))
			boxplot(AUC[, 33:48], main = "missing=T, dispersal=F", xlab = "Configurations", ylab = "AUC", col = col_box[33:48], names = 1:16, ylim = range(AUC, na.rm = TRUE))
			boxplot(AUC[, 49:64], main = "missing=T, dispersal=T", xlab = "Configurations", ylab = "AUC", col = col_box[49:64], names = 1:16, ylim = range(AUC, na.rm = TRUE))
			dev.off()
		}
	}

	#---------------------------------------------------------------------------------------------------------
	# COR
	#---------------------------------------------------------------------------------------------------------
	if (mes == "COR") {
		ns <- length(Y_COR)/K
		for (k in 1:K) {
			Ik <- (ns * (k - 1) + 1):(ns * k)
			M.COR <- matrix(Y_COR[Ik], ncol = ns/(R1 * R2), nrow = R1 * R2)
			COR <- data.frame(M.COR)
			colnames(COR) <- 1:ncol(COR)

			pdf(file = paste(dest, "COR-", k, ".pdf", sep = ""), width = 6.5, height = 4)
			set.panel(2, 2)
			par(mar = c(3, 2.5, 0.9, 1), mgp = c(1.5, 0.5, 0), font.main = 1, cex = 0.66, cex.main = 1)
			col_box <- 2 * (X$method[Ik] == "GLM") + 3 * (X$method[Ik] == "GAM") + 7 * (X$method[Ik] == "RF") + 8 * (X$method[Ik] == "MaxEnt")
			col_box <- col_box[seq(from = 1, by = R1 * R2, length.out = ns/(R1 * R2))]
			boxplot(COR[, 1:16], main = "missing=F, dispersal=F", xlab = "Configurations", ylab = "COR", col = col_box[1:16], names = 1:16, ylim = range(COR, na.rm = TRUE))
			boxplot(COR[, 17:32], main = "missing=F, dispersal=T", xlab = "Configurations", ylab = "COR", col = col_box[17:32], names = 1:16, ylim = range(COR, na.rm = TRUE))
			boxplot(COR[, 33:48], main = "missing=T, dispersal=F", xlab = "Configurations", ylab = "COR", col = col_box[33:48], names = 1:16, ylim = range(COR, na.rm = TRUE))
			boxplot(COR[, 49:64], main = "missing=T, dispersal=T", xlab = "Configurations", ylab = "COR", col = col_box[49:64], names = 1:16, ylim = range(COR, na.rm = TRUE))
			dev.off()
		}
	}

	#---------------------------------------------------------------------------------------------------------
	# One boxplot for each configuration
	#---------------------------------------------------------------------------------------------------------
	# with means on top of each boxplot
	if (mes == "RMSE") {
		Y_mes <- Y_RMSE
	}
	if (mes == "AUC") {
		Y_mes <- Y_AUC
	}
	if (mes == "COR") {
		Y_mes <- Y_COR
	}

	pdf(file = paste(dest, "boxplot", mes, ".pdf", sep = ""), width = 6.5, height = 8)
	layout(mat = matrix(c(1, 2, 3, 4, 5, 5, 6, 6), nrow = 4, ncol = 2, byrow = TRUE))

	par(mar = c(3, 2.5, 1.5, 1), mgp = c(1.5, 0.5, 0), font.main = 1, cex = 0.66, cex.main = 1)
	boxplot(data.frame(missingT = Y_mes[X$missing == "T"], missingF = Y_mes[X$missing == "F"]), log = "y", main = "missing", names = c("TRUE", "FALSE"), ylim = range(Y_mes, na.rm = TRUE) + c(0, 0.3), ylab = mes)
	text(x = c(1, 2), y = max(Y_mes) + 0.2, labels = formatC(round(c(mean(Y_mes[X$missing == "T"]), mean(Y_mes[X$missing == "F"])), 3), 3, format = "f"))

	par(mar = c(3, 2.5, 1.5, 1), mgp = c(1.5, 0.5, 0), font.main = 1, cex = 0.66, cex.main = 1)
	boxplot(data.frame(SACT = Y_mes[X$SAC == "T"], SACF = Y_mes[X$SAC == "F"]), log = "y", main = "dispersal", names = c("TRUE", "FALSE"), ylim = range(Y_mes, na.rm = TRUE) + c(0, 0.3), ylab = mes)
	text(x = c(1, 2), y = max(Y_mes) + 0.2, labels = formatC(round(c(mean(Y_mes[X$SAC == "T"]), mean(Y_mes[X$SAC == "F"])), 3), 3, format = "f"))

	par(mar = c(3, 2.5, 1.5, 1), mgp = c(1.5, 0.5, 0), font.main = 1, cex = 0.66, cex.main = 1)
	boxplot(data.frame(n100 = Y_mes[X$n == 100], n500 = Y_mes[X$n == 500]), log = "y", main = "n", names = c("100", "500"), ylim = range(Y_mes, na.rm = TRUE) + c(0, 0.3), ylab = mes)
	text(x = c(1, 2), y = max(Y_mes) + 0.2, labels = formatC(round(c(mean(Y_mes[X$n == 100]), mean(Y_mes[X$n == 500])), 3), 3, format = "f"))

	par(mar = c(3, 2.5, 1.5, 1), mgp = c(1.5, 0.5, 0), font.main = 1, cex = 0.66, cex.main = 1)
	boxplot(data.frame(BiasT = Y_mes[X$bias == "T"], BiasF = Y_mes[X$bias == "F"]), log = "y", main = "design", names = c("Road-based", "Simple random"), ylim = range(Y_mes, na.rm = TRUE) + c(0, 0.3), ylab = mes)
	text(x = c(1, 2), y = max(Y_mes) + 0.2, labels = formatC(round(c(mean(Y_mes[X$bias == "T"]), mean(Y_mes[X$bias == "F"])), 3), 3, format = "f"))

	par(mar = c(3, 2.5, 1.5, 1), mgp = c(1.5, 0.5, 0), font.main = 1, cex = 0.66, cex.main = 1)
	boxplot(data.frame(GAM = Y_mes[X$method == "GAM" & X$n == "100"], GLM = Y_mes[X$method == "GLM" & X$n == "100"], MaxEnt = Y_mes[X$method == "MaxEnt" & X$n == "100"], RF = Y_mes[X$method == "RF" & X$n == "100"]), log = "y", main = "technique/n=100", ylim = range(Y_mes, na.rm = TRUE) + c(0, 0.3), ylab = mes)
	text(x = c(1:4), y = max(Y_mes) + 0.2, labels = formatC(round(c(mean(Y_mes[X$method == "GAM" & X$n == "100"]), mean(Y_mes[X$method == "GLM" & X$n == "100"]), mean(Y_mes[X$method == "MaxEnt" & X$n == "100"]), mean(Y_mes[X$method == "RF" & X$n == "100"])), 3), 3, format = "f"))

	par(mar = c(3, 2.5, 1.5, 1), mgp = c(1.5, 0.5, 0), font.main = 1, cex = 0.66, cex.main = 1)
	boxplot(data.frame(GAM = Y_mes[X$method == "GAM" & X$n == "500"], GLM = Y_mes[X$method == "GLM" & X$n == "500"], MaxEnt = Y_mes[X$method == "MaxEnt" & X$n == "500"], RF = Y_mes[X$method == "RF" & X$n == "500"]), log = "y", main = "technique/n=500", ylim = range(Y_mes, na.rm = TRUE) + c(0, 0.3), ylab = mes)
	text(x = c(1:4), y = max(Y_mes) + 0.2, labels = formatC(round(c(mean(Y_mes[X$method == "GAM" & X$n == "500"]), mean(Y_mes[X$method == "GLM" & X$n == "500"]), mean(Y_mes[X$method == "MaxEnt" & X$n == "500"]), mean(Y_mes[X$method == "RF" & X$n == "500"])), 3), 3, format = "f"))

	dev.off()

}