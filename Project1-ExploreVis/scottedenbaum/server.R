df0 <- read.csv("df0.csv")
df1 <- read.csv("df1.csv") #reading in data frame of goals
library(googleVis)
library(tidyr)
library(ggplot2)
shinyServer(function(input, output){
  
  # plot_df <- reactive({
  #   print (input$selected)
  #   result = df0 %>% group_by_(input$selected) %>% summarise(count=n()) 
  #   return (result)
  #   
  # })
  

  input1 <- reactive({
    return (input$selectd)
  })
  
  input2 <- reactive({
    return (input$selected2)
  })
  
  # show histogram using googleVis
  output$hist <- renderGvis({
    
    #mydata <- plot_df()
    histdata <- df0 %>% group_by_(input$selected) %>% summarise(count=n()) 
    #bardata <- df0 %>% group_by_(c(input$selected, input$selected2)) %>% summarise(Count = n())
    gvisColumnChart(histdata, xvar=input$selected, yvar="count", 
                    options=list(title = paste("Number of Goals grouped by: ", input$selected),
                                               legend='none', 
                                              width = "200%", height = "500px",
                                              hAxis = "{title:'Groupings'}",
                                              yAxis = "{title:'Count}'",
                                              colors="['red']"
                                 ))
  })
  
  graph2 <- reactive({
    gdata <- df1 %>% filter(df1$Goal.Classification == input$filterbox) %>% group_by_(input$selected) %>%
      summarise(count = n())
    return (gdata)
  })
  
  output$col <- renderGvis({
    gvisColumnChart(graph2(), xvar=input$selected, yvar="count",
                    options = list(title = paste("Filtered Number of Families grouped by: ", input$selected),
                                   legend ='none', width = "automatic", height = "500px",
                                   hAxis = "{title:'Groupings'}",
                                   yAxis = "{title:'Count'}",
                                   colors="['red']"))
    # mydata <- graph2()
    # m <- ggplot(data = mydata, aes(x = count))
    # m <- m + geom_bar() + coord_polar()
    # print(m)
    
  })
  output$image2 <- renderImage({
      return(list(
        src = "BoothHope.jpg",
        filetype = "image/jpeg",
        alt = "This is George W. Booth"
      ))
    
    
  }, deleteFile = FALSE)
  
   output$bar1 <- renderGvis({
     mydata <- df0 %>% group_by_(input$selected, input$selected2) %>% summarise(count = n())
     bard <- spread(mydata, input$selected2, count)
     print(bard)
     gvisColumnChart(bard)#, xvar= yvar = count, options=list(legend ='none', width = 'automatic', height = '500px'))
    # gvisColumnChart( spread(input$selected2, count), col = count)
     #gvisColumnChart(mydata, xvar = input$selected2, yvar="count", options = list(legent='none', width = "automatic", height = "600px")
   })
  
})