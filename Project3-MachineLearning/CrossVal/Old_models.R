# Find the best lambda for the lasso method
grid2 = 10^seq(-1, -5, length = 100)
cv.logit.model.lasso= cv.glmnet(x, y, family="multinomial", 
                                lambda = grid2, alpha = 1, nfolds = 5)
plot(cv.logit.model.lasso, main = "Lasso Regression\n")
bestlambda.lasso = cv.logit.model.lasso$lambda.min

boost.interest = gbm(interest_level ~ . -listing_id -manager_id -building_id
                     -description -created -month -address_missing,
                     data = training_data,
                     distribution = "multinomial",
                     n.trees = 500,
                     interaction.depth = 10,
                     shrinkage = 0.1)

#Inspecting the relative influence.
par(mfrow = c(1, 1))
summary(boost.interest)

n.trees = seq(from = 100, to = 500, by = 100)
n.trees = 10000
#predmat = predict(boost.interest, newdata = test_data, n.trees = n.trees)
predmat = predict(boost.interest, newdata=test_data, n.trees=500, type="response")

# Now perform a Random Forest model on the data and CV
# optimize mtry for the model
control <- trainControl(method="cv", 
                        number=5, 
                        verboseIter=TRUE,
                        search="random",
                        summaryFunction=mnLogLoss,
                        classProbs=TRUE)

rf_model<-train(interest_level~ . -listing_id -created,
                data=training_data1,
                method="rf",
                trControl=control,
                allowParallel=TRUE,
                metric="logLoss",
                maximize=FALSE)

oob.err = numeric(3)
for (mtry in 1:3) {
  fit = randomForest(interest_level ~ . -listing_id -created,
                     data = training_data1,
                     mtry = mtry,
                     ntrees=100)
  oob.err[mtry] = fit$err.rate[100]
  cat("We're performing iteration", mtry, "\n")
}

plot(1:3, oob.err, pch = 16, type = "b",
     xlab = "Variables Considered at Each Split",
     ylab = "OOB Mean Squared Error",
     main = "Random Forest OOB Error Rates\nby # of Variables")

rf.train = randomForest(interest_level ~ . -listing_id -created,
                        data = training_data1,
                        mtry = 2,
                        ntrees=500)

pred <- predict(rf.train, newdata=test_data1, type='prob')

#Can visualize a variable importance plot.
importance(rf.train)
varImpPlot(rf.train)



