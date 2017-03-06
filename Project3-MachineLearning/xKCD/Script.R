#actual script

# Load packages and data
packages <- c("jsonlite", "dplyr", "purrr")
purrr::walk(packages, library, character.only = TRUE, warn.conflicts = FALSE)

setwd("~/Desktop/Kaggle_Apartment_Data")
test_data <- fromJSON("test.json")
train_data <- fromJSON("train.json")

vars <- setdiff(names(train_data), c("photos", "features"))


test_data <- map_at(test_data, vars, unlist) %>% tibble::as_tibble(.)
train_data <- map_at(train_data, vars, unlist) %>% tibble::as_tibble(.)

#create numfeatures and photos variables 
train_data$num_features = lapply(train_data$features, length) #the number of features per apartment
train_data$num_photos = lapply(train_data$photos, length) #num photos
test_data$num_features = lapply(test_data$features, length) #the number of features per apartment
test_data$num_photos = lapply(test_data$photos, length) #num photos

test_data$num_features = unlist(test_data$num_features)
train_data$num_features = unlist(train_data$num_features)
test_data$num_photos = unlist(test_data$num_photos)
train_data$num_photos = unlist(train_data$num_photos)

#manager_id maniuplation
temp = train_data %>% group_by(manager_id) %>% dplyr::summarise(Highcount = sum(interest_level == 'low'),
                                                  MidCount = sum(interest_level == 'medium'),
                                                  Lowcount = sum(interest_level == 'high'))

temp$total = temp$Highcount + temp$MidCount + temp$Lowcount
temp$highR = temp$Highcount/temp$total
temp$midR = temp$MidCount/temp$total
temp$lowR = temp$Lowcount/temp$total
temp = temp %>% dplyr::mutate(score = (2*highR) + midR)
temp2 = cbind('manager_id' = temp$manager_id, 'score' = temp$score)
temp2 = data.frame(temp2)
temp2$score = as.numeric(as.character(temp2$score))

train_data = left_join(train_data, temp2, by = "manager_id", copy = TRUE)
test_data = left_join(test_data, temp2, by = "manager_id", copy = TRUE)


#building id manipulation - currently not working 
temp = train_data %>% group_by(building_id) %>% dplyr::summarise(Highcount = sum(interest_level == 'low'),
                                                          MidCount = sum(interest_level == 'medium'),
                                                          Lowcount = sum(interest_level == 'high'))
temp$total = temp$Highcount + temp$MidCount + temp$Lowcount
temp$highR = temp$Highcount/temp$total
temp$midR = temp$MidCount/temp$total
temp$lowR = temp$Lowcount/temp$total
temp = temp %>% dplyr::mutate(score = (2*highR) + midR)
temp2 = cbind('building_id' = temp$building_id, 'building_score' = temp$score)
temp2 = data.frame(temp2)
temp2$building_score = as.numeric(as.character(temp2$building_score))

train_data = dplyr::left_join(train_data, temp2, by = "building_id", copy = TRUE)
test_data = left_join(test_data, temp2, by = "building_id", copy = TRUE)


#date formatting
#date formatting
train_data$created <- as.POSIXct(train_data$created, format = "%F %T")
test_data$created <- as.POSIXct(test_data$created, format = "%F %T")
train_data$month <- format(train_data$created, "%m")
test_data$month <- format(test_data$created, "%m")
#I'll get back to this



#number of descriptive words
head(train_data$description)
train_data$num_words = sapply(gregexpr("\\W+", train_data$description), length) + 1
test_data$num_words = sapply(gregexpr("\\W+", test_data$description), length) + 1

#important features words 
feat = train_data$features[train_data$interest_level == 'high']
num_unique <- data.frame(table(unlist(feat)))
num_unique[order(num_unique$Freq, decreasing = TRUE),][1:20,]
#hardwood floors, dishwasher, cats and dogs allowed, elevator, dishwasher, no fee

#collapse features
train_data$features <- lapply(train_data$features, paste, collapse = ' ')
test_data$features <- lapply(test_data$features, paste, collapse = ' ')

# #function for important features
# features <- function(data,feature){
#   test = test = lapply(data, grep, feature, fixed = TRUE) == 1
#   test[is.na(test)] <- 0
#   data$feature <- test
# }

#elevators
test = lapply(train_data$features, grep, 'Elevator', fixed = TRUE) == 1
test[is.na(test)] <- 0
train_data$Elevator <- test


test = lapply(test_data$features, grep, 'Elevator', fixed = TRUE) == 1
test[is.na(test)] <- 0
test_data$Elevator <- test


#cats allowed
test = lapply(train_data$features, grep, 'Allowed', fixed = TRUE) == 1
test[is.na(test)] <- 0
train_data$Allowed <- test


test = lapply(test_data$features, grep, 'Allowed', fixed = TRUE) == 1
test[is.na(test)] <- 0
test_data$Allowed <- test


#hardwood floors
test = lapply(train_data$features, grep, 'Hardwood Floors', fixed = TRUE) == 1
test[is.na(test)] <- 0
train_data$floors <- test


test = lapply(test_data$features, grep, 'Hardwood Floors', fixed = TRUE) == 1
test[is.na(test)] <- 0
test_data$floors <- test


#no fee
test = lapply(train_data$features, grep, 'No Fee', fixed = TRUE) == 1
test[is.na(test)] <- 0
train_data$noFee <- test


test = lapply(test_data$features, grep, 'No Fee', fixed = TRUE) == 1
test[is.na(test)] <- 0
test_data$noFee <- test

#streets and avenues and stuff
# 
# lapply(test_data$display_address, grep, 'Street', fixed = TRUE) 
# test[is.na(test)] <- 0
# train_data$ave <- test
# 
# test = lapply(test_data$street_address, grep, 'Avenue|Ave', fixed = TRUE) 
# test[is.na(test)] <- 0
# test_data$ave <- test
# 
# test = lapply(train_data$street_address, grep, 'Street', fixed = TRUE) == 1
# test[is.na(test)] <- 0
# train_data$street <- test
# 
# test = lapply(test_data$street_address, grep, 'Street|St', fixed = TRUE) == 1
# test[is.na(test)] <- 0
# test_data$ave <- test
# 
# train_data$street_type <- rep('a', nrow(train_data))
# train_data$street_type[train_data$street == 1] <- 'street'
# train_data$street_type[train_data$ave == 1] <- 'ave'
# train_data$street_type[train_data$street_type == 'a'] <- 'other'

#neighborhoods maybe?
library(ggplot2)
library(ggmap)
library(class)

# myLoc <- c(long=-73.9779, lat=40.7518)
# 
# myMap <- get_map(location = myLoc,
#                 source  = "google",
#                 maptype = "roadmap",
#                 zoom=11)
# 
# ggmap(myMap) +
#   geom_point(data=train_data, aes(x=longitude, y=latitude),
#              alpha=0.5, color="darkred", size=0.2)

m_neighborhoods <- c("Chelsea", "Washington Heights", "Harlem", 
                     "East Harlem", "Upper West Side", 
                     "Upper East Side", "Midtown West", "Midtown East",
                     "Greenwich Village",
                     "Lower East Side", "Murray Hill",
                     "Stuyvesant Town", "Upper Manhattan", "Hell's Kitchen", 
                     "East Village", "SoHo", "Financial District", "Gramercy",
                     "Garment District", "Morningside Heights", "Tribeca",
                     "Chinatown", "Times Square")

b_neighborhoods <- c("Bay Ridge", "Sunset Park", "Sheepshead Bay",
                     "Borough Park", "Midwood", "Flatbush", 
                     "Park Slope", "East New York", "Bedford-Stuyvesant", 
                     "Williamsburg", "Greenpoint", "Red Hook", "Downtown Brooklyn", 
                     "DUMBO", "Prospect Park", 
                     "Cypress Hills", "Bushwick", "Brooklyn Heights",
                     "Cobble Hill")

q_neighborhoods <- c("Astoria", "Long Island City", "Ridgewood", "Woodside", 
                     "Elmhurst", "Jackson Heights", "Corona", "Murray Hill", "Flushing", 
                     "Kew Gardens", "Jamaica", "Bayside", "Whitestone")

s_neighborhoods <- c("West New Brighton", "Mariners Harbor")


bx_neighborhoods <- c("West Bronx", "Yankee Stadium")

nj_neighborhoods <- c("Newark")

getCoords <- function(neighborhoods){  
  num_n <- length(neighborhoods)
  if (neighborhoods[1]=="Newark"){
    neighborhoods <- paste0(neighborhoods, ", NJ")
  } else {
    neighborhoods <- paste0(neighborhoods, ", NY")
  }
  
  lat <- rep(0, num_n)
  lon <- rep(0, num_n)
  
  for(i in 1:num_n){
    n <- neighborhoods[i]
    reply <- suppressMessages(geocode(n)) # You may want to expand on this to get status
    lat[i] <- reply$lat
    lon[i] <- reply$lon
  }
  return(data.frame(n=neighborhoods, lat=lat, lon=lon))
}

X <- do.call("rbind", list(getCoords(m_neighborhoods), getCoords(b_neighborhoods), 
                                                      getCoords(q_neighborhoods), getCoords(s_neighborhoods),
                                                      getCoords(bx_neighborhoods), getCoords(nj_neighborhoods)))

neighborhoods <- knn(X[, c("lat", "lon")], train_data[, c(8,10)], X$n, k = 1)
train_data$neighborhoods <- neighborhoods
neighborhoods <- knn(X[, c("lat", "lon")], test_data[, c(8,10)], X$n, k = 1)
test_data$neighborhoods <- neighborhoods

#distance from the center?
library(geosphere)
centerX <- median(train_data$latitude)
centerY <- median(train_data$longitude)
x1 <-train_data$latitude[1]
y1 <- train_data$longitude[1]

dist <- c()
for (i in 1:nrow(train_data)){
  dist[i] <- distm(c(centerY, centerX), 
        c(train_data$longitude[i],train_data$latitude[i]), fun = distHaversine)
}
train_data$dist <- dist 

#other feature manipulation
train_data$bathrooms[train_data$bathrooms > 5] <- 5
train_data$bathrooms = as.factor(train_data$bathrooms)

test_data$bathrooms[test_data$bathrooms > 5] <- 5
test_data$bathrooms = as.factor(test_data$bathrooms)

train_data$bedrooms[train_data$bedrooms > 5] <- 5
train_data$bedrooms = as.factor(train_data$bedrooms)

test_data$bedrooms[test_data$bedrooms > 5] <- 5
test_data$bedrooms = as.factor(test_data$bedrooms)

#just important features
train_data$important = train_data$Elevator + train_data$noFee + train_data$Allowed + train_data$floors
test_data$important = test_data$Elevator + test_data$noFee + test_data$Allowed + test_data$floors
train_data$important = as.factor(train_data$important)
test_data$important = as.factor(test_data$important)

#_______________________________________________________________________#
#possible area classification with svm?
library(e1071)
area <- svm(factor(interest_level) ~ latitude + longitude,
            data = train,
            kernel = 'radial',
            cost =1,
            gamma = 0.5)

#not good predictions
svm_predicted <- predict(area, test)
svm_predictions <- predict(area, test, type = 'prob', na.action = na.pass)

set.seed(0)
cv.multi = tune(svm,
                factor(interest_level) ~ latitude + longitude,
                data = train,
                kernel = "radial",
                ranges = list(cost = 10^(seq(-1, 1.5, length = 20)),
                              gamma = 10^(seq(-2, 1, length = 20))))

#sub training and test datasets 
set.seed(0)
inds = sample(1:nrow(train_data), 0.75*nrow(train_data))
train <- train_data[inds, ]
test <- train_data[-inds, ]

#_______________________________________________________________________#
#how about a random forest in good measure
library(randomForest)
rf.apartment = randomForest(factor(interest_level) ~ bathrooms + bathrooms +
                              price + num_features + latitude + longitude +
                              num_photos + score + num_words +
                              important,
                            data = train, importance = TRUE, na.action = na.exclude)

rf.predict <- predict(rf.apartment, test_data, type = 'prob', na.action = na.exclude)
rf.predictions <- predict(rf.apartment, test, type = 'class', na.action = na.pass)

#replace the na values
rf.predict[is.na(rf.predict)] <- predictions[is.na(rf.predict)]

#_______________________________________________________________________#

#test models for ensemble

library(nnet)
x <- multinom(interest_level ~ building_score, train_data, na.action = na.pass)
#multinomial model
glm(interest_level ~ price, family = 'multinomial', data = train_data, )

#_______________________________________________________________________#
#caret stuff - preferred way

library(caret)
fitControl <- trainControl(method = "cv", 
                           number = 3, 
                           verboseIter = TRUE,
                           
                           ## Estimate class probabilities 		   	  
                           classProbs = TRUE,
                           summaryFunction=mnLogLoss)
                           

set.seed(0) 
gbmGrid <- expand.grid(interaction.depth = c(2,3), 	
                       n.trees = seq(from = 100, to = 3000, by = 100),
                       shrinkage = 0.1, 
                       n.minobsinnode = 10)

gbm <- train(interest_level ~ bathrooms + bedrooms +
               price + num_features +
               num_photos + score + num_words +
               neighborhoods, data = train, method = "gbm", 
                 trControl = fitControl, 
                 verbose = TRUE,
                 # tuneLength = 1,
                 tuneGrid = gbmGrid, 
                 ## Specify which metric to optimize 
                 metric = "logLoss",
                 maximize = FALSE)

#log loss
gbm$resample$logLoss

#variable importance
gbmImp <- varImp(gbm, scale = TRUE)
plot(gbmImp, top = 30)

#a plot of log loss
trellis.par.set(caretTheme())
plot(gbm, metric = "logLoss")
#_______________________________________________________________________#
#final gbm after selecting best parammeters
gbm$bestTune


fitCtrl <- trainControl(method = 'none')
gbmFinal <- train(interest_level ~ bathrooms + bedrooms +
                    price + num_features +
                    num_photos + score + num_words +
                    neighborhoods, data = train, method = "gbm", 
             trControl = fitCtrl, 
             verbose = TRUE,
             # tuneLength = 1,
             tuneGrid = gbm$bestTune, 
             ## Specify which metric to optimize 
             metric = "logLoss",
             maximize = FALSE)


#predictions from the final gbm models
gbm.class <- predict(gbmFinal, test, type = 'raw', na.action = na.pass)
gbm.prob <- predict(gbmFinal, test, type = 'prob', na.action = na.pass)

#predictions from multinomial regression
lm.class <- predict(x, test, type = 'class', na.action = na.pass)
lm.prob <- predict(x, test_data, type = 'prob', na.action = na.pass)

#replacing NA values in the linear model
lmprob[is.na(lm.prob)] <- gbm.prob[is.na(lm.prob)]

#ensemble
predictions<-(lm_predictions + predictions*9)/10


#trying to get log loss evaluation
new <- data.frame(obs = test$interest_level, pred = gbm.class, gbm.prob)
mnLogLoss(new, c('high', 'low', 'medium'))

#_______________________________________________________________________#
#writing to a csv

testPreds <- data.frame(listing_id = test_data$listing_id, predictions[,c('high', 'medium', 'low')])
library(data.table)
fwrite(testPreds, "submission.csv")

#_______________________________________________________________________#
# Example of Stacking algorithms
# create submodels
library(caret)
library(caretEnsemble)
control <- trainControl(method="repeatedcv", number=3, repeats=3, savePredictions=TRUE, classProbs=TRUE)
algorithmList <- c('lda', 'rpart', 'glm', 'knn', 'svmRadial')
set.seed(0)
models <- caretList(interest_level~bathrooms + bedrooms +
                      price + num_features +
                      num_photos + score + num_words +
                      neighborhoods, data=train, trControl=control, methodList=algorithmList)
results <- resamples(models)
summary(results)
dotplot(results)


#______________________________________________________________________#
#fuckin around with xgboost
x_train = train[c('bathrooms', 'bedrooms', 'price', 'num_features', 'num_photos', 'score',
                'num_words', 'neighborhoods', 'building_score', 'created', 'latitude', 'longitude')]
x_val = test[c('bathrooms', 'bedrooms', 'price', 'num_features', 'num_photos', 'score',
               'num_words', 'neighborhoods', 'building_score', 'created', 'latitude', 'longitude')]

#dtest <- xgb.DMatrix(data.matrix(test_data))
dtrain <- xgb.DMatrix(data.matrix(x_train), label = as.integer(factor(train$interest_level)))
dval = xgb.DMatrix(data.matrix(x_val), label=as.integer(factor(test$interest_level)))

xgb_params = list(
  colsample_bytree= 0.7,
  subsample = 0.7,
  eta = 0.1,
  objective= 'multi:softprob',
  max_depth= 4,
  min_child_weight= 1,
  eval_metric= "mlogloss",
  num_class = 4,
  seed = 0
)


gbdt = xgb.train(params = xgb_params,
                 data = dtrain,
                 nrounds =1000,
                 watchlist = list(train = dtrain, val=dval),
                 print_every_n = 25,
                 early_stopping_rounds=50)

importance_matrix <- xgb.importance(names(x_train), model = gbdt)
print(importance_matrix)
xgb.plot.importance(importance_matrix = importance_matrix)


allpredictions =  (as.data.frame(matrix(predict(gbdt,dtest), nrow=dim(test), byrow=TRUE)))
