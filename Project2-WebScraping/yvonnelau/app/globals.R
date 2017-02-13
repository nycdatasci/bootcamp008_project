load('data/data.RData')
load('data/product_words.RData')
load('data/data_review_only.RData')
load('data/word_freq.RData')

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