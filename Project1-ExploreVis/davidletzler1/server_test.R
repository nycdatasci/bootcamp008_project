library(dplyr)


shinyServer(function(input,output){
  school.sub<- reactive({
    address.temp<-switch(input$test, "English/Language Arts"=select(address.temp, -Proficient.Math, -MathColor),
                         "Mathematics"=select(address.temp, -Proficient.ELA, -ELAColor)) %>%
      filter(Year==input$year, Grade==input$grade, Income.Bucket==input$income, 9>=input$range[1] & 9<=input$range[2])
  })
  
  census.sub<-reactive({
    
    copy_longlat@polygons = tract.longlat@polygons[switch("Highest Quintile", "Highest Quintile"=census.vital$Income.Bucket=="Highest Quintile",
                                                          "Second-Highest Quintile"=census.vital$Income.Bucket=="Second-Highest Quintile",
                                                          "Middle Quintile"=census.vital$Income.Bucket=="Middle Quintile",
                                                          "Second-Lowest Quintile"=census.vital$Income.Bucket=="Second-Lowest Quintile",
                                                          "Lowest Quintile"=census.vital$Income.Bucket=="Lowest Quintile",
                                                          "All"= census.vital$X>0)]
  })
  
  output$map<-renderLeaflet({
    address.temp<-address.test
    leaflet() %>%  addTiles() %>% setView(lng=-74, lat=40.7, zoom=11)
    
  })
  
  observe({
    proxy=leafletProxy("map", data=census.sub())
    proxy %>% clearShapes() %>% addPolygons(data=copy_longlat, weight=1, layerId=as.character(1:length(copy_longlat@data)))
  })
  
  observe({
    
    proxy=leafletProxy("map", data=school.sub())
    proxy %>% clearMarkers() %>% addCircleMarkers(lng=address.temp$long, lat=address.temp$lat, layerId= as.character(1:nrow(address.temp)), opacity=1, color = address.temp[,12], radius= 3, popup=paste(sep="<br/>", address.temp$School.Name, paste(address.temp[,9], "% Proficient")))
    
  })
  
  observe({
    proxy=leafletProxy("map")
    proxy %>% clearControls %>% addLegend("bottomright", pal = pal, values = address.test$Proficient.ELA, na.label= 'Not Reported', title = paste("Percent Proficient, ", input$year))
    
  })
})

observeEvent(input$year, {
  proxy=leafletProxy("map")
  if (input$year!="NA"){
    address.temp<-filter(address.test, Year==input$year)
  }
})
observeEvent(input$income, {
  proxy=leafletProxy("map")
  if (input$income!="All"){
    copy_longlat@polygons = tract.longlat@polygons[census.vital$Income.Bucket!=input$income]
    address.temp<-address.temp[address.temp$Geography %in% filter(census.vital, Income.Bucket==input)$Geography,]
  }
  proxy %>% removeShape(data=copy_longlat@polygons)    
  
})



observeEvent(input$range[1], {
  proxy=leafletProxy("map")
  if (input$range[1]!=0){
    address.temp<-filter(address.test, Year==input$year)
  }
})
observeEvent(input$range[2], {
  proxy=leafletProxy("map")
  if (input$range[2]!=100){
    args$max<-input$range[2]      }
})

observe({
  proxy=leafletProxy("map")
  if (input$test=="Mathematics"){
    proxy %>% clearMarkers() %>% 
      addCircleMarkers(lng=address.temp$long, lat=address.temp$lat, opacity=1, color = address.temp$MathColor, radius= 3, popup=paste(sep="<br/>", address.temp$School.Name, paste(address.temp$Proficient.Math, "% Proficient")))
  }
  else{
    proxy %>% clearMarkers() %>% 
      addCircleMarkers(lng=address.temp$long, lat=address.temp$lat, opacity=1, color = address.temp$ELAColor, radius= 3, popup=paste(sep="<br/>", address.temp$School.Name, paste(address.temp$Proficient.ELA, "% Proficient")))
    
  }
})

address.temp<-switch("Mathematics", "English/Language Arts"=select(address.test, -Proficient.Math, -MathColor), "Mathematics"=select(address.test, -Proficient.ELA, -ELAColor))  %>%
  filter(Year==2016, Grade=="All Grades", Income.Bucket %in% "Highest Quintile")
