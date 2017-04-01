# ui.R
library(shiny)
library(ggplot2)

# Define UI
fluidPage(
  
  # Title
  titlePanel("fMRI Biomarker for Deep Brain Stimulation"),
  
  # Sidebar
  sidebarLayout(
    sidebarPanel(
      radioButtons(
        "subj", 
        "Subject Number",
        c("Subject 1" = "635",
          "Subject 2" = "985",
          "Subject 3" = "76"),
        selected = "635"
      ),
      br(),
      radioButtons(
        "contact", 
        "Stimulation Site",
        c("Deep" = "1",
          "Middle" = "2",
          "Superficial" = "3"),
        selected = "2"
      ),
      br(),
      sliderInput(
        "voltage", 
        "Voltage", 
        value = 3,
        min = 1, 
        max = 7,
        step = 2,
        ticks = TRUE
      )
    ),
    
    # Main Panel
    mainPanel(
      # tabsetPanel(type = "tabs", 
      #             tabPanel("Plot", plotOutput("plot")), 
      #             tabPanel("Summary Data", plotOutput("summary")), 
      #             tabPanel("Brain Maps", imageOutput("facetplot"))
      tabsetPanel(
        type = "tabs", 
        tabPanel("Plot", plotOutput("plot"))
      )
    )
  )
)