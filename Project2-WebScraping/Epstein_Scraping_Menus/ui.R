library(shinydashboard)
library(leaflet)

shinyUI(
  
  dashboardPage(skin = 'purple',
  dashboardHeader(title = 'New York City Menus'), 
  dashboardSidebar(
    sidebarUserPanel(fluidRow(column(width = 4, 
                                     img(src = "HeadShot.png", height = 40, width = 40), 'Made by Daniel Epstein'))
    ), 
    br(),
    sidebarMenu(id = 'menu1',
                menuItem('Map', tabName = 'map', icon = icon('map')),
                menuItem('Heat Map', tabName = 'heatmap', icon = icon('map')),
                menuItem('Table', tabName = 'table', icon = icon('table')),
                menuItem('Price Histogram', tabName = 'histogram', icon = icon('bar-chart'))
      ),
    selectizeInput('Cuisine',
                   label = 'Select Cuisine',
                   choices = c('All', 'Afghan', 'African', 'American', 'Chinese', 'French', 'German', 'Greek', 'Indian', 'Italian', 'Japanese', 'Mediterranean', 'Mexican', 'Peruvian', 'Portuguese', 'Russian', 'Spanish', 'Tapas', 'Thai', 'Vietnamese'),
                   selected = 'Russian'
      ),
    selectizeInput('Item',
                  label = 'Select Item',
                  choices = c('All', 'BLT', 'Burger', 'Burrito', 'Cake', 'Cheese', 'Dumpling', 'Egg', 'Noodles', 'Pasta', 'Pie', 'Pizza', 'Risotto', 'Salad', 'Sandwich', 'Stew', 'Taco'),
                  selected = 'Salad'
    ),
    selectizeInput('Ingredient',
                   label = 'Select Ingredient',
                   choices = c('All', 'Bacon', 'Beans', 'Beef', 'Bison', 'Carrots', 'Cheese', 'Chicken', 'Duck', 'Dumpling', 'Egg', 'Fish', 'Garlic', 'Lamb', 'Lobster', 'Pork', 'Potato', 'Rice', 'Shrimp', 'Tofu', 'Tomato', 'Turkey', 'Veggie'),
                   selected = 'All'
    ),
    selectizeInput('Ingredient_2',
                   label = 'Select Second Ingredient',
                   choices = c('All', 'Bacon', 'Beans', 'Beef', 'Bison', 'Carrots', 'Cheese', 'Chicken', 'Duck', 'Dumpling', 'Egg', 'Fish', 'Garlic', 'Lamb', 'Lobster', 'Pork', 'Potato', 'Rice', 'Shrimp', 'Tofu', 'Tomato', 'Turkey', 'Veggie'),
                   selected = 'All'
    ),
    selectizeInput('Ingredient_3',
                   label = 'Select Second Ingredient',
                   choices = c('All', 'Bacon', 'Beans', 'Beef', 'Bison', 'Carrots', 'Cheese', 'Chicken', 'Duck', 'Dumpling', 'Egg', 'Fish', 'Garlic', 'Lamb', 'Lobster', 'Pork', 'Potato', 'Rice', 'Shrimp', 'Tofu', 'Tomato', 'Turkey', 'Veggie'),
                   selected = 'All'
    ),
    selectizeInput('Method',
                   label = 'Select Cooking Method',
                   choices = c('All', 'Baked', 'Braised', 'Broiled', 'Fried', 'Grilled', 'Poached', 'Raw', 'Roasted', 'Saute', 'Seared', 'Simmer', 'Smoked', 'Steamed', 'Stir fried'),
                   selected = 'All'
    ),
    conditionalPanel(
      condition = "input.menu1 == 'histogram'",  
      sliderInput('binsize',
                  label = 'Bin size:',
                  min = 0.5, max = 10, step = 0.5, sep = '', value = 1, ticks = T
                  )
    )
    ),
  
  dashboardBody( 
    tabItems(
      tabItem(tabName = 'map',
              #leaflet map
              fluidRow(column(width = 6, leafletOutput('map', width = '200%', height = '600px'))), 
              fluidRow(column(width = 3, textOutput('stats')), column(width = 3), column(width = 3), column(width = 3, 'Green: Less than $10')),
              fluidRow(column(width = 3, textOutput('min')), column(width = 3), column(width = 3), column(width = 3, 'Yellow: Less than $15')),
              fluidRow(column(width = 3, textOutput('max')), column(width = 3), column(width = 3), column(width = 3, 'Orange: Less than $20')),
              fluidRow(column(width = 3), column(width = 3), column(width = 3), column(width = 3, 'Red: More than $20'))
      ),
      tabItem(tabName = 'heatmap',
              fluidRow(column(width = 6, leafletOutput('heatmap', width = '200%', height = '600px'))),
              fluidRow(column(width = 3, textOutput('heatstats'))),
              fluidRow(column(width = 3, textOutput('heatmin'))),
              fluidRow(column(width = 3, textOutput('heatmax')))
              ),
      tabItem(tabName = 'table',
              fluidRow(column(width = 6, DT::dataTableOutput('table', width = '200%')))
              ),
      tabItem(tabName = 'histogram',
              fluidRow(column(width = 6, plotOutput('histogram', width = '200%', height = '600px'))),
              fluidRow(column(width = 3, textOutput('hist_stats'))),
              fluidRow(column(width = 3, textOutput('mean'))),
              fluidRow(column(width = 3, textOutput('median')))
              )
    )
  )
)

)
