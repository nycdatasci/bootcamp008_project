library(shiny)
shinyUI(fluidPage(
  headerPanel(
    h1("NYC Crime Over Time", align = "center")
  ),
  title = "NYC Crime Over Time",
  plotOutput("plot", width = "82%"),
  hr(),
  br(),
  br(),
  fluidRow(
                 mainPanel(align = "center",
                   selectInput("select", label = h5("Select Crime"),
                               choices = list("Assault" = "Assault", "Burglary" = "Burglary", "Burglary" = "Burglary", "Grand Larceny" = "Grand Larceny", "Murder" = "Murder", "Rape" = "Rape", "Robbery" = "Robbery", "Car Theft" = "Car Theft")),
                   sliderInput("Slider", "Year", 2000, 2015, 2000, step=1, sep = "")
              )
        )))

