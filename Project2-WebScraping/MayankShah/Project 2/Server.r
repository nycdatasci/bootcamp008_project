FinalScrape <- read.csv("FinalScrape2.csv", header = TRUE)

GenreSummary <- FinalScrape %>% group_by(Group, Genre) %>% summarise(GenreSums = length(Genre))

AverageTime <- FinalScrape %>% group_by(Group) %>% summarise(Average_Time = mean(Length))


library(ggplot2)
library(readxl)
library(plyr)
library(dplyr)
library(ggrepel)
library(car)

shinyServer(function(input, output){
  output$SongPlot <- renderPlot({
    ggplot(FinalScrape, aes(Date, Length, label=Song)) + geom_point(aes(Date, Length), size = 2, color = 'grey') + geom_label_repel(aes(Date, Length, fill = factor(Group), label = Song), fontface='plain', box.padding = unit(.35, "lines"), point.padding = unit(0.5, "lines"), segment.color = 'grey50') + ylim(77, 112) + xlab("") + ylab("Days on Top")
  })

  output$BarPlot <- renderPlot({
    ggplot(AverageTime, aes(Group, Average_Time, fill = as.factor(Group))) + geom_bar(stat = "identity") + xlab("Decade") + ylab("Average Days at #1") + theme(legend.title=element_blank())
  })
  output$GenrePlot <- renderPlot({
    ggplot(GenreSummary, aes(x = Group, y = GenreSums, fill = Genre)) + geom_bar(stat = "identity", position = "fill") + xlab("Decade") + ylab("Genre Breakdown")
  })
})