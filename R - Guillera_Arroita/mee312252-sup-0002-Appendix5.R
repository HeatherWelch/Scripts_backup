#---------------------------------------------------------------------------------------------------------
# GLM (logit link, with regularization)
# Ridge regression: alpha=0; Lasso: alpha=1; can be anything in-between
#---------------------------------------------------------------------------------------------------------
fit_glmnet <- function(name,tag="",myalpha=1, n.folds=10, prev.stratify=T, nameout="GLMnet", orthog=T) {  
  
  # load datasets
  load(paste(path.datasets, "/", name, sep = ""))
  R1 <- length(M)
  R2 <- length(M[[1]])
    
  # number of covarites depends on the factor missing (true or false)
  p<-ifelse(ident$missing == "F",5,4)
  
  # return AUC, COR and RMSE
  AUC <- matrix(NA, ncol = R1, nrow = R2)
  COR <- matrix(NA, ncol = R1, nrow = R2)
  RMSE <- matrix(NA, ncol = R1, nrow = R2)

  # get predictor names
  vars <- names(M[[1]][[1]][3:(2 + p)]) #predictor names (depends on p)
  nameit<-c(vars,paste("I(", vars, "^2", ")",sep=""))  #and with quadratic terms
  
  # orthogonalize predictors if needed (using whole dataset)
  if (orthog){ 
    load("pred_VD.Rdata")
    tmp<-orthog_preds(pred_VD); xbars<-tmp$xbars; alphas<-tmp$alphas;
  }
  
  # loop through all data sets available
  thepreds<-list()   # to save predictions
  for (k in 1:R1) {
    thepreds[[k]]<-list()  
    for (r in 1:R2) {  
      
      ## prepare training data
      A <- data.frame(pa = M[[k]][[r]]$pa, M[[k]][[r]][3:(2 + p)]) # depends on p
      y<-A$pa  # y = response
      if (orthog){  # x = predictors; either orthogonal x and x^2, or not.
          Atemp <- A[,-1]
          x <- matrix(NA, nrow=dim(Atemp)[1], ncol=2*p)
          dimnames(x)[[2]] <- nameit
          for (i in 1:p){
            x[,i] <- Atemp[,i]-xbars[i]
            x[,(i+5)] <- x[,i]^2 - alphas[i]*x[,i]
          }
      }else{
          sqr.formula <- as.formula(paste("pa~1", paste(vars, collapse = "+"), paste(paste("I(", vars, "^2", ")", sep = ""), collapse = "+"), sep = "+"))
          x <- model.matrix(sqr.formula,data=A) 
          x <- x[,-1]  #get rid of intercept column
      }
        
      ## prepare stratification for cv.glmnet (if needed)
      if (prev.stratify) {
          # identify presences and absences 
          presence.mask <- A$pa == 1
          absence.mask <- A$pa == 0
          n.pres <- sum(presence.mask)
          n.abs <- sum(absence.mask)
          # create vectors of randomised numbers and feed into presences and absences
          selector <- rep(0,n.pres+n.abs)
          selector[presence.mask]<- sample(rep(seq(1, n.folds), length = n.pres))
          selector[absence.mask] <- sample(rep(seq(1, n.folds), length = n.abs))
      } 
        
      ## fit sequence of models with cv.glmnet
      if(prev.stratify==T){
          cv.mod=cv.glmnet(x, y, family="binomial", alpha=myalpha, standardize=T, type.measure="deviance", nfolds=n.folds, foldid=selector)
      }else{
          cv.mod=cv.glmnet(x, y, family="binomial", alpha=myalpha, standardize=T, type.measure="deviance", nfolds=n.folds)
      }
      
      ## prepare the test data        
      AT <- data.frame(pa = MT[[k]][[r]]$pa, MT[[k]][[r]][3:(2 + p)]) 
      if (orthog){
          Atemp <- AT[,-1]
          data.test <- matrix(NA, nrow=dim(Atemp)[1], ncol=2*p)
          dimnames(data.test)[[2]] <- nameit
          for (i in 1:p){
              data.test[,i] <- Atemp[,i]-xbars[i]
              data.test[,(i+5)] <- data.test[,i]^2 - alphas[i]*data.test[,i]
          }
      }else{
          data.test <- model.matrix(sqr.formula,data=AT) 
          data.test <- data.test[,-1]
      }
      
      ## predict to test data    
      newpred <- predict(cv.mod, newx=data.test, s="lambda.min", type="response")  

      ## evaluate performance     
      AUC[r, k]  <- performance(prediction(newpred, labels = MT[[k]][[r]]$pa), measure = "auc")@y.values[[1]]
      COR[r, k]  <- biserial.cor(x = newpred, y = MT[[k]][[r]]$pa, use = "all.obs", level = 2)
      RMSE[r, k] <- sqrt(mean((newpred - MT[[k]][[r]]$prob)^2))
      thepreds[[k]][[r]]<-newpred
      
    }  #end for (r in 1:R2)
  }  #end for (k in 1:R1)
  
  ## gather things together to return
  ident$technique <- nameout
  name.new <- paste(ident$num, "_", ident$missing, "_", ident$SAC, "_", ident$technique, "_", ident$samplesize, "_", ident$samplingbias,tag, ".Rdata", sep = "")
  save(AUC, RMSE, COR, ident, thepreds, file = paste(path.results, "/", name.new, sep = ""))   
  return(sum(is.na(AUC)))
}

# function to orthogonalize predictors 
orthog_preds <- function(pred_VD){
  L<-as.matrix(pred_VD[,-c(1,2)])
  xbars <- apply(L,2,mean)
  tmp <- apply(L, 2, function(x) x - mean(x)) 
  alphas <- colSums(tmp^3)/colSums(tmp^2)
  return(list(xbars=xbars,alphas=alphas))
}

