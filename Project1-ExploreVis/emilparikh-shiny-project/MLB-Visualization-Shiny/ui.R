suppressMessages({
  library(shiny)
  library(shinydashboard)
  library(DT)
})

shinyUI(dashboardPage(
  dashboardHeader(title = "MLB Visualization"),
  dashboardSidebar(
    sidebarMenu(
      h5("Navigate:", id = "nav-label"),
      menuItem("Mean differences", icon = icon("bar-chart"), newtab = FALSE, href="#diff"),
      menuItem("Hitting correlations", icon = icon("table"), newtab = FALSE, href = "#corr-hitting"),
      menuItem("Pitching correlations", icon = icon("table"), newtab = FALSE, href = "#corr-pitching")
    ),
    br(),
    #select meandiff
    selectInput(inputId = "theStat", label = h5("Select a variable:"), choices = lblList),
    #select scatter hitting
    selectizeInput(
      inputId = 'xyHitting',
      label = h5('Select axes values for hitting:'),
      choices = c(lblList$Hitting, "Win %" = "winPercent"),
      multiple = TRUE,
      options = list(maxItems = 2)
    ),
    #select scatter pitching
    selectizeInput(
      inputId = 'xyPitching',
      label = h5('Select axes values for pitching:'),
      choices = c(lblList$Pitching, "Win %" = "winPercent"),
      multiple = TRUE,
      options = list(maxItems = 2)
    ),
    br(),
    radioButtons(
      "includeBottom",
      inline = TRUE,
      label = h5("Include bottom half of non-playoff teams in comparison?"),
      choices = list("Yes" = TRUE, "No" = FALSE),
      selected = TRUE
    ),
    sidebarUserPanel("Emil Parikh")
  ), #end sidebar
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "app.css")
    ),
    fluidRow(#SECTION TITLE
      box(
        width = 12,
        align = "left",
        #solidHeader = TRUE,
        #background = "navy",
        h3("Mean differences of playoff and non-playoff teams"),
        id = "diff",
        class = "subheader"
      )
    ),
    fluidRow(
      valueBoxOutput(outputId = "meandiff", width = 12)
    ),
    br(),
    fluidRow(#SECTION
      box(
        width = 12,
        dataTableOutput("diffTable"),
        br(),
        title = h5(textOutput("barPlotTitle")),
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        plotOutput("barPlot")
      )
    ),
    # fluidRow(
    #   box(
    #     width = 11,
    #     title = h5(textOutput("diffTableTitle")),
    #     status = "primary",
    #     solidHeader = TRUE,
    #     collapsible = FALSE
    #     dataTableOutput("diffTable")
    #   )
    # ),
    fluidRow(#SECTION TITLE
      br(),
      box(
        width = 12,
        align = "left",
        #background = "navy",
        h3("Correlations between variables: Hitting"),
        id = "corr-hitting",
        class = "subheader"
      )
    ),
    fluidRow(#CORRPLOT HITTING SECTION
      box(
        width = 6,
        title = h5("Correlation coefficients: Playoff team hitting"),
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        plotOutput("corrHittingPlayoff")
      ),
      box(
        width = 6,
        title = h5("Correlation coefficients: Non-playoff team hitting"),
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        plotOutput("corrHittingNonPlayoff")
      )
    ),
    fluidRow(#CORRPLOT HITTING SCATTER
      box(
        width = 12,
        title = h5(textOutput("scatterHittingTitle")),
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        h4(textOutput("selectHittingMsg")),
        plotOutput("scatterHitting")
      )
    ),
    fluidRow(#SECTION TITLE
      br(),
      box(
        width = 12,
        align = "left",
        #background = "navy",
        h3("Correlations between variables: Pitching"),
        id = "corr-pitching",
        class = "subheader"
      )
    ),
    fluidRow(#CORRPLOT PITCHING SECTION
      box(
        width = 6,
        title = h5("Correlation coefficients: Playoff team pitching"),
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        plotOutput("corrPitchingPlayoff")
      ),
      box(
        width = 6,
        title = h5("Correlation coefficients: Non-playoff team pitching"),
        align = "center",
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        plotOutput("corrPitchingNonPlayoff")
      )
    ),
    fluidRow(#CORRPLOT PITCHING SCATTER
      box(
        width = 12,
        title = h5(textOutput("scatterPitchingTitle")),
        status = "primary",
        solidHeader = TRUE,
        collapsible = FALSE,
        h4(textOutput("selectPitchingMsg")),
        plotOutput("scatterPitching")
      )
    ),
    tags$script(type = "text/javascript", src = "app.js")
  )
))