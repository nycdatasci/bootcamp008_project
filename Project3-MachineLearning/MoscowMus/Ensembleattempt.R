library("jsonlite")
library("dplyr")
library("purrr")
library("xgboost")
library(tree)
library(ISLR)
library(stringr)
library(caret)
library(gbm)
library(caretEnsemble)

train_data <- fromJSON("train.json")
vars <- setdiff(names(train_data), c("photos", "features"))
train_data <- map_at(train_data, vars, unlist) %>% tibble::as_tibble(.)

# Test data
test_data <- fromJSON("test.json")
vars <- setdiff(names(test_data), c("photos", "features"))
test_data <- map_at(test_data, vars, unlist) %>% tibble::as_tibble(.)

word_features = c("created", "description", "photos", "display_address", "street_address", "features", "listing_id", "longitude", "latitude")



# Remove wordy features out of the dataset
processed_train = train_data
processed_train[word_features] = NULL

processed_test = test_data
processed_test[word_features] = NULL


#New feature, price divided by rooms
processed_train$priceperroom = processed_train$price/(processed_train$bathrooms + processed_train$bedrooms)
processed_test$priceperroom = processed_test$price/(processed_test$bathrooms + processed_test$bedrooms)

#New feature, price divided by bedrooms
processed_train$priceperbroom = processed_train$price/(processed_train$bedrooms)
processed_test$priceperbroom = processed_test$price/(processed_test$bedrooms)

#New feature, price divided by bathrooms
processed_train$priceperbathroom = processed_train$price/(processed_train$bathrooms)
processed_test$priceperbathroom = processed_test$price/(processed_test$bathrooms)

#Has street






#ManSkill
ManSkilltrain <- processed_train %>% group_by(manager_id) %>% summarize("ManSkill" = mean(as.numeric(as.factor(interest_level))))
processed_train <- inner_join(processed_train, ManSkilltrain, by = "manager_id") 


processed_test <- left_join(processed_test, ManSkilltrain, by = "manager_id")

processed_train$manager_id <- NULL
processed_test$manager_id<- NULL
#BuildingID

BuildLvltrain <- processed_train %>% group_by(building_id) %>% summarize("BuildLvl" = mean(as.numeric(as.factor(interest_level))))
processed_train <- inner_join(processed_train, BuildLvltrain, by = "building_id") 
processed_test <- left_join(processed_test, BuildLvltrain, by = "building_id")



processed_train$building_id <- NULL
processed_test$building_id<- NULL


# # of photos
# processed_train$photocount <- sapply(processed_train, function(x) sum(str_count(x, "http")))
# View(processed_train)



#numeric
str(processed_train)
str(processed_test)
processed_train$bedrooms <- as.numeric(processed_train$bedrooms)
processed_train$price <- as.numeric(processed_train$price)
processed_test$bedrooms <- as.numeric(processed_test$bedrooms)
processed_test$price <- as.numeric(processed_test$price)


View(processed_train)






# Create processed X and processed Y
train_X = processed_train
train_X$interest_level = NULL
train_y = processed_train$interest_level
train_y[train_y == "low"] = 0
train_y[train_y == "medium"] = 1
train_y[train_y == "high"] = 2
test_X = processed_test

str(train_X)













set.seed(100)
pmt = proc.time()
model = xgboost(data = as.matrix(train_X), 
                label = train_y,
                eta = 0.05,
                max_depth = 10,
                nround=1000, 
                subsample = 1,
                colsample_bytree = 0.5,
                seed = 100,
                eval_metric = "mlogloss",
                objective = "multi:softprob",
                num_class = 3,
                missing = NaN,
                silent = 0)
show(proc.time() - pmt)



pred = predict(model, as.matrix(test_X), missing=NaN)
pred_matrix = matrix(pred, nrow = nrow(test_data), byrow = TRUE)
pred_submission = cbind(test_data$listing_id, pred_matrix)
colnames(pred_submission) = c("listing_id", "low", "medium", "high")
pred_df = as.data.frame(pred_submission)
write.csv(pred_df, "second_submission.csv", row.names = FALSE)

##model importance
model2 <- xgb.dump(model, with_stats = T)
model2[1:10]
names <- dimnames(data.matrix(processed_test[,-1]))[[2]]
importance_matrix <- xgb.importance(names, model = model)
xgb.plot.importance(importance_matrix[1:10,])

###Views###
View(processed_test)
View(processed_train)
View(test_data)
str(test_X)




#GBM

boost.interest = gbm(interest_level ~ ., data = processed_train,
                     distribution = "gaussian",
                     n.trees = 10000,
                     interaction.depth = 4)

