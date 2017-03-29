library(shinydashboard)
setwd("~/NYCDSA/Project 4/")

shinyUI(dashboardPage(
  dashboardHeader(title = "The New York Times Bestseller List"),
  dashboardSidebar(
    sidebarUserPanel("Dr. David Letzler", image = "https://shiny.nycdatascience.com/images/student/David%20Letzler.jpg"),
    
    sidebarMenu(
      menuItem("Publisher Market Share", tabName= "market", icon=icon("pie-chart")),
      selectInput("era", "Select Year Range", choices= c("2008-2013"='pre', "2013-2017"='post')),
      selectInput("list", "Select List", choices = c("All" = "All", "Hardcover Fiction"="Hardcover Fiction", "Trade Paperback Fiction"="Paperback Trade Fiction", "Mass Market Fiction"="Paperback Mass-Market Fiction", "E-Book Fiction"="E-Book Fiction")),
      selectInput("genre", "Select Imprint Genre", choices = c("All", "Commericial"="Commercial", "General"="General", "Spiritual"="Spiritual", "Literary"="Literary", "Genre" ="Genre", "Science Fiction & Fantasy"="Science Fiction & Fantasy", "Romance/Erotica"="Romance/Erotica", "Mystery/Crime"="Mystery/Crime", "Thriller/Horror"="Thriller/Horror")),
      selectInput("rank", "Select Top Seller Option", choices=c("Imprint"="publisher", "Author"="author", "Title"="title")),
      menuItem("Publisher Year-by-Year", tabName="time", icon=icon("line-chart")),
      menuItem("Review Impact", tabName="review", icon=icon("newspaper-o"))
    )
    
    
  ),
  
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "market",fluidRow(box(htmlOutput("market"), height=500),
                                              box(htmlOutput("bar"), height=500))),
      tabItem(tabName = "time", fluidRow(box(htmlOutput("time"), height=500))),
      tabItem(tabName = "review", fluidRow(box(plotOutput("review"), height=500))
  )))
))