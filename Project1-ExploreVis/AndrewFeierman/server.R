## server.R ##

library(scales)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(ggvis)
library(leaflet)
library(RColorBrewer)
library(DT)
library(googleVis)


shinyServer(

  function(input, output, session){
  #customize data table output
  ed <- reactive({
    clean_bm %>% 
      select(City = city, Year, "Zip Code" = Zip.Code, "Site EUI" = SiteEUI, "Source EUI" = SourceEUI, "Weather Normalized Site EUI" =NormSiteEUI, "Weather Normalized Source EUI" = NormSourceEUI, "ENERGY STAR Score" = ENERGY.STAR.Score, "Reported Floor Area" = ReportedGFA, "Property Type" = PropType)%>%
      filter(City %in% input$data_cities, Year %in% input$data_years)
  })  
  
  # show data using DataTable
  output$table <- renderDataTable({
    datatable(ed(), rownames = c(ed)) %>% 
      formatStyle(input$selected, background="skyblue", fontWeight='bold')
  })

  
  graph1xlims <- reactive({
    xlim(input$xrange[1], input$xrange[2])
  })
  
  graph1ylims <- reactive({
    ylim(input$yrange[1], input$yrange[2])
  })
  
  output$graph1 <- renderPlot({
    plot_check <- clean_bm %>%
      filter(Year %in% input$show_years, city %in% input$show_cities)
    de <- ggplot(data = plot_check, aes(x = plot_check[input$xvar], y = plot_check[input$yvar], alpha = .05), size = .1) +
      geom_point(aes()) + 
      graph1xlims() +
      graph1ylims() +
      xlab(plotrev[input$xvar]) +
      ylab(plotrev[input$yvar]) +
      scale_color_discrete(name="City", breaks=c(input$show_cities), labels=c(input$show_cities)) +
      guides(alpha = FALSE) + 
      theme(axis.text = element_text(size=13), axis.title = element_text(size=14))
    if (input$yearcolor == "Year") {
      de <- de + geom_point(aes(color = factor(Year), alpha = (1/length(input$show_cities)))) + scale_color_discrete(name="Year", breaks=c(input$show_years), labels=c(input$show_years))
    }
    if (input$yearcolor == "City") {
      de <- de + geom_point(aes(color = factor(city), alpha = (1/length(input$show_cities))))
    }
    if (input$trendline == TRUE) {
      de <- de + geom_smooth(aes(group = city, color = city, fill = factor(city))) + scale_fill_manual(values = c("orange","purple", "red"), name = "Trendline(s)")
    }
    de
  })
  
  cityplots <- reactive({
    clean_bm %>%
      filter(city %in% input$radio)
  })
  
  citygroup <- reactive({
    cityplots()%>%
      group_by(Year) %>%
      summarise(count = n())
  })
  
  cityviolin <- reactive({
    cityplots() %>%
      filter(PropType %in% c("Office", "Warehouse", "Medical Office", "Hospital", "Education"))
  })

  output$city1 <- renderPlot({
    ggplot(citygroup(), aes(x = Year, y = count, fill = factor(Year))) + 
      geom_histogram(width = .4, stat='identity') + 
      ggtitle(paste0(input$radio, " Buildings\n Reporting Each Year")) + 
      ylab("") +
      theme_gdocs() +
      theme(plot.title = element_text(hjust = 0.5), axis.text = element_text(size=13), axis.title = element_text(size = 14)) +
      scale_fill_discrete(guide = F)
  })  

  output$city2 <- renderPlot({
    c2 <- ggplot(cityplots(), aes(y = ReportedGFA, x = NormSourceEUI, color = as.factor(Year))) +
      geom_point(alpha = .5) +
      ggtitle("Building Size vs. \nEnergy Use per Square Foot") +
      scale_color_discrete(name="Year") +
      ylab("Building Size (ft2)") +
      xlab("Energy Use Intensity (kBtu / ft2)") + 
      theme_gdocs() + 
      theme(plot.title = element_text(hjust = 0.5), axis.text = element_text(size=13), axis.title = element_text(size = 14)) + 
      scale_y_continuous(labels = comma)
    if (input$log==TRUE){
      c2 <- c2 + coord_trans(y = 'log', x = 'log')  
      }
    c2
  })
  
  output$city3 <- renderPlot({
    c3 <- ggplot(cityplots(), aes(x = ReportedGFA, y = ENERGY.STAR.Score, color = log10(NormSourceEUI))) +
      geom_point() + 
      ggtitle("Building Size vs. \nENERGY STAR Score") +
      xlab("Building Size (ft2)") +
      scale_color_gradient(name = "ENERGY STAR Scores", low = 'green', high = 'red') +
      guides(color=F) +
      theme_gdocs() +
      theme(plot.title = element_text(hjust = 0.5), axis.text = element_text(size=13), axis.title = element_text(size = 14)) +
      scale_x_continuous(labels = comma, breaks=seq(0, 3000000, 1000000), limits=c(0, 3000000))
    if (input$log==TRUE){
        c3 <- c3 + coord_trans(y = 'log') + geom_jitter()
      }
    c3
  })
  
  output$city4 <- renderPlot({
    ggplot(cityviolin(), aes(x = PropType, y = NormSourceEUI, group = PropType)) + 
      geom_violin(aes(fill = factor(PropType))) + 
      ylim(0, 1000) + 
      scale_color_brewer() + 
      ggtitle("Energy Use Intensity\n In Common Property Types") +
      xlab("Grouped Property Type") +
      ylab("Energy Use Per Square Foot\n (kBtu/ft2)") + 
      theme_gdocs() + 
      theme(legend.position='none', plot.title = element_text(hjust = 0.5), axis.text = element_text(size=13), axis.title = element_text(size = 14))
  })

  filteredData <- reactive({
    full_zips %>% filter(city.x %in% input$mapcity, Year %in% input$mapyear)
  })

  colorpal <- reactive({
    colorQuantile(colorRamp(c("#0000FF", "#FF0000"), interpolate="spline"), full_zips$MedSourceEUI, n = 10)
  })

  output$map <- renderLeaflet({
    leaflet(filteredData()) %>% addTiles() %>%
      setView(-73.90, 40.7128, zoom = 12) %>% 
      addCircles(~longitude, ~latitude, weight = 5, color = ~qpal(MedNormSourceEUI), fillColor = ~qpal(MedNormSourceEUI), fillOpacity = .9, popup = ~paste("Source EUI:", MedNormSourceEUI, " Zip Code:", zip), radius = ~full_zips$Count) %>%
      addLegend(position = "bottomleft", pal = qpal, values = ~MedNormSourceEUI, title = "Energy Consumption", labels = c("Low Energy Consumption","","","","","","","","", "High Energy Consumption"))
  })
?addLegend
  observe({
    qpal <- colorpal()
    if (input$mapcity == "NYC") {
      mapx <- -73.8 
      mapy <- 40.7128
      mapzoom <- 12
    }
    if (input$mapcity == "DC") {
      mapx <- -77
      mapy <- 38.94
      mapzoom <- 12
    }
    
    if(input$mapcity == "San Francisco") 
    {mapx <- -122.4194
      mapy <- 37.76 
      mapzoom <- 12
    }

    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>% 
      setView(lng = mapx, lat = mapy, zoom = mapzoom) %>%
      addCircles(~longitude, ~latitude, color = ~qpal(MedNormSourceEUI), weight = 5, fillColor = ~qpal(MedNormSourceEUI), fillOpacity = .9, popup = ~paste("Zip Code:", zip, "\n"," Source EUI:", MedNormSourceEUI), radius = ~full_zips$Count * 5)
  })
  
  #customize data table output
  cityinfo <- reactive({
    clean_bm %>% 
      select(City = city, Year, "Zip Code" = Zip.Code, "Site EUI" = SiteEUI, "Source EUI" = SourceEUI, "Weather Normalized Site EUI" =NormSiteEUI, "Weather Normalized Source EUI" = NormSourceEUI, "ENERGY STAR Score" = ENERGY.STAR.Score, "Reported Floor Area" = ReportedGFA, "Property Type" = PropType) %>%
      filter(City %in% input$data_cities, Year %in% input$data_years)
  })  
  
  #Stats feature to be added later!
  # output$willitwork <- reactive({
  #   paste0("Stats about ", input$radio)
  # })
  # 
  # output$citystats1 <- reactive({
  #   paste0(input$radio, " has released ", length(unique(cityplots()$Year)), " years of data.")
  # })
  # 
  # output$citystats2 <- reactive({
  #   paste0("In total, ", length(unique(cityplots()$ID)), " buildings have reported data to New York City.")
  # })
  
})
