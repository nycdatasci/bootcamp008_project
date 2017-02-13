library(dplyr)


shinyServer(function(input,output){

  school.sub<-reactive({
    address.temp<-switch(input$test, "English/Language Arts"=select(address.test, -Proficient.Math, -MathColor, Proficient=Proficient.ELA, Color=ELAColor), "Mathematics"=select(address.test, -Proficient.ELA, -ELAColor, Proficient=Proficient.Math, Color=MathColor))  %>%
      filter(Year==input$year, Grade==input$grade, Proficient>=input$range[1] & Proficient<=input$range[2], Income.Bucket %in% switch(input$income, "Highest Quintile"="Highest Quintile", "Second-Highest Quintile"="Second-Highest Quintile", "Middle Quintile"="Middle Quintile", "Second-Lowest Quintile"="Second-Lowest Quintile", "Lowest Quintile"="Lowest Quintile", "All"=c("Highest Quintile", "Second-Highest Quintile", "Middle Quintile", "Second-Lowest Quintile", "Lowest Quintile")))
  })
  
  census.sub<-reactive({
   polygons<-switch(input$income, "Highest Quintile"=tract.longlat@polygons[census.vital$Income.Bucket=="Highest Quintile"],
                                                         "Second-Highest Quintile"=tract.longlat@polygons[census.vital$Income.Bucket=="Second-Highest Quintile"],
                                                         "Middle Quintile"=tract.longlat@polygons[census.vital$Income.Bucket=="Middle Quintile"],
                                                         "Second-Lowest Quintile"=tract.longlat@polygons[census.vital$Income.Bucket=="Second-Lowest Quintile"],
                                                         "Lowest Quintile"=tract.longlat@polygons[census.vital$Income.Bucket=="Lowest Quintile"],
                                                         "All"= tract.longlat@polygons)
  })
  
  data.sub<-reactive({
    newdata<-switch(input$income, "Highest Quintile"=tract.longlat@data[census.vital$Income.Bucket=="Highest Quintile",],
                    "Second-Highest Quintile"=tract.longlat@data[census.vital$Income.Bucket=="Second-Highest Quintile",],
                    "Middle Quintile"=tract.longlat@data[census.vital$Income.Bucket=="Middle Quintile",],
                    "Second-Lowest Quintile"=tract.longlat@data[census.vital$Income.Bucket=="Second-Lowest Quintile",],
                    "Lowest Quintile"=tract.longlat@data[census.vital$Income.Bucket=="Lowest Quintile",],
                    "All"= tract.longlat@data)
  })
  
  output$map<-renderLeaflet({
   
    leaflet() %>%  addTiles() %>% setView(lng=-74, lat=40.7, zoom=11) 
      
  })
  
  observe({
    copy_longlat@polygons<-census.sub()
    copy_longlat@data<-data.sub()
    census.data<-switch(input$income, "Highest Quintile"=census.vital[census.vital$Income.Bucket=="Highest Quintile",],
                        "Second-Highest Quintile"=census.vital[census.vital$Income.Bucket=="Second-Highest Quintile",],
                        "Middle Quintile"=census.vital[census.vital$Income.Bucket=="Middle Quintile",],
                        "Second-Lowest Quintile"=census.vital[census.vital$Income.Bucket=="Second-Lowest Quintile",],
                        "Lowest Quintile"=census.vital[census.vital$Income.Bucket=="Lowest Quintile",],
                        "All"= census.vital)
    proxy=leafletProxy("map", data=copy_longlat)
    proxy %>% clearShapes() %>% addPolygons(weight=1, group="Tracts", color = "black", fillOpacity= 0.5, fillColor = census.data$Color, popup=paste(sep="<br/>", copy_longlat@data$NTAName, paste0("Median AnnualHousehold Income (2010): $",census.data$Median.Household.Income)))
  })
  
  observe({
   
    proxy=leafletProxy("map", data=school.sub())
    proxy %>% clearMarkers() %>% addCircleMarkers(lng=~long, lat=~lat, opacity=1, color = ~Color, group="Markers", radius= 3, popup= ~paste(sep="<br/>", School.Name, paste(Proficient, "% Proficient"))) %>%
    clearControls %>% addLegend("bottomright", pal = pal, values = address.test$Proficient.ELA, na.label= 'Not Reported', title = paste0("Percent Proficient in ", input$test, ", ", input$year)) %>%
      addLegend("topright", pal = pal2, values = census.vital$Median.Household.Income, na.label= 'Not Reported', title = "Median Household Income")
      
      
  })
  
})
