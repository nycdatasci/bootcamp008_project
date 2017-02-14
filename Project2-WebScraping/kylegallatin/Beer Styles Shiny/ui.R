#beerStyles ui

library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = 'American Beer Styles'),
  dashboardSidebar(
    sidebarUserPanel('Kyle Gallatin', image = 'handsome_man.jpg'),
    sidebarMenu(
      menuItem("Most Reviewed", tabName = 'mReviews', icon = icon("beer")),
      menuItem("ABV ~ Rating", tabName = 'ABV', icon = icon('ambulance')),
      menuItem("Style Ratings", tabName = 'Avg', icon = icon('glass')),
      menuItem("Table", tabName = 'table', icon = icon('table')),
      sliderInput("ratings","Min Number of Ratings", 0, 16327, 0),
      sliderInput("avg", "Min Average Rating", 0 , 5, 0, step = 0.1),
      sliderInput('alcohol', "Min Alcohol Content", 0, 13, 0, step = 0.1)
    )),
  dashboardBody(
    tabItems(
      tabItem(tabName = "mReviews",
              fluidRow(plotOutput("plot1"))),
      tabItem(tabName = 'ABV',
              fluidRow(plotOutput("plot2")),
              fluidRow(verbatimTextOutput('text'))),
      tabItem(tabName = 'Avg',
              fluidRow(plotOutput("plot3"))),
      tabItem(tabName = 'table',
              fluidRow(dataTableOutput("table1")))
  ))
))
