library(googleVis)
library(dplyr)
library(reshape)
setwd("~/NYCDSA/Project 4/")
bestseller<-read.csv("bestseller.csv", stringsAsFactors = F)

shinyServer(function(input, output){
  
  era<-reactive({
    era<-switch(input$era, "pre"=filter(bestseller, published_date < as.Date("2013-07-15", "%Y-%m-%d")), "post"=filter(bestseller, published_date >= as.Date("2013-07-15", "%Y-%m-%d")))
  })
  
  seller<-reactive({
    seller<-if (input$list=="All") era() else filter(era(), display_name==input$list)
  })
    
  genre<-reactive({
    genre<-if (input$genre=="All") seller() else filter(seller(), genre==input$genre) 
  })
    

  rank<-reactive({
    rank<-switch(input$rank, "publisher"=group_by(genre(), publisher), "author"=group_by(genre(), author), "title"=group_by(genre(), title))
  })  
    
  output$bar<-renderGvis({
    chart<-rank() %>% summarize(Total.Weeks=n())
    chart<-chart[order(chart$Total.Weeks, decreasing=T),][1:15,]
    gvisBarChart(chart, names(chart)[1], names(chart)[2], options=list(title = "Top Sellers", height=500))
    
  })
  
  output$market<-renderGvis({
    pie<-genre() %>% group_by(parent) %>% summarize(Total.Weeks=n())
    gvisPieChart(pie, labelvar = "Parent", numvar = "Total Weeks", options = list(title= "Market Share", height=500), "market")
  })
  
  output$time<-renderGvis({
    line<-genre() %>% group_by(parent, year) %>% summarize(Total.Weeks=n()) %>% cast(year ~ parent)
    rownames(line)<-line$year
    line<-line[,-1]
    line[is.na(line)]<-0
    line<-line/rowSums(line) * 100
    line$year<-rownames(line)
    gvisLineChart(line, xvar="year", yvar = names(line)[-(ncol(line))], options = list(title = "List Share By Year", height=500), "time")
    
  })
  
  output$weeks<-renderGvis({
    weeks<-genre() %>% group_by(title) %>% summarize(Weeks = n())
    gvisHistogram(weeks, options = list(title = "Weeks on Charts for Each Book", height=500, legend="{ position: 'none' }"), "weeks")
    
  })
  
  output$med<-renderInfoBox({
    weeks<-genre() %>% group_by(title) %>% summarize(Weeks = n())
    infoBox(h4(paste("The median bestseller lasts for", median(weeks$Weeks), "weeks")), icon = icon("book"))
  })
  
  output$top<-renderInfoBox({
    weeks<-genre() %>% group_by(title) %>% summarize(Weeks = n())
    top<-weeks[weeks$Weeks>52, ]
    percent<-signif(sum(top$Weeks)/sum(weeks$Weeks)*100, 3)
    infoBox(h4(paste(percent, "% of the lists are books on for > 1 year")), icon = icon("bookmark"))
  })
  
  output$one<-renderInfoBox({
    weeks<-genre() %>% group_by(title) %>% summarize(Weeks = n())
    one<-weeks[weeks$Weeks==1,]
    percent<-signif(nrow(one)/nrow(weeks)*100,3)
    infoBox(h4(paste(percent, "% of books are only on for one week")), icon = icon("bookmark-o"))
  })
    
})