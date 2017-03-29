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
library(h2o)

######
# Start h2o
h2o.init()

# Change into the Kaggle Dir
#### GLEN
setwd("~/Desktop/Kaggel_2Sigma")

#### EMIL
#cd("D:/Dropbox/Kaggle/")
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

data_train_ord <- data_train[,c(2,3,9,15)]
corr_ordtran <- cor(data_train_ord, method="kendall", use = "pairwise.complete.obs")
corrplot(corr_ordtran, method = "color", order="hclust")


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

# Find the best lambda for the ridge method
grid1 = 10^seq(5, -2, length = 100)
cv.logit.model.ridge= cv.glmnet(x, y, family="multinomial", 
                                lambda = grid1, alpha = 0, nfolds = 5)

plot(cv.logit.model.ridge, main = "Ridge Regression\n")
bestlambda.ridge = cv.logit.model.ridge$lambda.min

# Refit the model with the best lambda
logit.model.ridge= glmnet(x, y, family="multinomial", 
                          lambda = bestlambda.ridge, alpha = 0)

train_up <- downSample(x, y)
x_up = model.matrix(Class ~ ., train_up)[, -1]
y_up = train_up$Class
logit.model.ridge.up = glmnet(x_up, y_up, family="multinomial", 
                          lambda = bestlambda.ridge, alpha = 0)

ridge_predictions = predict(logit.model.ridge.up, 
                            newx=x_test, type="response")
ridge_pred <- cbind(ridge_predictions[,,1], listing_id=test_data1$listing_id)
write.csv(ridge_pred, 'ridge_pred_up.csv', row.names=FALSE)

train_down <- upSample(x, y)
x_down = model.matrix(Class ~ ., train_down)[, -1]
y_down = train_down$Class
logit.model.ridge.down = glmnet(x_down, y_down, family="multinomial", 
                              lambda = bestlambda.ridge, alpha = 0)

ridge_predictions = predict(logit.model.ridge.down, 
                            newx=x_test, type="response")
ridge_pred <- cbind(ridge_predictions[,,1], listing_id=test_data1$listing_id)
write.csv(ridge_pred, 'ridge_pred_down.csv', row.names=FALSE)

p = (ridge_predictions)[,,1]
multiloss(p, y_test)

ridge_predictions = predict(logit.model.ridge, 
                            newx=x_test, type="class")

table(ridge_predictions, y_test)
sum(diag(tab))/sum(tab)

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
en_pred <- cbind(en_predictions[,,1], listing_id=test_data1$listing_id)
write.csv(en_pred, 'en_pred.csv', row.names=FALSE)

p = (en_predictions)[,,1]
multiloss(p, y_test)

en_predictions = predict(logit.model.en, newx=x_test, type="class")
table(en_predictions, y_test)

#
# Run a random forest model (ranger is a faster implementation of RF)
# 
#
ranger.train <- ranger(interest_level ~ . -listing_id -created,
                       data = training_data1,
                       mtry = 7,
                       num.trees=500,
                       probability = TRUE)

ranger_preds <- predict(ranger.train, data=test_data1)
ranger_preds <- cbind(ranger_preds$predictions, listing_id=test_data1$listing_id)
write.csv(ranger_preds, 'ranger_preds.csv')

multiloss(ranger_preds$predictions, y_test)

ranger.train2 <- ranger(interest_level ~ . -listing_id -created,
                       data = training_data1,
                       mtry = 7,
                       num.trees=500)

ranger.predict.val <- predict(object = ranger.train.val, data = test_data1)
mn_input <- data.frame(obs=y_test, pred=ranger.predict.val$predictions)
mn_input <- cbind(mn_input, ranger.predict.prob$predictions)
mnLogLoss(data = mn_input, lev = c("high", "low", "medium"))

ranger_preds2 <- predict(ranger.train2, data=test_data1)
table(ranger_preds2$predictions, y_test)


rf.forVarImp = randomForest(interest_level ~ . -listing_id -created,
                            data = training_data1,
                            mtry = 7,
                            num.trees=500,
                            importance = TRUE)
varImpPlot(rf.forVarImp)

#
# Setup the GBM model for the data
#
train2 <- dplyr::select(training_data1,-created, -listing_id)
train <- as.h2o(train2, destination_frame = "train.hex")

varnames <- setdiff(colnames(train), "interest_level")
gbm1 <- h2o.gbm(x = varnames,
                y = "interest_level",
                training_frame = train,
                distribution = "multinomial",
                model_id = "gbm1",
                nfolds = 2,
                ntrees = 1500,
                learn_rate = 0.01,
                max_depth = 4,
                min_rows = 20,
                sample_rate = 0.8,
                col_sample_rate = 0.7,
                stopping_rounds = 5,
                stopping_metric = "logloss",
                stopping_tolerance = 0,
                seed=465
)

test2 <- dplyr::select(test_data1,-created, -listing_id)
test <- as.h2o(test2, destination_frame = "test.hex")
gmb_preds <- h2o.predict(object=gbm1, newdata=test, type="class")

GMP_P <- dplyr::select(as.data.frame(gmb_preds),-predict)
P_val <- dplyr::select(as.data.frame(gmb_preds),-high, -low, -medium)

gbm_preds <- cbind(GMP_P, listing_id=test_data1$listing_id)
write.csv(gbm_preds, 'gbm_preds.csv')

mn_input <- data.frame(obs=y_test, pred=P_val)
mn_input <- cbind(mn_input, GMP_P)
mnLogLoss(data = mn_input, lev = c("high", "low", "medium"))

TEST <- dplyr::select(data_TEST1, -created, -listing_id)
TEST <- as.h2o(TEST, destination_frame = "TEST.hex")
gmb_TEST_preds <- h2o.predict(object=gbm1, newdata=TEST)

GMP_P <- dplyr::select(as.data.frame(gmb_TEST_preds),-predict)
listing_ids <- dplyr::select(data_TEST1, listing_id)
gmp_predictions <- cbind(GMP_P, listing_ids)

tab<- table(as.vector(gmb_preds[,'predict']), y_test)
sum(diag(tab))/sum(tab)

write.csv(gmp_predictions, 'gmb_predictions.csv', row.names = FALSE)
# Save the model
#model_path <- h2o.saveModel(object=model, path=getwd(), force=TRUE)
# Load the model
#saved_model <- h2o.loadModel(model_path)

train_down <- downSample(x, y)
train2 <- as.h2o(train_down, destination_frame = "train2.hex")
varnames <- setdiff(colnames(train2), "Class")
gbm2 <- h2o.gbm(x = varnames,
                y = "Class",
                training_frame = train2,
                distribution = "multinomial",
                model_id = "gbm2",
                nfolds = 2,
                ntrees = 1500,
                learn_rate = 0.01,
                max_depth = 4,
                min_rows = 20,
                sample_rate = 0.8,
                col_sample_rate = 0.7,
                stopping_rounds = 5,
                stopping_metric = "logloss",
                stopping_tolerance = 0,
                seed=465
)

test2 <- dplyr::select(test_data1,-created, -listing_id)
test <- as.h2o(test2, destination_frame = "test.hex")
gmb_preds2 <- h2o.predict(object=gbm2, newdata=test, type="class")
tab <- table(as.vector(gmb_preds2[,'predict']), y_test)
sum(diag(tab))/sum(tab)

train_up <- upSample(x, y)
train3 <- as.h2o(train_up, destination_frame = "train3.hex")
varnames <- setdiff(colnames(train3), "Class")
gbm3 <- h2o.gbm(x = varnames,
                y = "Class",
                training_frame = train3,
                distribution = "multinomial",
                model_id = "gbm3",
                nfolds = 2,
                ntrees = 1500,
                learn_rate = 0.01,
                max_depth = 4,
                min_rows = 20,
                sample_rate = 0.8,
                col_sample_rate = 0.7,
                stopping_rounds = 5,
                stopping_metric = "logloss",
                stopping_tolerance = 0,
                seed=465
)

test3 <- dplyr::select(test_data1,-created, -listing_id)
test <- as.h2o(test3, destination_frame = "test.hex")
gmb_preds2 <- h2o.predict(object=gbm3, newdata=test, type="class")
tab <- table(as.vector(gmb_preds2[,'predict']), y_test)
tab
sum(diag(tab))/sum(tab)

