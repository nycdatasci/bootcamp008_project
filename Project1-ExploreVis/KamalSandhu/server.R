


shinyServer(function(input, output){
  
  ############################# VALUE BOXES DRILLING ACTIVITY MAPS ###########################################
  output$NewWellsDrilledDA <- renderValueBox({
    drilling_activitySub <- subset(drilling_activity, Date > as.Date(input$date[1],"%y-%m-%d") 
                                   & Date < as.Date(input$date[2],"%y-%m-%d"))
    
    valueBox(
      dim(drilling_activitySub)[1], "Wells Drilled During This Period" ,icon = icon("download"),
      color = "purple"
    )
  })
  
  output$ContractorsActiveDA <- renderValueBox({
    drilling_activitySub <- subset(drilling_activity, Date > as.Date(input$date[1],"%y-%m-%d") 
                                   & Date < as.Date(input$date[2],"%y-%m-%d"))
    drillersThisPeriod <- drilling_activitySub %>%
      group_by(Drilling.Contractor) %>%
      distinct(Drilling.Contractor)
    
    valueBox(
      dim(drillersThisPeriod)[1], "Drilling Contractors Were Active" ,icon = icon("industry"),
      color = "purple"
    )
  })
  
  output$LicenceesActiveDA <- renderValueBox({
    drilling_activitySub <- subset(drilling_activity, Date > as.Date(input$date[1],"%y-%m-%d") 
                                   & Date < as.Date(input$date[2],"%y-%m-%d"))
    licenceesThisPeriod <- drilling_activitySub %>%
      group_by(Licencee) %>%
      distinct(Licencee)
    
    valueBox(
      dim(licenceesThisPeriod)[1], "Licencees Were Active" ,icon = icon("group"),
      color = "purple"
    )
  })
  ############################# VALUE BOXES DRILLING CHARTS ###########################################
  
  output$TopReasonDA <- renderValueBox({
    drilling_activitySub <- subset(drilling_activity, Date > as.Date(input$date[1],"%y-%m-%d") 
                                   & Date < as.Date(input$date[2],"%y-%m-%d"))
    topReasonDA <- drilling_activitySub %>%
      group_by(Activity.Type) %>%
      count()
    
    valueBox(
      topReasonDA[1,2], paste0("Were Drilled To ", levels(topReasonDA$Activity.Type)[as.numeric(topReasonDA[1,1])]),
      icon = icon("list"),
      color = "purple"
    )
  })
  
  output$TopDrillerDA <- renderValueBox({
    drilling_activitySub <- subset(drilling_activity, Date > as.Date(input$date[1],"%y-%m-%d") 
                                   & Date < as.Date(input$date[2],"%y-%m-%d"))
    topDrillerDA <- drilling_activitySub %>%
      group_by(Drilling.Contractor) %>%
      count(sort = T) %>%
      top_n(1)
    
    valueBox(
      topDrillerDA[1,2], paste0("Were Drilled By ", levels(topDrillerDA$Drilling.Contractor)[as.numeric(topDrillerDA[1,1])]),
      icon = icon("hand-peace-o"),
      color = "purple"
    )
  })
  
  output$TopLicenceeDA <- renderValueBox({
    drilling_activitySub <- subset(drilling_activity, Date > as.Date(input$date[1],"%y-%m-%d") 
                                   & Date < as.Date(input$date[2],"%y-%m-%d"))
    
    topLicenceeDA <- drilling_activitySub %>%
      group_by(Licencee) %>%
      count(sort = T) %>%
      top_n(1)
    
    valueBox(
      topLicenceeDA[1,2], paste0("Were Ordered By ", levels(topLicenceeDA$Licencee)[as.numeric(topLicenceeDA[1,1])]),
      icon = icon("trophy"),
      color = "purple"
    )
  })
  
  ############################# VALUE BOXES LICENCES MAPS ###########################################
  output$NewLicencesIssued <- renderValueBox({
    well_licencesSub <- subset(well_licences, Date > as.Date(input$date[1],"%y-%m-%d") 
                               & Date < as.Date(input$date[2],"%y-%m-%d"))
    
    valueBox(
      dim(well_licencesSub)[1], "New Well Licences Were Issued" ,icon = icon("newspaper-o"),
      color = "purple"
    )
  })
  
  output$PercentHorizontalLicences <- renderValueBox({
    well_licencesSub <- subset(well_licences, Date > as.Date(input$date[1],"%y-%m-%d") 
                               & Date < as.Date(input$date[2],"%y-%m-%d"))
    
    horizontalThisPeriod <- well_licencesSub %>%
      filter(Drilling.Type == "HORIZONTAL")
    
    valueBox(
      paste0(as.integer(100*(dim(horizontalThisPeriod)[1])/(dim(well_licencesSub))),"%"), "Were Horizontal" ,
      icon = icon("angle-double-right"),
      color = "purple"
    )
  })
  
  output$AverageDepthLicences <- renderValueBox({
    well_licencesSub <- subset(well_licences, Date > as.Date(input$date[1],"%y-%m-%d") 
                               & Date < as.Date(input$date[2],"%y-%m-%d"))
    avDepth <- well_licencesSub %>%
      summarise(depth = mean(Projected.Depth))
    
    valueBox(
      paste0(as.integer(avDepth), " m"), "Average Projected Depth" ,icon = icon("list"),
      color = "purple"
    )
  })
  
  
  
  ############################# VALUE BOXES LICENCES CHARTS ###########################################
  output$TopLicenceeLic <- renderValueBox({
    well_licencesSub <- subset(well_licences, Date > as.Date(input$date[1],"%y-%m-%d") 
                               & Date < as.Date(input$date[2],"%y-%m-%d"))
    
    topLicenceeLic <- well_licencesSub %>%
      group_by(Licencee) %>%
      count(sort = T) %>%
      top_n(1)
    
    valueBox(
      topLicenceeLic[1,2], paste0("Were Applied For By ",levels(topLicenceeLic$Licencee)[as.numeric(topLicenceeLic[1,1])]),
      icon = icon("hand-peace-o"),
      color = "purple"
    )
  })
  
  output$TopSubstanceLic <- renderValueBox({
    well_licencesSub <- subset(well_licences, Date > as.Date(input$date[1],"%y-%m-%d") 
                               & Date < as.Date(input$date[2],"%y-%m-%d"))
    
    topSubstanceLic <- well_licencesSub %>%
      group_by(Substance) %>%
      count(sort = T) %>%
      top_n(1)
    
    valueBox(
      topSubstanceLic[1,2], paste0("Were Licenced For ",levels(topSubstanceLic$Substance)[as.numeric(topSubstanceLic[1,1])]),
      icon = icon("list"),
      color = "purple"
    )
  })
  
  output$TopTypeLic <- renderValueBox({
    well_licencesSub <- subset(well_licences, Date > as.Date(input$date[1],"%y-%m-%d") 
                               & Date < as.Date(input$date[2],"%y-%m-%d"))
    
    topTypeLic <- well_licencesSub %>%
      group_by(Well.Type) %>%
      count(sort = T) %>%
      top_n(1)
    
    valueBox(
      topTypeLic[1,2], paste0("Were For ",levels(topTypeLic$Well.Type)[as.numeric(topTypeLic[1,1])]),      
      icon = icon("fire"),color = "purple"
    )
  })
  
  ############################# VALUE BOXES PIPELINE MAPS ###########################################
  output$pmv1 <- renderValueBox({
    pipelinesSub <- subset(pipelinesConst, Date > as.Date(input$date[1],"%y-%m-%d")
                               & Date < as.Date(input$date[2],"%y-%m-%d"))
    valueBox(
      dim(pipelinesSub)[1], "Pipelines Went Under Construction",
      icon = icon("share-alt"),
      color = "purple"
    )
  })

  output$pmv2 <- renderValueBox({
    pipelinesSub <- subset(pipelinesConst, Date > as.Date(input$date[1],"%y-%m-%d")
                               & Date < as.Date(input$date[2],"%y-%m-%d"))

    topCompanyPipe <- pipelinesSub %>%
      group_by(Licencee) %>%
      count(sort = T) %>%
      top_n(1)

    valueBox(
      topCompanyPipe[1,2], paste0("Were Started By ",levels(topCompanyPipe$Licencee)[as.numeric(topCompanyPipe[1,1])]), 
      icon = icon("trophy"),
      color = "purple"
    )
  })

  output$pmv3 <- renderValueBox({
    pipelinesSub <- subset(pipelinesConst, Date > as.Date(input$date[1],"%y-%m-%d")
                               & Date < as.Date(input$date[2],"%y-%m-%d"))

    topCountyPipe <- pipelinesSub %>%
      group_by(County.To) %>%
      count(sort = T) %>%
      top_n(1)

    valueBox(
      topCountyPipe[1,2], paste0("Ended At ",levels(topCountyPipe$County.To)[as.numeric(topCountyPipe[1,1])]),
      icon = icon("hand-pointer-o"),color = "purple"
    )
  })
  
  ############################# VALUE BOXES PIPELINE CHARTS ###########################################
  output$pcv1 <- renderValueBox({
    pipelinesSub <- subset(pipelinesConst, Date > as.Date(input$date[1],"%y-%m-%d")
                           & Date < as.Date(input$date[2],"%y-%m-%d"))
    
    topCountyPipe <- pipelinesSub %>%
      group_by(County.From) %>%
      count(sort = T) %>%
      top_n(1)
    
    valueBox(
      topCountyPipe[1,2], paste0("Started From ",levels(topCountyPipe$County.From)[as.numeric(topCountyPipe[1,1])]),
      icon = icon("globe"),color = "purple"
    )
  })

  output$pcv2 <- renderValueBox({
    pipelinesSub <- subset(pipelinesConst, Date > as.Date(input$date[1],"%y-%m-%d")
                               & Date < as.Date(input$date[2],"%y-%m-%d"))

    avLength <- pipelinesSub %>%
      summarise(mean(Length))

    valueBox(
      paste0(as.integer(avLength[1,1]), " km"), "Was the Average Length of a Pipeline", 
      icon = icon("long-arrow-right"),
      color = "purple"
    )
  })

  output$pcv3 <- renderValueBox({
    pipelinesSub <- subset(pipelinesConst, Date > as.Date(input$date[1],"%y-%m-%d")
                               & Date < as.Date(input$date[2],"%y-%m-%d"))

    topCompanyPipe <- pipelinesSub %>%
      group_by(Licencee) %>%
      count(sort = T) %>%
      top_n(1)

    valueBox(
      topCompanyPipe[1,2], paste0("Were Started By ",levels(topCompanyPipe$Licencee)[as.numeric(topCompanyPipe[1,1])]),
      icon = icon("hand-o-left"),color = "purple"
    )
  })
  
  
  ############################# VALUE BOXES ABANDONED WELLS MAPS ###########################################
  
  output$TotalWells <- renderValueBox({
    valueBox(
      dim(abandoned_wells)[1], "Abandoned Wells in Alberta" ,icon = icon("ban"),
      color = "purple"
    )
  })
  
  output$MostFrom <- renderValueBox({
    valueBox(
      as.numeric(mostAbndWellsFrom$n[1]), "Abandoned Wells from CNRL" ,icon = icon("exclamation"),
      color = "purple"
    )
  })
  
  output$Category <- renderValueBox({
    x <- as.integer(100*dim(categoryAbnd)[1]/(dim(abandoned_wells)[1]))
    valueBox(
      paste0(x,"%"), "Are Not Product Categorized",
      icon = icon("bomb"),
      color = "purple"
    )
  })
  
  
  ############################# CHARTS DRILLING ###########################################
  #1 Activity By month
  #2 Contractors active by month
  #3 Licencees active by month
  #5 Busiest drilling contractors
  #5 Busiest drilling licencess
  #6 Busiest counties
  #7 Top reasons for drilling
  
  output$chartDrilling <- renderDygraph({
    if (input$radioDA == 1) {
      drillsByMonthG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    } else if (input$radioDA == 2) {
      drillersByMonthG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioDA == 3) {
      licenceesByMonthDAG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioDA == 4) {
      top5TimeG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioDA == 5) {
      top5TimeLicG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioDA == 6) {
      top5TimeLicCountyDAG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioDA == 7) {
      top5TimeLicReasonDAG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }
  })
  
  
  
  
  ############################# CHARTS LICENCES ###########################################
  #1 Number of licences given out by month
  #2 Number of licencees active by month
  #3 Products for which wells were dug
  #4 Depths by Drilling Types
  #5 Depths by substance
  #6 Depths by well type
  #7 Depths by companies
  
  output$chartLicences <- renderDygraph({
    if (input$radioLic == 1) {
      licencesByMonthLicG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    } else if (input$radioLic == 2) {
      licenceesByMonthLicG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioLic == 3) {
      typesLicG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioLic == 4) {
      depthsTypesG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioLic == 5) {
      depthsSubstanceG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioLic == 6) {
      depthsWellTypesTimeG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioLic == 7) {
      depthsCompaniesG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }
  })
  
  
  
  
  ############################# CHARTS Pipelines ###########################################
  ##1 Number of pipeline starts per month
  #2 Number of companies starting pipeline construction
  #3 Length of pipelines on which construction began
  #4 County where the pipeline started
  #5 County where the pipeline ended
  output$chartPipelines <- renderDygraph({
    if (input$radioPipe == 1) {
      pipesByMonthG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioPipe == 2) {
      permiteesByMonthG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioPipe == 3) {
      lengthByMonthG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40) 
    }else if (input$radioPipe == 4) {
      countyFromMonthG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }else if (input$radioPipe == 5) {
      countyToMonthG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }
  })
  
  
  
  
  
  ############################ CHARTS PRICE AND VOLUME ###################################
  #Production by month for conventional oil
  #Production by month for un-conventional oil
  #Price of WCS by month
  #Price of Brent by month
  #Breakdown of productions
  
  
  output$priceProduction <- renderDygraph({
    if (input$radioPP == 1){
      pricesG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    } else if(input$radioPP == 2){
      productionG %>% dyRangeSelector(dateWindow = c(input$date[1], input$date[2]), height = 40)
    }
    
  })
  
  
  
  ############################# MAP DRILLING ###########################################
  output$mapDrillingdf <- renderLeaflet({
    abMap %>%
      addLayersControl(
        baseGroups = c("Map", "Lights Off"),
        overlayGroups = c("Locations","Heatmap"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })

  observe({

    drilling_activitySub <- subset(drilling_activity, Date > as.Date(input$date[1])
                                   & Date < as.Date(input$date[2]))

    leafletProxy("mapDrillingdf", data = drilling_activitySub) %>%
      addCircleMarkers(data = drilling_activitySub, ~Long,~Lat,
                       clusterOptions = markerClusterOptions(), group = "Locations") %>%
      addWebGLHeatmap(data = drilling_activitySub, lng = ~Long, lat = ~Lat,group = "Heatmap",
                       size = "15000",opacity = .6, alphaRange = .7)

  })
  
  ############################# MAP LICENCES ###########################################
  output$mapLicencesdf <- renderLeaflet({
    abMap %>%
      addLayersControl(
        baseGroups = c("Map", "Lights Off"),
        overlayGroups = c("Locations","Heatmap"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })

  observe({
    well_licencesSub <- subset(well_licences, Date > as.Date(input$date[1],"%y-%m-%d")
                               & Date < as.Date(input$date[2],"%y-%m-%d"))

    leafletProxy("mapLicencesdf", data = well_licencesSub) %>%
      addWebGLHeatmap(data = well_licencesSub, lng = ~Long, lat = ~Lat,group = "Heatmap",
                      size = "15000",opacity = .6, alphaRange = .7) %>%
      addCircleMarkers(data = well_licencesSub, ~Long,~Lat,
                       clusterOptions = markerClusterOptions(), group = "Locations")
  })

  ############################# MAP PIPELINES ###########################################

  output$mapPipelinesdf <- renderLeaflet({
    abMap %>%
      addLayersControl(
        baseGroups = c("Map", "Lights Off"),
        overlayGroups = c("Start Locations","End Locations","Heatmap - Start Locations","Heatmap - End Locations"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })

  observe({
    pipelinesConstSub <- subset(pipelinesConst, Date > ymd(input$date[1]), Date < ymd(input$date[2]))

    leafletProxy("mapPipelinesdf", data = pipelinesConstSub) %>%
      addWebGLHeatmap(data = pipelinesConstSub, lng = ~fLong, lat = ~fLat,group = "Heatmap - Start Locations",
                      size = "15000",opacity = .4, alphaRange = .7, gradientTexture = "./www/blue.jpg") %>%
      addWebGLHeatmap(data = pipelinesConstSub, lng = ~tLong, lat = ~tLat,group = "Heatmap - End Locations",
                      size = "15000",opacity = .4, alphaRange = .7) %>%
      addCircleMarkers(data = pipelinesConstSub, ~fLong,~fLat,color = "orange",
                       clusterOptions = markerClusterOptions(), group = "Start Locations") %>%
      addCircleMarkers(data = pipelinesConstSub, ~tLong,~tLat, color = "#03F",
                       clusterOptions = markerClusterOptions(), group = "End Locations")
  })

  ############################# MAP ABANDONED ###########################################

  output$mapAbandoneddf <- renderLeaflet({
    abMap %>%
      addLayersControl(
        baseGroups = c("Map", "Lights Off"),
        overlayGroups = c("Locations","Heatmap"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })

  observe({
    num <- dim(abandoned_wells)[1]*input$markersAbnd/100

    abandoned_wells_sample <- sample_n(abandoned_wells,num)

    leafletProxy("mapAbandoneddf", data = abandoned_wells_sample) %>%
      addCircleMarkers(data = abandoned_wells_sample, ~Long,~Lat,
                               clusterOptions = markerClusterOptions(), group = "Locations") %>%
      addWebGLHeatmap(data = abandoned_wells_sample, lng = ~Long, lat = ~Lat,group = "Heatmap",
                      size = "15000",opacity = .6, alphaRange = .7)
  })


  ############################# DATA TABLES ###########################################
  output$summaryDrillingdf = renderDataTable({
    drilling_activitySub <- subset(drilling_activity, Date > as.Date(input$date[1],"%y-%m-%d")
                                   & Date < as.Date(input$date[2],"%y-%m-%d"))
    drilling_activitySub[,c('Date','Licencee','Drilling.Contractor','Activity.Type','County.Name')]
  })

  output$summaryLicencesdf = renderDataTable({
    well_licencesSub <- subset(well_licences, Date > as.Date(input$date[1],"%y-%m-%d")
                               & Date < as.Date(input$date[2],"%y-%m-%d"))
    well_licencesSub[,c('Date','Licencee','Mineral.Rights','Projected.Depth','Drilling.Type','Well.Type')]
  })
  output$summaryPipelinesdf = renderDataTable({
    pipelinesConstSub <- subset(pipelinesConst, Date > ymd(input$date[1]), Date < ymd(input$date[2]))
    pipelinesConstSub[,c('ActivityStartDate','Licencee', 'Length', 'County.From','County.To')]
  })
  output$summaryAbandoneddf = renderDataTable({
    abandoned_wells[,c('Licensee','Status','Fluid','SurfLoc')]
  })
})
