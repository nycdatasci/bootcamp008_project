library(ggplot2)

function(input,output){
  output$plot <- renderPlot(
    cleanMapPlot(countries_data[countries_data$Country == input$country_input,], colombia_adm.df, unique(colombia_data$report_date)[input$dts],input$case_input)
  )
}