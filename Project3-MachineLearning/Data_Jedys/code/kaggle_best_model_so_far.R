library(dplyr)
library(xgboost)
library(tidyr)
library(lubridate)

apartments_train = readRDS('train-v17.rds')
apartments_test = readRDS('test-v17.rds')

train_outcomes = apartments_train$interest_level

#create training outcome matrix
apartments_train$value <- 1
train_outcomes_real <- spread(apartments_train, key=interest_level, value = value)
train_outcomes_real = subset(train_outcomes_real, select = c(high, medium, low))
train_outcomes_real[is.na(train_outcomes_real)] <- 0

apartments_train$value = NULL

multiloss <- function(predicted, actual){

  predicted <- apply(predicted, c(1,2), function(x) max(min(x, 1-10^(-15)), 10^(-15)))

  score <- -sum(actual*log(predicted))/nrow(predicted)

  return(score)
}

train_outcome_dummy = ifelse(train_outcomes == 'high', 0, ifelse(train_outcomes == 'medium', 1, 2))

test_listing_id = as.character(apartments_test$listing_id)

train_n = nrow(apartments_train)
test_n = nrow(apartments_test)

#drop columns

apartments_train = subset(apartments_train, select = -c(aptID, building_id, description, display_address, listing_id, manager_id, street_address, created, created.Date, created.WDayLbl, mgrHighPct, mgrMediumPct, mgrLowPct, bldgHighPct, bldgMediumPct, bldgLowPct, interest_level))
apartments_test = subset(apartments_test, select = -c(aptID, building_id, description, display_address, listing_id, manager_id, street_address, created, created.Date, mgrHighPct, mgrMediumPct, mgrLowPct, bldgHighPct, bldgMediumPct, bldgLowPct, created.WDayLbl))

#Change all NA to 0

apartments_train[is.na(apartments_train)] <- 0
apartments_test[is.na(apartments_test)] <- 0

apartments_train_data_matrix = xgb.DMatrix(as.matrix(apartments_train), label = train_outcome_dummy)

apartments_test_data_matrix = xgb.DMatrix(as.matrix(apartments_test))


#train xgboost model, possibly stratify

params = list(
  eta = 0.01,
  gamma = 0.175,
  max_depth = 7,
  max_delta_step = 0,
  scale_pos_weight = 1,
  min_child_weight = 1,
  colsample_bytree = 0.8,
  colsample_bylevel = 1,
  subsample = 0.8,
  seed = 0,
  lambda = 1,
  alpha = 0,
  nthread = 16,
  objective = 'multi:softprob',
  eval_metric = 'mlogloss',
  num_class = 3,
  maximize = F
)

xgb_train = xgb.cv(params, apartments_train_data_matrix, nrounds = 5000, nfold = 5, early_stopping_rounds = 20)

xgb_mat = as.matrix(xgb_train)

log_loss_df = as.data.frame(xgb_mat[4])

min_log_loss = min(log_loss_df$test_mlogloss_mean)
print(min_log_loss)
min_log_loss_train = min(log_loss_df$train_mlogloss_mean)
print(min_log_loss_train)
min_log_loss_idx = which.min(log_loss_df$test_mlogloss_mean)
print(min(log_loss_df$test_mlogloss_mean))
nround = min_log_loss_idx

#train model

trained_xgb <- xgb.train(params = params, data=apartments_train_data_matrix, nrounds=1756)

imp <- xgb.importance(names(apartments_train),model = trained_xgb)
head(imp)
plot(imp$Gain)
imp

##################

#predict on training set and check log loss
train_predictions =  (as.data.frame(matrix(predict(trained_xgb, apartments_train_data_matrix), nrow=train_n, byrow=TRUE)))
names(train_predictions)<-c("high","medium","low")

multiloss(train_predictions, train_outcomes_real)

#predict on test set
test_predictions =  (as.data.frame(matrix(predict(trained_xgb, apartments_test_data_matrix), nrow=test_n, byrow=TRUE)))

######################
##Generate Submission
test_predictions = cbind(test_listing_id, test_predictions)
names(test_predictions)<-c("listing_id", "high","medium","low")
tsForSave = paste0(substr(year(now()), 3, 4), paste0(ifelse(month(now()) < 10, '0', ''), month(now())), day(now()), '-', hour(now()), minute(now()))
write.csv(test_predictions,paste0('D:/kaggle_apartments_xgboost-', tsForSave,'.csv'),row.names = FALSE)
