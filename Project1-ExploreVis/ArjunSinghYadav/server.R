

  server <- function(input, output, session) {
    
    la2<- reactive({
      data.frame(la%>%select(crime_cat,lat,long)%>%
                       filter(crime_cat == input$yaxis))
      })
    df1 <- reactive({
      req(input$yaxis)
      color <- colorFactor(topo.colors(7), input$yaxis)
      df %>%
        select_("long", "lat", "occ_date", yaxis=input$yaxis) %>%
        filter(complete.cases(yaxis))
    }
      )
    
    df2 <- reactive({
      
      df1() %>%
        filter(occ_date > input$date_range[1] & occ_date < input$date_range[2])
     
    })

    # observe({
    #   print(input$date_range[1],input$date_range[2])
    #   print(class(input$date_range))
    #   print(nrow(df2()))
    # })
    
    output$mymap <- renderLeaflet({
      #input$goButton
      leaflet() %>%
        addTiles() %>%
        setView(lng =  -122.620608423371, lat = 45.4654788882659, zoom = 12)%>%
        addProviderTiles('OpenStreetMap.BlackAndWhite',layerId=1)
         
       
    })
    observe({
      
      proxy <- leafletProxy("mymap")
      proxy %>%
        clearShapes()%>%
        clearMarkers()%>%
        clearMarkerClusters()%>%
        addCircleMarkers(lng = df2()$lat, lat = df2()$long,clusterOptions = markerClusterOptions(),popup= paste(df2()$long, df2()$lat))
      })
    
    output$table <- renderDataTable({table_df},
                                    options = list(scrollX = TRUE))
    output$clus <- renderPlot({
      
      la2<-data.frame(la%>%select(crime_cat,lat,long)%>%
                   filter(crime_cat == input$yaxis))
      ggmap(get_googlemap(center = c(-122.651608423371,45.4899788882659),size=c(640,640),maptype = "roadmap",scale = 2,zoom=11))+ geom_density2d(aes(x = lat, y = long), data = la2, size = 0.3) + stat_density2d(data = la2,aes(x = lat, y = long, fill = ..level.., alpha = ..level..), size = 0.01,bins = 20, geom = "polygon") + scale_fill_gradient(low = "green", high = "black") +scale_alpha(range = c(0, 0.3), guide = FALSE)
    })
    
    
  }
  