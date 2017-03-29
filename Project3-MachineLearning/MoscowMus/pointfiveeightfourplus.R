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
library(rgeos)
library(sp)  # classes for spatial data
library(raster)  # grids, rasters
library(rasterVis)  # raster visualisation
library(maptools)
library(rgeos)
library(geosphere)
library(syuzhet)
library(DT)
seed = 1985
set.seed(seed)



train <- fromJSON("train.json")
test <- fromJSON("test.json")

# unlist every variable except `photos` and `features` and convert to tibble

#Train
vars <- setdiff(names(train), c("photos", "features"))
train <- map_at(train, vars, unlist) %>% tibble::as_tibble(.)
train_id <-train$listing_id

#Test
vars <- setdiff(names(test), c("photos", "features"))
test <- map_at(test, vars, unlist) %>% tibble::as_tibble(.)
test_id <-test$listing_id

#add feature for length of features
train$feature_count <- lengths(train$features)
test$feature_count <- lengths(test$features)
train$photo_count <- lengths(train$photos)
test$photo_count <- lengths(test$photos)

#Add fill for listings lacking any features
train[unlist(map(train$features,is_empty)),]$features = 'Nofeat'
test[unlist(map(test$features,is_empty)),]$features = 'Nofeat'


#add dummy interest level for test
test$interest_level <- 'none'


#combine train and test data
train_test <- rbind(train,test)

#features to use
feat <- c("bathrooms","bedrooms","building_id", "created","latitude", "description",
          "listing_id","longitude","manager_id", "price", "features",
          "display_address", "street_address","feature_count","photo_count", "interest_level")

train_test = train_test[,names(train_test) %in% feat]

############################
##Process Word features
word_remove = c('allowed', 'building','center', 'space','2','2br','bldg','24',
                '3br','1','ft','3','7','1br','hour','bedrooms','bedroom','true',
                'stop','size','blk','4br','4','sq','0862','1.5','373','16','3rd','block',
                'st','01','bathrooms')

#create sparse matrix for word features
word_sparse<-train_test[,names(train_test) %in% c("features","listing_id")]
train_test$features = NULL


#Create word features
word_sparse <- word_sparse %>%
  filter(map(features, is_empty) != TRUE) %>%
  tidyr::unnest(features) %>%
  unnest_tokens(word, features)

data("stop_words")

#remove stop words and other words
word_sparse = word_sparse[!(word_sparse$word %in% stop_words$word),]
word_sparse = word_sparse[!(word_sparse$word %in% word_remove),]

#get most common features and use (in this case top 150)
top_word <- as.character(as.data.frame(sort(table(word_sparse$word),decreasing = TRUE)[1:30])$Var1)
word_sparse = word_sparse[word_sparse$word %in% top_word,]
word_sparse$word = as.factor(word_sparse$word)
word_sparse<-dcast(word_sparse, listing_id ~ word,length, value.var = "word")

#merge word features back into main data frame
train_test<-merge(train_test,word_sparse, by = "listing_id", sort = FALSE,all.x=TRUE)

###############
##Non-word features

#obtain Manager/Building "skill" and convert building and manager id to integer
train_test$manager_id<-as.integer(factor(train_test$manager_id))
ManSkill <- train_test %>% group_by(manager_id) %>% summarize("ManSkill" = mean(as.numeric(as.factor(interest_level))))
train_test <- inner_join(train_test, ManSkill, by = "manager_id")


train_test$building_id<-as.integer(factor(train_test$building_id))
BuildSkill <- train_test %>% group_by(building_id) %>% summarize("BuildSkill" = mean(as.numeric(as.factor(interest_level))))
train_test <- inner_join(train_test, BuildSkill, by = "building_id")

#convert street and display address to integer
train_test$display_address<-as.integer(factor(train_test$display_address))
train_test$street_address<-as.integer(factor(train_test$street_address))


#convert date
train_test$created<-ymd_hms(train_test$created)
train_test$month<- month(train_test$created)
train_test$day<- day(train_test$created)
train_test$hour<- hour(train_test$created)
train_test$created = NULL

# Closest Subway Stations
#read CSV of subway points and select relevant columns
SubwayCSV <- read.csv("FixedSubway1.csv")
SubwayCSV <- dplyr::select(SubwayCSV, Lat, Lon, Total.Routes)
SubwayPoints <- dplyr::select(SubwayCSV, Lat, Lon)
ListingPoints <- dplyr::select(train_test, latitude, longitude, listing_id)
#transform to coordinate dataframes
SubwayLocs <- coordinates(SubwayPoints)
ListingLocs <- coordinates(ListingPoints)
#distance matrix
mat <- distm(ListingPoints[,c('longitude','latitude')], SubwayPoints[,c('Lon','Lat')], fun=distCosine)
ListingPoints$ClosestLat <- SubwayPoints$Lat[apply(mat, 1, which.min)]
ListingPoints$ClosestLon <- SubwayPoints$Lon[apply(mat, 1, which.min)]
ListingPoints$DistanceFromSubway <- apply(mat, 1, min)

#replace mistakes with mean
ListingPoints$DistanceFromSubway[ListingPoints$DistanceFromSubway > 300000] <- mean(ListingPoints$DistanceFromSubway)

IDDistances<- dplyr::select(ListingPoints, listing_id, DistanceFromSubway)
train_test <- inner_join(train_test, IDDistances, by = "listing_id")


##Length of description in words
train_test$description_len<-sapply(strsplit(train_test$description, "\\s+"), length)
train_test$description = NULL

#price to bedroom ratio
#train_test$bed_price <- train_test$price/train_test$bedrooms
#train_test[which(is.infinite(train_test$bed_price)),]$bed_price = train_test[which(is.infinite(train_test$bed_price)),]$price

#add sum of rooms and price per room
#train_test$room_sum <- train_test$bedrooms + train_test$bathrooms
#train_test$room_diff <- train_test$bedrooms - train_test$bathrooms
#train_test$room_price <- train_test$price/train_test$room_sum
#train_test$bed_ratio <- train_test$bedrooms/train_test$room_sum
#train_test[which(is.infinite(train_test$room_price)),]$room_price = train_test[which(is.infinite(train_test$room_price)),]$price



#log transform features, these features aren't normally distributed
train_test$photo_count <- log(train_test$photo_count + 1)
train_test$feature_count <- log(train_test$feature_count + 1)
train_test$price <- log(train_test$price + 1)
#train_test$room_price <- log(train_test$room_price + 1)
#train_test$bed_price <- log(train_test$bed_price + 1)
train_test$ManSkill <- log(train_test$ManSkill + 1)
train_test$BuildSkill <- log(train_test$BuildSkill + 1)
train_test$DistanceFromSubway <- log(train_test$DistanceFromSubway + 1)

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

x_train$manager_id <- as.numeric(as.factor(x_train$manager_id))
x_val$manager_id <- as.numeric(as.factor(x_val$manager_id))
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
allpredictions = cbind(allpredictions, test$listing_id)
names(allpredictions)<-c("high","low","medium","listing_id")
allpredictions=allpredictions[,c(1,3,2,4)]
write.csv(allpredictions,paste0(Sys.Date(),"-BaseModel-20Fold-Seed",seed,".csv"),row.names = FALSE)


####################################
###Generate Feature Importance Plot
imp <- xgb.importance(names(train),model = gbdt)
xgb.ggplot.importance(imp)
