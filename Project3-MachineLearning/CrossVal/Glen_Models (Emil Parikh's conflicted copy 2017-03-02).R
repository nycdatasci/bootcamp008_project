# Load the libraries
library(dplyr)
library(tidyr)
library(tidytext)
library(randomForest)
library(tree)
library(gbm)
library(caret)
library(glmnet)
# Change into the Kaggle Dir

#### GLEN
#setwd("~/Desktop/Kaggel_2Sigma")

#### EMIL
cd("D:/Dropbox/Kaggle/")

# Source the directory with our functions

source('data_Cleaning.R')

# Import the data
imported_data <- importRentHopData('train.json','test.json')

# Clean the data
clean_train <- cleanRentHopData(imported_data$train)
clean_test <- cleanRentHopData(imported_data$test)

# Add the sentiment analysis
clean_train <- get_senti(clean_train)
clean_test <- get_senti(clean_test)

# Add the manager skills, impute for missing managers in the test data
clean_train1 <- manager_fracs_train(clean_train)
clean_test1 <- manager_fracs_test(clean_test, clean_train)

# write out the data to a CSV file
setwd("~/Dropbox/Kaggle")
write.csv(clean_train1, file="Glen_train_data.csv")
write.csv(clean_test1, file="Glen_test_data.csv")

# Read in Emil's picture data
photo_data <- readRDS('image_data.rds')

# Merge Photo data with the test and training data
clean_train2 <-  merge(x=clean_train1, y=photo_data, by = "listing_id", all.x = TRUE)
clean_test2 <-  merge(x=clean_test1, y=photo_data, by = "listing_id", all.x = TRUE)
# set the NAs to zero
clean_train2[is.na(clean_train2)] <- 0
clean_test2[is.na(clean_test2)] <- 0
# Drop manager_id, building_id, description, and address_missing
clean_train3 <- dplyr::select(clean_train2, -manager_id, -building_id, -description, -address_missing)
clean_test3 <- dplyr::select(clean_test2, -manager_id, -building_id, -description, -address_missing)

# Read in the features data
features_train <- read.csv('logitfeatures_train.csv')  %>%
                           dplyr::rename(features_high = high,features_med = medium, 
                                         features_low = low) %>%
                          dplyr::select(-interest_level)
features_test  <- read.csv('logitfeatures_test.csv') %>%
                            dplyr::rename(features_high = high,features_med = medium, 
                            features_low = low)

clean_train4 <- left_join(clean_train3, features_train, by='listing_id')
clean_test4  <- left_join(clean_test3, features_test, by='listing_id')

# Write the files out to CVS and RDS formats
write.csv(clean_train4, file="Working_Traning.csv", row.names=FALSE)
saveRDS(clean_train4, file="Working_Traning.rds")
write.csv(clean_test4, file="Working_Test.csv", row.names=FALSE)
saveRDS(clean_test4, file="Working_Test.rds")

# Read the data in
setwd("~/Dropbox/Kaggle")
data_train <- readRDS('Working_Traning.rds')
data_TEST  <- readRDS('Working_Test.rds')

data_train[,c(2,3,9)] <- lapply(data_train[,c(2,3,9)], as.factor)
data_TEST[,c(2,3,9)] <- lapply(data_TEST[,c(2,3,9)], as.factor)

# Divide data into training and test
trainIdx <- createDataPartition(data_train$interest_level, 
                                p = .8,
                                list = FALSE,
                                times = 1)
training_data <- data_train[trainIdx,]
test_data <- data_train[-trainIdx,]

# We now have 3 DFs including the training data divided in training_data & test_data
# and the TEST data in data_TEST

# Perform a logistic regression and a logistic regression with regularization
training_data1 <- training_data
training_data1[,c(5:7,10:32)] <- scale(training_data1[,c(5:7,10:32)])

test_data1 <- test_data
test_data1[,c(5:7,10:32)] <- scale(test_data1[,c(5:7,10:32)])

data_TEST1 <- scale(data_TEST[,c(5:7,10:32)])

# Perform logistic regression on the data using glmnet along with regularization and CV
x = model.matrix(interest_level ~ . -listing_id -created, training_data1)[, -1]
y = training_data1$interest_level

x_test = model.matrix(interest_level ~ . -listing_id -created, test_data1)[, -1]
y_test = test_data1$interest_level

grid1 = 10^seq(5, -2, length = 100)
# Find the best lambda for the ridge method
cv.logit.model.ridge= cv.glmnet(x, y, family="multinomial", 
                                lambda = grid1, alpha = 0, nfolds = 5)
plot(cv.logit.model.ridge, main = "Ridge Regression\n")
bestlambda.ridge = cv.logit.model.ridge$lambda.min
# Find the best lambda for the lasso method
grid2 = 10^seq(-1, -5, length = 100)
cv.logit.model.lasso= cv.glmnet(x, y, family="multinomial", 
                                lambda = grid2, alpha = 1, nfolds = 5)
plot(cv.logit.model.lasso, main = "Lasso Regression\n")
bestlambda.lasso = cv.logit.model.lasso$lambda.min

# Refit the model with the best lambda
logit.model.ridge= glmnet(x, y, family="multinomial", 
                          lambda = bestlambda.ridge, alpha = 0)

ridge_predictions = predict(logit.model.ridge, 
                            newx=x_test, type="response")
p = (ridge_predictions)[,,1]
multiloss(p, y_test)

# fitCtrl <- trainControl(method = "cv",
#                         number = 5,
#                         verboseIter = FALSE,
#                         summaryFunction=defaultSummary)
# 
# logit.ridge.fit <- train(y ~ x,
#                    data = training_data1, 
#                    method = "ridge", 
#                    verbose = TRUE,
#                    trControl = fitCtrl,
#                    metric='Accuracy',
#                    maximize=FALSE)
# logit.model.lasso= glmnet(x, y, family="multinomial", 
#                           lambda = bestlambda.lasso, alpha = 1)
#
# Now perform a Random Forest model on the data and CV
# optimize mtry for the model
control <- trainControl(method="repeatedcv", 
                        number=5, repeats=3, search="random")

rf_model<-train(interest_level~ . -listing_id -created,
                data=training_data1,
                method="rf",
                trControl=control,
                prox=TRUE,
                metric = 'Accuracy',
                allowParallel=TRUE)

# oob.err = numeric(5)
# for (mtry in 1:5) {
#   fit = randomForest(interest_level ~ . -listing_id -created,
#                      data = training_data1, 
#                      mtry = mtry,
#                      ntrees=100)
#   oob.err[mtry] = fit$err.rate[100]
#   cat("We're performing iteration", mtry, "\n")
# }
# 
# plot(1:5, oob.err, pch = 16, type = "b",
#      xlab = "Variables Considered at Each Split",
#      ylab = "OOB Mean Squared Error",
#      main = "Random Forest OOB Error Rates\nby # of Variables")

#Can visualize a variable importance plot.
importance(rf.train)
varImpPlot(rf.train)


pred = predict(rf.train, newdata=test_data, type="prob")
tab <- table("Predicted" = pred, "True" = test_data$interest_level)
err_rate <- 1 - sum(diag(tab))/sum(tab)


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

multiloss <- function(p, actual){
  sum(sapply(unique(actual), 
             function(item){sum(-log(p[actual==item,item]))})
      )/nrow(p)
}
