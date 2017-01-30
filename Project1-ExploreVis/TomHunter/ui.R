library(shiny)
require(global.R)
options(shiny.error = browser)

fluidPage(
  
  headerPanel("Got Heat?"),
  sidebarLayout(
    helpText(p("Built on NYC apartment heating 311 complaint data and Heat Seek, NYC temperature sensor data"
            )),
    sidebarPanel(
        selectizeInput(
          inputId = "nyc_bar_col_sel",
          label = "Select 311 Categorical Variables",
          choices = cols_311,
          selected = cols_311[1]
        ),
        selectizeInput(
          inputId = 'hs_cat_inp',
          label = "Select Heat Seek Grouping Variable",
          choices = cols_hs,
          selected = cols_hs[1]
        ),
    mainPanel(
      tabsetPanel(
        tabPanel("311 Data", 
                 plotOutput("bar_311")),
        tabPanel("Heat Seek Data",
                 plotOutput("line_hs")),
        tabPanel("Sensor Map", 
                 plotOutput("map_hs", width = "100%"))
      )
    )
  )
))



