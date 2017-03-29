library(wordcloud)
library(tm)
library(NLP)
library(SnowballC)
library(tm)
library(readr)

y<- read_csv("~/Library/Mobile Documents/com~apple~CloudDocs/CPTransactiondata/CPwordcloud.csv")
cp_wc <- Corpus(VectorSource(CPwordcloud$search_word))

View(CPwordcloud)

y = read.csv('CPwordcloud.csv')
library(wordcloud)
wordcloud(y$search_word, y$count, max.words = 50)

wordcloud(CPwordcloud$search_word, CPwordcloud$count, max.words = 50, colors =brewer.pal(8,"RdYlGn"))

#wordcloud(Search_Word$wordclouds, Hits$wordclouds, max.words = 50, colors =brewer.pal(8,"RdPu"))
#wordcloud(hic$wd, hic$score, max.words = 50, colors =brewer.pal(8,"Dark2"))
#help(wordcloud)

#set.seed(1234)
#wordcloud(words = df$Search_Word, freq = df$Hits, max.freq = 5, min.freq = 0,
#          max.words=100, random.order=FALSE, rot.per=0.35, 
#          colors=brewer.pal(8, "Dark2"))

head(CPwordcloud)
summary(CPwordcloud)
help("wordcloud")