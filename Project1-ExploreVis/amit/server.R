library(googleVis)
library(corrplot)
shinyServer(function(input, output){
  dataInput1 <- reactive({
    cor(empl %>%
          filter (region == input$in1) %>%
          select (empl,gdp,population,avg_temp,co2),method="pearson",use ="na.or.complete")
  })
  
  output$plot1 <- renderPlot({ 
    corrplot(dataInput1(), method = input$param1)
  })
  dataInput2 <- reactive({
    cor(empl %>%
          filter (country == input$in2) %>%
          select (empl,gdp,population,avg_temp,co2),method="pearson",use ="na.or.complete")
  })
  output$plot2 <- renderPlot({ 
    corrplot(dataInput2(), method = input$param2) 
  })
  output$gvis <- renderGvis({
    print(head(empl))
    gvisMotionChart(empl,
                    idvar = "country",
                    timevar = "year",
                    xvar = "gdp",
                    yvar = "empl",
                    sizevar ="population",
                    colorvar = "region",
                    options=list(width="1000px", height="600px"))
  })
})