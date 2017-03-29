
setwd("~/NYCDSA/Project 4")

bestseller<-read.csv("Full_Pub2.csv", stringsAsFactors = F)

reviews<-read.csv("reviews.csv", stringsAsFactors = F)
reviews$text<-gsub("â€™", "'",reviews$text)
reviews$text<-gsub("â€œ", '"',reviews$text)
reviews$text<-gsub("â€", '"',reviews$text)
reviews$text<-gsub("Â", '"',reviews$text)
reviews$text<-gsub("ã", 'e',reviews$text)


library(dplyr)
bestseller<-read.csv("")
bestseller.review<-select(bestseller, author, title, book_review_link, sunday_review_link)
bestseller.rev.uni<-unique(bestseller.review)
nrow(bestseller.review) #4553
length(bestseller.rev.uni$book_review_link[!bestseller.rev.uni$book_review_link==""]) #287.
length(bestseller.rev.uni$book_review_link[!bestseller.rev.uni$sunday_review_link==""]) #373.
length(bestseller.rev.uni$book_review_link[!bestseller.rev.uni$book_review_link=="" & !bestseller.rev.uni$sunday_review_link==""])#178 get both
length(bestseller.rev.uni$book_review_link[bestseller.rev.uni$book_review_link=="" & bestseller.rev.uni$sunday_review_link==""]) #4071, so 482 get reviews
#0.106 got a review
#Estimate 50,000 novels per year, of which 1% make bestseller list.  By Bayes, ~16% of books that get reviewed make bestseller list
total<-40000
hard<-9000
trade<-18000
mass<-9000
ebook<-18000



bestseller.trade<-filter(bestseller, display_name=="Paperback Trade Fiction")
bestseller.trade.r<-select(bestseller.trade, author, title, book_review_link, sunday_review_link)
bestseller.tr.uni<-unique(bestseller.trade.r)
trade.best<-nrow(unique(bestseller.tr.uni)) #681
trade.rev<-length(bestseller.tr.uni$book_review_link[!bestseller.tr.uni$book_review_link=="" | !bestseller.tr.uni$sunday_review_link==""]) #225
trade.best.per<-trade.best/(trade*8.75)
trade.rev.per<-trade.rev/(1800)

#Much more--33% of bestsellers got reviews
#Estimate 8,000 come out in trade paper per year, of which .085 get reviewed.  3.8% of those that get reviewed make bestseller list--interesting.

bestseller.hard<-filter(bestseller, display_name=="Hardcover Fiction")
bestseller.hard.r<-select(bestseller.hard, author, title, book_review_link, sunday_review_link)
bestseller.hard.uni<-unique(bestseller.hard.r)
hard.best<-nrow(bestseller.hard.uni) #2048--Interesting that it's that much higher
hard.rev<-length(bestseller.hard.uni$book_review_link[!bestseller.hard.uni$book_review_link=="" | !bestseller.hard.uni$sunday_review_link==""])
hard.best.per<-hard.best/(hard*8.75)
hard.rev.per<-hard.rev/(1400)
#18% get review
#Estimate 18,000 hardcover books, of which 9.36% get reviewed.

bestseller.mass<-filter(bestseller, display_name=="Paperback Mass-Market Fiction")
bestseller.mass.r<-select(bestseller.mass, author, title, book_review_link, sunday_review_link)
bestseller.mass.uni<-unique(bestseller.mass.r)
mass.best<-nrow(bestseller.mass.uni) #1927
mass.rev<-length(bestseller.mass.uni$book_review_link[!bestseller.mass.uni$book_review_link=="" | !bestseller.mass.uni$sunday_review_link==""])#1857
mass.best.per<-mass.best/(mass*8.75)
mass.rev.per<-mass.rev/(300)
#Only 3% of mass-market got reviewed

reviews.per<-data.frame(c("Hardcover", "Hardcover", "Trade Paperback", "Trade Paperback", "Mass Market", "Mass Market"), c("Total", "Reviewed"), c(hard.best.per, hard.rev.per, trade.best.per, trade.rev.per, mass.best.per, mass.rev.per))
colnames(reviews.per)=c("Format", "Type", "Fraction")

best.reviews<-data.frame(c("Hardcover", "Trade Paperback", "Mass-Market", "Hardcover", "Trade Paperback", "Mass-Market"), c("Reviewed", "Reviewed", "Reviewed", "Not Reviewed", "Not Reviewed", "Not Reviewed"), c(hard.rev, trade.rev, mass.rev, hard.best-hard.rev, trade.best-trade.rev, mass.best-mass.rev))
colnames(best.reviews)<-c("Bestseller.List", "Reviewed", "Number")

library(ggplot2)
library(ggthemes)
rev<-ggplot(data=reviews.per, aes(x=Format, y=Fraction))
rev + geom_bar(stat="identity", aes(fill=Type), position="dodge") + labs(title="How Likely is a Book to Be a Bestseller?", y="Estimated Fraction") + theme_gdocs() + theme(plot.title = element_text(hjust = 0.5)) + guides(fill=guide_legend(title="Reviewed by NY Times?"))

best<-ggplot(best.reviews, aes(x=Bestseller.List, Number))
best + geom_bar(stat="identity", aes(fill=Reviewed), position="stack") + labs(title="How Many Bestsellers Get Reviewed?", x="Format", y="Number of Bestsellers") + theme_gdocs() + theme(plot.title = element_text(hjust = 0.5)) + guides(fill=guide_legend(title="Bestseller Reviewed?"))

#Rough estimate--63% paperback to 37% hardcover


mean(sapply(sapply(fict.rev$text, strsplit, split="\\W"), length))


library(tm)
reviews_text<-reviews$text
reviews_text<-gsub("â€™", "'",reviews_text)
reviews_text<-gsub("â€œ", '"',reviews_text)
reviews_text<-gsub("â€", '"',reviews_text)
reviews_text<-gsub("Â", '',reviews_text)
reviews_text<-gsub("\\", '',reviews_text, fixed=T)

review_text<-Corpus(VectorSource(reviews_text))
review_dtm<-DocumentTermMatrix(review_text, control = list(
       tolower = TRUE,
       removeNumbers = TRUE,
       stopwords = function(x) { removeWords(x, stopwords()) },
       removePunctuation = TRUE,
       stemming = TRUE
  ))
review_dtm_sp<-removeSparseTerms(review_dtm, sparse = 0.99)

rev_kcl = kmeans(as.matrix(review_dtm_sp), centers = 3)


###
library(qdap)
library(dplyr)
library(syuzhet)
rt<-sentSplit(fict.rev, "text")

get_last<-function(name){
  name.split<-unlist(strsplit(name, split=" "))
  return(name.split[length(name.split)])
}
author_name<-sapply(rt$book_author, get_last)
names(author_name)<-c()


rt.filter<-rep(0, nrow(rt))
for (i in 1:nrow(rt)){
  rt.filter[i]<-author_name[i] %in% strsplit(rt$text[i], split="\\W")[[1]]
}

rt.filter2<-rep(2, nrow(rt))
for (i in 1:nrow(rt)){
  rt.filter2[i]<-(author_name[i] %in% strsplit(rt$text[i], split="\\W")[[1]]) | (all(strsplit(rt$book_title[i], split=" ")[[1]] %in% strsplit(rt$text[i], split="\\W")[[1]]))
  
}


rt2<-cbind(rt, rt.filter2)
rt.lines<-filter(rt2, rt.filter2==1)$text

pred<-read.table("predictions.txt", sep=",")
pred<-unlist(c(pred))

rt3<-filter(rt2, rt.filter2==1)



rt.pred<-cbind(rt, pred)
rt.pred$pred<-rt.pred$pred-1
rt.pred$pred[rt.pred$pred==-1]<-0

pred.sent<-rt.pred %>% group_by(book_author, book_title, byline,) %>% summarize(review = sum(pred), length = n()) %>% mutate(avg.sent = review/length * 8)


rt.authorbook<-cbind(rt2, get_sentiment(rt2$text))
rt.filtered<-filter(rt.authorbook, rt.filter2==1)

#rt.nrc<-mutate(rt.filtered, sentiment=trust + positive) %>% group_by(book_author, book_title, byline) %>% summarize(review = round(sum(sentiment),2), length=n()) %>% mutate(avg.sent = review/length * 8)

rt.judge3<-rt.authorbook %>% group_by(book_author, book_title, byline, url) %>% summarize(review = round(sum(sentiment),2), length = n()) %>% mutate(avg.sent = review/length * 8)

test.sent<-pred.sent %>% filter(book_title %in% c("Forgetting Tree", "Blue Diary", "Nightbird", "The Whistler", "Angel of Light", "Luka and the Fire of Life", "Mason & Dixon", "Adored", "Devil Knows You're Dead", "Los Alamos", "The Villa", "Ghostway",
                                                  "Forgotten Waltz", "Pet Sematary", "Wilde Lake", "Falling Man", "Life Expectancy: A Novel", "Welcome to Temptation", "Virtual Light", "Cold Mountain", "Aloft(Lee, Chang-Rae)", "The Buried Giant",
                                                  "The Dive From Clausen's Pier", "New York Dead", "The Girl on the Train", "Gone for Good", "Hunters", "The Days of Abandonment",
                                                  "Wolf in White Van", "L. A. Requiem", "The Assassination of Margaret Thatcher", "The Last Days of Night", "The White Tiger", "The Jane Austen Book Club",
                                                  "Persian Pickle Club", "Sure of You", "Sudden, Fearful Death", "Train Dreams", "That Old Cape Magic", "My Sister's Keeper", "Artemis Fowl", "Before the Fall", "The Naming of the Dead"))





reviews2<-read.csv("reviews_2.csv", stringsAsFactors = F)


reviews2$text<-gsub("â€™", "'",reviews2$text)
reviews2$text<-gsub("â€œ", '"',reviews2$text)
reviews2$text<-gsub("â€", '"',reviews2$text)
reviews2$text<-gsub("Â", '',reviews2$text)
reviews2$text<-gsub("ˆ", '',reviews2$text)
reviews2$text<-gsub("ã", '',reviews2$text)
reviews2$text<-gsub("\\", '',reviews2$text, fixed=T)

library(mallet)

reviews.tm<-mallet.import(reviews2$book_title, reviews2$text, stoplist.file="stopwords.txt")
topic.model <- MalletLDA(num.topics=25)
topic.model$loadDocuments(reviews.tm)

vocab<-topic.model$getVocabulary()
word.fre<-mallet.word.freqs(topic.model)
topic.model$setAlphaOptimization(10, 50)
topic.model$train(400)


doc.topics6 <- mallet.doc.topics(topic.model6, smoothed=T, normalized=T)
topic.words6 <- mallet.topic.words(topic.model6, smoothed=T, normalized=T)

top.words6<-data.frame(matrix(nrow=nrow(topic.words6), ncol=10))
for (i in 1:nrow(topic.words6)){
  top.words6[i,]<-mallet.top.words(topic.model6, topic.words6[i,])[,1]
}

doc.topics7 <- mallet.doc.topics(topic.model7, smoothed=T, normalized=T)
topic.words7 <- mallet.topic.words(topic.model7, smoothed=T, normalized=T)

top.words7<-data.frame(matrix(nrow=nrow(topic.words7), ncol=10))
for (i in 1:nrow(topic.words7)){
  top.words7[i,]<-mallet.top.words(topic.model7, topic.words7[i,])[,1]
}


doc.topics11 <- mallet.doc.topics(topic.model11, smoothed=T, normalized=T)
topic.words11 <- mallet.topic.words(topic.model11, smoothed=T, normalized=T)

top.words11<-data.frame(matrix(nrow=nrow(topic.words11), ncol=10))
for (i in 1:nrow(topic.words11)){
  top.words11[i,]<-mallet.top.words(topic.model11, topic.words11[i,])[,1]
}


topic.model2<- MalletLDA(num.topics=25)
topic.model2$loadDocuments(reviews.tm)
topic.model2$setAlphaOptimization(10, 50)
topic.model2$train(400)

topic.model3<- MalletLDA(num.topics=40)
topic.model3$loadDocuments(reviews.tm)
topic.model3$setAlphaOptimization(10, 50)
topic.model3$train(600)

#Try 35 next

topic.model3<- MalletLDA(num.topics=35)
topic.model3$loadDocuments(reviews.tm)
topic.model3$setAlphaOptimization(10, 50)
topic.model3$train(600)

topic.model4<- MalletLDA(num.topics=37)
topic.model4$loadDocuments(reviews.tm)
topic.model4$setAlphaOptimization(10, 50)
topic.model4$train(500)


topic.model5<- MalletLDA(num.topics=38)
topic.model5$loadDocuments(reviews.tm)
topic.model5$setAlphaOptimization(10, 50)
topic.model5$train(600)

topic.model6<- MalletLDA(num.topics=36)
topic.model6$loadDocuments(reviews.tm)
topic.model6$setAlphaOptimization(10, 50)
topic.model6$train(500)
#36 best so far...
topic.model7<- MalletLDA(num.topics=30)
topic.model7$loadDocuments(reviews.tm)
topic.model7$setAlphaOptimization(10, 50)
topic.model7$train(500)
#30 good, too
topic.model8<- MalletLDA(num.topics=33)
topic.model8$loadDocuments(reviews.tm)
topic.model8$setAlphaOptimization(10, 50)
topic.model8$train(500)

topic.model9<-MalletLDA(num.topics=31)
topic.model9$loadDocuments(reviews.tm)
topic.model9$setAlphaOptimization(10, 50)
topic.model9$train(500)

topic.model10<-MalletLDA(num.topics=28)
topic.model10$loadDocuments(reviews.tm)
topic.model10$setAlphaOptimization(10, 50)
topic.model10$train(500)

topic.model11<- MalletLDA(num.topics=30)
topic.model11$loadDocuments(reviews.tm)
topic.model11$setAlphaOptimization(10, 50)
topic.model11$train(500)

plot(doc.topics7[,4], main = "The 'Fiction' Topic", ylab="Proportion of Document")
abline(h=0.08, lty=2, lwd=4, col="red")
abline(h=0.16, lty=2, lwd=4, col="red")
abline(h=0.12, lty=2, lwd=2, col="red")

difficult<-doc.topics7[(doc.topics7[,4]<0.16) & (doc.topics7[,4]>.08),]
reviews2$fiction<-NA
reviews2$fiction[doc.topics7[,4]>.16]<-1
reviews2$fiction[doc.topics7[,4]<.08]<-0
reviews2$fiction[((doc.topics7[,4]<0.16) & (doc.topics7[,4]>.08))][grepl("memoir", reviews2$text[(doc.topics7[,4]<0.16) & (doc.topics7[,4]>.08)])]<-0
reviews2$fiction[((doc.topics7[,4]<0.16) & (doc.topics7[,4]>.08) & (doc.topics7[,10]>0.15))]<-0
reviews2$fiction[((doc.topics7[,4]<0.16) & (doc.topics7[,4]>.08) & (doc.topics7[,22]>0.154))]<-0
reviews2$fiction[is.na(reviews2$fiction) & (doc.topics7[,4]<0.12)]<-0
reviews2$fiction[is.na(reviews2$fiction)]<-1
fict.rev<-reviews2[reviews2$fiction==1,]


fict.rev$url<-gsub("https", "http", fict.rev$url)
bestseller$book_review_link<-gsub("https", "http", bestseller$book_review_link)
bestseller$sunday_review_link<-gsub("https", "http", bestseller$sunday_review_link)
sell.review<-left_join(bestseller, reviews2, by = c("book_review_link" = "url"))[,c(-19, -20, -24)]
sell.review<-left_join(sell.review, reviews2, by = c("sunday_review_link" = "url"))[,c(-22, -23, -27)]
names(sell.review)[19:24]<-c("book.reviewer", "review.date", "book.review", "sunday.reviewers", "sunday.date", "sunday.review")

missing<-unique(sell.review[!is.na(sell.review$book_review_link) & is.na(sell.review$book.review),]$book_review_link)



sell.sent<-left_join(sell.review, rt.judge3[4:7], by=c("book_review_link" = "url"))
sell.sent<-left_join(sell.sent, rt.judge3[4:7], by=c("sunday_review_link" = "url"))

missing.book<-read.csv("missing_book.csv", stringsAsFactors = F)
missing.sunday<-read.csv("missing_sunday.csv", stringsAsFactors = F)

book.sent<-sentSplit(missing.book, "text")
sunday.sent<-sentSplit(missing.sunday, "text")

for (i in 1:length(sunday.sent)){
  sell.sent$book.review[sell.sent$book_review_link==missisunday.sent$x[i]]<-sunday.sent$text[]
}

rt.filter2<-rep(2, nrow(rt))
for (i in 1:nrow(rt)){
  rt.filter2[i]<-(author_name[i] %in% strsplit(rt$text[i], split="\\W")[[1]]) | (all(strsplit(rt$book_title[i], split=" ")[[1]] %in% strsplit(rt$text[i], split="\\W")[[1]]))
  
}

trade.total<-sell.sent %>% filter(display_name=="Paperback Trade Fiction") %>% group_by(author, title) %>% summarize(book = mean(avg.sent.x, na.rm=T), sunday = mean(avg.sent.y, na.rm=T), book.length = mean(length.x, na.rm=T), sunday.length=mean(length.y, na.rm=T))

trade.total<-trade.total[trade.total$book!="NaN" | trade.total$sunday!="NaN",]

mean(rt.judge3$avg.sent)#0.87
mean(trade.total$book, na.rm=T)#0.7
mean(trade.total$sunday, na.rm=T)#1.14
mean(c(trade.total$sunday, trade.total$book), na.rm=T)

best.reviews<-c(trade.total$sunday, trade.total$book)
best.reviews<-best.reviews[best.reviews!="NaN"]

t.test(rt.judge3$avg.sent, best.reviews)
t.test(trade.total$book, trade.total$sunday)

mean(rt.judge3$length)#45.9
mean(trade.total$ na.rm=T)
mean(trade.total$sunday, na.rm=T)
mean(c(trade.total$sunday.length, trade.total$book.length), na.rm=T)#51.1

best.length<-c(trade.total$sunday.length, trade.total$book.length)
best.length<-best.length[best.length!="NaN"]

t.test(best.length, rt.judge3$length)

t.test(trade.total$sunday.length, trade.total$book.length)
#Note: Missing 115/285 regular book (but 28 pre-2008), 155/370 Sundays (but 51 pre-2008); missing 30.5% and 28.1%, so estimate 70% of total yield.
