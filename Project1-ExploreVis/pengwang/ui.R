library(PerformanceAnalytics)
library(quantmod)
library(dygraphs)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = 'Investment Returns'),
  dashboardSidebar(
    fluidRow(
      column(6,
             textInput("stock1", "Stock 1", "GOOG")),
      column(6,
             numericInput("w1", "Portf. %", 25, min = 1, max = 100))
    ), 
    fluidRow(
      column(6,
             textInput("stock2", "Stock 2", "AAPL")),
      column(6,
             numericInput("w2", "Portf. %", 25, min = 1, max = 100))
    ), 
    fluidRow(
      column(6,
             textInput("stock3", "Stock 3", "FB")),
      column(6,
             numericInput("w3", "Portf. %", 25, min = 1, max = 100))
    ), 
    fluidRow(
      column(6,
             textInput("stock4", "Stock 4", "TSLA")),
      column(6,
             numericInput("w4", "Portf. %", 25, min = 1, max = 100))
    ), 
    sidebarMenu(menuItem("Individual Stocks", tabName = "individual", 
                         icon = icon("line-chart")),
                menuItem("Portfolio", tabName = "portfolio", icon = 
                           icon("line-chart")),
                menuItem('Protfolio Growth', tabName = 'growth', 
                         icon = icon('line-chart'))),
    checkboxInput('return', 'Check this for returns rather than price', 
                  value = T),
    selectInput('frequency', 'Choose the Frequency', 
                choices = c('daily', 'weekly', 'monthly', 'quarterly')),
    dateInput('start_date', 'Starting Date', value = '2012-10-01', 
              min = '2012-10-01', format = 'yyyy-mm-dd', startview = 'month')
    ),
  
  dashboardBody(tabItems(
    tabItem(tabName = "individual",
            dygraphOutput('plotI', width = 'auto', height = '500px')),
    tabItem(tabName = "portfolio",
            dygraphOutput('plotP', width = 'auto', height = '500px')),
    tabItem(tabName = 'growth', 
            dygraphOutput('plotG', width = 'auto', height = '500px'),
    br(),
    fluidRow(infoBoxOutput('box1', width = 6), infoBoxOutput('box2', width = 6))
    )
  )
  )
)