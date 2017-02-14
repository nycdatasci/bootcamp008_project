#beerStyles server

shinyServer(function(input, output){
  
  #reactive function for the ratings sliderbar
  numRatings <- reactive({
    beerStyle[beerStyle$Ratings >= input$ratings,]
  })
  
  avgRating <- reactive({
    numRatings()[beerStyle$Avg >= input$avg,]
  })
  
  #reative function for alcohol content, just checking for linear regression
  alcoholContent <- reactive({
    avgRating()[beerStyle$ABV >= input$alcohol,]
  })
  
  #reactive function for the linear regression analysis
  reg <- reactive({
    temp = lm(alcoholContent()$Avg ~ alcoholContent()$ABV)
    return(temp)
  })
  

  
  #reactive function for plot fill if numRatings is high
  fill <- reactive({
    if (input$ratings > 4500) {
      return('Brewery')
    } else {
      return(NULL)
    }
  })
  
  #plot of the count of each style, with Bros ratings 
  output$plot1 <- renderPlot(
    ggplot(alcoholContent()[!is.na(alcoholContent()$Avg),], aes_string(x = 'Style', fill = fill())) + 
      geom_histogram(stat = 'count') +
      coord_flip() +
      ggtitle('Number of Beers by Style')
  )
  
  
  output$plot2 <- renderPlot(
    ggplot(alcoholContent(), aes(ABV, Avg, col = Style)) + 
      geom_point() + 
      geom_abline(intercept = reg()$coefficients[1], slope = reg()$coefficients[2]) +
      ylab('Average Rating') +
      ggtitle('Average Rating by Alcohol Content')
  )
  
  output$plot3 <- renderPlot(
    ggplot(alcoholContent(), aes(x = Style, y = Avg, fill = Style)) + 
      geom_boxplot() +
      coord_flip() +
      theme_minimal() +
      ggtitle('Average Rating by Style') +
      ylab('Average Rating')
  )
  
  output$table1 <- renderDataTable(
    alcoholContent()
  )
  
  output$text <- renderPrint(
    summary(reg())
  )
  
  
})