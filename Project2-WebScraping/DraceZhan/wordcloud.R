
library(tidyr)
library(dplyr)
library(readr)
library(gdata)
library(wordcloud)
library(tm)

UnnestedPros <- read_csv("~/WebScrapeProj/IndeedCsvs/UnnestedPros.csv")
featureCompany = c('Amazon.com', 'Aetna', 'Groupon', 'Bloomberg', 'The Washington Post', 'JPMorgan Chase', 'GrubHub', 'Google', 'Honeywell', 'Blizzard Entertainment')
newPros = UnnestedPros[UnnestedPros$company %in% featureCompany,]

newPros$pro = gsub(',', ' ', newPros$pro)
newPros$pro = gsub(';', ' ', newPros$pro)
newPros$pro = gsub(':', ' ', newPros$pro)
newPros$pro = gsub('/', ' ', newPros$pro)
npCorpus = Corpus(VectorSource(newPros$pro))
npCorpus = tm_map(npCorpus, content_transformer(tolower))
npCorpus = tm_map(npCorpus, removeWords, stopwords('english'))
npM = TermDocumentMatrix(npCorpus)
npM = as.matrix(npM)
colnames(npM) = newPros$company
npM = t(rowsum(t(npM), group = rownames(t(npM))))
#darker colors = more frequent
comparison.cloud(npM, colors=brewer.pal(11, "Paired"), scale=c(3,0.5), title.size = 1)


UnnestedCons <- read_csv("~/WebScrapeProj/IndeedCsvs/UnnestedCons.csv")
newCons = UnnestedCons[UnnestedCons$company %in% featureCompany,]

newCons$con = gsub(',', ' ', newCons$con)
newCons$con = gsub(';', '', newCons$con)
newCons$con = gsub(':', ' ', newCons$con)
newCons$con = gsub('/', ' ', newCons$con)
ncCorpus = Corpus(VectorSource(newCons$con))
ncCorpus = tm_map(ncCorpus, content_transformer(tolower))
ncCorpus = tm_map(ncCorpus, removeWords, stopwords('english'))
ncM = TermDocumentMatrix(ncCorpus)
ncM = as.matrix(ncM)
colnames(ncM) = newCons$company
ncM = t(rowsum(t(ncM), group = rownames(t(ncM))))
#darker colors = more frequent
comparison.cloud(ncM, colors=brewer.pal(11, "Paired"), scale=c(3,0.5), title.size = 1)

