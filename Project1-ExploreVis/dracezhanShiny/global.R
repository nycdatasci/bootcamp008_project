#load libraries needed
#install.packages(c("wordcloud","tm"),repos="http://cran.r-project.org")
#devtools::install_github("ricardo-bion/ggradar", dependencies=TRUE)

library(wordcloud)
library(tm)
library(tidyr)
library(dplyr)
library(ggplot2)
library(corrplot)
library(Rttf2pt1)
library(ggradar)
library(scales)
library(shinydashboard)
library(RColorBrewer)
library(DT)

VGdata = read.csv('data/Video_Games_Sales_Dec_2016.csv', stringsAsFactors = F)
#VGdata = read.csv('data/Video_Games_Sales_Dec_2016.csv', stringsAsFactors = F) for mac/linux deployment locally
VGdata[c(2,4,5,15,16)] <- lapply(VGdata[c(2,4,5,15,16)], factor)
VGdata[3] <- lapply(VGdata[3], as.numeric)
sony<-c('PS','PS2','PS3','PS4' ,'PSP','PSV')
microsoft<-c('PC','X360','XB','XOne')
nintendo<-c('3DS','DS','GBA','GC','N64','Wii','WiiU', 'GB', 'GBA', 'GC', 'NES', 'N64', 'SNES')
sega<-c('DC', 'SAT', 'GEN', 'GG', 'SCD')
PC<-c('2600', '3DO')
companyFunc<-function(x){
  if (x %in% sony == TRUE) {return('SONY')}
  else if(x %in% microsoft == TRUE) {return('MICROSOFT')}
  else if(x %in% nintendo == TRUE) {return('NINTENDO')}
  else if(x %in% sega == TRUE) {return('SEGA')}
  else{return('OTHER')}
}
VGdata$companyPlatform<-sapply(VGdata$Platform, companyFunc)
VGdata$Critic_Score = VGdata$Critic_Score/10

VGdata[c(6:14)] <- lapply(VGdata[c(6:14)], as.numeric)
VGdataCor = cor(VGdata[,6:14], use="pairwise.complete.obs")
colnames(VGdataCor) = c(
  'NA Sales', 'EU Sales', 'Japan Sales', 'Other Sales', 'Critic Score', 'Global Sales',
  'Total Critic Reviews', 'User Score', 'Total User Score')
rownames(VGdataCor) = c(
  'NA Sales', 'EU Sales', 'Japan Sales', 'Other Sales', 'Critic Score', 'Global Sales',
  'Total Critic Reviews', 'User Score', 'Total User Score')

genreAvgScore = VGdata %>% group_by(Genre) %>% summarise(avgUser = mean(User_Score, na.rm = T), avgCritic = mean(Critic_Score, na.rm = T))
genreAvgScore = genreAvgScore[-1,]
genreAvgScore = genreAvgScore %>% gather(key = 'type', value = 'scores', 2:3)

YearGrp = VGdata %>% group_by(Year_of_Release, Genre) %>% summarise(total.genre.sales = sum(Global_Sales))
YearMaxGrp = YearGrp %>% group_by(Year_of_Release) %>% slice(which.max(total.genre.sales))
YearTopTwoGenre = YearGrp %>% group_by(Year_of_Release) %>%top_n(2)

YearGrpPlat = VGdata %>% group_by(Year_of_Release, Platform) %>% summarise(total.plat.sales = sum(Global_Sales))
YearMaxPlat = YearGrpPlat %>% group_by(Year_of_Release) %>%slice(which.max(total.plat.sales))
YearTopTwoPlat = YearGrpPlat %>% group_by(Year_of_Release) %>%top_n(2)

BestSeller = VGdata %>% group_by(Year_of_Release) %>% filter(Global_Sales==max(Global_Sales)) %>% arrange(Year_of_Release) 
BestSeller$Genre = as.factor(BestSeller$Genre)
YearMaxGrp$Genre = as.factor(YearMaxGrp$Genre)
BestSeller$Name = gsub('Pokémon', 'Pokemon', BestSeller$Name)
BestSeller$Name = gsub('/', ' ', BestSeller$Name)
BestSeller$Name = gsub('-', '', BestSeller$Name)
BestSeller$Name = gsub(':', ' ', BestSeller$Name)
BestSellerCorpus = Corpus(VectorSource(BestSeller$Name))
BestSellerCorpus = tm_map(BestSellerCorpus, content_transformer(tolower))
BestSellerCorpus = tm_map(BestSellerCorpus, removeWords, stopwords('english'))
BestSellerM = TermDocumentMatrix(BestSellerCorpus)
BestSellerM = as.matrix(BestSellerM)
colnames(BestSellerM) = BestSeller$Genre
BestSellerM = t(rowsum(t(BestSellerM), group = rownames(t(BestSellerM))))

tot_region_sales = VGdata %>% group_by(Year_of_Release) %>% summarise(tot_NA_sales = sum(
  NA_Sales), tot_EU_sales = sum(EU_Sales), tot_JP_sales = sum(JP_Sales))

bigThree = VGdata %>% group_by(companyPlatform) %>% summarise(Total_Sales = sum(Global_Sales), Total_Users = sum(User_Count, na.rm = T),
                                                              'NA' = sum(NA_Sales),
                                                              'EU' = sum(EU_Sales),
                                                              'JP' = sum(JP_Sales),
                                                              'Other' = sum(Other_Sales))

scaled_bigThree = bigThree %>%  mutate_each(funs(rescale), -companyPlatform) %>% select(-Total_Sales, -Total_Users)

companyNoRecUsers = VGdata%>%group_by(companyPlatform) %>%  slice(which(is.na(User_Count)))
companyNoRecUsers =companyNoRecUsers %>% group_by(companyPlatform) %>% summarise_each(funs(sum), one_of(c('NA_Sales', 'EU_Sales', 'Global_Sales', 'JP_Sales', 'Other_Sales'))) 
companyNaNSums = VGdata %>% group_by(companyPlatform) %>% count(companyPlatform)
companyNoRecUsers = merge(companyNoRecUsers, companyNaNSums)
colnames(companyNoRecUsers)[7] = 'Total_Missing_UserCounts'
companyNoRecUsers[1] = lapply(companyNoRecUsers[1], factor)