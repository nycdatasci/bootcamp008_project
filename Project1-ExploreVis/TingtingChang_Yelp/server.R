## server.R ##
library(shinydashboard)
library(shiny)
library(leaflet)
library(googleVis)
source("global.R")

shinyServer(function(input, output){
  data1 <- reactive({
    data.list[[which(attri_col == input$attributes)]]
  })
  
  data2 <- reactive({
    hp.list[[which(hp_col == input$hp.at)]]
  })
  
  output$chart1 <- renderPlot({
    ggplot(head(data1(), input$num_cat),
           aes(x = reorder(categories, total),
               y = total,
               fill = stars
    )) +
      geom_histogram(stat = "identity")  +
      coord_flip() +
      xlab("") +
      ylab("Total number of stores qualified")
  })
  
  
  
  output$hist1 <- renderPlot({
    ggplot(data2(), aes(fill = categories,
                        x = reorder(categories, total),
                        y = total)) +
      geom_bar(stat = "identity") + 
      coord_flip() + 
      theme_minimal() +
      theme(legend.position = 'none') +
      xlab("") 
  })
  
  output$map1 <- renderLeaflet({
    leaflet() %>%
      setView(lng=-112.0356, lat=33.50975, zoom=10) %>%
      addTiles() %>%
      addMarkers(data = dataset %>% filter(attributes.Ambience.hipster),
                 lng = ~longitude,
                 lat = ~latitude,
                 popup = paste(sep="<br/>",
                               paste(as.vector(dataset$name), ", Stars:", as.vector(dataset$stars)),
                               paste0(as.vector(dataset$full_address)),
                               "<style> .leaflet-popup-content-wrapper {
                           background-color: rgba(66, 191, 93, 0.7);
                           color: #f9f6f4;
                           font-size:11px;
                           font-weight: bold;
                           }</style>")
                 ,
                 icon = ~iconSet[c("red")]
                 )%>%
      addCircleMarkers(data = dataset %>% filter(!attributes.Ambience.hipster),
                       lng = ~longitude,
                       lat = ~latitude,
                       opacity = .8,
                       radius = 1,
                       color = 'green',
                       popup = paste(sep="<br/>",
                                     paste(as.vector(dataset$name), ", Stars:", as.vector(dataset$stars)),
                                     paste0(as.vector(dataset$full_address)),
                                     "<style> .leaflet-popup-content-wrapper {
                                     background-color: rgba(66, 191, 93, 0.7);
                                     color: #f9f6f4;
                                     font-size:11px;
                                     font-weight: bold;
  }</style>")
      )
  })
  
  output$map2 <- renderPlot({
    ggmap(get_googlemap(center = "phoenix, AZ",
                                   zoom = 12,
                                   maptype = "roadmap",
                                   scale = 2)) +
      geom_density2d(data = phx,                                
                     mapping = aes(x = longitude, y = latitude),    
                     color = "black") +
      stat_density2d(data = phx,                                
                     mapping = aes(x = longitude, y = latitude,
                                   alpha = ..level.., fill = ..level..),   
                     geom = "polygon") +
      scale_fill_gradient(low = "yellow", high = "red")   +           
      guides(alpha = FALSE) +    
      labs(fill = "Density",
           # Add the title to our map in a programmatic manner
           title = "hipsters in phoenix")   
    
    
})
  
  output$table <- renderDataTable({
    DT::datatable(summ, rownames=FALSE)
      
  })
  
  output$downloadTable <- downloadHandler(
    filename = "table.csv",
    content = function(file) {
      write.csv(summ, file)
    }
  )
  
})