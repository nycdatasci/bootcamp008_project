library(rjson)
library(dplyr)
library(purrr)
library(knitr)
library(stringr)
library(VIM)
library(mice)
library(lubridate)
library(tidyr)
library(syuzhet)
library(DT)

source('code/functions.R')

# Read from JSON
train = fromJSON(file='../data/train.json')
test = fromJSON(file='../data/test.json')

# Generate
trainDF = generateDFFromJSON(train, 'train')
testDF = generateDFFromJSON(test, 'test')

#Building, manager percentiles
trainDF = bldgMgrPct(trainDF, testDF, 'train')
testDF = bldgMgrPct(trainDF, testDF, 'test')

# Photo DF
trainPhotos = generatePhotosDFFromJSON(train)
testPhotos = generatePhotosDFFromJSON(test)

# Features DF
trainFeatures = generateFeaturesDFFromJSON(train)
testFeatures = generateFeaturesDFFromJSON(test)

# saveRDS(trainDF, 'train-final.rds')
# saveRDS(trainFeatures, 'trainFeatures-final.rds')
# saveRDS(trainPhotos, 'trainPhotos-final.rds')

# saveRDS(testDF, 'test-final.rds')
# saveRDS(testFeatures, 'testFeatures-final.rds')
# saveRDS(testPhotos, 'testPhotos-final.rds')
