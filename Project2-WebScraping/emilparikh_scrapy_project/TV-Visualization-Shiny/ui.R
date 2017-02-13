suppressMessages({
  library(shiny)
  library(DT)
})

shinyUI(fluidPage(
  
  titlePanel("TV Show Explorer"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "app.css")
  ),
  fluidRow(
    column(
      12,
      wellPanel(
        selectInput(
          inputId = "plotType",
          label = "Select a plot type:",
          choices = list(
            Genre = c(
              "Count of Shows" = "genre_count",
              "Median Rating" = "genre_rating",
              "Median Number of Years" = "genre_years",
              "Total Votes" = "genre_votes"
            ),
            Network = c(
              "Count of Shows" = "network_count",
              "Median Rating" = "network_rating",
              "Median Number of Years" = "network_years",
              "Total Votes" = "network_votes"
            )
          )
          )
        )       
      )# end column

  ), # end row
  fluidRow(
    column(
      6,
      plotOutput(
        "facetPlot",
        height = "600px",
        brush = brushOpts(
          id = "facetPlot_brush",
          resetOnNew = TRUE
        )
      )# end plot
    ),# end column
    column(
      6,
      plotOutput("detailPlot", height = "600px")
    )
  ),# end row
  br(),br(),
  fluidRow(
    column(
      12,
      dataTableOutput("dataTable")
    )
  )
))