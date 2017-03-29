#use naive bayes on all of the binary feature data, including descriptive words 

# Load packages and data
packages <- c("jsonlite", "dplyr", "purrr")
purrr::walk(packages, library, character.only = TRUE, warn.conflicts = FALSE)

setwd("~/Desktop/Kaggle_Apartment_Data")
test_data <- fromJSON("test.json")
train_data <- fromJSON("train.json")

vars <- setdiff(names(train_data), c("photos", "features"))


test_data <- map_at(test_data, vars, unlist) %>% tibble::as_tibble(.)
train_data <- map_at(train_data, vars, unlist) %>% tibble::as_tibble(.)


#maybe some good old date formatting
train_data$created <- as.POSIXct(train_data$created, format = "%F %T")
test_data$created <- as.POSIXct(test_data$created, format = "%F %T")

train_data$month <- format(train_data$created, "%m")
train_data$month <- as.numeric(train_data$month)
test_data$month <- format(test_data$created, "%m")
test_data$month <- as.numeric(test_data$month)

train_data$day <- as.numeric(format(train_data$created, "%d"))
test_data$day <- as.numeric(format(test_data$created, "%d"))

#price by building 
temp = train_data %>% group_by(manager_id) %>% summarise(manager_price = mean(price))
train_data = left_join(train_data, temp, by = "manager_id", copy = TRUE)

temp = test_data %>% group_by(manager_id) %>% summarise(manager_price = mean(price))
test_data = left_join(test_data, temp, by = "manager_id", copy = TRUE)


#price by bedrooms & bathrooms
train_data$room_price <- train_data$price/(train_data$bedrooms + train_data$bathrooms)
test_data$room_price <- test_data$price/(test_data$bedrooms + test_data$bathrooms)


#price by bedroom - compensate for 0s
train_data$bed_price <- train_data$price/train_data$bedrooms
test_data$bed_price <- test_data$price/test_data$bedrooms

train_data$bed_price[train_data$bed_price == 'Inf'] <- train_data$price
test_data$bed_price[test_data$bed_price == 'Inf'] <- test_data$price

#create numfeatures and photos variables 
train_data$num_features = lapply(train_data$features, length) #the number of features per apartment
train_data$num_photos = lapply(train_data$photos, length) #num photos
test_data$num_features = lapply(test_data$features, length) #the number of features per apartment
test_data$num_photos = lapply(test_data$photos, length) #num photos

test_data$num_features = unlist(test_data$num_features)
train_data$num_features = unlist(train_data$num_features)
test_data$num_photos = unlist(test_data$num_photos)
train_data$num_photos = unlist(train_data$num_photos)


#num_words
train_data$num_words = sapply(gregexpr("\\W+", train_data$description), length) + 1
test_data$num_words = sapply(gregexpr("\\W+", test_data$description), length) + 1


#Street or avenue?
train_data$Street = as.logical(unlist(lapply('Street| St| st|STREET|street', grepl, train_data$display_address))) * 1
test_data$Street = as.logical(unlist(lapply('Street| St| st|STREET|street', grepl, test_data$display_address))) * 1

train_data$Avenue = as.logical(unlist(lapply('Avenue|Ave|ave|avenue', grepl, train_data$display_address))) * 1
test_data$Avenue = as.logical(unlist(lapply('Avenue|Ave|ave|avenue', grepl, test_data$display_address))) * 1


#East or west?
train_data$East = as.logical(unlist(lapply('E | E | e ', grepl, train_data$display_address))) * 1
test_data$East = as.logical(unlist(lapply('E | E | e ', grepl, test_data$display_address))) * 1

train_data$West = as.logical(unlist(lapply('W | W | w ', grepl, train_data$display_address))) * 1
test_data$West = as.logical(unlist(lapply('W | W | w ', grepl, test_data$display_address))) * 1


#important description words 
train_data$studio <- as.logical(unlist(lapply('Studio|STUDIO|studio',grepl,train_data$description))) * 1
test_data$studio <- as.logical(unlist(lapply('Studio|STUDIO|studio',grepl,test_data$description))) * 1

train_data$new <- as.logical(unlist(lapply('NEW|new|New',grepl,train_data$description))) * 1
test_data$new <- as.logical(unlist(lapply('NEW|new|New',grepl,test_data$description))) * 1 


#distance from the center?
library(geosphere)
centerX <- 40.7589
centerY <- 73.9851
x1 <-train_data$latitude[1]
y1 <- train_data$longitude[1]

dist <- c()
for (i in 1:nrow(train_data)){
  dist[i] <- distm(c(centerY, centerX), 
                   c(train_data$longitude[i],train_data$latitude[i]), fun = distHaversine)
}
train_data$dist <- dist 

centerX <- 40.7589
centerY <- 73.9851
x1 <-test_data$latitude[1]
y1 <- test_data$longitude[1]

dist <- c()
for (i in 1:nrow(test_data)){
  dist[i] <- distm(c(centerY, centerX), 
                   c(test_data$longitude[i],test_data$latitude[i]), fun = distHaversine)
}
test_data$dist <- dist 



#neighborhoods
library(ggplot2)
library(ggmap)
library(class)

lm_neighborhoods <- c("Chelsea",  
                     "Midtown West", "Midtown East",
                     "Greenwich Village",
                     "Lower East Side", "Murray Hill",
                     "Stuyvesant Town" , "Hell's Kitchen", 
                     "East Village", "SoHo", "Financial District", "Gramercy",
                     "Garment District", "Tribeca",
                     "Chinatown", "Times Square")

um_neighborhoods <- c("Harlem", "Upper Manhattan", "Morningside Heights", "Upper West Side",
                      "East Harlem", "Upper East Side", "Washington Heights")

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

X <- do.call("rbind", list(getCoords(lm_neighborhoods), getCoords(b_neighborhoods), 
                           getCoords(q_neighborhoods), getCoords(s_neighborhoods),
                           getCoords(bx_neighborhoods), getCoords(nj_neighborhoods),
                           getCoords(um_neighborhoods)))

neighborhoods <- knn(X[, c("lat", "lon")], train_data[, c(8,10)], X$n, k = 1)
train_data$neighborhoods <- neighborhoods
neighborhoods <- knn(X[, c("lat", "lon")], test_data[, c(8,10)], X$n, k = 1)
test_data$neighborhoods <- neighborhoods


#neighborhoods maniuplation for area
append <- function(neighborhoods){
  if (neighborhoods[1]=="Newark"){
    neighborhoods <- paste0(neighborhoods, ", NJ")
  } else {
    neighborhoods <- paste0(neighborhoods, ", NY")
  }}
temp = as.character(train_data$neighborhoods)
temp[temp %in% append(um_neighborhoods)] <- 'Upper Manhattan'
temp[temp %in% append(lm_neighborhoods)] <- 'Lower Manhattan'
temp[temp %in% append(b_neighborhoods)] <- 'Brooklyn'
temp[temp %in% append(q_neighborhoods)] <- 'Queens'
temp[temp %in% append(bx_neighborhoods)] <- 'Bronx'
temp[temp %in% append(s_neighborhoods)] <- 'S'
temp[temp %in% append(nj_neighborhoods)] <- 'NJ'
train_data$area = factor(temp)

temp = as.character(test_data$neighborhoods)
temp[temp %in% append(um_neighborhoods)] <- 'Upper Manhattan'
temp[temp %in% append(lm_neighborhoods)] <- 'Lower Manhattan'
temp[temp %in% append(b_neighborhoods)] <- 'Brooklyn'
temp[temp %in% append(q_neighborhoods)] <- 'Queens'
temp[temp %in% append(bx_neighborhoods)] <- 'Bronx'
temp[temp %in% append(s_neighborhoods)] <- 'S'
temp[temp %in% append(nj_neighborhoods)] <- 'NJ'
test_data$area = factor(temp)


#bed price by neighborhood
temp = train_data %>% group_by(neighborhoods, bedrooms) %>% dplyr::summarise(mid_price = median(price))
train_data = left_join(train_data, temp, by = c('neighborhoods', 'bedrooms'))

temp = test_data %>% group_by(neighborhoods, bedrooms) %>% dplyr::summarise(mid_price = median(price))
test_data = left_join(test_data, temp, by = c('neighborhoods', 'bedrooms'))

train_data$expensive = (train_data$price > train_data$mid_price) * 1
train_data$cheap = (train_data$price <= train_data$mid_price) * 1

test_data$expensive = (test_data$price > test_data$mid_price) * 1
test_data$cheap = (test_data$price <= test_data$mid_price) * 1

#other feature manipulation
# train_data$bathrooms[train_data$bathrooms > 5] <- 5
# train_data$bathrooms = as.factor(train_data$bathrooms)
# 
# test_data$bathrooms[test_data$bathrooms > 5] <- 5
# test_data$bathrooms = as.factor(test_data$bathrooms)
# 
# train_data$bedrooms[train_data$bedrooms > 5] <- 5
# train_data$bedrooms = as.factor(train_data$bedrooms)
# 
# test_data$bedrooms[test_data$bedrooms > 5] <- 5
# test_data$bedrooms = as.factor(test_data$bedrooms)



#append David's features
best_features <- read.csv("~/Desktop/Kaggle_Apartment_Data/NYC_DS_Project_3/best_features.csv")
best_features$X <- NULL
train_data = left_join(train_data, best_features, by = 'listing_id')


best_features_test <- read.csv('~/Desktop/Kaggle_Apartment_Data/NYC_DS_Project_3/best_features_test.csv', row.names = NULL)
best_features_test$X <- NULL
test_data = left_join(test_data, best_features_test, by = 'listing_id')

# sentiment <- read.csv('~/Desktop/Kaggle_Apartment_Data/NYC_DS_Project_3/sentiment_probably_useless.csv')
# sentiment$X <- NULL
# sentiment$interest_level <- NULL
# train_data <- left_join(train_data, sentiment, by = 'listing_id')

#manager_id scoring - may fuck some shit up we'll see
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

#true test of fucking up - the building id score
# temp = train_data %>% group_by(building_id) %>% dplyr::summarise(Highcount = sum(interest_level == 'low'),
#                                                                  MidCount = sum(interest_level == 'medium'),
#                                                                  Lowcount = sum(interest_level == 'high'))
# temp$total = temp$Highcount + temp$MidCount + temp$Lowcount
# temp$highR = temp$Highcount/temp$total
# temp$midR = temp$MidCount/temp$total
# temp$lowR = temp$Lowcount/temp$total
# temp = temp %>% dplyr::mutate(score = (2*highR) + midR)
# temp2 = cbind('building_id' = temp$building_id, 'building_score' = temp$score)
# temp2 = data.frame(temp2)
# temp2$building_score = as.numeric(as.character(temp2$building_score))
# 
# train_data = dplyr::left_join(train_data, temp2, by = "building_id", copy = TRUE)
# test_data = left_join(test_data, temp2, by = "building_id", copy = TRUE)

#convert building and manager id to integer
train_data$building_id<-as.integer(factor(train_data$building_id))
test_data$building_id<-as.integer(factor(test_data$building_id))

train_data$manager_id<-as.integer(factor(train_data$manager_id))
test_data$manager_id<-as.integer(factor(test_data$manager_id))

#fuckin around with xgboost
library(xgboost)
library(caret)

train = train_data[c('bathrooms', 'bedrooms', 'price', 'num_features', 'num_photos',
                     'num_words', 'latitude', 'longitude', 'Street', 'Avenue','East', 'West', 
                     'room_price','manager_id', 'building_id', 'studio', 'day', 'month',
                     'mid_price', 'neighborhoods', 'area', 'dist', 'bed_price',
                     'expensive', 'cheap', 'score', 'manager_price',
                     'Hardwood1', 'FeeNo', 'LaundryNone', 'Elevator1', 'Cat1',
                     'Renovate1', 'Deck1', 'Dishwasher1','EatIn1','Prewar1')]

# [c('bathrooms', 'bedrooms', 'price', 'num_features', 'num_photos',
#    'num_words', 'latitude', 'longitude', 'Street', 'Avenue',
#    'Hardwood1', 'FeeNo', 'LaundryNone', 'Elevator1', 'Cat1',
#    'East', 'West', 'dist', 'neighborhoods', 'HighCeiling1',
#    'Prewar1', 'EatIn1', 'room_price', 'manager_id', 'area',
#    'Renovate1', 'Deck1', 'Dishwasher1', 'score', 'building_id',
#    'building_score', 'Positive.Affect', 'Space.Affect', 'About.Town.Affect',
#    'Character.Count', 'studio', 'day', 'month', 'new')]

train_y = train_data$interest_level
train_y[train_y == "low"] = 0
train_y[train_y == "medium"] = 1
train_y[train_y == "high"] = 2

test = test_data[c('bathrooms', 'bedrooms', 'price', 'num_features', 'num_photos',
                   'num_words', 'latitude', 'longitude', 'Street', 'Avenue','East', 'West', 
                   'room_price','manager_id', 'building_id', 'studio', 'day', 'month',
                   'mid_price', 'neighborhoods', 'area', 'dist', 'bed_price',
                   'expensive', 'cheap', 'score', 'manager_price',
                   'Hardwood1', 'FeeNo', 'LaundryNone', 'Elevator1', 'Cat1',
                   'Renovate1', 'Deck1', 'Dishwasher1','EatIn1','Prewar1')]





# cross-validate xgboost to get the accurate measure of error
xgb_params = list(
  gamma = 2,
  colsample_bytree= 0.7,
  subsample = 0.7,
  eta = 0.01,
  objective= 'multi:softprob',
  max_depth= 8,
  min_child_weight= 1,
  eval_metric= "mlogloss",
  num_class = 3,
  seed = 0
)

xgb_cv_1 = xgb.cv(params = xgb_params,
                  data = data.matrix(train),
                  label = train_y,
                  nrounds = 4000, 
                  nfold = 8,                                                   # number of folds in K-fold
                  prediction = TRUE,                                           # return the prediction using the final model 
                  showsd = TRUE,                                               # standard deviation of loss across folds
                  stratified = TRUE,                                           # sample is unbalanced; use stratified sampling
                  verbose = TRUE,
                  print_every_n = 25, 
                  early_stop_round = 50
)

#hyperparameter search of xgb using caret 
fitControl <- trainControl(method = "cv", 
                           number = 5, 
                           verboseIter = TRUE,
                           classProbs = TRUE,
                           summaryFunction=mnLogLoss,
                           returnResamp = "all", 
                           allowParallel = TRUE
                           #use search if you want to randomly search
                           #if you want to specify a grid, delete the "search = 'random'" below
                           # search = 'random'
                           )

#use a grid if you want to specify params
#wrap all the values you want to try in c() as I've done with eta below
xgb_grid_1 = expand.grid(
  nrounds = c(1000,2000),
  eta = c(0.1,0.01),
  max_depth = c(5,8),
  gamma = c(1,2),
  colsample_bytree= 0.7,
  subsample = 0.7,
  min_child_weight= c(1,5)
)

#run the actual search
#train is just all variables minus the response or label
#new_y is just the original "high" "medium" "low" as factors
#this will not run if any of your variables are characters
new_y <- train_data$interest_level
xgb_param_search <- train(x = data.matrix(train), y = factor(new_y),
                          method = "xgbTree", 
                          trControl = fitControl, 
                          verbose = TRUE, 
                          #use tune length if doing a random search to specify how many values for each cv
                          # tuneLength = 10,
                          #uncomment tune grid below if you want params specified in your tune grid
                          tuneGrid = xgb_grid_1,
                          metric = 'logLoss',
                          maximize = FALSE)



xg <- xgboost(
  params = xgb_params,
  data = data.matrix(train),
  label = train_y,
  nrounds =3500,
  print_every_n = 25,
  early_stopping_rounds=50
)

importance_matrix <- xgb.importance(names(train), model = xg)
print(importance_matrix)
xgb.plot.importance(importance_matrix = importance_matrix)



pred = predict(xg,  data.matrix(test), missing=NaN)
pred_matrix = matrix(pred, nrow = nrow(test_data), byrow = TRUE)
pred_submission = cbind(test_data$listing_id, pred_matrix)
colnames(pred_submission) = c("listing_id", "low", "medium", "high")
pred_df = as.data.frame(pred_submission)
write.csv(pred_df, "submission.csv", row.names = FALSE)
