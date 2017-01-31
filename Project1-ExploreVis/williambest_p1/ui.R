# ui.R
library(leaflet)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = 'Tornados Since 1996'),
  dashboardSidebar(
    sidebarMenu(
      selectInput("state", "Select State:",
                  choices = state.abb[state.abb!="AK" & state.abb!="HI"], multiple=FALSE, selectize=TRUE
      ),
      menuItem("Map", tabName = "storm_map", icon = icon("map")),
      menuItem("State Comparison", tabName = "state_comparison", icon = icon("bar-chart")),
      menuItem("State at a Glance", tabName = "state_data", icon = icon("th")),
      menuItem("Options", icon = icon("gear"),
               checkboxInput("include.zero.values", "Include Zero Values", value = FALSE),
               radioButtons("group.by", "Grouping Method", c("By Year" = "Year", "By Storm" = "Storm"), selected = "Year"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "storm_map",
        fluidRow(
          div(class="outer",
              
              tags$head(
                # Include our custom CSS
                includeCSS("style.css"),
                includeScript("gomap.js")
              ),
              
          leafletOutput('map', height = 550),
          absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                        width = 330, height = "auto",
                        
                        h2("State Tornado Explorer"),
                        
                        checkboxGroupInput("map.mag", "Severity", 
                                           choices = c("F0", "F1", "F2", "F3", "F4", "F5"),
                                           selected = c("F0", "F1", "F2", "F3", "F4", "F5"), inline = TRUE),
                        sliderInput("map.year", "Year Occured", 1996, 2015, value = c(2005, 2015))
                        
                        #plotOutput("map.loss.boxplot", height = 200)
                        #plotOutput("scatterCollegeIncome", height = 250)
          )
          )
        )
      ),
      tabItem(tabName = "state_comparison",
        fluidRow(
          box(htmlOutput("loss.chart"), height = "250"),
          box(htmlOutput("casualty.chart"), height = "250"),
          box(htmlOutput("state.comparison"))
        )
      ),
      tabItem(tabName = "state_data",
        fluidRow(
          infoBoxOutput("average.storms.per.year"),
          infoBoxOutput("casualties.per.storm"),
          infoBoxOutput("loss.per.storm")
        ),
        fluidRow(
          box(htmlOutput("state.severity.bubble.chart"),
              checkboxInput("state.log.scale", "Log Scale", value = FALSE),
              width = "100%", height = 400)
        )
      )
    )
  )
)