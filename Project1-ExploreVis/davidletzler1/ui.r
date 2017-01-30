library(shiny)

shinyUI(fluidPage(
  
  titlePanel(title=h2("New York City Public School Performance on Common Core Exams", style = "font-family: 'times'", align='center')),
  sidebarLayout(
    sidebarPanel(
      helpText("Select Criteria"),
      
      radioButtons("test", label = h5("Select Test"), choices = list("English/Language Arts", "Mathematics"), selected="Mathematics"),
      selectInput("grade", label = h5("Select Grade Level"), choices = list("3rd Grade"='3', "4th Grade"='4', "5th Grade"='5', "6th Grade"='6', "7th Grade"='7', "8th Grade"='8', "All Grades"="All Grades"), selected="All Grades"),
      selectInput("year", label = h5("Select Year"), choices= list("2013"=2013, "2014"=2014, "2015"=2015, "2016"=2016), selected=2016),
      selectInput("income", label=h5("Select Neighborhood Income Bracket"), choices=list("Highest Quintile", "Second-Highest Quintile", "Middle Quintile", "Second-Lowest Quintile", "Lowest Quintile", "All"), selected="All"),
      sliderInput("range", label=h5("% Proficiency Range"), min=0, max=100, value=c(0,100))
      ),
    mainPanel(
      leafletOutput("map", height=800)
  ))
  
))