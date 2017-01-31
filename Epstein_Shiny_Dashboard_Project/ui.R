library(shinydashboard)
library(leaflet)

shinyUI(dashboardPage(
  dashboardHeader(title = 'New York City Movies'), 
  dashboardSidebar(
    sidebarUserPanel(fluidRow(column(width = 4, 
                     img(src = "HeadShot.png", height = 40, width = 40), 'Made by Daniel Epstein'))
    ), br(),
    sidebarMenu(id = 'menu1',
      menuItem('Map', tabName = 'map', icon = icon('map')),
      menuItem('Data', tabName = 'data', icon = icon('table')),
      menuItem('By Group', tabName = 'groups', icon = icon('users')),
      menuItem('Histogram', tabName = 'histogram', icon = icon('bar-chart')),
      menuItem('Box Plot', tabName = 'box', icon = icon('reorder')),
      menuItem('Scatter Plot', tabName = 'scatter', icon = icon('line-chart'))
    ),
    conditionalPanel(
      condition = "input.menu1 != 'histogram'",
      sliderInput('range', 
                label = 'Range of IMDB Scores:',
                min = 0.0, max = 10.0, step = 0.1, ticks = T, value = c(0.0, 10.0)
                ),
      sliderInput('range_year',
                  label = 'Range of Years:',
                  min = 1945, max = 2006, step = 1, sep = '', ticks = T, value = c(1945, 2006)
                  )
    ),
    conditionalPanel(
      condition = "input.menu1 == 'data'",
      selectizeInput('selected',
                    label = 'Select Variable to Sort by',
                    choices = c('Film', 'Year', 'Director', 'IMDB'))
                    ),
    conditionalPanel(
      condition = "input.menu1 == 'groups'",
      selectizeInput('by_group',
                     label = 'Select Variable to Group by',
                     choices = c('Director', 'Borough', 'Neighborhood'), selected = 'Director')
                    ),
    conditionalPanel(
      condition = "input.menu1 == 'histogram'",  
      selectInput('var',
                label = 'choose a variable to graph',
                choices = c('IMDB Score', 'Year', 'Budget', 'Duration', 'Gross'),
                selected = 'IMDB Score')
                  ),
    conditionalPanel(
      condition = "input.menu1 == 'histogram' && input.var == 'IMDB Score'",
      sliderInput('binsize_IMDB',
                  label = 'Bin size:',
                  min = 0.1, max = 3, step = 0.1, sep = '', value = 1, ticks = T
                  )
    ),
    conditionalPanel(
      condition = "input.menu1 == 'histogram' && input.var == 'Year'",
      sliderInput('binsize_year',
                  label = 'Bin size:',
                  min = 1, max = 30, step = 1, sep = '', value = 10, ticks = T
                  )
    ),
    
    conditionalPanel(
      condition = "input.menu1 == 'histogram' && input.var == 'Duration'",
      sliderInput('binsize_duration',
                  label = 'Bin size:',
                  min = 5, max = 75, step = 5, sep = '', value = 25, ticks = T
      )
    ),
    
    conditionalPanel(
      condition = "input.menu1 == 'histogram' && input.var == 'Budget'",
      sliderInput('binsize_budget',
                  label = 'Bin size:',
                  min = 1000000, max = 50000000, step = 1000000, value = 25000000, ticks = T
                  )
    ),
    
    conditionalPanel(
      condition = "input.menu1 == 'histogram' && input.var == 'Gross'",
      sliderInput('binsize_gross',
                  label = 'Bin size:',
                  min = 1000000, max = 50000000, step = 1000000, value = 25000000, ticks = T
      )
    ),
    
    conditionalPanel(
      condition = "input.menu1 == 'box'",
      selectizeInput('xvar_box',
                     label = 'Choose Factor',
                     choices = c('Borough'), selected = 'Borough'
      ),
      selectizeInput('yvar_box',
                     label = 'Choose Y-axis variable',
                     choices = c('IMDB', 'Duration', 'Budget', 'Gross'), selected = 'IMDB'
      )
    ),
    
    conditionalPanel(
      condition = "input.menu1 == 'scatter'",
      selectizeInput('xvar',
                     label = 'Choose X-axis variable',
                     choices = c('Year', 'Budget', 'Duration', 'Gross'), selected = 'Year'
                    ),
      selectizeInput('yvar',
                     label = 'Choose Y-axis variable',
                     choices = c('IMDB', 'Budget', 'Duration', 'Gross'), selected = 'IMDB'
                    ),
      selectizeInput('factor',
                     label = 'Choose a factor',
                     choices = c('Borough', 'Neighborhood'), selected = 'Borough')
    )
  ),
  dashboardBody( 
    tabItems(
      tabItem(tabName = 'map',
              #leaflet map
              fluidRow(column(width = 6, leafletOutput('map', width = '200%', height = '600px')))
              ),
      tabItem(tabName = 'data',
              fluidRow(column(width = 6, DT::dataTableOutput('table', width = '200%')))
              ),
      tabItem(tabName = 'groups',
              fluidRow(column(width = 6, DT::dataTableOutput('groups', width = '200%')))
              ),
      tabItem(tabName = 'histogram',
              fluidRow(column(width = 6, plotOutput('histogram', width = '200%', height = '600px')))
              ),
      tabItem(tabName = 'box',
              fluidRow(column(width = 6, plotOutput('box', width = '200%', height = '600px')))
      ),
      tabItem(tabName = 'scatter',
              fluidRow(column(width = 2, actionButton('regression', label = 'Click to add Regression Line')),
                       br(), br(),
                       column(width = 6, plotOutput('scatter', width = '200%', height = '600px')))
              )
      )
    )
  )
)