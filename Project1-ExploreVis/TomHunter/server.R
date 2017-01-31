library(ggplot2)
library(scales)
library(leaflet)
require(global.R)

function(input,output){
  
  #311 outputs
  
  #by borough
  output$bar_311_by_borough <- renderPlot({
    #unspecified logic
    if(input$exclude_unspecified == TRUE) {
      df_311subset <- df_311subset[!df_311subset$Borough %in% c('Unspecified'),]
    }
    
    g <- ggplot(data = df_311subset, aes(x = Borough))
    g <- g+geom_bar(aes(fill = Year))
    g <- g+ggtitle("311 Heating Complaints by Borough")
    g <- g+scale_y_continuous(labels = comma)
    g <- g+ylab("Total Complaints")
    g
    })
  
  #by year
  output$bar_311_by_year <- renderPlot({
    #unspecified logic
    if(input$exclude_unspecified == TRUE) {
      df_311subset <- df_311subset[!df_311subset$Borough %in% c('Unspecified'),]
    }
    
    g <- ggplot(data = df_311subset, aes(x = Year))
    g <- g+geom_bar(aes(fill = Borough))
    g <- g+ggtitle("311 Heating Complaints by Year")
    g <- g+scale_y_continuous(labels = comma)
    g <- g+ylab("Total Complaints")
    g
  })
  
  #by Winter
  output$bar_311_by_winter <- renderPlot({
    #unspecified logic
    if(input$exclude_unspecified == TRUE) {
      df_311subset <- df_311subset[!df_311subset$Borough %in% c('Unspecified'),]
    }
    
    #not winters logic
    if(input$exclude_not_winters == TRUE) {
      df_311subset <- df_311subset[!is.na(df_311subset$Winters),]
    }
    
    g <- ggplot(data = df_311subset, aes(x = Winters))
    g <- g+geom_bar(aes(fill = Borough))
    g <- g+ggtitle("311 Heating Complaints by Winter (Oct 1st - May 31st)")
    g <- g+scale_y_continuous(labels = comma)
    g <- g+ylab("Total Complaints")
    g
  })
  
  #Heat Seek outputs
  output$line_hs <- renderPlot({
    #all data
    plotable_data <- df_hs[!is.na(df_hs$temp),]
    
    #time series date ranges
    lower <- as.POSIXct(input$hs_date_inp[1], tz='EST')
    upper <- as.POSIXct(input$hs_date_inp[2], tz='EST')
    plotable_data <- plotable_data[plotable_data$created_at >= lower & plotable_data$created_at <= upper,]
    
    #filter by address
    plotable_data <- plotable_data %>% filter(., clean_address == input$hs_address_select)
    
    #remove outliers logic
    if(input$remove_outliers == TRUE) {
      plotable_data$temp <- remove_outliers(plotable_data$temp)
    }
    
    g <- ggplot(data = plotable_data, aes_string(x = plotable_data$created_at, y = plotable_data$temp))
    g <- g+xlab("Time")
    g <- g+ylab("Temperature (ºF)")
    
    #highlight violations logic
    if(input$group_by_violations == TRUE) {
      g <- g+geom_point(aes(colour = violation))
      g <- g+scale_colour_manual(values = c('#62B73A','#F7161A'))
      g <- g+theme(legend.title=element_text(size=14))
      g
    } else {
      g <- g+geom_point()
      g
    }
    
    })
  
  #sensor map
  output$map_hs <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles('CartoDB.Positron') %>%
      addMarkers(lng = sensor_mapping$lon, 
                 lat = sensor_mapping$lat,
                 popup = paste('Address:', sensor_mapping$unique_address, '<br>'))
  })
  
  #data
  output$data <- renderDataTable(
    df_hs,
    options = list(
      pageLength = 50,
      scrollCollapse = TRUE)
  )

  outputOptions(output, 'bar_311_by_borough', suspendWhenHidden = FALSE)
  outputOptions(output, 'bar_311_by_year', suspendWhenHidden = FALSE)
  outputOptions(output, 'bar_311_by_winter', suspendWhenHidden = FALSE)
  outputOptions(output, 'line_hs', suspendWhenHidden = FALSE)
  outputOptions(output, 'map_hs', suspendWhenHidden = FALSE)
  outputOptions(output, 'data', suspendWhenHidden = FALSE)
  
}
