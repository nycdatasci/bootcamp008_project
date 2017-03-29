#library(syuzhet)
#sentiment<-sapply(listings[[5]], get_sentiment, method="afinn")
#interest<-factor(unlist(listings$interest_level), levels=c("low", "medium", "high"))
#levels(interest)<-c(1,2,3)
#interest<-as.numeric(as.character(interest))
#qd.sent<-lm(interest ~ sentiment)
#summary(qd.sent)
#bing R2: .002, nrc: .0007, syuzhet:.001, afinn: .004
#Straight-up univariate standard sentiment won't work

desc<-unlist(listings3$description)
desc2<-tolower(unlist(strsplit(desc, split=" ")))
freq<-data.frame(table(desc2))
freq2<-freq[order(freq, decreasing=T),]
colnames(freq2)[1]<-"word"

setwd("C:/Users/David/Desktop/Corpora/brown_corpus_untagged")
brown<-lapply(dir(), scan, what="character")
brown<-unlist(brown)
brown.table<-data.frame(table(brown))
brown.freq<-brown.table[order(brown.table[,2], decreasing=T),]
colnames(brown.freq)[1]<-"word"

#Keyness function
keyness<-function(test,reference){
  test.total<-sum(test)
  reference.total<-sum(reference)
  expected1<-test.total * (test + reference)/(test.total+reference.total)
  expected2<-reference.total*(test + reference)/(test.total+reference.total)
  
  return(2*((test*log(test/expected1)) + (reference * log(reference/expected2))))
}

#Construct keyness matrix and inspect for high-keyness sentiment words
library(dplyr)
desc.brown<-inner_join(freq2, brown.freq, by="word", copy=T)
desc.brown[,2:3]<-sapply(desc.brown[,2:3], as.numeric)
desc.brown2<-desc.brown %>% mutate(Keyness = keyness(desc.brown$Freq.x, desc.brown$Freq.y))
desc.brown3<-filter(desc.brown2, Freq.x>Freq.y)

wordcloud(desc.brown3$word, round(desc.brown3$Keyness), min.freq=1000)

#Sentiment: brand? great, beautiful*, amazing, gorgeous, stunning,  perfect, enjoy, best, bright, sun*ny, !, 
#fantastic, spectacular, unique, charming, nice, elegant, lovely, incredible, excellent, fabulous, classic, better, vibrant, awesome, wonderful
#finest, sleek, happy, desirable
#Size: spacious/space, full/fully, lots, tons, huge, plenty, ample, oversized, massive, grand, abundan*t, generous, soaring
#Location: real? central/center?  heart? convenient*?, easily? overlooking? historic? helpful, rare, nearby, luxur*y, exclusive, prime,

pos.sent<-c("great", "beautiful", "beautifully", "amazing", "gorgeous", "stunning", "perfect", "enjoy", "best", "bright", "sun", "sunlight", "sunny", 
            "fantastic", "spectacular", "unique", "charming", "nice", "elegant", "lovely", "incredible", "excellent", "fabulous", "classic", "better", "vibrant", "awesome", "wonderful",
            "finest", "sleek", "happy", "desirable")
space.sent<-c("spacious", "space", "full", "fully", "lots","tons", "huge", "plenty", "ample", "oversized", "massive", "grand", "abundant", "abundance", "generous", "soaring")

mat.sent<-c("luxury", "luxury", "luxurious", "center", "central", "heart", "convenient", "conveniently", "easily", "overlooking", "historic", "helpful", "rare", "nearby", "exclusive", "prime")


listings3$luxury[grepl("luxur", listings3$description)]<-1
listings3$central[grepl(" centr", listings3$description)]<-1
listings3$heart[grepl("heart", listings3$description)]<-1
listings3$convenient[grepl(" convenien", listings3$description)]<-1
listings3$easily[grepl("easily", listings3$description)]<-1
listings3$overlooking[grepl("overlooking", listings3$description)]<-1
listings3$historic[grepl("historic", listings3$description)]<-1
listings3$rare[grepl("rare", listings3$description)]<-1
listings3$nearby[grepl("nearby", listings3$description)]<-1
listings3$exclusive[grepl("exclusive", listings3$description)]<-1
listings3$prime[grepl("prime", listings3$description)]<-1

listings3$spacious[grepl(" spac", listings3$description)]<-1
listings3$full[grepl(" full", listings3$description)]<-1
listings3$lots[grepl(" lots", listings3$description)]<-1
listings3$tons[grepl("tons", listings3$description)]<-1
listings3$huge[grepl("huge", listings3$description)]<-1
listings3$plenty[grepl("plenty", listings3$description)]<-1
listings3$ample[grepl(" ample", listings3$description)]<-1
listings3$oversized[grepl("oversized", listings3$description)]<-1
listings3$massive[grepl("massive", listings3$description)]<-1
listings3$grand[grepl("grand", listings3$description)]<-1
listings3$abundant[grepl("abundan", listings3$description)]<-1
listings3$generous[grepl("generous", listings3$description)]<-1
listings3$soaring[grepl("soaring", listings3$description)]<-1

listings3$great[grepl("great", listings3$description)]<-1
listings3$beautiful[grepl("beautiful", listings3$description)]<-1
listings3$amazing[grepl("amazing", listings3$description)]<-1
listings3$gorgeous[grepl("gorgeous", listings3$description)]<-1
listings3$stunning[grepl("stunning", listings3$description)]<-1
listings3$perfect[grepl("perfect", listings3$description)]<-1
listings3$enjoy[grepl("enjoy", listings3$description)]<-1
listings3$best[grepl("best", listings3$description)]<-1
listings3$bright[grepl("bright", listings3$description)]<-1
listings3$sun[grepl(" sun", listings3$description)]<-1
listings3$fantastic[grepl("fantastic", listings3$description)]<-1
listings3$spectacular[grepl("spectacular", listings3$description)]<-1
listings3$unique[grepl("unique", listings3$description)]<-1
listings3$charming[grepl("charming", listings3$description)]<-1
listings3$nice[grepl("nice", listings3$description)]<-1
listings3$elegant[grepl("elegant", listings3$description)]<-1
listings3$lovely[grepl("lovely", listings3$description)]<-1
listings3$elegant[grepl("incredible", listings3$description)]<-1
listings3$excellent[grepl("excellent", listings3$description)]<-1
listings3$fabulous[grepl("fabulous", listings3$description)]<-1
listings3$classic[grepl("classic", listings3$description)]<-1
listings3$better[grepl("better", listings3$description)]<-1
listings3$vibrant[grepl("vibrant", listings3$description)]<-1
listings3$awesome[grepl("awesome", listings3$description)]<-1
listings3$wonderful[grepl("wonderful", listings3$description)]<-1
listings3$finest[grepl("finest", listings3$description)]<-1
listings3$sleek[grepl("sleek", listings3$description)]<-1
listings3$happy[grepl("happy", listings3$description)]<-1
listings3$desirable[grepl("desirable", listings3$description)]<-1

listings3[,14:65][is.na(listings3[,14:65])]<-0

library(e1071)
bnb.sent<-naiveBayes(y=full_list$interest_level[train], x=listings3[train,14:65])
sent.pred<-predict(bnb.feat, listings3[-train,14:65], type="raw")
MultiLogLoss(full_list$interest_level[-train], sent.pred)
#Everything gets 0.69/.22/.077--not useful

description<-lapply(lapply(listings$description, tolower), strsplit, split="\\W")
desc.vec<-lapply(description, unlist)
space.loc<-sapply(desc.vec, match, space.sent)
space.count<-rep(0, length(listings))
for (i in 1:length(space.loc)){
  space.count[i]<-sum(!is.na(space.loc[[i]]))
}
pos.loc<-sapply(desc.vec, match, pos.sent)
pos.count<-rep(0, length(listings))
for (i in 1:length(pos.loc)){
  pos.count[i]<-sum(!is.na(pos.loc[[i]]))
}
mat.loc<-sapply(desc.vec, match, mat.sent)
mat.count<-rep(0, length(listings))
for (i in 1:length(mat.loc)){
  mat.count[i]<-sum(!is.na(mat.loc[[i]]))
}
#rm(desc2, description, space.loc)
#rm(mat.loc, pos.loc)
characters<-sapply(listings$description, nchar)

sentiment<-data.frame(unlist(listings$listing_id), unlist(listings$interest_level), 500*pos.count/characters, 500*space.count/characters, 500*mat.count/characters)
colnames(sentiment)<-c("listing_id", "interest_level", "Positive.Affect", "Space.Affect", "About.Town.Affect")

sentiment.raw<-data.frame(unlist(listings$listing_id), unlist(listings$interest_level), pos.count, space.count, mat.count, characters)
colnames(sentiment.raw)<-c("listing_id", "interest_level", "Positive.Affect", "Space.Affect", "About.Town.Affect", "Character.Count")

write.csv(sentiment.raw, "sentiment_probably_useless.csv")

raw.lm<-lm(interest ~ Space.Affect, data=sentiment.raw)
#.7% on saturated, .5% on space-only
sent.lm<-lm(interest ~ Space.Affect, data=sentiment)
#Again, only .6% R2 on saturated, .3% on space-only (which is best)


library(tm)
library(SnowballC)

description<-unlist(listings3$description)
desc.corpus<-Corpus(VectorSource(description))

desc.dtm<-DocumentTermMatrix(desc.corpus, control = list(
  tolower = TRUE,
  removeNumbers = TRUE,
  stopwords = function(x) { removeWords(x, stopwords()) },
  removePunctuation = TRUE,
  stemming = TRUE
))



desc.sparse<-removeSparseTerms(desc.dtm, 0.99)
desc.freq = findFreqTerms(desc.sparse, 500)

desc.best<-desc.sparse[,desc.freq]
desc.mat<-as.matrix(desc.best)



train<-sample(1:nrow(desc.mat), .7*nrow(desc.mat))

convert_counts = function(x) {
  x = ifelse(x > 0, 1, 0)
}

desc.use<-apply(desc.mat, 2, convert_counts)

desc.class<-naiveBayes(y=full_list$interest_level[train], x=desc.use[train,])
desc.pred<-predict(desc.class, desc.use[-train,], type="raw")
MultiLogLoss(full_list$interest_level[-train], desc.pred)
#MNB (desc.mat) is nearly 15--description does not appear relevant.
#BNB (desc.) is at 2.1--better, but not necessarily important.
fa.parallel(desc.use, fa="pc", n.iter=15)
desc.pca<-principal(desc.use, rotate="none", k=30)