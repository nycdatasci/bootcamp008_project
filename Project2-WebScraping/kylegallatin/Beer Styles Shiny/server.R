#beerStyles server

shinyServer(function(input, output){
  
  #reactive function for the ratings sliderbar
  numRatings <- reactive({
    beerStyle[beerStyle$Ratings >= input$ratings,]
  })
  
  avgRating <- reactive({
    numRatings()[beerStyle$Avg >= input$avg,]
  })
  
  #reactive function for the linear regression analysis
  reg <- reactive({
    temp = lm(avgRating()$Avg ~ avgRating()$ABV)
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
    ggplot(avgRating()[!is.na(avgRating()$Avg),], aes_string(x = 'Style', fill = fill())) + 
      geom_histogram(stat = 'count') +
      coord_flip()
  )
  
  
  output$plot2 <- renderPlot(
    ggplot(avgRating(), aes(ABV, Avg, col = Style)) + 
      geom_point() + 
      geom_abline(intercept = reg()$coefficients[1], slope = reg()$coefficients[2]) 
  )
  
  output$plot3 <- renderPlot(
    ggplot(avgRating(), aes(x = Style, y = Avg)) + 
      geom_boxplot() +
      coord_flip() +
      theme_minimal()
  )
  
  output$table1 <- renderDataTable(
    avgRating()
  )
  
  output$text <- renderPrint(
    summary(reg())
  )
  
  
})