library(shiny)
library(leaflet)
library(rCharts)
library(ggplot2)
library(dplyr)
library(scales)
library(DT)

source('global.R')
attach('./data/combined_movies.rda')

shinyServer(function(input, output){
  
  reactive_dataset <- reactive({
    if (input$menu1 != 'histogram'){
      dataset <- combined_movies[combined_movies$IMDB >= input$range[1] & movie_dataset$IMDB <= input$range[2] & combined_movies$Year >= input$range_year[1] & movie_dataset$Year <= input$range_year[2],]
    }
    else if (input$var == 'IMDB Score'){
      dataset <- combined_movies[combined_movies$IMDB >= input$range[1] & movie_dataset$IMDB <= input$range[2],]
    }  
    else if (input$var == 'Year') {
      dataset <- combined_movies[combined_movies$Year >= input$range_year[1] & movie_dataset$Year <= input$range_year[2],]  
    }
    else{
      dataset <- combined_movies
    }

    dataset
  })
  
  output$map <- renderLeaflet({
    leaflet(combined_movies) %>% 
      #addTiles() %>% 
      addProviderTiles('CartoDB.Positron') %>%
      addMarkers(popup = paste(
        paste0("<img src = ./", combined_movies$Poster_new, " width='200' height = '300'"), '<br>','<br>', '<br>',
        combined_movies$Film, ",", 
        combined_movies$Year, "<br>", 
        'Location:', combined_movies$Location.Display.Text, '<br>', 
        'IMDB rating:', combined_movies$IMDB, '<br>', 
        paste0('<a href = ', combined_movies$IMDB.LINK, " target = '_blank'", '> IMDB Link </a>'),
        "<style> div.leaflet-popup-content {width:auto !important;}</style>"
          )
        )
  })
 
observe( {
    new_data = reactive_dataset()  
    updated = new_data[!is.na(new_data$Film), ]
    proxy = leafletProxy('map', data = updated)
    proxy %>% clearMarkers() %>%
    addMarkers(popup = paste(
              paste0("<img src = ./", updated$Poster_new, " width='200' height = '300'"), '<br>', '<br>', '<br>',
              updated$Film, ",", 
              updated$Year, "<br>", 
              'Location:', updated$Location.Display.Text, '<br>', 
              'IMDB rating:', updated$IMDB, '<br>', 
              paste0('<a href = ', updated$IMDB.LINK, " target = '_blank'", '> IMDB Link </a>'),
              "<style> div.leaflet-popup-content {width:auto !important;}</style>"
                )
              )
  })
  
  observe({
  output$table <- DT::renderDataTable({
    data = reactive_dataset()
    stripped_data <- data[!is.na(data$Film), c('Film', 'Year', 'Director', 'Budget', 'Gross', 'Duration', 'IMDB')]
    cleaned_data <- stripped_data[!duplicated(stripped_data),]
    DT::datatable(cleaned_data, rownames = FALSE) %>% DT::formatStyle(input$selected, background = 'skyblue', fontWeight = 'bold')
    })
  })
  
  observe({
    output$groups <- DT::renderDataTable({
      data = reactive_dataset()
      if (input$by_group == 'Director'){
        df <- data %>% group_by(Director) %>% summarise(count = n()) %>% arrange(desc(count))
        DT::datatable(df[!is.na(df$Director), ]) 
      }
      else if (input$by_group == 'Borough'){
        df <- data %>% group_by(Borough) %>% summarise(count = n()) %>% arrange(desc(count))
        DT::datatable(df[!is.na(df$Borough), ]) 
      }
      else if (input$by_group == 'Neighborhood'){
        df <- data %>% group_by(Neighborhood) %>% summarise(count = n()) %>% arrange(desc(count))
        DT::datatable(df[!is.na(df$Neighborhood), ])
      }
    })
  })
  
  observe({
    output$histogram <- renderPlot({
      data = reactive_dataset()
      if(input$var == 'Year'){
        g <- ggplot(data, aes(x = as.numeric(data$Year), fill = ..x..)) +
        geom_histogram(breaks = seq(input$range_year[1], input$range_year[2], by = input$binsize_year)) +
        xlab('Year') +
        theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
        scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
        scale_x_continuous(breaks = seq(input$range_year[1], input$range_year[2], input$binsize_year), expand = c(0, 0)) +
        scale_y_continuous(breaks = seq(5, 200, 5), expand = c(0, 0)) 
        print(g)
      }
      else if (input$var == 'IMDB Score'){
        g <- ggplot(data, aes(x = data$IMDB, fill = ..x..)) + 
        geom_histogram(breaks = seq(input$range[1], input$range[2], by = input$binsize_IMDB)) +
        xlab('IMDB Score') +
        theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
        scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
        scale_x_continuous(breaks = seq(input$range[1], input$range[2], input$binsize_IMDB), expand = c(0, 0)) +
        scale_y_continuous(breaks = seq(5, 200, 5), expand = c(0, 0)) 
        print(g)
      }
      else if (input$var == 'Duration'){
        g <- ggplot(data, aes(x = data$Duration, fill = ..x..)) + 
          geom_histogram(breaks = seq(50, 250, by = input$binsize_duration)) + 
          xlab('Movie Duration') +
          scale_x_continuous(breaks = seq(50, 250, input$binsize_duration), expand = c(0, 5)) +
          scale_y_continuous(breaks = seq(0, 200, by = 10), expand = c(0, 0)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) 
        print(g)
      }
      else if (input$var == 'Budget'){
        g <- ggplot(data, aes(x = data$Budget, fill = ..x..)) + 
          geom_histogram(breaks = seq(0, 200000000, by = input$binsize_budget)) + 
          xlab('Budget') +
          scale_x_continuous(breaks = seq(0, 200000000, input$binsize_budget), labels = comma, expand = c(0, 0)) +
          scale_y_continuous(breaks = seq(0, 200, by = 5), expand = c(0, 0)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) 
        print(g)
      }
      else if (input$var == 'Gross'){
        g <- ggplot(data, aes(x = data$Gross, fill = ..x..)) + 
          geom_histogram(breaks = seq(0, 200000000, by = input$binsize_gross)) + 
          xlab('Gross') +
          scale_x_continuous(breaks = seq(0, 200000000, input$binsize_gross), labels = comma, expand = c(0, 0)) +
          scale_y_continuous(breaks = seq(0, 200, by = 5), expand = c(0, 0)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) 
        print(g)
      }
    })
  })
  

  observe({
    output$scatter <- renderPlot({
      if (input$regression %% 2 != 0){
        data = reactive_dataset()
        g <- ggplot(na.omit(data[, c(input$xvar, input$yvar, input$factor)]), aes_string(x = input$xvar, y = input$yvar)) +
          geom_point(aes_string(color = input$factor)) +
          scale_color_gradient(low = 'blue') +
          scale_colour_brewer() +  
          theme_dark() +
          #scale_x_continuous() +
          #scale_y_continuous() +
          geom_smooth(method = 'lm', formula = y~x, se = FALSE)
      }
      else {
        data = reactive_dataset()
        g <- ggplot(na.omit(data[, c(input$xvar, input$yvar, input$factor)]), aes_string(x = input$xvar, y = input$yvar)) +
          geom_point(aes_string(color = input$factor)) +
          scale_colour_brewer() +
          theme_dark()
          #scale_x_continuous() +
          #scale_y_continuous()
      }
      print(g)
      
    })
  })
  
  observe({
    output$box <- renderPlot({
      
      data = reactive_dataset()
      g <- ggplot(na.omit(data[, c(input$xvar_box, input$yvar_box)]), aes_string(x = input$xvar_box, y = input$yvar_box)) +
      geom_boxplot(aes(fill = ..x..)) +
      scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
      theme(legend.position = 'none') 
      #scale_x_continuous(expand = c(0,0)) +
      #scale_y_continuous(expand = c(0, 0)) 
      
      print(g)
      
    })
  })
})
