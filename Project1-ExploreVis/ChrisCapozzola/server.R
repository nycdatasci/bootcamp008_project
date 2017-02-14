library(ggplot2)

function(input,output){
  output$plot <- renderPlot(
    cleanMapPlot(countries_data[countries_data$Country == input$country_input,], colombia_adm.df, unique(colombia_data$report_date)[input$dts],input$case_input)
  )
  output$summary <- renderPrint(
    print(unique(colombia_data$report_date)[input$dts])
  )
  
  
  output$freq <- renderPlot(
    cleanBarPlot(countries_data[countries_data$Country == input$country_input,],unique(colombia_data$report_date)[input$dts],input$case_input)
  )
  
  output$series <- renderPlot(
    cleanTrendPlot(countries_data[countries_data$Country == input$country_input,],input$case_input)
  )
}