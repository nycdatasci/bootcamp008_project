library("jsonlite")
library("dplyr") 
library("purrr")
library("ggplot2")
library("mlogit")
library("nnet")
library("car")
# Load the data
setwd("~/Desktop/Kaggel_2Sigma")
data <- fromJSON("train.json")
# unlist every variable except photos and features and convert to tibble
vars <- setdiff(names(data), c("photos", "features"))
data <- map_at(data, vars, unlist) %>% tibble::as_tibble(.)
# trim the description
.trim <- function (x) gsub("^\\s+|\\s+$", "", x)
data$description <- .trim(data$description)

length(unique(data$features))

# Summarize count of features
feature = data.frame(feature = tolower(unlist(data$features))) %>% # convert all features to lower case
  group_by(feature) %>%
  summarise(feature_count = n()) %>%
  arrange(desc(feature_count)) %>%
  filter(feature_count >= 50)


# 
data_reduced <- mutate(data,address_missing=(.trim(data$street_address)=="" | .trim(data$display_address)==""))
data_reduced$months <- months(as.Date(data_reduced$created, "%Y-%m-%d"))
data_reduced <- dplyr::select(data_reduced, -street_address, -display_address, -building_id, -created)
data_reduced[,c("interest_level")] <- lapply(data_reduced[,c("interest_level")], factor)
data_reduced <- data_reduced %>%
                mutate(Num_photos=sapply(data_reduced$photos, function(x){length(x)})) %>%
                mutate(Num_features=sapply(data_reduced$features, function(x){length(x)})) %>%
                mutate(len_des=sapply(data_reduced$description, function(x){nchar(x)}))
names(data_reduced$Num_photos) <- NULL
names(data_reduced$Num_features) <- NULL
names(data_reduced$len_des) <- NULL

Test_data <- dplyr::select(data_reduced,-features, -photos, -description)
logit.overall = multinom(interest_level ~ ., data = Test_data)

probs_vec <- predict(logit.overall, test, type="probs")
predict(logit.overall, test, type="class")
table(Test_data$interest_level)

probs_vec <- data.frame(high=probs_vec[,"high"], medium=probs_vec[,"medium"], low=probs_vec[,"low"])
list_id <- dplyr::select(data_reduced, listing_id)
list_id <- data.frame(listing_id=data_reduced$listing_id)
fin_list <- merge(list_id, probs_vec, by=0)
fin_list <- dplyr::select(fin_list, -Row.names)
write.csv(fin_list, file='submit.csv', row.names=F)
