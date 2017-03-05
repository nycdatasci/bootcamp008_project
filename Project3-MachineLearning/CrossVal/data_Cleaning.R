importRentHopData <- function(train_json, test_json){
  packages <- c("jsonlite", "purrr")
  purrr::walk(packages, library, character.only = TRUE, warn.conflicts = FALSE)
  
  train <- fromJSON(train_json)
  test <- fromJSON(test_json)
  
  vars_train <- setdiff(names(train), c("photos", "features"))
  vars_test <- setdiff(names(test), c("photos", "features"))
  
  train <- map_at(train, vars_train, unlist) %>% tibble::as_tibble(.)
  test <- map_at(test, vars_test, unlist) %>% tibble::as_tibble(.)
  
  return(list(
    train=train,
    test=test
  ))
}

cleanRentHopData <- function(df){
  packages <- c("dplyr", "car", "purrr", "tidytext", "tidyr", "lubridate")
  purrr::walk(packages, library, character.only = TRUE, warn.conflicts = FALSE)
  .trim <- function (x) gsub("^\\s+|\\s+$", "", x)
  
  df$description <- .trim(df$description)
  
  # removing street address, and display_address because lat long gives us that information
  df <- df %>% mutate(address_missing=(.trim(df$street_address)=="" | .trim(df$display_address)==""))
  df <- df %>% dplyr::select(-street_address, -display_address)
  
  # create months column
  df <- df %>% mutate(month = months(as.Date(created)))
  
  if("interest_level" %in% colnames(df)){
    #y to factor
    df[,c("interest_level")] <- lapply(df[,c("interest_level")], factor)
  }
  
  # add col for number of photos, features, and description
  df <- df %>% mutate(photos_num=sapply(df$photos, function(x){length(x)}))
  names(df$photos_num) <- NULL
  df <- df %>% mutate(features_num=sapply(df$features, function(x){length(x)}))
  names(df$features_num) <- NULL
  df <- df %>% mutate(desc_chars=sapply(df$description, function(x){nchar(x)}))
  names(df$desc_chars) <- NULL
  
#  reduced <- df %>% dplyr::select(-features, -photos, -description, -listing_id)
#  reduced <- df %>% dplyr::select(-features, -photos, -listing_id)
  reduced <- df %>% dplyr::select(-features, -photos)
  
  #### add hour and day columns
  datetime <- ymd_hms(reduced$created, tz = "")
  reduced$hour <- as.numeric(format(datetime, "%H"))
  reduced$dayOfMonth <- as.numeric(format(datetime, "%d"))
  reduced$dayOfWeek <- as.numeric(format(datetime, "%w"))
  
  reduced[,"dayOfWeek"] <- lapply(reduced[,"dayOfWeek"], factor)
  
  return(reduced)
}

# Sentiment analysis function
get_senti <- function(df) {
  # Remove the data columns we don't need for this analysis
  sent <- dplyr::select(df, description, listing_id)
  # Get the sentiments using tidytext and the NRC sentiment library
  sent[sent$description == '',1] = 'a'
  sent$description <- strsplit(tolower(sent$description), " ")
  sent <- unnest(sent,description, .drop=TRUE) %>%
    rename(word = description) %>%
    left_join(get_sentiments("nrc")) %>%
    group_by(listing_id, sentiment) %>%
    mutate(word, n = n()) %>%
    dplyr::select(-word)
  
  sent <- sent[!duplicated(sent),]
  
  sent <- sent %>%
    group_by(listing_id) %>%
    spread(sentiment, n, fill = 0) %>%
    dplyr::select(-12)
  
  semi_complete <- inner_join(df, sent, by="listing_id")
  
  return(semi_complete)
} 



