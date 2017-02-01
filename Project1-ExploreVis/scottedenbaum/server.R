# df0 <- read.csv("df0.csv")
# df1 <- read.csv("df1.csv") 
# Poh <- read.csv("Poh.csv")
mf0 <- read.csv("mf0.csv")
#reading in data frame of goals
library(googleVis)
library(dplyr)
library(tidyr)
library(ggplot2)
library(wordcloud)
library(tm)
library(ggthemes)
shinyServer(function(input, output){


  mdata <- reactive({
    
    return (mf0 %>% filter(Goal.Classification %in% input$filterbox))
  })
  
  input2 <- reactive({
    return (input$selected2)
  })
  
  # show histogram using googleVis
  output$hist <- renderGvis({
    histdata <- mf0 %>% group_by_(input$selected) %>% summarise(count=n()) %>% arrange(desc(count))
    gvisColumnChart(histdata, xvar=input$selected, yvar="count", 
                    options=list(title = paste("Number of Goals grouped by: ", input$selected),
                                               legend='none', 
                                              width = "210%", height = "500px",
                                              hAxis = "{title:'Groupings'}",
                                              yAxis = "{title:'Count}'",
                                              colors="['red']")
                    )#columnchart
  })
  
  graph2 <- reactive({
    gdata <- mf0 %>% filter(mf0$Goal.Classification %in% input$filterbox) %>% group_by_(input$selected) %>%
      summarise(count = n()) %>% arrange(desc(count))
    return (gdata)
  })
 
 
  output$col <- renderGvis({
    gvisColumnChart(graph2(), xvar=input$selected, yvar="count",
                    options = list(title = paste("Number of Goals grouped by: ", input$selected),
                                   legend ='none', width = "210%", height = "500px",
                                   hAxis = "{title:'Groupings'}",
                                   yAxis = "{title:'Count'}",
                                   colors="['red']"))
    
  })
  
  output$cloud <- renderPlot({
    worddf <- count(mf0, Goal.Classification)
    wordcloud(words = worddf$Goal.Classification, freq = worddf$n, min.freq = 1)
  })
  
  output$rose <- renderPlot({
    
    g <- ggplot(mdata(), aes(x=Goal.Classification, fill = Goal.Classification)) +
      geom_bar(width = 1) + coord_polar() + scale_fill_brewer(palette="RdGy") + theme_hc() + 
      theme(axis.text.x = element_text(angle = 20, hjust = 1), 
            axis.ticks = element_blank(), axis.text.y = element_blank(), 
            panel.grid = element_blank(), axis.title.y = element_blank(), 
            axis.ticks.y = element_blank(), axis.ticks.x = element_blank(), 
            panel.grid.minor.x = element_blank() ) + ggtitle("Comparison of Goal Classification")  
    return(g)
})

  output$image2 <- renderImage({
      return(list(
        src = "www/BoothHope.jpg",
        filetype = "image/jpeg",
        alt = "This is George W. Booth"
      ))
  }, deleteFile = FALSE)
  
  output$imagePOH <- renderImage({
    return(list(
      src = "www/PathwayOfHope.jpg",
      filetype = "image/jpeg",
      alt = "This is Pathway of Hope"
    ))
  }, deleteFile = FALSE)
  
  output$imageClient <- renderImage({
    return(list(
      src = "www/Capture.jpg",
      filetype = "image/jpeg",
      alt = "This is a Pathway of Hope family"
    ))
  }, deleteFile = FALSE)
  
  output$imagePOHLogo <- renderImage({
    return(list(
      src = "www/POHLogo1.jpg",
      filetype = "image/jpeg",
      alt = "This is a Pathway of Hope family"
    ))
  }, deleteFile = FALSE)
  
   
   output$table <- DT::renderDataTable({
     datatable(mf0, rownames=FALSE) %>% 
       formatStyle(input$selected,  
                   background="skyblue", fontWeight='bold')
     # Highlight selected column using formatStyle
   })   
  
})