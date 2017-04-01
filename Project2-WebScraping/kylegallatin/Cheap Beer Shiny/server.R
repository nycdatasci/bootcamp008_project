library(shinydashboard)
library(shiny)
library(dplyr)
#server
options(digits = 4)

shinyServer(function(input, output){
  
  #reactive function for beer name
  beers <- reactive({
    filter(classic, name == c(input$checkGroup))
  })
  
  #reactive function for beer attribute being assessed
  parameter <- reactive({
    input$selected
  })
  
  #first plot of graphs over time
  output$plot <- renderPlot(
    ggplot(beers(), aes_string(x = 'date', y = parameter(), col = 'name')) + 
      geom_smooth(se = FALSE) +
      ggtitle('Rating over Time')
  )
  
  #second plot of boxplots for averages
  output$plot2 <- renderPlot(
    ggplot(beers(), aes_string(x = 'name', y = parameter(), fill = 'name')) + 
      geom_boxplot() + 
      theme_minimal() +
      coord_flip() +
      ggtitle('Boxplot of Ratings')
  )
  
  output$plot3 <- renderPlot(
    ggplot(beers(), aes_string(x = 'year', y = parameter())) + 
      geom_boxplot() + 
      facet_grid(~name, scales = "free_x") +
      geom_smooth(aes(group = 1)) +
      coord_flip()
  )
  
  #table
  output$table <- renderDataTable(
    classic
  )
  
  #info graphics 
  #replace all "tastes" and classic_mean calc w reactive outputs 
  stats <- reactive({
    stats = beers()[colnames(beers()) == parameter()]
    stats = na.omit(cbind(beers()$name, stats))
    colnames(stats) <- c('name', parameter())
    stats %>% group_by(name) %>% summarise_each(funs(mean))
  })
  
  output$maxBox <- renderInfoBox({
    max_value <- max(stats()[,2])
    max_beer <- 
      stats()$name[stats()[,2]==max_value]
    infoBox(max_beer, max_value, icon = icon("hand-o-up"))
  })
  output$minBox <- renderInfoBox({
    min_value <- min(stats()[,2])
    min_beer <- 
      stats()$name[stats()[,2]==min_value]
    infoBox(min_beer, min_value, icon = icon("hand-o-down"))
  })

  
  
  
  
})