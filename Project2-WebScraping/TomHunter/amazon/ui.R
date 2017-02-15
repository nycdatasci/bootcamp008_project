library(shinydashboard)
library(plotly)

dashboardPage(
  dashboardHeader(title = 'Amazon Products'), 
  dashboardSidebar(
    sidebarUserPanel(fluidRow(column(width = 4, 
                                     img(src = "Tom-Hunter-1.jpg", height = 40, width = 40), 'Made by Tom Hunter'))
    ), br(),
    sidebarMenu(id = 'menu1',
                menuItem('Intro', tabName = 'intro', icon = icon('bars')),
                menuItem('Data', tabName = 'data', icon = icon('table')),
                menuItem('Categorical Variables', tabName = 'groups', icon = icon('users')),
                menuItem('Bar Charts', tabName = 'bar', icon = icon('bar-chart')),
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
                                 "List_Price", "OneStarPct", "TwoStarPct","ThreeStarPct","FourStarPct", "FiveStarPct")
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
      condition = "input.menu1 == 'bar'",  
      selectInput('var',
                  label = 'Choose a variable to view as a bar chart',
                  choices = c('Manufacturer', 'Origin', 'Category'),
                  selected = 'Origin'
      ),
      checkboxInput("remove_NA", "Remove NA and blank values", TRUE),
      checkboxInput("remove_low_counts", "Remove Small Counts", TRUE)
    ),
    conditionalPanel(
      condition = "input.menu1 == 'histogram'",  
      selectInput('var_his',
                  label = 'Choose a variable to view as a histogram',
                  choices = c('Avg_Customer_Rating', "OneStarPct",
                              "TwoStarPct","ThreeStarPct","FourStarPct", "FiveStarPct"),
                  selected = 'Avg_Customer_Rating'
                  )
    ),
    conditionalPanel(
      condition = "input.menu1 == 'box'",
      selectizeInput('xvar_box',
                     label = 'Choose Factor',
                     choices = c('Category', 'Manufacturer', 'Origin'), 
                     selected = 'Category'
      ),
      selectizeInput('yvar_box',
                     label = 'Choose Y-axis variable',
                     choices = c('Avg_Customer_Rating', "Number_of_Customer_Questions",
                                 "Number_of_Reviews", "OneStarPct", "TwoStarPct","ThreeStarPct",
                                 "FourStarPct", "FiveStarPct"), 
                     selected = 'Avg_Customer_Rating'
      )
    ),
    
    conditionalPanel(
      condition = "input.menu1 == 'scatter'",
      selectizeInput('xvar',
                     label = 'Choose X-axis variable',
                     choices = c('Sale_Price', 'Avg_Customer_Rating', "Number_of_Customer_Questions",
                                 "Number_of_Reviews", "List_Price", "OneStarPct", "TwoStarPct","ThreeStarPct",
                                 "FourStarPct", "FiveStarPct"),
                     selected = "FiveStarPct"
      ),
      selectizeInput('yvar',
                     label = 'Choose Y-axis variable',
                     choices = c('Sale_Price', 'Avg_Customer_Rating', "Number_of_Customer_Questions",
                                 "Number_of_Reviews", "List_Price", "OneStarPct", "TwoStarPct","ThreeStarPct",
                                 "FourStarPct", "FiveStarPct"),
                     selected = 'Avg_Customer_Rating'
      ),
      selectizeInput('factor',
                     label = 'Choose a factor',
                     choices = c('Category', 'Manufacturer', 'Origin'), 
                     selected = 'Origin')
    )
  ),
  dashboardBody( 
    tabItems(
      tabItem(tabName = 'intro',
              HTML("<h3><b>Problem</b><h3>",
                   "<ul>",
                    "<li><h4>What differentiates a high selling product from a low selling product on Amazon?</h4></li>",
                   "</ul>",
                   "<h3><b>Theorized solution</b></h3>",
                   "<ul>",
                    "<li><h4>GOAL: Estimating product sales using change in BSR</h4></li>",
                    "<li><h4>GOAL: Predict BSR using product attribute data</h4></li>",
                   "</ul>",
                   "<h3><b>Problems encountered</b></h3>",
                   "<ul>",
                    "<li><h4>Inconsistent Dom structure</h4></li>",
                    "<li><h4>Captchas </h4></li>",
                    "<li><h4>IP bans</h4></li>",
                    "<li><h4>User-agent profiling</h4></li>",
                    "<li><h4>Work arounds?</h4></li>",
                   "</ul>",
                   "<h3><b>Dashboard Visualizations</b></h3>",
                   "<h3><b>Next steps</b></h3>",
                   "<ul>",
                    "<li><h4>More dynamic selectors</h4></li>",
                    "<li><h4>Supplementing data with API</h4></li>",
                   "</ul>"
                  )
      ),
      tabItem(tabName = 'data',
              fluidRow(column(width = 6, DT::dataTableOutput('table', width = '200%')))
      ),
      tabItem(tabName = 'groups',
              fluidRow(column(width = 6, DT::dataTableOutput('groups', width = '200%')))
      ),
      tabItem(tabName = 'bar',
              fluidRow(column(width = 6, plotOutput('bar', width = '200%', height = '600px')))
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