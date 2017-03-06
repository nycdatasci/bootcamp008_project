# function to create new features from price and room
priceRoomFeatures <- function(apartments){
  #fix fomatting
  apartments$price = as.numeric(as.character(apartments$price))
  apartments$bathrooms = as.numeric(as.character(apartments$bathrooms))
  apartments$bedrooms = as.numeric(as.character(apartments$bedrooms))
  apartments$latitude = as.numeric(as.character(apartments$latitude))
  apartments$longitude = as.numeric(as.character(apartments$longitude))

  ##Count of words in description
  apartments$description <- as.character(apartments$description)
  apartments$description_len<-sapply(strsplit(apartments$description, "\\s+"), length)

  #price to bedroom ratio
  apartments$bed_price <- apartments$price/apartments$bedrooms
  apartments[which(is.infinite(apartments$bed_price)),]$bed_price = apartments[which(is.infinite(apartments$bed_price)),]$price

  #add sum of rooms and price per room
  apartments$room_sum <- apartments$bedrooms + apartments$bathrooms
  apartments$room_diff <- apartments$bedrooms - apartments$bathrooms
  apartments$room_price <- apartments$price/apartments$room_sum
  apartments$bed_ratio <- apartments$bedrooms/apartments$room_sum
  apartments[which(is.infinite(apartments$room_price)),]$room_price = apartments[which(is.infinite(apartments$room_price)),]$price

  # by cluster: price, bed_price, room_price
  temp <- apartments %>%
    group_by(cluster)%>%
    summarize(avg_price = mean(price), avg_bed_price  = mean(bed_price), avg_room_price = mean(room_price))

  # join avg_cluster stats to the apt dataset
  apartments <- left_join(apartments, temp, by='cluster')

  # compute difference between listing and average of cluster
  apartments$price_diff <- apartments$price - apartments$avg_price
  apartments$bed_price_diff <- apartments$bed_price - apartments$avg_bed_price
  apartments$room_price_diff <- apartments$room_price - apartments$avg_room_price

  return(apartments)
}

# add price for clusters
# cluster_stats <- function(apartments){
#   # by cluster: price, bed_price, room_price
#   temp <- apartments %>%
#     group_by(cluster) %>%
#     summarize(avg_price = mean(price), avg_bed_price  = mean(bed_price), avg_room_price = mean(room_price))
#
#   # join avg_cluster stats to the apt dataset
#   apartments <- left_join(apartments, temp, by='cluster')
#
#   # compute difference between listing and average of cluster
#   apartments$price_diff <- apartments$price - apartments$avg_price
#   apartments$bed_price_diff <- apartments$bed_price - apartments$avg_bed_price
#   apartments$room_price_diff <- apartments$room_price - apartments$avg_room_price
#
#   return(apartments)
# }

#calculate percentile columns
bldgMgrPct = function(train, test, returnWhich) {
  train$manager_id = as.character(train$manager_id)
  test$manager_id = as.character(test$manager_id)

  train_manager_count = group_by(train, manager_id) %>% summarise(count = n())
  train_manager_count = arrange(train_manager_count, desc(count))

  #Top 1%
  top_1_limit = nrow(train_manager_count) - round(nrow(train_manager_count) * .99)
  train_manager_count['Manager_Top_1_Perc'] = 0
  train_manager_count$Manager_Top_1_Perc[1:top_1_limit] = 1

  #Top 5%
  top_5_limit = nrow(train_manager_count) - round(nrow(train_manager_count) * .95)
  train_manager_count['Manager_Top_5_Perc'] = 0
  train_manager_count$Manager_Top_5_Perc[1:top_5_limit] = 1

  #Top 10%
  top_10_limit = nrow(train_manager_count) - round(nrow(train_manager_count) * .9)
  train_manager_count['Manager_Top_10_Perc'] = 0
  train_manager_count$Manager_Top_10_Perc[1:top_10_limit] = 1

  #Top 25%
  top_25_limit = nrow(train_manager_count) - round(nrow(train_manager_count) * .75)
  train_manager_count['Manager_Top_25_Perc'] = 0
  train_manager_count$Manager_Top_25_Perc[1:top_25_limit] = 1

  #join these columns and drop count column
  train = left_join(train, select(train_manager_count, -count), on = 'manager_id')

  train$Manager_Top_1_Perc = ifelse(is.na(train$Manager_Top_1_Perc), 0, train$Manager_Top_1_Perc)
  train$Manager_Top_5_Perc = ifelse(is.na(train$Manager_Top_5_Perc), 0, train$Manager_Top_5_Perc)
  train$Manager_Top_10_Perc = ifelse(is.na(train$Manager_Top_10_Perc), 0, train$Manager_Top_10_Perc)
  train$Manager_Top_25_Perc = ifelse(is.na(train$Manager_Top_25_Perc), 0, train$Manager_Top_25_Perc)
  train$manager_id = ifelse(is.na(train$manager_id), 0, train$manager_id)

  #count building
  train_building_count = group_by(train, building_id) %>% summarise(count = n())
  train_building_count = arrange(train_building_count, desc(count))
  train_building_count = train_building_count[2:nrow(train_building_count),]

  #Percentiles for buildings

  #Top 1%
  top_1_limit = nrow(train_building_count) - round(nrow(train_building_count) * .99)
  train_building_count['Building_Top_1_Perc'] = 0
  train_building_count$Building_Top_1_Perc[1:top_1_limit] = 1

  #Top 5%
  top_5_limit = nrow(train_building_count) - round(nrow(train_building_count) * .95)
  train_building_count['Building_Top_5_Perc'] = 0
  train_building_count$Building_Top_5_Perc[1:top_5_limit] = 1

  #Top 10%
  top_10_limit = nrow(train_building_count) - round(nrow(train_building_count) * .9)
  train_building_count['Building_Top_10_Perc'] = 0
  train_building_count$Building_Top_10_Perc[1:top_10_limit] = 1

  #Top 25%
  top_25_limit = nrow(train_building_count) - round(nrow(train_building_count) * .75)
  train_building_count['Building_Top_25_Perc'] = 0
  train_building_count$Building_Top_25_Perc[1:top_25_limit] = 1

  #join these columns onto training set, drop count column

  train = left_join(train, select(train_building_count, -count), on = 'building_id')

  train$Building_Top_1_Perc = ifelse(is.na(train$Building_Top_1_Perc), 0, train$Building_Top_1_Perc)
  train$Building_Top_5_Perc = ifelse(is.na(train$Building_Top_5_Perc), 0, train$Building_Top_5_Perc)
  train$Building_Top_10_Perc = ifelse(is.na(train$Building_Top_10_Perc), 0, train$Building_Top_10_Perc)
  train$Building_Top_25_Perc = ifelse(is.na(train$Building_Top_25_Perc), 0, train$Building_Top_25_Perc)
  train$building_id = ifelse(is.na(train$building_id), 0, train$building_id)

  #join to test set
  test = left_join(test, train_building_count, on = 'building_id')

  test$Building_Top_1_Perc = ifelse(is.na(test$Building_Top_1_Perc), 0, test$Building_Top_1_Perc)
  test$Building_Top_5_Perc = ifelse(is.na(test$Building_Top_5_Perc), 0, test$Building_Top_5_Perc)
  test$Building_Top_10_Perc = ifelse(is.na(test$Building_Top_10_Perc), 0, test$Building_Top_10_Perc)
  test$Building_Top_25_Perc = ifelse(is.na(test$Building_Top_25_Perc), 0, test$Building_Top_25_Perc)

  test$building_id = ifelse(is.na(test$building_id), 0, test$building_id)
  test$building_id = ifelse(is.na(test$building_id), 0, test$building_id)

  test = left_join(test, select(train_manager_count, -count), on = 'manager_id')

  test$Manager_Top_1_Perc = ifelse(is.na(test$Manager_Top_1_Perc), 0, test$Manager_Top_1_Perc)
  test$Manager_Top_5_Perc = ifelse(is.na(test$Manager_Top_5_Perc), 0, test$Manager_Top_5_Perc)
  test$Manager_Top_10_Perc = ifelse(is.na(test$Manager_Top_10_Perc), 0, test$Manager_Top_10_Perc)
  test$Manager_Top_25_Perc = ifelse(is.na(test$Manager_Top_25_Perc), 0, test$Manager_Top_25_Perc)

  #change NA to 0 in test set
  test$manager_id = ifelse(is.na(test$manager_id), 0, test$manager_id)
  test$building_id = ifelse(is.na(test$building_id), 0, test$building_id)

  if (returnWhich == 'train') {
    return(train)
  } else if(returnWhich == 'test') {
    return(test)
  }
}

monthweeks <- function(x) {
  UseMethod("monthweeks")
}
monthweeks.Date <- function(x) {
  ceiling(as.numeric(format(x, "%d")) / 7)
}
monthweeks.POSIXlt <- function(x) {
  ceiling(as.numeric(format(x, "%d")) / 7)
}
monthweeks.character <- function(x) {
  ceiling(as.numeric(format(as.Date(x), "%d")) / 7)
}

# Main DF generator
generateDFFromJSON = function(json, type) {
  # Create data frame from list
  df = data.frame(
    aptID = names(json$bathrooms),
    #bathrooms = as.numeric(unlist(json$bathrooms)),
    bathrooms = as.numeric(unlist(json$bathrooms)),
    bedrooms = as.numeric(unlist(json$bedrooms)),
    building_id = unlist(json$building_id),
    created = as.character(unlist(json$created)),
    description = as.character(unlist(json$description)),
    display_address = as.character(unlist(json$display_address)),
    latitude = as.numeric(as.character(unlist(json$latitude))),
    longitude = as.numeric(as.character(unlist(json$longitude))),
    listing_id = as.character(unlist(json$listing_id)),
    manager_id = unlist(json$manager_id),
    price = as.numeric(unlist(json$price)),
    street_address = as.character(unlist(json$street_address))
  )

  if (type == 'train') {
    df$interest_level = unlist(json$interest_level)
    df$interest_level = factor(df$interest_level, levels(df$interest_level)[c(1, 3, 2)])
  }

  # Casting
  df$description = as.character(df$description)
  df$display_address = as.character(df$display_address)
  df$street_address = as.character(df$street_address)
  df$listing_id = as.character(df$listing_id)
  df$latitude = as.numeric(as.character(df$latitude))
  df$longitude = as.numeric(as.character(df$longitude))

  # Convert blank values in complete DF, 0 in building_id to NA
  df = as.data.frame(apply(df, 2, function(x) gsub('^[:blank:]*$', NA, trimws(x))))
  df$building_id = gsub('^[0]$', NA, df$building_id)

  # Create variables based on timestamp
  tz = 'America/New_York'
  tsFormat = '%Y-%m-%d %H:%M'

  train = df %>%
    mutate(
      created = as.POSIXct(strptime(created, tz=tz, format=tsFormat)),

      created.Day = day(created),
      created.Month = month(created),
      created.Year = year(created),

      created.Date = make_date(created.Year, created.Month, created.Day),

      created.WDay = wday(created),
      created.WDayLbl = substr(wday(created, label = T), 1, 3),  # week starts on Sun in the US!
      created.Week = week(created),

      created.Hour = hour(created),

      created.Yday = yday(created),
      created.MWeek = monthweeks(created.Date)
    )

  photos = data.frame(
    aptID = rep(names(json$photos), sapply(json$photos, length)),
    photo = tolower(unlist(json$photos))
  )

  features = data.frame(
    aptID = rep(names(json$features), sapply(json$features, length)),
    feature = tolower(unlist(json$features))
  )

  # Photo count
  df = left_join(
    df,
    photos %>% group_by(aptID) %>% summarise(photoCount = n()),
    by='aptID'
  )

  # Feature count
  df = left_join(
    df,
    features %>% group_by(aptID) %>% summarise(featureCount = n()),
    by='aptID'
  )

  df$featureCount[is.na(train$featureCount)] = 0
  df$photoCount[is.na(train$photoCount)] = 0

  #train$featureCount = ifelse(is.na(train$featureCount), 0, train$featureCount)
  #train$photoCount = ifelse(is.na(train$photoCount), 0, train$photoCount)

  #add dummy columns for different features
  features$dining_room <- NA
  features[str_detect(features$feature, 'dining room'),]$dining_room <- 1

  features$pre_war <- NA
  features[str_detect(features$feature, 'pre-war'),]$pre_war <- 1

  features$laundry_in_building <- NA
  features[str_detect(features$feature, 'laundry in building'),]$laundry_in_building <- 1

  features$dishwasher <- NA
  features[str_detect(features$feature, 'dishwasher'),]$dishwasher <- 1

  features$hardwood_floors <- NA
  features[str_detect(features$feature, 'hardwood floors'),]$hardwood_floors <- 1

  features$dogs <- NA
  features[str_detect(features$feature, 'dogs allowed'),]$dogs <- 1

  features$cats <- NA
  features[str_detect(features$feature, 'cats allowed'),]$cats <- 1

  features$doorman <- NA
  features[str_detect(features$feature, 'doorman'),]$doorman <- 1

  features$elevator <- NA
  features[str_detect(features$feature, 'elevator'),]$elevator <- 1

  features$no_fee <- NA
  features[str_detect(features$feature, 'no fee'),]$no_fee <- 1

  features$fitness_center <- NA
  features[str_detect(features$feature, 'fitness center'),]$fitness_center <- 1

  features$laundry_in_unit <- NA
  features[str_detect(features$feature, 'laundry in unit'),]$laundry_in_unit <- 1

  features$loft <- NA
  features[str_detect(features$feature, 'loft'),]$loft <- 1

  features$fireplace <- NA
  features[str_detect(features$feature, 'fireplace'),]$fireplace <- 1

  features$roof_deck <- NA
  features[str_detect(features$feature, 'roof deck'),]$roof_deck <- 1

  features$outdoor_space <- NA
  features[str_detect(features$feature, 'outdoor space'),]$outdoor_space <- 1

  features$high_speed_internet <- NA
  features[str_detect(features$feature, 'high speed internet'),]$high_speed_internet <- 1

  features$balcony <- NA
  features[str_detect(features$feature, 'balcony'),]$balcony <- 1

  features$swimming_pool <- NA
  features[str_detect(features$feature, 'swimming pool'),]$swimming_pool <- 1

  features$garden_or_patio <- NA
  features[str_detect(features$feature, 'garden/patio'),]$garden_or_patio <- 1

  features$wheelchair_access <- NA
  features[str_detect(features$feature, 'wheelchair access'),]$wheelchair_access <- 1

  features$common_outdoor_space <- NA
  features[str_detect(features$feature, 'common outdoor space'),]$common_outdoor_space <- 1

  features[is.na(features)] <- 0

  cols = colnames(features)[3:length(colnames(features))]
  new_features = aggregate(features[cols], by=features['aptID'], FUN=max)

  ncolDF = ncol(df)
  df <- left_join(df, new_features, by = 'aptID')
  df[, (ncolDF+1):ncol(df)][is.na(df[, (ncolDF+1):ncol(df)])] <- 0
  rm(new_features)


  # Description to vector summary
  if (type == 'train') {
    descVec = read.csv('../data/description_vec_training_v2.csv')
  } else if (type == 'test') {
    descVec = read.csv('../data/description_vec_test_v2.csv')
  }

  descVec$aptID = as.character(descVec$aptID)
  df = left_join(df, unique(descVec), by='aptID')
  rm(descVec)

  # load location clusters from python
  if (type == 'train') {
    cluster = read.csv(file='../data/train_location_cluster2.csv', header=T)
  } else if (type == 'test') {
    cluster = read.csv(file='../data/test_location_cluster2.csv', header=T)
  }
  cluster = select(cluster, aptID, cluster)

  # change type of id for join operation
  cluster$aptID = as.character(cluster$aptID)
  df$aptID = as.character(df$aptID)

  # join clusters
  df = left_join(df, cluster, by='aptID')
  rm(cluster)

  #create new features from price and room
  df = priceRoomFeatures(df)

  # add new cluster related variables
  #df = cluster_stats(df)

  # Sentiment analysis
  df = cbind(df, get_nrc_sentiment(df$description))

  # Photo features
  goldenRatio = 1.61803398875
  photoFeat = readRDS('../data/photo_features.rds')
  photoFeat$pxSize = photoFeat$height * photoFeat$width
  photoFeat$pxRatio = ifelse(
    (photoFeat$width / photoFeat$height) < 1,
    1 / (photoFeat$width / photoFeat$height),
    photoFeat$width / photoFeat$height
  )
  photoFeat$diffGR = abs(1.61803398875 - photoFeat$pxRatio)

  photoFeatures = group_by(photoFeat, listing_id) %>%
    summarise(
      avgR = mean(r),
      avgG = mean(g),
      avgB = mean(b),
      avgBright = mean(brightness),

      avgWidth = mean(width),
      avgHeight = mean(height),
      avgPxRatio = mean(pxRatio),
      avgPxSize = mean(pxSize),
      avgDiffGR = mean(diffGR),

      medR = median(r),
      medG = median(g),
      medB = median(b),
      medBright = median(brightness),

      medWidth = median(width),
      medHeight = median(height),
      medPxRatio = median(pxRatio),
      medPxSize = median(pxSize),
      medDiffGR = median(diffGR)
    )

  df$listing_id = as.integer(as.character(df$listing_id))
  df = left_join(df, photoFeatures, by='listing_id')

  # TFIDF on description
  # data from python script
  if (type == 'train') {
    tfidf = read.csv('../data/description_prob_train_logit_v4.csv')
  } else if (type == 'test') {
    tfidf = read.csv('../data/description_prob_test_logit_v4.csv')
  }
  tfidf$aptID = as.character(tfidf$aptID)
  df = left_join(df, tfidf, by='aptID')

  photos_cluster = read.csv(file = '../data/photos_cluster.csv', stringsAsFactors = F)
  photos_cluster = photos_cluster %>%
    group_by(listing_id, photos_cluster)%>%
    summarise(n=n())

  photos_cluster$photos_cluster <- paste0("photo_cluster_",as.character(photos_cluster$photos_cluster))

  photos_cluster = spread(photos_cluster, key = photos_cluster, value = n)
  photos_cluster[is.na(photos_cluster)] = 0
  df = left_join(df, photos_cluster, by = 'listing_id')
  rm(photos_cluster)

  return(df)
}

# Create separate photos DF
generatePhotosDFFromJSON = function(json) {
  photos = data.frame(
    aptID = rep(names(json$photos), sapply(json$photos, length)),
    photo = tolower(unlist(json$photos))
  )

  return(photos)
}

# Create separate features DF
generateFeaturesDFFromJSON = function(json) {
  features = data.frame(
    aptID = rep(names(json$features), sapply(json$features, length)),
    feature = tolower(unlist(json$features))
  )

  return(features)
}
