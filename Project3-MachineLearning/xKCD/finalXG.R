#########################
##Load Data
# Load packages and data
library(lubridate)
library(dplyr)
library(jsonlite)
library(caret)
library(purrr)
library(xgboost)
library(MLmetrics)
library(tidytext)
library(reshape2)
seed = 1985
set.seed(seed)

setwd("~/Desktop/Kaggle_Apartment_Data")

train <- fromJSON("train.json")
test <- fromJSON("test.json")

pca_test <- read.csv("~/Desktop/Kaggle_Apartment_Data/NYC_DS_Project_3/pca_30_features_test.csv")
pca_train <- read.csv("~/Desktop/Kaggle_Apartment_Data/NYC_DS_Project_3/pca_30_features_train.csv")
colnames(pca_train)[2] <- 'listing_id'
pca <- rbind(pca_test, pca_train)
pca$X <- NULL
# unlist every variable except `photos` and `features` and convert to tibble

#Train
vars <- setdiff(names(train), c("photos", "features"))
train <- map_at(train, vars, unlist) %>% tibble::as_tibble(.)
train_id <-train$listing_id

#Test
vars <- setdiff(names(test), c("photos", "features"))
test <- map_at(test, vars, unlist) %>% tibble::as_tibble(.)
test_id <-test$listing_id

#create numfeatures and photos variables 
train$num_features = lapply(train$features, length)
train$num_photos = lapply(train$photos, length) 
test$num_features = lapply(test$features, length) 
test$num_photos = lapply(test$photos, length) 

test$num_features = unlist(test$num_features)
train$num_features = unlist(train$num_features)
test$num_photos = unlist(test$num_photos)
train$num_photos = unlist(train$num_photos)

#Add fill for listings lacking any features
train[unlist(map(train$features,is_empty)),]$features = 'Nofeat'
test[unlist(map(test$features,is_empty)),]$features = 'Nofeat'


#add dummy interest level for test
test$interest_level <- 'none'


#combine train and test data
train_test <- rbind(train,test)

#features to use
feat <- c("bathrooms","bedrooms","building_id", "created", "description",
          "listing_id","manager_id", "price", "features", "latitude","longitude",
          "display_address", "street_address","num_photos","num_features", "interest_level")

train_test = train_test[,names(train_test) %in% feat]

############################
##Process Word features

##Length of description in words
train_test$num_words = sapply(gregexpr("\\W+", train_test$description), length) + 1



library(syuzhet)
library(DT)
sentiment.train <- get_nrc_sentiment(train_test$description)

# add select fields from sentiment analysis
train_test$desc.trust = sentiment.train$trust
train_test$desc.positive = sentiment.train$positive
train_test$desc.negative = sentiment.train$negative

library(tm)
library(SnowballC)

train_test$interest_level = as.factor(train_test$interest_level)
train_corpus = Corpus(VectorSource(train_test$description))

train_dtm = DocumentTermMatrix(train_corpus, control = list(
  tolower = TRUE,
  removeNumbers = TRUE,
  stopwords = function(x) { removeWords(x, stopwords()) },
  removePunctuation = TRUE,
  stemming = TRUE
))

interest_train_labels = train_test$description

eval_dtm_freq_train = removeSparseTerms(train_dtm, sparse = 0.999)
eval_freq_words = findFreqTerms(train_dtm, 45000)

eval_dtm_freq_train = train_dtm[, eval_freq_words]

convert_counts = function(x) {
  x = ifelse(x > 0, 1, 0)
}

eval_train = apply(eval_dtm_freq_train, 2, convert_counts)
train_test = cbind(train_test, eval_train)

#lpca on the sparse matrix
library(logisticPCA)

logpca_cv = cv.lpca(eval_train, ks = 2, ms = 1:10)
plot(logpca_cv)

logpca_model = logisticPCA(eval_train, k = 4, m = which.min(logpca_cv))
PC = logpca_model$PCs

train_test$features = NULL
train_test$description = NULL


###############
##Non-word features

#convert building and manager id to integer
train_test$building_id<-as.integer(factor(train_test$building_id))
train_test$manager_id<-as.integer(factor(train_test$manager_id))

#convert street and display address to integer
train_test$display_address<-as.integer(factor(train_test$display_address))
train_test$street_address<-as.integer(factor(train_test$street_address))


#convert date
train_test$created<-ymd_hms(train_test$created)
train_test$month<- month(train_test$created)
train_test$day<- day(train_test$created)
train_test$hour<- hour(train_test$created)
train_test$created = NULL


# price to bedroom ratio
train_test$bed_price <- train_test$price/train_test$bedrooms
train_test[which(is.infinite(train_test$bed_price)),]$bed_price = train_test[which(is.infinite(train_test$bed_price)),]$price

# add sum of rooms and price per room
train_test$room_sum <- train_test$bedrooms + train_test$bathrooms
train_test$room_diff <- train_test$bedrooms - train_test$bathrooms
train_test$room_price <- train_test$price/train_test$room_sum
train_test$bed_ratio <- train_test$bedrooms/train_test$room_sum
train_test[which(is.infinite(train_test$room_price)),]$room_price = train_test[which(is.infinite(train_test$room_price)),]$price



#log transform features, these features aren't normally distributed
train_test$num_photos <- log(train_test$photo_count + 1)
train_test$num_features <- log(train_test$feature_count + 1)
train_test$price <- log(train_test$price + 1)


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

neighborhoods <- knn(X[, c("lat", "lon")], train_test[, c('latitude','longitude')], X$n, k = 1)
train_test$neighborhoods <- neighborhoods

#neighborhoods maniuplation for area
append <- function(neighborhoods){
  if (neighborhoods[1]=="Newark"){
    neighborhoods <- paste0(neighborhoods, ", NJ")
  } else {
    neighborhoods <- paste0(neighborhoods, ", NY")
  }}
temp = as.character(train_test$neighborhoods)
temp[temp %in% append(um_neighborhoods)] <- 'Upper Manhattan'
temp[temp %in% append(lm_neighborhoods)] <- 'Lower Manhattan'
temp[temp %in% append(b_neighborhoods)] <- 'Brooklyn'
temp[temp %in% append(q_neighborhoods)] <- 'Queens'
temp[temp %in% append(bx_neighborhoods)] <- 'Bronx'
temp[temp %in% append(s_neighborhoods)] <- 'S'
temp[temp %in% append(nj_neighborhoods)] <- 'NJ'
train_test$area = as.numeric(as.factor(temp))

#bed price by neighborhood
temp = train_test %>% group_by(neighborhoods, bedrooms) %>% dplyr::summarise(mid_price = median(price))
train_test = left_join(train_test, temp, by = c('neighborhoods', 'bedrooms'))

train_test$neighborhoods <- as.numeric(as.factor(neighborhoods))

#above or below median price?
train_test$expensive = (train_test$price > train_test$mid_price) * 1

#add in the PCA
train_test <- left_join(train_test, pca, by = 'listing_id')

#logistic PCA
train_test = cbind(train_test, PC)

#############################
#split train test
train <- train_test[train_test$listing_id %in%train_id,]
test <- train_test[train_test$listing_id %in%test_id,]

#Convert labels to integers
train$interest_level<-as.integer(factor(train$interest_level))
y <- train$interest_level
y = y - 1
train$interest_level = NULL
test$interest_level = NULL

##################
#Parameters for XGB

xgb_params = list(
  gamma = 0.1,
  colsample_bytree= 0.7,
  subsample = 0.7,
  eta = 0.1,
  objective= 'multi:softprob',
  max_depth= 4,
  min_child_weight= 1,
  eval_metric= "mlogloss",
  num_class = 3,
  seed = seed
)


#convert xgbmatrix
dtest <- xgb.DMatrix(data.matrix(test))

#create folds
kfolds<- 10
folds<-createFolds(y, k = kfolds, list = TRUE, returnTrain = FALSE)
fold <- as.numeric(unlist(folds[1]))

x_train<-train[-fold,] #Train set
x_val<-train[fold,] #Out of fold validation set

y_train<-y[-fold]
y_val<-y[fold]


#convert to xgbmatrix
dtrain = xgb.DMatrix(as.matrix(x_train), label=y_train)
dval = xgb.DMatrix(as.matrix(x_val), label=y_val)

#perform training
gbdt = xgb.train(params = xgb_params,
                 data = dtrain,
                 nrounds =475,
                 watchlist = list(train = dtrain, val=dval),
                 print_every_n = 25,
                 early_stopping_rounds=50)

allpredictions =  (as.data.frame(matrix(predict(gbdt,dtest), nrow=dim(test), byrow=TRUE)))


######################
##Generate Submission
allpredictions = cbind (allpredictions, test$listing_id)
names(allpredictions)<-c("high","low","medium","listing_id")
allpredictions=allpredictions[,c(1,3,2,4)]
write.csv(allpredictions,paste0(Sys.Date(),"-BaseModel-20Fold-Seed",seed,".csv"),row.names = FALSE)

library(Ckmeans.1d.dp)
imp <- xgb.importance(names(train),model = gbdt)
xgb.ggplot.importance(imp)
