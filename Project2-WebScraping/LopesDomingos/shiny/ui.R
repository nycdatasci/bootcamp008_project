library(shiny)
library(shinydashboard)
library(leaflet)

shinyUI(dashboardPage(
  dashboardHeader(title = "Scraped jobs"),
  dashboardSidebar(
    sidebarMenu(id = "menu",
      menuItem("Scraped companies", tabName = "companies"),
      menuItem("Scraped aggregators", tabName = "aggregators")),
    conditionalPanel(
      condition = "input.menu == 'companies'",
      checkboxGroupInput("companiesGroup", label = h3("Select companies"), 
                         choices = list("Amazon" = 'amazon',
                                        "Apple" = 'apple',
                                        "Facebook" = 'facebook'),
                         selected = c('amazon', 'apple', 'facebook')),
      actionButton("companies_refresh", label = "Apply")),
    conditionalPanel(
      condition = "input.menu == 'aggregators'",
      sliderInput("date_slider", label = "Weeks in the past",
                  min = 0, max = 5, value = c(0, 4), step = 1, round = T),
      sliderInput("size_slider", label = "Heatmap point size",
                  min = 0, max = 100000, value = 10000, step = 1000, round = T)
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tabItems(
      tabItem(tabName = "companies", leafletOutput("companiesMap")),
      tabItem(tabName = "aggregators", leafletOutput("aggregatorsMap"))
    )
  )
))