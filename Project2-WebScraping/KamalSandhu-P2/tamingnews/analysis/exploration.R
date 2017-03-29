library(readr)
library(ggplot2)
library(dplyr)
library(ggthemes)
data <- read_csv("C:/Users/sandh/Dropbox/FRM/
                 Bootcamp/Projects/Project 2/tamingnews/analysis/data/data.csv")

df = as.data.frame(data)
df$Source <- as.factor(df$Source)
x <- as.factor(c('CNN', 'Fox News','Reuters'))
levels(df$Source) <- x


avGs <- df %>%
  group_by(Source) %>%
  summarise(mean(gMag),mean(gSent))

avLen <- df %>%
  group_by(Source) %>%
  summarise(len = mean(lenArticle))

df <- df %>%
  mutate(returnLen = lenGoogleAPIentities +
           lenGoogleAPItokens + 
           lenTextrazorAPIentailments+ 
           lenTextrazorAPIproperties+ 
           lenTextrazorAPItopics+ 
           lenTextrazorAPIsentences+ 
           lenTextrazorAPIrelations+ 
           lenTextRazorAPIcoarseTopics+
           lenTextrazorAPIentities)

'%!in%' <- function(x,y)!('%in%'(x,y))

gEntities1 <- df[df$gentity1 %!in% c("Trump", "Donald Trump"),] %>%
  group_by(Source, gentity1) %>%
  summarise(count = n()) %>%
  top_n(5)

gEntities2 <- df[df$gentity2 %!in% c("Trump", "Donald Trump"),] %>%
  group_by(Source, gentity2) %>%
  summarise(cumSalience = sum(gentity2salience)) %>%
  arrange(desc(cumSalience)) %>%
  top_n(5)

colnames(gEntities1) <- c('Source', 'Entity', 'Count')
colnames(gEntities2) <- c('Source', 'Entity', 'Count')
gEntities <- rbind(gEntities1, gEntities2)
gEntities <- gEntities %>%
  group_by(Source, Entity) %>%
  summarise(Count = sum(Count)) %>%
  arrange(desc(Count)) %>%
  top_n(5)


tEntities1 <- df[df$tentity1 %!in% c("Trump", "Donald Trump"),] %>%
  group_by(Source, tentity1) %>%
  summarise(cumSalience = sum(tentity1salience)) %>%
  arrange(desc(cumSalience)) %>%
  top_n(5)

tEntities2 <- df[df$tentity2 %!in% c("Trump", "Donald Trump"),] %>%
  group_by(Source, tentity2) %>%
  summarise(cumSalience = sum(tentity2salience)) %>%
  arrange(desc(cumSalience)) %>%
  top_n(5)

colnames(tEntities1) <- c('Source', 'Entity', 'Count')
colnames(tEntities2) <- c('Source', 'Entity', 'Count')
tEntities <- rbind(tEntities1, tEntities2)
tEntities <- tEntities %>%
  group_by(Source, Entity) %>%
  summarise(Count = sum(Count)) %>%
  arrange(desc(Count)) %>%
  top_n(5)


gtopic1 <- df[df$gtopic1 %!in% c("Trump", "Donald Trump"),] %>%
  group_by(Source, gtopic1) %>%
  summarise(num = n()) %>%
  arrange(desc(num)) %>%
  top_n(5)

gtopic2 <- df[df$gtopic2 %!in% c("Trump", "Donald Trump"),] %>%
  group_by(Source, gtopic2) %>%
  summarise(num = n()) %>%
  arrange(desc(num)) %>%
  top_n(5)

colnames(gtopic1) <- c('Source', 'Topic', 'Count')
colnames(gtopic2) <- c('Source', 'Topic', 'Count')
gtopic <- rbind(gtopic1, gtopic2)
gtopic <- gtopic %>%
  group_by(Source, Topic) %>%
  summarise(Count = sum(Count)) %>%
  arrange(desc(Count)) %>%
  top_n(5)


gSent <- ggplot(df) + geom_density(aes(x = gSent, color = Source)) + 
  ggtitle("Google Sentiment") + 
  theme_classic() + xlab('Sentiment') + 
  ylab("Density")

gMag <- ggplot(df) + geom_density(aes(x = gMag, color = Source)) + 
  ggtitle("Google Sentiment Magnitude") + 
  theme_classic() + xlab('Magnitude') + 
  ylab("Density") + xlim(c(-5, 45))

lenG <- ggplot(avLen) + 
  geom_bar(aes(x = Source, y = len, fill = Source), stat = 'identity') + 
  ggtitle("Average Length of Article") + 
  theme_classic() + 
  xlab('') + 
  ylab("")

returnLenG <- ggplot(df) + 
  geom_point(aes(lenArticle, returnLen, color = Source)) +
  theme_classic()+ 
  xlab("Number of Character in an Article") + 
  ylab("Number of Character in Response")


gEntitiesGcnn <- ggplot(gEntities[gEntities$Source %in% c("CNN"),]) + 
  geom_bar(aes(x = reorder(Entity, Count), y = Count), stat = 'identity', fill = 'blue')+
  theme_classic()+ ggtitle("CNN Entities Categorized by Google") +
  xlab("") + 
  ylab("")+ theme(axis.text.x = element_text(angle = 60, hjust = 1))
  
gEntitiesGreuters <- ggplot(gEntities[gEntities$Source %in% c("Reuters"),]) + 
  geom_bar(aes(x = reorder(Entity, Count), y = Count), stat = 'identity', fill = 'blue')+
  theme_classic()+ ggtitle("Reuters Entities Categorized by Google") +
  xlab("") + 
  ylab("")+ theme(axis.text.x = element_text(angle = 60, hjust = 1))

gEntitiesGfox <- ggplot(gEntities[gEntities$Source %in% c("Fox News"),]) + 
  geom_bar(aes(x = reorder(Entity, Count), y = Count), stat = 'identity', fill = 'blue')+
  theme_classic()+ ggtitle("Fox Entities Categorized by Google") +
  xlab("") + 
  ylab("")+ theme(axis.text.x = element_text(angle = 60, hjust = 1))

tEntitiesGcnn <- ggplot(tEntities[tEntities$Source %in% c("CNN"),]) + 
  geom_bar(aes(x = reorder(Entity, Count), y = Count), stat = 'identity', fill = 'blue')+
  theme_classic()+ ggtitle("CNN Entities Categorized by TextRazor") +
  xlab("") + 
  ylab("")+ theme(axis.text.x = element_text(angle = 60, hjust = 1))

tEntitiesGreuters <- ggplot(tEntities[tEntities$Source %in% c("Reuters"),]) + 
  geom_bar(aes(x = reorder(Entity, Count), y = Count), stat = 'identity', fill = 'blue')+
  theme_classic()+ ggtitle("Reuters Entities Categorized by TextRazor") +
  xlab("") + 
  ylab("")+ theme(axis.text.x = element_text(angle = 60, hjust = 1))

tEntitiesGfox <- ggplot(tEntities[tEntities$Source %in% c("Fox News"),]) + 
  geom_bar(aes(x = reorder(Entity, Count), y = Count), stat = 'identity', fill = 'blue')+
  theme_classic()+ ggtitle("Fox Entities Categorized by TextRazor") +
  xlab("") + 
  ylab("")+ theme(axis.text.x = element_text(angle = 60, hjust = 1))

gtopicGcnn <- ggplot(gtopic[gtopic$Source %in% c("CNN"),]) + 
  geom_bar(aes(x = reorder(Topic, Count), y = Count), stat = 'identity', fill = 'blue')+
  theme_classic()+ ggtitle("CNN Topics Categorized by Google") +
  xlab("") + 
  ylab("")+ theme(axis.text.x = element_text(angle = 60, hjust = 1))

gtopicGreuters <- ggplot(gtopic[gtopic$Source %in% c("Reuters"),]) + 
  geom_bar(aes(x = reorder(Topic, Count), y = Count), stat = 'identity', fill = 'blue')+
  theme_classic()+ ggtitle("Reuters Topics Categorized by Google") +
  xlab("") + 
  ylab("")+ theme(axis.text.x = element_text(angle = 60, hjust = 1))

gtopicGfox <- ggplot(gtopic[gtopic$Source %in% c("Fox News"),]) + 
  geom_bar(aes(x = reorder(Topic, Count), y = Count), stat = 'identity',fill = 'blue')+
  theme_classic()+ ggtitle("Fox Topics Categorized by Google") + 
  xlab("") + 
  ylab("") + theme(axis.text.x = element_text(angle = 60, hjust = 1))



lenG
gSent
gMag
returnLenG

gEntitiesGcnn
gEntitiesGreuters
gEntitiesGfox

tEntitiesGcnn
tEntitiesGreuters
tEntitiesGfox

gtopicGcnn
gtopicGreuters
gtopicGfox 
