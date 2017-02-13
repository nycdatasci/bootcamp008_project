library(shiny)
library(ggplot2)
library(scales)
library(data.table)
library(plotly)
require(global.R)

options(shiny.error = browser)
source("./global.R")

function(input, output){
  
  #SETUP
  reactive_dataset <- reactive({
    # stripped_data <- data[, c("ASIN", 'Category', 'Manufacturer', 'Origin','Sale_Price', 'Avg_Customer_Rating', 
    #                           "Number_of_Customer_Questions","Number_of_Reviews", "List_Price", 
    #                           "1_Star_%", "2_Star_%","3_Star_%","4_Star_%", "5_Star_%")]
    # cleaned_data <- stripped_data[!duplicated(stripped_data),]
    dataset <- df
    
  })
  
  observe({
    output$table <- DT::renderDataTable({
      data = reactive_dataset()
      stripped_data <- data[, c("ASIN", 'Category', 'Manufacturer', 'Origin','Sale_Price', 'Avg_Customer_Rating', 
                                "Number_of_Customer_Questions","Number_of_Reviews", "List_Price", 
                                "1_Star_%", "2_Star_%","3_Star_%","4_Star_%", "5_Star_%")]
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
  
  #BAR CHARTS
  observe({
    output$bar <- renderPlot({
      
      data = reactive_dataset()
      
      if(input$var == 'Manufacturer'){
        if(input$remove_NA == TRUE) {
          d <- tbl_df(data) %>%
            filter(Manufacturer != c(''))
        } else if(input$remove_low_counts == TRUE) {
          d <- d %>%
            filter(count(Manufacturer) <= 10)
        } else {
          d <- data
        }
        g <- ggplot(d, aes(x = Manufacturer)) +
          geom_bar() +
          xlab('Manufacturer') +
          theme(axis.title = element_text(size = 20), 
                plot.title = element_text(size = 21, hjust = 0.5),
                axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_y_continuous()
        g
      }
      else if (input$var == 'Origin'){
        if(input$remove_NA == TRUE) {
          d <- tbl_df(data) %>%
            filter(Origin != c(''))
        } else {
          d <- data
        }
        g <- ggplot(d, aes(x = Origin)) +
          geom_bar() +
          xlab('Product Origin') +
          theme(axis.title = element_text(size = 20), 
                plot.title = element_text(size = 21, hjust = 0.5),
                axis.text.x = element_text(angle = 45, hjust = 1, size = 15)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_y_continuous()
        print(g)
      }
      else if (input$var == 'Category'){
        if(input$remove_NA == TRUE) {
          d <- tbl_df(data) %>%
            filter(Category != c(''))
        } else if(input$remove_low_counts == TRUE) {
          d <- d %>%
            filter(count(Category) <= 10)
        } else {
          d <- data
        }
        g <- ggplot(d, aes(x = Category)) +
          geom_bar() +
          xlab('Product Category') +
          theme(axis.title = element_text(size = 20), 
                plot.title = element_text(size = 21, hjust = 0.5),
                axis.text.x = element_text(angle = 45, hjust = 1, size = 15)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_y_continuous()
        g
      }
    })
  })
  
  
  #HISTOGRAMS
  observe({
    output$histogram <- renderPlot({
      
      data = reactive_dataset()
      
      if (input$var == 'Avg_Customer_Rating'){
        
        g <- ggplot(data, aes(x = `Avg_Customer_Rating`)) +
          geom_histogram() +
          xlab('Average Customer Rating') +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_x_continuous() +
          scale_y_continuous()
        g
      }
      else if (input$var == "1_Star_%"){
        g <- ggplot(data, aes(x = `1_Star_%`)) +
          geom_histogram() +
          xlab('% of 1 Star Reviews') +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_x_continuous() +
          scale_y_continuous()
        g
      }
      else if (input$var == "2_Star_%"){
        g <- ggplot(data, aes(x = `2_Star_%`)) +
          geom_histogram() +
          xlab('% of 2 Star Reviews') +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_fill_continuous()+
          scale_x_continuous() +
          scale_y_continuous()
        g
      }
      else if (input$var == "3_Star_%"){
        g <- ggplot(data, aes(x = `3_Star_%`)) +
          geom_histogram() +
          xlab('% of 3 Star Reviews') +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_x_continuous() +
          scale_y_continuous()
        g
      }
      else if (input$var == "4_Star_%"){
        g <- ggplot(data, aes(x = `4_Star_%`)) +
          geom_histogram() +
          xlab('% of 4 Star Reviews') +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_x_continuous() +
          scale_y_continuous()
        g
      }
      else if (input$var == "5_Star_%"){
        g <- ggplot(data, aes(x = `5_Star_%`)) +
          geom_histogram() +
          xlab('% of 5 Star Reviews') +
          theme(axis.title = element_text(size = 20), plot.title = element_text(size = 21, hjust = 0.5)) +
          scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
          scale_x_continuous() +
          scale_y_continuous()
        g
      }
    })
  })
  
  #BOXPLOTS
  observe({
    output$box <- renderPlot({
      data = reactive_dataset()
      data <- na.omit(data[, c(input$`xvar_box`, input$`yvar_box`)])
      g <- ggplot(data, aes_string(x = input$xvar_box, y = input$yvar_box)) +
        geom_boxplot() +
        scale_fill_gradient(low = "#56B1F7", high = "#132B43") +
        theme(legend.position = 'none') 
      g
    })
  })
  
  observe({
    output$scatter <- renderPlot({
      if (input$regression %% 2 != 0){
        data = reactive_dataset()
        data <- na.omit(data[, c(input$xvar, input$yvar, input$factor)])
        g <- ggplot(data, aes_string(x = input$xvar, y = input$yvar)) +
          geom_point(aes_string(colour = input$factor)) +
          scale_color_gradient(low = 'blue') +
          scale_colour_brewer() +  
          theme_dark() +
          scale_x_continuous() +
          scale_y_continuous() +
          geom_smooth(method = 'lm', formula = y~x, se = FALSE)
      }
      else {
        data = reactive_dataset()
        data <- na.omit(data[, c(input$xvar, input$yvar, input$factor)])
        g <- ggplot(data, aes_string(x = input$xvar, y = input$yvar)) +
          geom_point(aes(color = input$`factor`)) +
          scale_colour_brewer() +
          theme_dark() +
          scale_x_continuous() +
          scale_y_continuous()
      }
      g
    })
  })
}