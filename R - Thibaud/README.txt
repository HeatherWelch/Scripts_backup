To run the simulation process, only the file main.R need be open. It must be run line by line and it will load the data and source the necessary other files. The script species_VD.R is independent of the simulation and allows estimation of the spatial autocorrelation for the real species using a spatial probit model. Finally, the data files ``FI-VD.Rdata'', ``FI-VD-extEN.Rdata'', ``FI-VD-extNE.Rdata'' and ``FI-VD-extTI.Rdata'' contain the results of the simulations presented in the paper.

- main.R: The main R script for running the simulation, plotting the results and calculating the coefficients R2.
- functionsFI.R: Some functions for the simulation.
- create_species.R: R scripts for creating the virtual species.
- species_VD.R: R scripts for calculating the spatial autocorrelation for VD species.
- fit_spatialprobit.R: Function to fit the spatial probit model.
- save_matrixresults.R: Function to save the results of the simulation (RMSE) and the corresponding configurations in a matrix.
- plot_results.R: Function to plot the results.
- anova.R: Function to do the ANOVA for the log(RMSE) values.
- factor_importance_R2.R: Function to calculate the coefficients R$^2$.
- factor_importance_R2.R: Function to calculate the log-likelihood differences.
- extern_valid.R: Fonction for validation on other landscapes.
- pred_VD.Rdata, pred_EN.Rdata, pred_NE.Rdata, pred_TI.Rdata: Data file for the real predictors in VD, EN, NE and TI.
- distroad_VD.Rdata: Data file for the sampling design (distance to the nearest-road).
- datasp_VD.Rdata: Data file for the 10 real species used in VD.
- FI-VD.Rdata, FI-VD5.Rdata, FI-VD10.Rdata, FI-VD15.Rdata, FI-VD-extEN.Rdata, FI-VD-extNE.Rdata, FI-VD-extTI.Rdata: The results for the simulations of the paper.
