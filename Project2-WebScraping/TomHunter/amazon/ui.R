library(shinydashboard)
library(plotly)

dashboardPage(
  dashboardHeader(title = 'Amazon Products'), 
  dashboardSidebar(
    sidebarUserPanel(fluidRow(column(width = 4, 
                                     img(src = "Tom-Hunter-1.jpg", height = 40, width = 40), 'Made by Tom Hunter'))
    ), br(),
    sidebarMenu(id = 'menu1',
                menuItem('Data', tabName = 'data', icon = icon('table')),
                menuItem('Categorical Variables', tabName = 'groups', icon = icon('users')),
                menuItem('Histograms', tabName = 'histogram', icon = icon('bar-chart')),
                menuItem('Box Plots', tabName = 'box', icon = icon('reorder')),
                menuItem('Scatter Plots', tabName = 'scatter', icon = icon('line-chart'))
    ),
    conditionalPanel(
      condition = "input.menu1 == 'data'",
      selectizeInput('selected',
                     label = 'Select Variable to Search',
                     choices = c("ASIN", "Product_Title", 'Category', 'Manufacturer', 'Origin','Sale_Price', 
                                  "Avg_Customer_Rating", "Number_of_Customer Questions","Number_of_Reviews", 
                                 "List_Price", "1_Star_%", "2_Star_%","3_Star_%","4_Star_%", "5_Star_%")
                     )
    ),
    conditionalPanel(
      condition = "input.menu1 == 'groups'",
      selectizeInput('by_group',
                     label = 'Select Variable to Group by',
                     choices = c('Manufacturer', 'Origin', 'Category'), 
                     selected = 'Category'
                     )
    ),
    conditionalPanel(
      condition = "input.menu1 == 'histogram'",  
      selectInput('var',
                  label = 'Choose a variable to view as a histogram',
                  choices = c('Manufacturer', 'Origin', 'Category', 'Avg_Customer_Rating', "1_Star_%",
                              "2_Star_%","3_Star_%","4_Star_%", "5_Star_%"),
                  selected = 'Category'
                  )
    ),
    
    # conditionalPanel(
    #   condition = "input.menu1 == 'histogram' && input.var == 'Duration'",
    #   sliderInput('binsize_duration',
    #               label = 'Bin size:',
    #               min = 5, max = 75, step = 5, sep = '', value = 25, ticks = T
    #   )
    

    conditionalPanel(
      condition = "input.menu1 == 'box'",
      selectizeInput('xvar_box',
                     label = 'Choose Factor',
                     choices = c('Category', 'Manufacturer', 'Origin'), 
                     selected = 'Category'
      ),
      selectizeInput('yvar_box',
                     label = 'Choose Y-axis variable',
                     choices = c('Sale_Price', 'Avg_Customer_Rating', "Number_of_Customer_Questions",
                                 "Number_of_Reviews", "List_Price", "1_Star_%", "2_Star_%","3_Star_%",
                                 "4_Star_%", "5_Star_%"), 
                     selected = 'Sale_Price'
      )
    ),
    
    conditionalPanel(
      condition = "input.menu1 == 'scatter'",
      selectizeInput('xvar',
                     label = 'Choose X-axis variable',
                     choices = c('Sale_Price', 'Avg Customer_Rating', "Number_of_Customer_Questions",
                                 "Number_of_Reviews", "List_Price", "1_Star_%", "2_Star_%","3_Star_%",
                                 "4_Star_%", "5_Star_%"),
                     selected = "5_Star_%"
      ),
      selectizeInput('yvar',
                     label = 'Choose Y-axis variable',
                     choices = c('Sale_Price', 'Avg Customer_Rating', "Number_of_Customer_Questions",
                                 "Number_of_Reviews", "List_Price", "1_Star_%", "2_Star_%","3_Star_%",
                                 "4_Star_%", "5_Star_%"),
                     selected = 'Avg Customer Rating'
      ),
      selectizeInput('factor',
                     label = 'Choose a factor',
                     choices = c('Category', 'Manufacturer', 'Origin'), selected = 'Category')
    )
  ),
  dashboardBody( 
    tabItems(
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