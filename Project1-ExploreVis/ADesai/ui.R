library(shiny)
library(leaflet)
library(shinythemes)

# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("San Diego's Burritos"),
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    selectInput('hood', label = h3('Select Neighborhood'), 
                choices = unique(rt2$Neighborhood), multiple = T), 
    sliderInput('rating', 'Yelp', 2, 5, 5),
    sliderInput('price', 'Price', 2.99,12, 12),
    selectizeInput(inputId = "num", 
                   label = "X-Axis (Linear)", 
                   choices = num_cols)
    ),
 
  mainPanel(
    
      tabsetPanel(
        tabPanel("Burrito Finder", leafletOutput('mymap')),
        tabPanel("Correlations", plotOutput('corrOut')),
        tabPanel("Linear", plotOutput('line'))
      
      
      )
  )
)
)
