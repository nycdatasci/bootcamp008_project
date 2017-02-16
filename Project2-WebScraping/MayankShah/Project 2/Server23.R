library(readxl)
library(plyr)
library(dplyr)
library(ggrepel)
library(car)

setwd("/Users/mayanks/Desktop/Project 2")





#NewStart
FinalScrape <- read.csv("FinalScrape2.csv", header = TRUE)

#correlation

cor(FinalScrape$Length, FinalScrape$Group)
#.1891968 
#Higher decades positively correlate with longer times at the top of charts

t.test(FinalScrape$Length[FinalScrape$Group == "1960"],
       FinalScrape$Length[FinalScrape$Group == "2000"],
       alternative = "two.sided")
#Average length of chart topper in 60s was 19 days, 25 days in 2000s. 95% confidence interval of -10.67 to -2.39


t.test(FinalScrape$Length[FinalScrape$Group == "1960"],
       FinalScrape$Length[FinalScrape$Group == "1990"],
       alternative = "two.sided")
#Average length of chart topper in 60s was 19 days, 26 days in 1990s. 95% confidence interval of -11 to -2.5
var.test(FinalScrape$Length[FinalScrape$Group == "1960"], FinalScrape$Length[FinalScrape$Group == "2000"], alternative = "greater")


bartlett.test(FinalScrape$Length ~ FinalScrape$Group)
#We can conclusively say that the length of time at the top of the charts is affected by the decade


summary(aov(Length ~ Group, data = FinalScrape))
#we have evidence to conclude that decade did afffect length of time as chart topper

###Chart 1
ggplot(FinalScrape, aes(Date, Length, label=Song)) + geom_point(aes(Date, Length), size = 2, color = 'grey') + geom_label_repel(aes(Date, Length, fill = factor(Group), label = Song), fontface='plain', box.padding = unit(.35, "lines"), point.padding = unit(0.5, "lines"), segment.color = 'grey50') + ylim(77, 112)


AverageTime <- FinalScrape %>% group_by(Group) %>% summarise(Average_Time = mean(Length))

###Chart 2
ggplot(AverageTime, aes(Group, Average_Time, fill = as.factor(Group))) + geom_bar(stat = "identity")


GenreSummary <- FinalScrape %>% group_by(Group, Genre) %>% summarise(GenreSums = length(Genre))

Sixties <- GenreSummary[GenreSummary$Group == "1960", ]
Seventies <- GenreSummary[GenreSummary$Group == "1970", ]
Eighties <- GenreSummary[GenreSummary$Group == "1980", ]
Ninties <- GenreSummary[GenreSummary$Group == "1990", ]
TwoThousands <- GenreSummary[GenreSummary$Group == "2000", ]

#Chart 3
ggplot(GenreSummary, aes(x = Group, y = GenreSums, fill = Genre)) + geom_bar(stat = "identity")



ggplot(Seventies, aes(x = "", y = GenreSums, fill = Genre)) + geom_bar(stat = "identity") + coord_polar("y", start = 0)
ggplot(Eighties, aes(x = "", y = GenreSums, fill = Genre)) + geom_bar(stat = "identity") + coord_polar("y", start = 0)
ggplot(Ninties, aes(x = "", y = GenreSums, fill = Genre)) + geom_bar(stat = "identity") + coord_polar("y", start = 0)
ggplot(TwoThousands, aes(x = "", y = GenreSums, fill = Genre)) + geom_bar(stat = "identity") + coord_polar("y", start = 0)




