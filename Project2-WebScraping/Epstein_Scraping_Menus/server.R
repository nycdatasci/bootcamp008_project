library(shiny)
library(leaflet)
library(rCharts)
library(ggplot2)
library(dplyr)
library(DT)
library(scales)
library(leaflet.extras)


load('./data/menus_reduced.rda')

shinyServer(function(input, output){
  
  reactive_dataset <- reactive({
    if (input$Cuisine == 'All'){
      dataset <- menus_reduced[!is.na(menus_reduced$Price),]
      if (input$Item != 'All'){
        dataset = filter(dataset, grepl(tolower(input$Item), tolower(dataset[, 'Title'])))
      }
      if (input$Ingredient != 'All'){
        dataset = filter(dataset, grepl(tolower(input$Ingredient), tolower(dataset[, 'Description'])))
      }
      if (input$Ingredient_2 != 'All'){
        dataset = filter(dataset, grepl(tolower(input$Ingredient_2), tolower(dataset[, 'Description'])))
      }
      if (input$Ingredient_3 != 'All'){
        dataset = filter(dataset, grepl(tolower(input$Ingredient_3), tolower(dataset[, 'Description'])))
      }
      if (input$Method != 'All'){
        dataset = filter(dataset, grepl(tolower(input$Method), tolower(dataset[, 'Description'])))
      }
    }
    else {
      dataset <- menus_reduced[!is.na(menus_reduced$Price),]
      dataset = filter(dataset, grepl(input$Cuisine, dataset[, 'Cuisine']))
      if (input$Item != 'All'){
        dataset = filter(dataset, grepl(tolower(input$Item), tolower(dataset[, 'Title'])))
      }
      if (input$Ingredient != 'All'){
        dataset = filter(dataset, grepl(tolower(input$Ingredient), dataset[, 'Description']))
      }
      if (input$Ingredient_2 != 'All'){
        dataset = filter(dataset, grepl(tolower(input$Ingredient_2), tolower(dataset[, 'Description'])))
      }
      if (input$Ingredient_3 != 'All'){
        dataset = filter(dataset, grepl(tolower(input$Ingredient_3), tolower(dataset[, 'Description'])))
      }
      if (input$Method != 'All'){
        dataset = filter(dataset, grepl(tolower(input$Method), tolower(dataset[, 'Description'])))
      }
    }
    dataset
  })
 
  
  output$map <- renderLeaflet({
    initial_data = menus_reduced[menus_reduced$Cuisine == "Russian", ]
    pinIcons <- icons(
      iconUrl = ifelse(initial_data$Price < 10.0, 'green.png', ifelse(initial_data$Price <= 20.0, 'yellow.png', 'red.png')),
      iconWidth = 24, iconHeight = 32,
      iconAnchorX = 15, iconAnchorY = 30
    )
    leaflet(initial_data) %>%
      addProviderTiles('Stamen.Toner', options = providerTileOptions(minZoom=12, maxZoom=17)) %>%
      fitBounds(~min(-70), ~min(38), ~max(-76), ~max(42)) %>%
      setView(lng = -73.95923, lat = 40.75, zoom = 12) %>%
      addMarkers(
                icon = pinIcons,
                 popup = paste('<i>', initial_data$Restaurant, '</i>', '<br>', 
                               '<b>', initial_data$Title, '</b>', '<br>', 
                               initial_data$Description, '<br>', 
                               '<b>', paste0('$', formatC(initial_data$Price, digits = 2, format = 'f')))
                 )

      
  })
  
  observe( {
    new_data = reactive_dataset()  
    pinIcons <- icons(
      iconUrl = ifelse(new_data$Price < 10.0, 'green.png', ifelse(new_data$Price < 15.0, 'yellow.png', ifelse(new_data$Price < 20.0, 'orange.png', 'red.png'))),
      iconWidth = 24, iconHeight = 32,
      iconAnchorX = 15, iconAnchorY = 30,
      popupAnchorX = -2, popupAnchorY = -15
    )
    proxy = leafletProxy('map', data = new_data)
    proxy %>% 
    clearMarkers() %>%
    clearHeatmap() %>%  
    addMarkers(
              icon = pinIcons,  
               popup = paste('<i>', new_data$Restaurant, '</i>', '<br>',  
                             '<b>', new_data$Title, '</b>', '<br>',
                             new_data$Description, '<br>', 
                             '<b>', paste0('$', formatC(new_data$Price, digits = 2, format = 'f'))))
  })
  
  output$heatmap <- renderLeaflet({
    initial_data = menus_reduced[menus_reduced$Cuisine == "Russian", ]
    leaflet(initial_data) %>%
      addProviderTiles('Stamen.Toner', options = providerTileOptions(minZoom=12, maxZoom=17)) %>%
      fitBounds(~min(-70), ~min(38), ~max(-76), ~max(42)) %>%
      setView(lng = -73.95923, lat = 40.75, zoom = 12) %>%
      addHeatmap(lng = ~longitude, lat = ~latitude, intensity = ~Price, blur = 20, max = 50, radius = 15)
    
  })
  
  observe( {
    new_data = reactive_dataset()  
    proxy = leafletProxy('heatmap', data = new_data)
    proxy %>% 
      clearMarkers() %>%
      clearHeatmap() %>%  
      addHeatmap(lng = ~longitude, lat = ~latitude, intensity = ~Price, blur = 20, max = 50, radius = 15)
  })

  observe({
    output$table <- DT::renderDataTable({
      data = reactive_dataset()
      data = data[, 1:6]
      DT::datatable(data, rownames = FALSE) %>% formatStyle(input$selected, background = 'skyblue', fontWeight = 'bold')
    })
  })
  
  
  
  observe({
    stat_data = reactive_dataset()
      output$stats <- renderText({
        paste0(nrow(stat_data), ' results found')
      })
      output$heatstats <- renderText({
        paste0(nrow(stat_data), ' results found')
      })
      output$min <- renderText({
        paste0('Minimum price: ', '$', formatC(min(stat_data$Price), digits = 2, format = 'f'))
      })
      output$heatmin <- renderText({
        paste0('Minimum price: ', '$', formatC(min(stat_data$Price), digits = 2, format = 'f'))
      })
      output$max <- renderText({
        paste0('Max price: ', '$', formatC(max(stat_data$Price), digits = 2, format = 'f'))
      })  
      output$heatmax <- renderText({
        paste0('Max price: ', '$', formatC(max(stat_data$Price), digits = 2, format = 'f'))
      })
      output$mean <- renderText({
        paste0('Mean price: ', '$', formatC(mean(stat_data$Price), digits = 2, format = 'f'))
      })  
      output$median <- renderText({
        paste0('Median price: ', '$', formatC(median(stat_data$Price), digits = 2, format = 'f'))
      })  
      output$hist_stats <- renderText({
        paste0(nrow(stat_data), ' results found')
      })
    })

  
  observe({
    output$histogram <- renderPlot({
      data = reactive_dataset()
        g <- ggplot(data, aes(x = data$Price, fill = ..x..)) +
          geom_histogram(breaks = seq(3, max(data$Price) + 1, by = input$binsize)) +
          xlab('Price') +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient('Price', low = "#00e500", high = "#e50000", labels = dollar) +
          scale_x_continuous(breaks = seq(3, max(data$Price) + input$binsize, input$binsize), labels = dollar, expand = c(0, 0)) +
          scale_y_continuous(expand = c(0, 0))
        print(g)
    })
  })
})