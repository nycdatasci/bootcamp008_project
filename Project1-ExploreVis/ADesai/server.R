library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)


shinyServer(function(input, output,session) {
  
  output$mymap<-  renderLeaflet(  {
  if(length(input$hood) == 0){
    hoods <- rt2$Neighborhood
  } else{
    hoods <- input$hood
  }
    #print(hoods)
    A <- rt2 %>% filter(Cost<input$price & Yelp<input$rating & Neighborhood == hoods  )
    #A <- rt2 %>% filter(Yelp<input$rating)
    #A <- rt2 %>%filter(Neighborhood == hoods)
   
    output$value <- renderPrint({ input$select })
    # Add default OpenStreetMap map tiles
    leaflet(A) %>% setView(lng=-117.1611, lat=32.7157, zoom = 10)%>%   
    addTopoJSON(topoData)%>%
    addTiles() %>%
      addMarkers(as.vector(A$Long), as.vector(A$Lat), popup = paste(sep="<br/>",
              paste0(A$Notes),
              paste0(A$Location),
              paste0("<a href='", A$URL, "'>Website</a>"),
              "<style> .leaflet-popup-content-wrapper {
              background-color: #AFD3EE; font-size:11px;font-weight: bold;
  }</style>"), icon = ~iconSet[c('burrito')])
  })
  
    # #Correlation  
    output$corrOut<-  renderPlot(  {
      if(length(input$hood) == 0){
        hoods <- rt2$Neighborhood
      } else{
        hoods <- input$hood
      }
      
      B <- rt2 %>% filter(Cost<input$price & Yelp<input$rating & Neighborhood == hoods  )
      corr <- subset(B, select = c(Cost,Volume, Tortilla, Temp, Meat, Fillings,
                                   Meat.filling, Uniformity, Salsa, Synergy,
                                   Wrap, overall), na.rm = TRUE)
     
      #print(corr)
        corr2<- cor(corr, use= 'pairwise.complete.obs')

        cplot <- corrplot(corr2, method='color', bg = 'yellow', type = 'lower', addgrid.col = 'grey')

            #output$value <- renderPrint({ input$hood2 })
             #  corrplot(B) %>%  cplot

        output$value <- renderPlot(cplot)
  })

      #Line graph
    output$line <- renderPlot({
      if(length(input$hood) == 0){
        hoods <- rt2$Neighborhood
      } else{
        hoods <- input$hood
      }
      
      C <- rt2 %>% filter(Cost<input$price & Yelp<input$rating & Neighborhood == hoods  )
      output$line <- renderPlot(
      ggplot(C, aes_string(x = input$num, y = "overall")) +
        geom_smooth(aes_string(fill = input$price))
    )
    
       
    })
})
