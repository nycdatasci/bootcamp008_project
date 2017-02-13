library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(skin = "red",
  dashboardHeader(title = "Billboard Top 100"),
  dashboardSidebar(
    sidebarUserPanel("Mayank Shah", image = "Face.png"),
    sidebarMenu(
      menuItem("Introduction", tabName = "Intro", icon = icon("music")),
      menuItem("Top 20 Songs Ever", tabName = "TopSongs", icon = icon("music")),
      menuItem("Genre Breakdown by Decade", tabName = "Genre", icon = icon("pie-chart")),
      menuItem("Length of Avg Chart Topper", tabName = "data", icon = icon("industry")),
      menuItem("Analysis and Conclusions", tabName = "Analysis", icon = icon("pie-chart")))
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "Intro",
              img(src = "Preview.png", align = "center")),
      tabItem(tabName = "TopSongs",
              plotOutput("SongPlot")),
      tabItem(tabName = "Genre",
              plotOutput("GenrePlot")),
      tabItem(tabName = "Analysis",
              img(src = "myImage.png", align = "center")),
      tabItem(tabName = "data",
              plotOutput("BarPlot"))
    )
  )
))
