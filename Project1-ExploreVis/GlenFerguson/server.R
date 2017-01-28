function(input, output) {
  
  dataInput1 <- reactive({
    filter(growth_data, FiveYearRange == paste0(input$years,'-',input$years+4))
  })

  dataInput2 <- reactive({
    cmd = paste0('filter(dataInput1()', ',', paste0('Region == "',input$regions, collapse='"|'), '")')
    eval(parse(text=cmd))
  })
  
  dataInput3 <- reactive({
    filter(bilateral_trade, Export_Country == input$Country)
  })
  
  dataInput4 <- reactive({
    cmd1 <- paste0('filter(bilateral_trade', ',', paste0('Export_Country == "',input$country, collapse='"|'), '")')
    select_bilat <- eval(parse(text=cmd1))
    select_bilat <- filter(select_bilat, Year == input$var_year)
    
    cmd2 <- paste0('c(',paste0('rep(',"'",list_country[input$country],"'",',8)', collapse=','),')')
    left = eval(parse(text=cmd2))
    right =c(paste0(rep(c('AME', 'ANZ', 'APA', 'ECA', 'LAC', 'USC', 'WEM', 'WEX'),length(input$country))))
    
    if(input$radio == 1) {
      Center=select_bilat$Index_value_trade_intensity
    }else {
      Center=select_bilat$Index_volume_trade_intensity
    }
    bilat_SK <- data.frame(From = `left`,
                           To    = `right`,
                           Weight= `Center`)
  })

  output$range = renderText({
    paste0(input$years,'-',input$years+4)
  })
  
  output$year = renderText({
    input$var_year
  })

  output$ex_country = renderText({
    paste0('Export Country: ', list_country[input$Country])
  })

#  output$SankeyTitle = renderText({   print(list_country[[input$country]])
#  })
  
  output$plot1 <- renderPlot({
    g <- ggplot(data=dataInput2(), aes_string(y = input$y, x = input$x)) + 
         geom_point(aes(color = Region), size = 3) +
         theme_tufte() + scale_color_brewer(palette = "Spectral") + 
         labs(x=names_col[[input$x]], y=names_col[[input$y]]) +
         theme(axis.text.x=element_text(size=14, angle = 30),
               axis.text.y=element_text(size=14),
               axis.title=element_text(size=14,face="bold"),
               legend.text = element_text(size=14),
               legend.title = element_text(size=14,face="bold"))
    if(input$checkbox1) {
      g + geom_text(aes(label=Country), hjust=0.5, vjust=1.5, check_overlap = TRUE)
    } else {
      g
    }
  }
  )
 output$plot2 <- renderPlot({
   g <- ggplot(data=dataInput3(), aes_string(y = input$variable, x = 'Year'))
   g + geom_bar(stat = "identity", aes(fill = Import_Region)) +
     theme_tufte() + scale_fill_brewer(palette = "Spectral") +
     labs(x='Year', y=names_bt_col[[input$variable]]) + 
     theme(axis.text.x=element_text(size=14, angle = 30),
           axis.text.y=element_text(size=14),
           axis.title=element_text(size=14,face="bold"),
           legend.text = element_text(size=14),
           legend.title = element_text(size=14,face="bold"))
 }
 )
  output$sankey <- renderGvis({
  result <- gvisSankey(data = dataInput4(), from="From", to="To", weight="Weight",
                       options=list(
                         width='100%',
                         height=525,
                         sankey="{link:  {color:  { fill: 'grey' }},
                                  node:  { color: { fill: '#a61d4c' },
                                  label: { color: '#871b47' } }}"))
})
}
