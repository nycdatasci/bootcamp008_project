# Load the libraries
library(dplyr)
library(tidyr)
library(tidytext)
library(randomForest)
library(tree)
library(gbm)
library(caret)

# Change into the Kaggle Dir

setwd("~/Desktop/Kaggel_2Sigma")

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
clean_test3 <- dplyr::select(clean_train2, -manager_id, -building_id, -description, -address_missing)
# Write the files out to CVS and RDS formats
write.csv(clean_train3, file="Working_Traning.csv")
saveRDS(clean_train3, file="Working_Traning.rds")

# Do something with the created variable

# Divide data into training and test
train <- sample(1:nrow(More_semi_complete), 0.8*nrow(More_semi_complete))
training_data = More_semi_complete[train, ]
test_data     = More_semi_complete[-train,]

oob.err = numeric(10)
for (mtry in 1:10) {
  fit = randomForest(interest_level ~ . -listing_id -manager_id -building_id
                                        -description -created -month,
                     data = training_data, 
                     mtry = mtry)
  oob.err[mtry] = fit$err.rate[500]
  cat("We're performing iteration", mtry, "\n")
}

plot(1:10, oob.err, pch = 16, type = "b",
     xlab = "Variables Considered at Each Split",
     ylab = "OOB Mean Squared Error",
     main = "Random Forest OOB Error Rates\nby # of Variables")

#Can visualize a variable importance plot.
importance(rf.train)
varImpPlot(rf.train)

set.seed(18)
rf.train = randomForest(interest_level ~ . -listing_id -manager_id -building_id
                                           -description -created -month,
                   data = training_data, 
                   ntrees=500,
                   mtry = 6)

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