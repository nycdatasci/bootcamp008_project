# Load the libraries
library(dplyr)
library(tidyr)
library(tidytext)

##PARALLEL RF
library(randomForest)
library(foreach)
library(e1071)
library(doParallel)
library(ranger)
######

library(tree)
library(gbm)
library(caret)
library(glmnet)

###### XGBoost
library(xgboost)
# Change into the Kaggle Dir
#### GLEN
#setwd("~/Desktop/Kaggel_2Sigma")

#### EMIL
cd("D:/Dropbox/Kaggle/")
multiloss <- function(p, actual){
  p <- pmin(pmax(p, 1e-15), 1 - 1e-15)
  sum(sapply(unique(actual),function(item){sum(-log(p[actual==item,item]))})
  )/nrow(p)
}

# Read the data in
setwd("~/Dropbox/Kaggle")
data_train <- readRDS('Working_Traning.rds')
data_TEST  <- readRDS('Working_Test.rds')

data_train[,c(2,3,9)] <- lapply(data_train[,c(2,3,9)], as.factor)
data_train[,c(16:34)] <- lapply(data_train[,c(16:34)], as.numeric)
data_TEST[,c(2,3,8)] <- lapply(data_TEST[,c(2,3,8)], as.factor)
data_TEST[,c(16:33)] <- lapply(data_TEST[,c(16:33)], as.numeric)

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
training_data1[,c(5:7,10:14,16:34)] <- scale(training_data1[,c(5:7,10:14,16:34)])
test_data1 <- test_data
test_data1[,c(5:7,10:14,16:34)] <- scale(test_data1[,c(5:7,10:14,16:34)])
data_TEST1 <- data_TEST
data_TEST1[,c(5:7,9:13,15:31)] <- scale(data_TEST[,c(5:7,9:13,15:31)])

# Perform logistic regression on the data using glmnet along with regularization and CV
x = model.matrix(interest_level ~ . -listing_id -created, training_data1)[, -1]
y = training_data1$interest_level

x_test = model.matrix(interest_level ~ . -listing_id -created, test_data1)[, -1]
y_test = test_data1$interest_level
x_TEST <- model.matrix(~. -listing_id -created, data_TEST1)[, -1]

# Find the best lambda for the ridge method
grid1 = 10^seq(5, -2, length = 100)
cv.logit.model.ridge= cv.glmnet(x, y, family="multinomial", 
                                lambda = grid1, alpha = 0, nfolds = 5)
plot(cv.logit.model.ridge, main = "Ridge Regression\n")
bestlambda.ridge = cv.logit.model.ridge$lambda.min

# Refit the model with the best lambda
logit.model.ridge= glmnet(x, y, family="multinomial", 
                          lambda = bestlambda.ridge, alpha = 0)

ridge_TEST_pred <- predict(logit.model.ridge, x_TEST, type="response")[,,1]
ridge_TEST_pred <- cbind(listing_id=data_TEST1$listing_id, ridge_TEST_pred)
write.csv(ridge_TEST_pred, "predictions/ridge_TEST_pred.csv", row.names = FALSE)

ridge_predictions = predict(logit.model.ridge, 
                            newx=x_test, type="response")

p = (ridge_predictions)[,,1]
multiloss(p, y_test)

# USe Caret to find the optimal params for Elastic Net
fitCtrl <- trainControl(method = "cv",
                        number = 5,
                        verboseIter = TRUE,
                        summaryFunction = mnLogLoss,
                        classProbs = TRUE)

logit.fit <- train(interest_level~ . -listing_id -created,
                   data = training_data1,
                   method = "glmnet",
                   family='multinomial',
                   trControl = fitCtrl,
                   metric = "logLoss",
                   maximize = FALSE)

# Fitting alpha = 0.1, lambda = 0.0145 on full training set
logit.model.en= glmnet(x, y, family="multinomial", 
                       lambda = 0.0145, alpha = 0.1)

en_predictions = predict(logit.model.en, newx=x_test, type="response")
en_TEST_pred <- predict(logit.model.en, x_TEST, type="response")[,,1]
en_TEST_pred <- cbind(listing_id=data_TEST1$listing_id, en_TEST_pred)
write.csv(en_TEST_pred, "predictions/en_TEST_pred.csv", row.names = FALSE)

p = (en_predictions)[,,1]
multiloss(p, y_test)
#
# Run a random forest model (ranger is a faster implementation of RF)
# 
#
ranger.train.prob <- ranger(interest_level ~ . -listing_id -created,
                            data = training_data1,
                            mtry = 7,
                            num.trees=1000,
                            probability = TRUE)

ranger.predict.prob <- predict(ranger.train.prob, test_data1)

ranger.train.val <- randomForest(interest_level ~ latitude + longitude + photos_num + features_num + desc_chars + hour + dayOfMonth + dayOfWeek + positive + mean_g + sd_r + mean_b + mean_r + sd_g + sd_b + features_high + features_low + features_med,
                           data = training_data1,
                           mtry = 4,
                           n.tree=1000)

ranger.predict.val <- predict(ranger.train.val, test_data1)

mn_input <- data.frame(obs=y_test, pred=ranger.predict.val$predictions)
mn_input <- cbind(mn_input, ranger.predict.prob$predictions)

mnLogLoss(data = mn_input, lev = c("high", "low", "medium"))

ranger_TEST_pred <- predict(ranger.train.prob, data = data_TEST1)
ranger_TEST_pred <- cbind(listing_id=data_TEST1$listing_id, ranger_TEST_pred$predictions)
write.csv(ranger_TEST_pred, "predictions/ranger_TEST_pred.csv", row.names = FALSE)


#
# SVM
#
cv.svm = svm(
  interest_level ~ . -listing_id -created,
  data = training_data1,
  kernel = "linear",
  cost=0.1
)
svm.pred <- predict(cv.svm, test_data1)
table(svm.pred, y_test)

# svm.pred high  low medium
# high      0    0      0
# low     767 6856   2245
# medium    0    0      0


#
# Setup the xgBoost model for the data
#





#### UP, DOWN, SMOTE
library(DMwR)
x_train <- training_data1 %>% select(-listing_id, -created, -interest_level)
y_train <- training_data1$interest_level

x_test <- test_data1 %>% select(-listing_id, -created, -interest_level)
y_test <- test_data1$interest_level

down_train <- downSample(x = x_train, y = y_train)
table(down_train$Class)

up_train <- upSample(x = x_train, y = y_train)
table(up_train$Class)

training_data1 <- training_data1 %>% select(-interest_level, interest_level)

# smote_train <- SMOTE(interest_level ~ . -listing_id -created, data  = training_data1)                         
# table(smote_train$Class)


#### random forest
down_outside <- ranger(
  Class ~ .,
  data = down_train,
  mtry = 6,
  num.trees=500,
  probability = TRUE)

up_outside <- ranger(
  Class ~ .,
  data = up_train,
  mtry = 6,
  num.trees=500,
  probability = TRUE)


down.pred <- predict(down_outside, x_test)
up.pred <- predict(up_outside, x_test)

ranger.down.pred <- cbind(listing_id=test_data1$listing_id, down.pred$predictions)
write.csv(ranger.down.pred, "predictions/Validation_Set/ranger_pred_down.csv", row.names = FALSE)

ranger.up.pred <- cbind(listing_id=test_data1$listing_id, up.pred$predictions)
write.csv(ranger.up.pred, "predictions/Validation_Set/ranger_pred_up.csv", row.names = FALSE)



#### r