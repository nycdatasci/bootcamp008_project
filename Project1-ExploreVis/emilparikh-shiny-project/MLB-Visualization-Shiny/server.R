suppressMessages({
  library(shiny)
  library(shinydashboard)
  library(DT)
})

source("helpers.R")

masterData <- getMasterData()
playoffCorrPlot <- createCorrPlots(masterData)

shinyServer(function(input, output){
  
  #get input for the mean difference section
  theStat <- reactive(input$theStat)
  
  #how much to round
  roundPlaces <- reactive({
    if(theStat() %in% c("OBP", "BA")) {
      return(3)
    } else{
      return(1)
    }
  })
  
  #statistic to label mapping
  statLabel <- reactive(statToLabel[[theStat()]])
  shortLabel <- reactive(statToShortLabel[[theStat()]])
  
  #radio button to include/exclude bottom MLB teams 
  includeBottom <- reactive(input$includeBottom)
  
  #get mean/bar data filtered by includeBottom
  barPlotList <- reactive({
    if(includeBottom()){
      grps <- c(1,2,3)
    }else{
      grps <- c(1,2)
    }
    
    return(getBarPlotData(masterData, summaryCols, grps))
  }) 
  
  #TITLES
  output$pageTitle <- renderText({statLabel()})
  
  output$barPlotTitle <- renderText({
    paste("Mean", shortLabel(), "by Year and Playoff Status")
  })
  
  # output$diffTableTitle <- renderText({
  #   paste("Difference of Playoff and Non-playoff", shortLabel())
  # })
  
  #MEANDIFF
  #mean and data for mean differences
  diffList <- reactive({
    return(getDiff(barPlotList()$data, theStat(), roundPlaces()))
  })
  
  output$meandiff <- renderValueBox({
    meanDiff <- round(diffList()$mean,3)
    valueBox(
      value = meanDiff,
      subtitle = paste("Mean difference in", tolower(statLabel()), "of playoff and non-playoff teams from 2005 to 2015."),
      color = "green"
    )
  })
  
  #diff table
  output$diffTable <- renderDataTable(
    datatable(
      isolate({
        diffList()$data
      }),
      options = list(
        processing = FALSE,
        searching = FALSE,
        paging=FALSE,
        ordering=FALSE
      ),
      selection="none"
    )
  )

  proxy = dataTableProxy("diffTable")
  observe({
    replaceData(proxy, diffList()$data)
  })
  

  #BAR PLOT
  output$barPlot <- renderPlot({
    bpl <- barPlotList()
    plotBar(
      df = bpl$data,
      yCol = theStat(),
      lab = statLabel(),
      yFrom = bpl$mins[theStat()],
      yTo = bpl$maxes[theStat()],
      yBy = bpl$yTicks[theStat()],
      roundYAxis = roundPlaces()
    )
  })
  
  #CORR PLOTS
  nonPlayoffCorrPlot <- reactive({
    if(includeBottom()){
      grps <- c(2,3)
    } else{
      grps <- c(2)
    }
    createCorrPlots(masterData, grps)
  })
  
  output$corrHittingPlayoff <- renderPlot({
    playoffCorrPlot$hitting
  })
  
  output$corrHittingNonPlayoff <- renderPlot({
    nonPlayoffCorrPlot()$hitting
  })
  
  output$corrPitchingPlayoff <- renderPlot({
    playoffCorrPlot$pitching
  })
  
  output$corrPitchingNonPlayoff <- renderPlot({
    nonPlayoffCorrPlot()$pitching
  })
  
  #SCATTER PLOTS
  selectText <- "Please select x and y values from the input box in the sidebar..."
  scatterTitle <- "Exploring relationships between"
  
  output$scatterHitting <- renderPlot({
    if(length(input$xyHitting) == 2){
      x <- input$xyHitting[1]
      y <- input$xyHitting[2]
      xLab <- statToLabel[[x]]
      yLab <- statToLabel[[y]]
      
      output$selectHittingMsg <- renderText("")
      output$scatterHittingTitle <- renderText(paste(scatterTitle, "hitting variables:", xLab, "vs.", yLab))
      
      if(includeBottom()){
        grps <- c(1,2,3)
      }else{
        grps <- c(1,2)
      }
      
      plotScatter(
        masterData,
        xCol = x,
        yCol = y,
        xLab = xLab,
        yLab = yLab,
        grps = grps
      )
    } else{
      output$selectHittingMsg <- renderText(selectText)
      output$scatterHittingTitle <- renderText(paste(scatterTitle, "hitting variables"))
    }
  }) # end hitting scatterplot
  
  output$scatterPitching <- renderPlot({
    if(length(input$xyPitching) == 2){
      x <- input$xyPitching[1]
      y <- input$xyPitching[2]
      xLab <- statToLabel[[x]]
      yLab <- statToLabel[[y]]
      
      output$selectPitchingMsg <- renderText("")
      output$scatterPitchingTitle <- renderText(paste(scatterTitle, "pitching variables:", xLab, "vs.", yLab))
      
      if(includeBottom()){
        grps <- c(1,2,3)
      }else{
        grps <- c(1,2)
      }
      
      plotScatter(
        masterData,
        xCol = x,
        yCol = y,
        xLab = xLab,
        yLab = yLab,
        grps = grps
      )
    } else{
      output$selectPitchingMsg <- renderText(selectText)
      output$scatterPitchingTitle <- renderText(paste(scatterTitle, "pitching variables"))
    }
  }) # end pitching scatterplot
  
})