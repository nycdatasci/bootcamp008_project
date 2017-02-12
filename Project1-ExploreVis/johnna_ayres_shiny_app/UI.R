library(shiny)
library(shinydashboard)

shinyUI(fluidPage(
  titlePanel("First Term Presidential Impact on Congressional Mid-Term Elections"), #(align = center)


  sidebarLayout(
    
    sidebarPanel(

      selectInput("president", 
                  label = h3("Select Presidential First Term"), 
                  choices = list("Ronald Reagan 1980 (R)" = 1980, 
                                 # "Regan Mid-Term" = 1982,
                                 "George HW Bush 1988 (R)" = 1988, 
                                 # "Bush I Mid-Term" = 1990, 
                                 "Bill Clinton 1992 (D)" = 1992, 
                                 # "Clinton Mid-Term" = 1994,
                                 "George W Bush 2000 (R)" = 2000,
                                 # "Bush II Mid-Term" = 2002, 
                                 "Barack Obama 2008 (D)" = 2008,
                                 # "Obama Mid-Term" = 2010,
                                 "Donald Trump 2016 (R)" = 2016), 
                  selected = 1980),
    
      checkboxInput("mid_term",
                    label = "Select Congressional Mid-Term Election",
                    value = FALSE),
      hr(),
      htmlOutput("bar3")
  ),
    
    mainPanel(h2("US Senate"),
              htmlOutput("map1"),
              h2("US House of Representatives"),
              htmlOutput("map2"))
              #h2("Congressional Seat Changes")
              #htmlOutput("bar3")
)))

