library(shinydashboard)
library(googleVis)

ui <- dashboardPage(
  dashboardHeader(title = "GDP Dashboard"),
  dashboardSidebar(sidebarMenu(
    menuItem("Intro", tabName = "Intro", icon = icon("gear")),
    menuItem("Correlation By Region", tabName = "widget1", icon = icon("th")),
    menuItem("Correlation By Country", tabName = "widget2", icon = icon("th")),
    menuItem("Time Series Dashboard", tabName = "dashboard", icon = icon("dashboard"))
  )),
  dashboardBody(
    tabItems(
      tabItem(tabName = "Intro",
              box(
                mainPanel(
                  h4("INTRODUCTION",align= "Left"),
                  h5("This app lets you choose different indicator and see how the indicators correlate to each other 
                     by building a correlation plot at the Region and Country Level. The Dashboard tab gives you a Time
                     Series analysis of how different countries performed over period of years from 1991 till 2014 comparing across various indicators.", align ="left"),
                  h4("TAB : Correlation by Region" ),
                  h5(" Please select the Region from 'Choose the region' dropdown to choose the region you are interested to find the correlation. This is a multiple select field
                      which lets you choose multiple Regions you are interested. Please select the icon Type for the Plot from 'Choose Icon type for the Plot' down to choose how you want the correlation plot to display"),
                  h4("TAB : Correlation by Country" ),
                  h5(" Please select the Country from 'Choose a Country' dropdown to choose a countryn you are interested to find the correlation. This is a multiple select field
                     which lets you choose multiple Countries you are interested. Please select the icon Type for the Plot from 'Choose Icon type for the Plot' down to choose how you want the correlation plot to display"),
                  h4("TAB : Time Series Dasboard "),
                  h5("Watch the animated motion plot move. Feel free to change the X and Y variables")
                  
              ))),
      tabItem(tabName = "widget1",
             box(
                  column(8,hr(),
                  selectInput('in1', 'Choose a Region', choices = empl.regions, multiple = T, selected = "NORTH AMERICA"),
                  selectInput('param1', 'Choose Icon type for Plot',c(Choose='', cor.options), selected = "pie"))),
             box(plotOutput("plot1"), height = 500)
                  ),
      tabItem(tabName = "widget2",
              box(
                column(8,hr(), 
                       selectInput('in2', 'Choose a Country', choices = empl.country, multiple = T, selected = "United States"),
                       selectInput('param2', 'Choose Icon type for Plot',c(Choose='', cor.options), selected = "pie"))),
              box(plotOutput("plot2"), height = 500)
      ),
      tabItem(tabName = "dashboard",
              mainPanel(
                htmlOutput("gvis")
              ))
      )
    ),
  skin = "green"
  )


