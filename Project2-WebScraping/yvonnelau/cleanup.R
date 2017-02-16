##############################################
###  Data Science Bootcamp 8               ###
###  Project 2 - Web Scrapping             ###
###  Yvonne Lau  / February 9, 2017        ###
###         Skincare Products              ###
###         Recommender System             ###
##############################################

library(stringr)
library(wordcloud)
library(memoise)
library(ggplot2)
library(reshape)
library(googleVis)
library(tm)
library(SnowballC)
library(wordcloud)
library(wordcloud2)
library(RColorBrewer)
library(viridis)
library(ggstance)
library(ggthemes)
library(tidyr)
library(dplyr)

library(qdap)

setwd("~/Desktop/nyc-data-science/project-2/skincare")

#auxiliary document used to process data and test graphs

data <- read.csv("skincare.csv", stringsAsFactors = F)
data$ReviewContent <- paste0(data$ReviewText,data$ReviewTextMore)
data$Category <- gsub("More ","",data$Category)
data$Brand <- gsub(" Product Reviews","",data$Brand)
data <- select(data, -ReviewText,-ReviewTextMore)

#Manually imput missing categories
data[data$Product=="Jack Black All Day Oil-Control Lotion",]$Category ="Moisturizer"
data[data$Product=="Z. Bigatti Lip Envy",]$Category = "Lip Balm"

# Number of Reviews 
ProductNReviewsScore <- data %>% 
  group_by(Product)%>%
  summarize(ProductNReviews=n(), ProductAvgRating = mean(UserRating))

BrandNReviewsScore <- data %>% 
  group_by(Brand)%>%
  summarize(BrandNReviews=n(), BrandAvgRating = mean(UserRating, na.rm=T))%>%
  arrange(desc(BrandNReviews))

# join information to data
data <- left_join(data,ProductNReviewsScore,by="Product")
data <- left_join(data,BrandNReviewsScore, by="Brand" )

# eliminate extra characters from date
data$Date <- substr(data$Date,3,nchar(data$Date))

# With Reviews only
data_review_only <- data[!is.na(data$ProductAvgRating),]

# Save data into an RData file
save(data,file = "data.RData")
save(data_review_only,file = "data_review_only.RData")

df <- data_review_only 

# WordCLouds
subset <- filter(df, Product == 'Olay Complete All Day Moisturizer with Sunscreen Broad Spectrum SPF 15 - Normal')

#turn into a Corpus
reviewCorpus <- Corpus(VectorSource(subset$ReviewContent))

# Text Cleaning
# Convert the text to lower case
reviewCorpus <- tm_map(reviewCorpus, content_transformer(tolower))
# Remove numbers
reviewCorpus <- tm_map(reviewCorpus, removeNumbers)
# Remove english common stopwords
reviewCorpus <- tm_map(reviewCorpus, removeWords, stopwords("english"))
# Remove additional stopwords
reviewCorpus <- tm_map(reviewCorpus, removeWords, c("product")) 
# Remove punctuations
reviewCorpus <- tm_map(reviewCorpus, removePunctuation)
# Eliminate extra white spaces
reviewCorpus <- tm_map(reviewCorpus, stripWhitespace)


# Create a term freq matrix
dtm <- TermDocumentMatrix(reviewCorpus)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)

word_freq <- d
save(word_freq, file="word_freq.RData")

#Generate the word cloud
wordcloud2(d)


# Top 10 Brands
test<- unique(data[c("Brand", "BrandNReviews")]) 
test <- arrange(test,desc(BrandNReviews))
test <- test %>% top_n(10)
Column <- gvisColumnChart(test)
plot(Column)

# Top 10 products in terms of volume of reviews
test<- unique(data[c("Product", "ProductNReviews")]) 
test <- arrange(test,desc(ProductNReviews))
test <- test %>% top_n(10)
Column <- gvisColumnChart(test)
plot(Column)
# Possible interesting question? 
# Why does Olay have more reviews than all other products?

# Top 10 Categories
test <- data %>% 
  group_by(Category) %>%
  summarise(CategoryNReviews = n()) %>%
  arrange(desc(CategoryNReviews))
  
test <- test %>% top_n(10)
Column <- gvisColumnChart(test)
plot(Column)

# Distribution of Review Scores
#---------------------------------------------Recommendation system
#Possible improvements: add in a way to check misspellings

# tf-idf
# Calculate frequency of words for each product
product_words <- data %>% 
  select(Product,ReviewContent)%>%
  tidytext::unnest_tokens(word, ReviewContent) %>%
  count(Product, word, sort = TRUE) %>%
  ungroup()

# Calculate the ammount of times a word appears in a document
total_words <- product_words %>%
  group_by(Product)%>%
  summarize(total_words = sum(n))

#join total and n
product_words <- left_join(product_words, total_words)

# compute df, idf
product_words <- product_words %>%
  tidytext::bind_tf_idf(word, Product, n)

# arrange dataset by tf_idf
product_words %>%
  select(-total_words) %>%
  arrange(desc(tf_idf)) 

#Add Category Information
product_words <- left_join(product_words,unique(data_review_only[c('Category','Product')]),by='Product')
#Subset product_words to words of lenght 4 or more
product_words <- product_words[nchar(product_words$word)>3,]

# save tf_idf
save(product_words, file = "product_words.RData")

# Toy dataset with 100 products 

# Find the top 5 products closest to query with cosine similarity

# List of products to iterate over to get top 5
# For loop: compute tf-id for each document and query
# return top 5 products with highest cosine similarity

cossim <- function(x,y){
  return (sum(x*y)/sqrt(sum(x*x))/sqrt(sum(y*y)))
}

# Function to compute tf_idf 
query_tf_idf <- function(tags_list, words_data){
  n <- length(tags_list)
  word <- data.frame(word = tags_list)
  # use cbind to concatenate columns
  tf <- rep(1/n,n)
  dt <- cbind(word,tf)
  selected_bag <- unique(select(words_data,word,idf))%>%filter(word %in% dt$word)
  dt <- left_join(dt,selected_bag)
  dt$tf_idf <- dt$tf * dt$idf
  dt <- dt[order(word),]
  return(dt)
}

recommend <- function(qr,number,dt){
  # product_words with columns as 
  product_words_sub <- dt%>%
    filter(word %in% qr$word)%>%
    select(word,Product,tf_idf)
  
  # spread dataframe into column for Product
  product_tf_idf <- spread(product_words_sub , key = Product, value = tf_idf)
  
  # Assign zero to perform cosine similarity operation
  product_tf_idf[is.na(product_tf_idf)] <- 0
  product_tf_idf <- product_tf_idf[order(product_tf_idf$word),]
  
  # label a third row for the cossine similarity values
  product_tf_idf[dim(product_tf_idf )[1]+1,1] = "cossim"
  
  # perform cosine similarity with query
  for(i in 2:dim(product_tf_idf)[2]){
    product_tf_idf[dim(product_tf_idf)[1],i] = 
      cossim(product_tf_idf[1:dim(product_tf_idf)[1]-1,i],qr$tf_idf)
  }
  
  result <- t(product_tf_idf[,-1])
  colnames(result) <- product_tf_idf$word
  result<-as.data.frame(result)
  result$Product <- rownames(result)
  
  result <- result%>%
    select(Product, cossim)%>%
    arrange(desc(cossim))%>%
    top_n(number)
  
  if(dim(result)[1] > number){
    # return only five if there are products ranked equally
    return (result[1:number,])
  }else {
    return (result) 
  }
}

#----------------------OVERALL Highest tf_idf, still needs a lot of improvement and tweaking
library(ggplot2)
library(viridis)
library(ggstance)
library(ggthemes)

plot_products_words <- product_words %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word))))


ggplot(plot_products_words[1:20,], aes(tf_idf, word, fill = Product, alpha = tf_idf)) +
  geom_barh(stat = "identity") +
  labs(title = "Highest tf-idf words in Total Beauty's Skincare Reviews",
       y = NULL, x = "tf-idf") +
  theme_tufte(base_family = "Arial", base_size = 13, ticks = FALSE) +
  scale_alpha_continuous(range = c(0.6, 1), guide = FALSE) +
  scale_x_continuous(expand=c(0,0)) +
  scale_fill_viridis(end = 0.85, discrete=TRUE) +
  theme(legend.title=element_blank()) +
  theme(legend.justification=c(0,0), legend.position=c(3,0))

# Highest tf-idf by products
top_5_products <- data %>%
  group_by(Product)%>%
  summarize(n=n())%>%
  arrange(desc(n))%>%
  top_n(5)

top_5_list <- top_5_products$Product

#--------------------- Highest tf-idf words in Top 5 most reivewed products 
plot_products_words_2 <- product_words %>% 
  filter(Product %in% top_5_list)%>%
  group_by(Product) %>%
  top_n(10) %>% 
  arrange(desc(tf_idf))%>%
  mutate(word = factor(word, levels = rev(unique(word))))%>%
  ungroup

# problem with this approach: name of thebrand is mentioned far more than anything else


ggplot(plot_products_words_2, aes(tf_idf, word, fill = Product, alpha = tf_idf)) +
  geom_barh(stat = "identity", show.legend = FALSE) +
  labs(title = "Highest tf-idf words in Top 5 most reviewed products",
       y = NULL, x = "tf-idf") +
  facet_wrap(~Product, ncol = 2, scales = "free") +
  theme_tufte(base_family = "Arial", base_size = 13, ticks = FALSE) +
  scale_alpha_continuous(range = c(0.6, 1)) +
  scale_x_continuous(expand=c(0,0)) +
  scale_fill_viridis(end = 0.85, discrete=TRUE) 

#--------------------------------

ggplot(data_review_only, aes(x=UserRating))+geom_bar(aes(fill = '#ffc0cb')) + 
  ggtitle("Distribution of User Ratings")+guides(fill=FALSE)






















