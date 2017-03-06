# Load packages and data
packages <- c("jsonlite", "dplyr")

setwd("~/Users/arianiherrera/Desktop/NYCDataScience/Kaggle_Project/data")
test_data <- fromJSON("/Users/arianiherrera/Desktop/NYCDataScience/Kaggle_Project/data/test.json")
train_data <- fromJSON("/Users/arianiherrera/Desktop/NYCDataScience/Kaggle_Project/data/train.json")

vars <- setdiff(names(train_data), c("photos", "features"))

test_data <- map_at(test_data, vars, unlist) %>% tibble::as_tibble(.)
train_data <- map_at(train_data, vars, unlist) %>% tibble::as_tibble(.)

# Use sentiment analysis for description variables
library(syuzhet)
library(DT)
sentiment.train <- get_nrc_sentiment(train_data$description)

# add select fields from sentiment analysis
train_data$desc.trust = sentiment.train$trust
train_data$desc.positive = sentiment.train$positive
train_data$desc.negative = sentiment.train$negative


# Naive Bayes approach to interest level
library(tm)
library(SnowballC)

train_data$interest_level = as.factor(train_data$interest_level)
train_corpus = Corpus(VectorSource(train_data$description))



high.sub = subset(train_data, interest_level == "high")
medium.sub = subset(train_data, interest_level == "medium")
low.sub = subset(train_data, interest_level == "low")

train_dtm = DocumentTermMatrix(train_corpus, control = list(
  tolower = TRUE,
  removeNumbers = TRUE,
  stopwords = function(x) { removeWords(x, stopwords()) },
  removePunctuation = TRUE,
  stemming = TRUE
))


eval_dtm_train = train_dtm[1:37014, ]
interest_train_labels = train_data[1:37014, ]$description
eval_dtm_test = train_dtm[37015:49352, ]
interest_test_labels  = train_data[37015:49352, ]$description

eval_dtm_freq_train = removeSparseTerms(eval_dtm_train, sparse = 0.999)

eval_freq_words = findFreqTerms(eval_dtm_train, 20000)

eval_dtm_freq_train = eval_dtm_train[, eval_freq_words]
eval_dtm_freq_test = eval_dtm_test[, eval_freq_words]

convert_counts = function(x) {
  x = ifelse(x > 0, "Yes", "No")
}

#Using the apply() function to convert the counts to indicators in the columns
#of both the training and the test data.
eval_train = apply(eval_dtm_freq_train, 2, convert_counts)
eval_test = apply(eval_dtm_freq_test, 2, convert_counts)

library(e1071)

#Applying the naiveBayes() classifier function to the training data.
description_classifier = naiveBayes(eval_train, interest_train_labels)

eval_test_pred = predict(description_classifier, eval_test)


## time stuff

# days left in month

train_data$created = as.Date(train_data$created)

som <- function(x) {
  as.Date(format(x, "%Y-%m-01"))
}

eom <- function(x) {
  som(som(x) + 35) - 1
}

train_data = mutate(train_data, month.end = eom(train_data$created))

train_data$date_diff <- train_data$month.end-train_data$created

train_data$date_diff <- as.numeric(train_data$date_diff)




