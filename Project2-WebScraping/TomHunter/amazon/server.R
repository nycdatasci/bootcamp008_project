library(shiny)
library(ggplot2)
library(scales)
library(data.table)
library(plotly)
require(global.R)

options(shiny.error = browser)
# require('./global.R')
# source("./global.R")

function(input, output){
  
  #SETUP
  reactive_dataset <- reactive({
    dataset <- df
  })
  
  observe({
    output$table <- DT::renderDataTable({
      data = reactive_dataset()
      stripped_data <- data[, c("ASIN", 'Category', 'Manufacturer', 'Origin','Sale Price', 'Avg Customer Rating', "Number of Customer Questions",
                                "Number of Reviews", "List Price", "1 Star %", "2 Star %","3 Star %",
                                "4 Star %", "5 Star %")]
      cleaned_data <- stripped_data[!duplicated(stripped_data),]
      DT::datatable(cleaned_data, rownames = FALSE) %>% formatStyle(input$selected, background = 'skyblue', fontWeight = 'bold')
    })
  })
  
  #DATATABLE
  observe({
    output$groups <- DT::renderDataTable({
      data = reactive_dataset()
    
      if (input$by_group == 'Manufacturer'){
        df <- data %>% 
          group_by(.,Manufacturer) %>% 
          summarise(count = n()) %>% 
          arrange(desc(count))
        DT::datatable(df[!is.na(df$Manufacturer), ]) 
      }
      else if (input$by_group == 'Origin'){
        df <- data %>% 
          group_by(Origin) %>% 
          summarise(count = n()) %>% 
          arrange(desc(count))
        DT::datatable(df[!is.na(df$Origin), ]) 
      }
      else if (input$by_group == 'Category'){
        df <- data %>% 
          group_by(Category) %>% 
          summarise(count = n()) %>% 
          arrange(desc(count))
        DT::datatable(df[!is.na(df$Category), ])
      }
    })
  })
  
  #HISTOGRAMS
  observe({
    output$histogram <- renderPlot({
      data = reactive_dataset()

      if(input$var == 'Manufacturer'){
        g <- ggplot(data, aes(x = input$`var`)) +
          # geom_histogram(breaks = seq(input$range_year[1], input$range_year[2], by = input$binsize_year)) +
          geom_histogram(stat = "count") +
          xlab(input$var) +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          # scale_x_continuous(breaks = seq(input$range_year[1], input$range_year[2], input$binsize_year), expand = c(0, 0)) +
          # scale_y_continuous(breaks = seq(5, 200, 5), expand = c(0, 0))
          scale_y_continuous()
        g
      }
      else if (input$var == 'Origin'){
        g <- ggplot(data, aes(x = input$`var`)) +
          # geom_histogram(breaks = seq(input$range[1], input$range[2], by = input$binsize_IMDB)) +
          geom_histogram(stat = "count") +
          xlab(input$var) +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          # scale_x_continuous(breaks = seq(input$range[1], input$range[2], input$binsize_IMDB), expand = c(0, 0))
          scale_fill_continuous()+
          scale_y_continuous(breaks = seq(5, 200, 5), expand = c(0, 0))
        print(g)
      }
      else if (input$var == 'Category'){
        g <- ggplot(data, aes(x = input$`var`)) +
          geom_histogram(stat = "count") +
          xlab(input$var) +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_fill_continuous()+
          scale_y_continuous(breaks = seq(5, 200, 5), expand = c(0, 0))
        print(g)
      }
      else if (input$var == 'Avg Customer Rating'){
        g <- ggplot(data, aes(x = input$`var`)) +
          geom_histogram() +
          xlab(input$var) +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          # scale_x_continuous(breaks = seq(input$range[1], input$range[2], input$binsize_IMDB), expand = c(0, 0))
          scale_fill_continuous()+
          scale_y_continuous(breaks = seq(5, 200, 5), expand = c(0, 0))
        print(g)
      }
      else if (input$var == "1 Star %"){
        g <- ggplot(data, aes(x = input$`var`)) +
          geom_histogram() +
          xlab(input$var) +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_fill_continuous()+
          scale_y_continuous(breaks = seq(5, 200, 5), expand = c(0, 0))
        print(g)
      }
      else if (input$var == "2 Star %"){
        g <- ggplot(data, aes(x = input$`var`)) +
          geom_histogram() +
          xlab(input$var) +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_fill_continuous()+
          scale_y_continuous(breaks = seq(5, 200, 5), expand = c(0, 0))
        print(g)
      }
      else if (input$var == "3 Star %"){
        g <- ggplot(data, aes(x = input$`var`)) +
          geom_histogram() +
          xlab(input$var) +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_fill_continuous()+
          scale_y_continuous(breaks = seq(5, 200, 5), expand = c(0, 0))
        print(g)
      }
      else if (input$var == "4 Star %"){
        g <- ggplot(data, aes(x = input$`var`)) +
          geom_histogram() +
          xlab(input$var) +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_fill_continuous()+
          scale_y_continuous(breaks = seq(5, 200, 5), expand = c(0, 0))
        print(g)
      }
      else if (input$var == "5 Star %"){

      }
    })
  })
  
  #BOXPLOTS
  observe({
    output$box <- renderPlot({
      
      data = reactive_dataset()
      d <- na.omit(data[, c(input$`xvar_box`, input$`yvar_box`)])
      g <- ggplot(d, aes(x = input$`xvar_box`, y = input$`yvar_box`)) +
        geom_boxplot() +
        scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
        theme(legend.position = 'none') 
      
      print(g)
      
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
}