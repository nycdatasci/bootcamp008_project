
library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = "NYC Crime"),
  dashboardSidebar(
    selectInput("select", label = h5("Select Crime"), choices = list("Assault" = "Assault", "Burglary"="Burglary", "Car Theft" = "Car Theft", "Grand Larceny" = "Grand Larceny", "Murder" = "Murder", "Rape" = "Rape", "Robbery" = "Robbery")),
    sliderInput("Slider", "Year", 2000, 2015, 2000, step=1, sep = "")
  ),
  dashboardBody(
    plotOutput("plot", width = "82%")
  )
))

