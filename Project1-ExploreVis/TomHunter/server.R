library(ggplot2)
library(plotly)
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
    g <- g+theme(legend.title=element_text(size=14))
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
    g <- g+theme(legend.title=element_text(size=14))
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
    g <- g+theme(legend.title=element_text(size=14))
    g <- g+scale_y_continuous(labels = comma)
    g <- g+ylab("Total Complaints")
    g
  })
  
  #Heat Seek outputs
  output$line_hs <- renderPlotly({
    #all data
    plotable_data <- df_hs[!is.na(df_hs$temp),]
    
    
    #filter by address
    plotable_data <- plotable_data %>% filter(., clean_address == input$hs_address_select)
    
    #remove outliers logic
    if(input$remove_outliers == TRUE) {
      plotable_data$temp <- remove_outliers(plotable_data$temp)
    }
    
    #highlight violations logic
    if(input$group_by_violations == TRUE) {
      cols <- c('#62B73A','#F7161A')
      # plotable_data$violation <- as.factor(plotable_data$violation, levels = c('Violation','In Compliance'))
      
      plot_ly(
        x = ~plotable_data$created_at,
        y = ~plotable_data$temp,
        name = 'Non-Violations',
        type = 'scatter',
        color = plotable_data$violation,
        colors = cols,
        mode = 'markers',
        text = paste(plotable_data$created_at, ' - ', plotable_data$temp, ' ºF')
      ) %>%
        layout(
          title = 'Remote Sensor Temperature Readings',
          xaxis = list(
            title = 'Time'
          ),
          yaxis = list(
            title = "Temperature (ºF)"
          )
        )
      
    } else {
      plot_ly(
        x = ~plotable_data$created_at,
        y = ~plotable_data$temp,
        type = 'scatter',
        mode = 'markers',
        text = paste(plotable_data$created_at, ' - ', plotable_data$temp, ' ºF')
      ) %>%
        layout(
          title = 'Remote Sensor Temperature Readings',
          xaxis = list(
            title = 'Time'
          ),
          yaxis = list(
            title = "Temperature (ºF)"
          )
        )
    }
    
    })
  
  #sensor map
  output$map_hs <- renderLeaflet({
    plotable_data <- df_hs[!is.na(df_hs$temp),]
    
    #outliers removal
    if(input$remove_outliers == TRUE) {
      plotable_data$temp <- remove_outliers(plotable_data$temp)
    }
    
    #plottable data logic
    if(input$violations_only == TRUE) {
      plotable_data <- tbl_df(plotable_data) %>%
        filter(violation == 'true')
    }
    
    #filter data for popup
    unique_sensors <- tbl_df(plotable_data) %>% 
      group_by(full_address, lat, lon) %>%
      summarise(avg_temp=mean(temp, na.rm = TRUE)) %>%
      dplyr::select(full_address, avg_temp, lat, lon) %>%
      dplyr::filter(!full_address == ', NY NA')
    
    #num violations & violation rate
    num_vio <- tbl_df(plotable_data) %>% 
      group_by(full_address, violation) %>%
      count(violation) %>%
      dplyr::filter(!full_address == ', NY NA') %>%
      dplyr::filter(violation == 'true') %>%
      dplyr::select(full_address, n)
    
    num_no_vio <- tbl_df(plotable_data) %>% 
      group_by(full_address, violation) %>%
      count(violation) %>%
      dplyr::filter(!full_address == ', NY NA') %>%
      dplyr::filter(violation == 'false') %>%
      dplyr::select(full_address, n)
    
    unique_sensors <- left_join(unique_sensors, num_vio) %>% 
      dplyr::rename(violations=n) %>%
      left_join(., num_no_vio) %>% 
      dplyr::rename(no_violations=n)
    
    unique_sensors$violations <- sapply(unique_sensors$violations, function(x) if (is.na(x)) {0} else {x})
    
    unique_sensors <- unique_sensors %>% 
                        mutate(total_readings = violations + no_violations) %>%
                        mutate(violation_rate = violations / total_readings)
    
    #formatting
    unique_sensors$avg_temp <- format(unique_sensors$avg_temp, digits = 3)
    unique_sensors$violation_rate <- percent(unique_sensors$violation_rate)
    
    leaflet() %>% 
      addProviderTiles('CartoDB.Positron') %>%
      addMarkers(lng = unique_sensors$lon, 
                 lat = unique_sensors$lat,
                 popup = paste(sep = "<br/>",
                               '<b>Address:</b>', unique_sensors$full_address,
                               '<b>Average Temp (ºF):</b>', unique_sensors$avg_temp,
                               '<b>Total Hours in Violation:</b>', unique_sensors$violations,
                               '<b>Total Readings:</b>', unique_sensors$total_readings,
                               '<b>Violation Rate:</b>', unique_sensors$violation_rate)
                 )
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
