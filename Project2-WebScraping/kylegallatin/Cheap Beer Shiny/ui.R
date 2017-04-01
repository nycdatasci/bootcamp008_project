library(shinydashboard)
#ui
shinyUI(dashboardPage(
  dashboardHeader(title = "College Lagers"),
  dashboardSidebar(
    sidebarUserPanel("Kyle Gallatin", image = 'handsome_man.jpg'),
    sidebarMenu(
      menuItem("Boxplots", tabName = "Boxplots", icon = icon("dropbox")),
      menuItem("Ratings by Time", tabName = "Ratings", icon = icon("hourglass")),
      menuItem("Data", tabName = 'table', icon = icon('table'))),
    selectizeInput("selected",
                   "Select Item to Display", 
                   choices = c('look', 'smell', 'taste', 'feel', 'overall')),
    checkboxGroupInput("checkGroup",
                       label = h3("Select Beers"),
                       choices = list("Budweiser" = "Budweiser ",
                                      "Bud Light" = "Bud Light ",
                                      "Coors" = "Coors ",
                                      "Coors Light" = "Coors Light ",
                                      "Busch Beer" = "Busch Beer ",
                                      "Busch Light" = "Busch Light ",
                                      "Miller High Life" = "Miller High Life ",
                                      "Natty Light" = "Natural Light ",
                                      "Natty Ice" = "Natural Ice "), 
                       selected = unique(classic$name))
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "Ratings",
              fluidRow(plotOutput("plot")),
              fluidRow(plotOutput("plot3")),
              fluidRow(img(src = 'beerIndustry.jpeg', height = 400, width = 600))),
      tabItem(tabName = "Boxplots",
              fluidRow(infoBoxOutput("maxBox"),
                       infoBoxOutput("minBox"),
                       infoBoxOutput("avgBox")),
              fluidRow(plotOutput("plot2"))),
      tabItem(tabName = "table",
              fluidRow(dataTableOutput('table')))
              ))
  )
)