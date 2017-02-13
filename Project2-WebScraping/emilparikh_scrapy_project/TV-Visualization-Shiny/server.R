suppressMessages({
  library(shiny)
  library(DT)
})

source("helpers.R")

#master plot, table data, and group color info
masterInfo <- getFacetPlotsAndData()

shinyServer(function(input, output){
  
  thePlot <- reactive({masterInfo[[input$plotType]]})
  
  # set detailPlot$data = NULL if the plot changes
  # only want data for detailPlot to be retrieved when a plot is zoomed
  observeEvent(thePlot(),{
    detailPlot$title <- NULL
  })
  
  # plot the master scatter plot w/ facet wrap
  output$facetPlot <- renderPlot(thePlot())
  
  output$detailPlot <- renderPlot({
    if(!is.null(detailPlot$title)){
      getDetailPlot(
        detailPlot$data,
        detailPlot$title,
        detailPlot$xAxis,
        detailPlot$yAxis,
        detailPlot$xRange,
        detailPlot$yRange,
        detailPlot$ptColor
      )
    }
  })
  
  # get chosen values from master plot
  detailPlot <- reactiveValues(
    data = NULL,
    title = NULL,
    xAxis = NULL,
    yAxis = NULL,
    xRange = NULL,
    yRange = NULL,
    ptColor = NULL,
    facet = NULL,
    ofType = NULL
  )
  
  observe({
    brush <- input$facetPlot_brush
    if (!is.null(brush)) {
      detailPlot$xAxis = brush$mapping$x
      detailPlot$yAxis = brush$mapping$y
      detailPlot$xRange = c(round(brush$xmin), round(brush$xmax))
      detailPlot$yRange = c(brush$ymin, brush$ymax)
      
      # value is either "Genre" or "Network"
      detailPlot$facet <- brush$mapping$panelvar1
      
      # the name of the genre or network that is zoomed
      detailPlot$ofType <- brush$panelvar1
      
      
      if(detailPlot$facet == "Genre"){
        data <- masterInfo[["genre_data"]]
      }else {
        data <- masterInfo[["network_data"]]
      }
      
      detailPlot$data = data[data[detailPlot$facet]==detailPlot$ofType,]
      
      detailPlot$title = paste(detailPlot$ofType, ": ", detailPlot$yAxis, " by ", detailPlot$xAxis)
      detailPlot$ptColor = masterInfo[["namedColors"]][detailPlot$ofType]
      
      output$dataTable <- renderDataTable({
        if(detailPlot$yAxis == "`Median Rating`"){
          yAxis <- "Rating"
          yRange <- detailPlot$yRange
        } else if(detailPlot$yAxis == "`Median Number of Years`"){
          yAxis <- "`Number of Years`"
          yRange <- detailPlot$yRange
        } else {
          yAxis <- "Year" # not really
          yRange <- c(1920, 2020)
        }
        
        d <- masterInfo[["all_data"]]
        d <- d[d[detailPlot$facet]==detailPlot$ofType,]
        d <- d %>%
          filter(Year >= detailPlot$xRange[1] & Year <= detailPlot$xRange[2]) %>%
          filter_(paste(yAxis, ">=", yRange[1], "&", yAxis, "<=", yRange[2])) %>%
          arrange(Year, desc(Votes))
        
        if(detailPlot$facet == "Network"){
          d <- d %>% select(-Genre) %>% unique()
        }
        
        datatable(
          d,
          options = list(
            processing = FALSE,
            searching = FALSE,
            paging=FALSE
            #ordering=FALSE
          ),
          selection="none",
          rownames = FALSE
        )
      })
      
    } else {
      detailPlot$data = NULL
      detailPlot$title = NULL
      # detailPlot$xAxis = NULL
      # detailPlot$yAxis = NULL
      # detailPlot$xRange = NULL
      # detailPlot$yRange = NULL
      # detailPlot$ptColor = NULL
      # detailPlot$facet = NULL
       detailPlot$ofType = "blank"
    }
  })
})