# server.R

shinyServer(function(input, output, session) {

  ########## START ##########
  datesLoadedReact = reactive({
    infoBox(
      h4('Data loaded for'),
      paste(
        min(trips$Start.Date),
        '-',
        max(trips$End.Date)
      ),
      icon = icon('calendar')
    )
  })

  output$datesLoaded = renderInfoBox(
    datesLoadedReact()
  )

  ########## STATIONS ##########
  stationsMapReact = reactive({
    stationsMap('stations')
  })

  output$stationsMap = renderLeaflet(
    stationsMapReact()
  )

  staCountReact = reactive({
    infoBox(
      h4('Stations'),
      nrow(stations),
      icon = icon('home')
    )
  })

  output$staCount = renderInfoBox(
    staCountReact()
  )

  cityCountReact = reactive({
    infoBox(
      h4('Cities'),
      nrow(distinct(stations, landmark)),
      icon = icon('map-signs')
    )
  })

  output$cityCount = renderInfoBox(
    cityCountReact()
  )

  dockCountReact = reactive({
    infoBox(
      h4('Docks'),
      format(sum(stations$dockcount), scientific=F, decimal.mark=".", big.mark=","),
      icon = icon('plug')
    )
  })

  output$dockCount = renderInfoBox(
    dockCountReact()
  )

  staPerCityReact = reactive({
    stationColumn('staPerCity')
  })

  output$staPerCity = renderGvis(
    staPerCityReact()
  )

  staSartByHourReact = reactive({
    stationRoseChart(staStartByHour, input$stationDetail)
  })

  output$staStartByHour = renderPlot(
    staSartByHourReact()
  )

  staEndByHourReact = reactive({
    stationRoseChart(staEndByHour, input$stationDetail)
  })

  output$staEndByHour = renderPlot(
    staEndByHourReact()
  )

  staStartByHourComp1React = reactive({
    stationRoseChart(staStartByHour, input$staComp1)
  })

  output$staStartByHourComp1 = renderPlot(
    staStartByHourComp1React()
  )

  staStartByHourComp2React = reactive({
    stationRoseChart(staStartByHour, input$staComp2)
  })

  output$staStartByHourComp2 = renderPlot(
    staStartByHourComp2React()
  )

  staEndByHourComp1React = reactive({
    stationRoseChart(staEndByHour, input$staComp1)
  })

  output$staEndByHourComp1 = renderPlot(
    staEndByHourComp1React()
  )

  staEndByHourComp2React = reactive({
    stationRoseChart(staEndByHour, input$staComp2)
  })

  output$staEndByHourComp2 = renderPlot(
    staEndByHourComp2React()
  )

  staCalendarReact = reactive({
    stationCalendar(staStartByDate, stations, input$stationDetail)
  })

  output$staCalendar = renderGvis(
    staCalendarReact()
  )

  staCalendarComp1React = reactive({
    stationCalendar(staStartByDate, stations, input$staComp1)
  })

  output$staCalendarComp1 = renderGvis(
    staCalendarComp1React()
  )

  staCalendarComp2React = reactive({
    stationCalendar(staStartByDate, stations, input$staComp2)
  })

  output$staCalendarComp2 = renderGvis(
    staCalendarComp2React()
  )

  ########## TRIPS ##########
  observeEvent({
    input$tripsWhich
    input$tripsCutoff
  },
  {
    proxy = leafletProxy('tripsMap')
    clearShapes(proxy)

    if (input$tripsWhich > 0) {
      routesForMap = eval(parse(text = paste(input$tripsWhich)))
      proxy %>% addRoutes(routesForMap, input$tripsCutoff)
    }
  })

  maxTripABeReact = reactive({
    trip = getTrip(routesABe)

    infoBox(
      h4('Trip most taken (A:B=B:A)'),
      h6(trip),
      icon=icon('arrow-up')
    )
  })

  output$maxTripABe = renderInfoBox({
    maxTripABeReact()
  })

  maxTripABneReact = reactive({
    trip = getTrip(routesABne)

    infoBox(
      h4('Trip most taken (A:B!=B:A)'),
      h6(trip),
      icon=icon('arrow-up')
    )
  })

  output$maxTripABne = renderInfoBox({
    maxTripABneReact()
  })

  tripCountReact = reactive({
    infoBox(
      h4('Trips'),
      format(nrow(trips), scientific=F, decimal.mark=".", big.mark=","),
      icon=icon('exchange')
    )
  })

  output$tripCount = renderInfoBox({
    tripCountReact()
  })

  output$tripsMap = renderLeaflet(
    stationsMap('trips')
  )

  tripsSankeyReact = reactive({
    if (input$tripsWhich == 0) {
      routesData = data.frame(nameStart='From', nameEnd='To', n=input$tripsCutoff+1)
    } else {
      routesData = eval(parse(text = paste0(input$tripsWhich, 'Sankey')))
    }

    sankeyTrips(routesData, input$tripsCutoff)
  })

  output$tripsSankey = renderGvis({
    tripsSankeyReact()
  })

  tripsTableReact = reactive({
    tripsTable(input$tripsWhich)
  })

  output$tripsTable = renderGvis(
    tripsTableReact()
  )

  ########## BIKES ##########
  bikeCountReact = reactive({
    infoBox(
      h4('Bikes in use'),
      n_distinct(bikes),
      icon = icon('bicycle')
    )
  })

  output$bikeCount = renderInfoBox({
    bikeCountReact()
  })

  maxBikeReact = reactive({
    metric = input$bikesMetric
    bks = orderBikes(bikes, metric, 'desc')

    maxVal = as.integer(bks[1, metric])
    maxBike = as.integer(bks[1, 'Bike.No'])

    infoBox(
      h4(paste('Bike', maxBike)),
      paste(format(round(maxVal / ifelse(metric != 'n', 60, 1), 1), scientific=F, decimal.mark=".", big.mark=","), ifelse(metric != 'n', 'min', '')),
      icon = icon('arrow-up')
    )
  })

  output$maxBike = renderInfoBox({
    maxBikeReact()
  })

  minBikeReact = reactive({
    metric = input$bikesMetric
    bks = orderBikes(bikes, metric)

    minVal = as.integer(bks[1, metric])
    minBike = as.integer(bks[1, 'Bike.No'])

    infoBox(
      h4(paste('Bike', minBike)),
      paste(round(minVal / ifelse(metric != 'n', 60, 1), 1), ifelse(metric != 'n', 'min', '')),
      icon = icon('arrow-down')
    )
  })

  output$minBike = renderInfoBox({
    minBikeReact()
  })

  bikesPlotReact = reactive({
    bikeHisto(bikes, input$bikesMetric)
  })

  output$bikesPlot = renderGvis(
    bikesPlotReact()
  )

  bikesOpsReact = reactive({
    bikeTimeLine(input$bikeOpsDays)
  })

  output$bikesOps = renderGvis(
    bikesOpsReact()
  )

  ########## CUSTOMERS ##########
  custSubscrReact = reactive({
    valueBox(
      format(as.integer(select(filter(cust, Subscriber.Type == 'Subscriber'), n)), scientific=F, decimal.mark=".", big.mark=","),
      'Trips by Subscribers',
      icon=icon('address-book-o')
    )
  })

  output$custSubscr = renderValueBox(
    custSubscrReact()
  )

  custCustReact = reactive({
    valueBox(
      format(as.integer(select(filter(cust, Subscriber.Type == 'Customer'), n)), scientific=F, decimal.mark=".", big.mark=","),
      'Trips by Customers',
      icon=icon('credit-card')
    )
  })

  output$custCust = renderValueBox(
    custCustReact()
  )

  custSubscrVsCustReact = reactive({
    valueBox(
      round(
        as.integer(select(filter(cust, Subscriber.Type == 'Subscriber'), n)) /
          as.integer(select(filter(cust, Subscriber.Type == 'Customer'), n)),
        3
      ),
      'Trips: Customers vs. Subscribers',
      icon=icon('line-chart')
    )
  })

  output$custSubscrVsCust = renderValueBox(
    custSubscrVsCustReact()
  )

  custSubscrDurReact = reactive({
    valueBox(
      paste0(
        format(as.integer(select(filter(cust, Subscriber.Type == 'Subscriber'), dur) / 60 / 60), scientific=F, decimal.mark=".", big.mark=","),
        'h'
      ),
      'Total trip duration by Subscribers',
      icon=icon('clock-o')
    )
  })

  output$custSubscrDur = renderValueBox(
    custSubscrDurReact()
  )

  custCustDurReact = reactive({
    valueBox(
      paste0(
        format(as.integer(select(filter(cust, Subscriber.Type == 'Customer'), dur) / 60 / 60), scientific=F, decimal.mark=".", big.mark=","),
        'h'
      ),
      'Total trip duration by Customers',
      icon=icon('clock-o')
    )
  })

  output$custCustDur = renderValueBox(
    custCustDurReact()
  )

  custSubscrVsCustDurReact = reactive({
    valueBox(
      round(
        as.integer(select(filter(cust, Subscriber.Type == 'Subscriber'), dur)) /
          as.integer(select(filter(cust, Subscriber.Type == 'Customer'), dur)),
        3
      ),
      'Duration: Customers vs. Subscribers',
      icon=icon('bar-chart')
    )
  })

  output$custSubscrVsCustDur = renderValueBox(
    custSubscrVsCustDurReact()
  )

  custSubscrMedDurReact = reactive({
    valueBox(
      paste0(
        format(as.integer(select(filter(cust, Subscriber.Type == 'Subscriber'), medDur) / 60), scientific=F, decimal.mark=".", big.mark=","),
        'min'
      ),
      'Med. Duration by Subscribers',
      icon=icon('clock-o')
    )
  })

  output$custSubscrMedDur = renderValueBox(
    custSubscrMedDurReact()
  )

  custCustMedDurReact = reactive({
    valueBox(
      paste0(
        format(as.integer(select(filter(cust, Subscriber.Type == 'Customer'), medDur) / 60), scientific=F, decimal.mark=".", big.mark=","),
        'min'
      ),
      'Med. Duration by Customers',
      icon=icon('clock-o')
    )
  })

  output$custCustMedDur = renderValueBox(
    custCustMedDurReact()
  )

  custSubscrVsCustMedDurReact = reactive({
    valueBox(
      round(
        as.integer(select(filter(cust, Subscriber.Type == 'Subscriber'), medDur)) /
          as.integer(select(filter(cust, Subscriber.Type == 'Customer'), medDur)),
        3
      ),
      'Med. Duration: Customers vs. Subscribers',
      icon=icon('area-chart')
    )
  })

  output$custSubscrVsCustMedDur = renderValueBox(
    custSubscrVsCustMedDurReact()
  )

  ########## WEATHER ##########
  weatherTripsReact = reactive({
    weatherTripsChart(weatherTrips, input$weatherCity, input$weatherDate[1], input$weatherDate[2], input$weatherMetric)
  })

  output$weatherTrips = renderGvis({
    weatherTripsReact()
  })
})

