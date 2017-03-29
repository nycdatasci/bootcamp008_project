library(googleVis)
library(dplyr)
library(reshape)
library(ggplot2)

shinyServer(function(input, output){
  
  era<-reactive({
    era<-switch(input$era, "pre"=filter(sell.review, published_date < as.Date("2013-07-15", "%Y-%m-%d")), "post"=filter(sell.review, published_date >= as.Date("2013-07-15", "%Y-%m-%d")))
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
  
  output$review<-renderPlot({
    ggplot(data=reviews.per, aes(x=Format, y=Percentage)) + geom_bar(stat="identity", aes(fill=Type), position="dodge")
  })
    
})