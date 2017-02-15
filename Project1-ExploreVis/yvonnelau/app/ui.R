?##############################################
###  Data Science Bootcamp 8               ###
###  Project 1 - Exploratory Visualization ###
###  Yvonne Lau  / January 29, 2017        ###
###     Restaurant Closures from Health    ###
###           Inspections in NYC           ###
##############################################


library(shiny)
library(shinydashboard)
library(leaflet)
library(ggplot2)
library(plotly)
library(reshape)

source("globals.R")

#
general_map_year <- c('2013' = 2013,'2014' = 2014,'2015' = 2015, '2016' = 2016,'2017' = 2017)
general_borough <- c("All Boroughs" = 1, "Manhattan","Bronx","Queens","Staten Island","Brooklyn")
general_year <- c("All Years" = 1, "2013","2014","2015","2016")
closure_info_year <- c("All Years"=1,'2012'= 2012,'2013' = 2013,'2014' = 2014,'2015' = 2015, '2016' = 2016,'2017' = 2017)
closure_info2_year <- c("All Years"=1,'2012'= 2012,'2013' = 2013,'2014' = 2014,'2015' = 2015, '2016' = 2016,'2017' = 2017)

#--------UI Design
dashboardPage(skin = "green",
  dashboardHeader(title = "NYC Restaurant Health Inspection Explorer",titleWidth = 400),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Map of Temporary Closures", tabName = "map", icon = icon("map")),
      menuItem("Restaurant Closures Analytics",tabName = "closure_info",icon = icon("bar-chart"),
               menuSubItem("Length of Closure", tabName = "days_closed"),
               menuSubItem("Proportion of Closure",tabName = "closure_prob")),
      menuItem("Closures Data", tabName = "data", icon = icon("database")),
      helpText("General Information", align = "center"),
      menuItem("Overview of All Restaurants",tabName = "overview",icon = icon("arrows-alt"),
               menuSubItem("By Borough", tabName = "general"),
               menuSubItem("By Borough and Cuisine", tabName = "tile")),
      menuItem("About this App", tabName = "app",icon=icon("info")),
      helpText("About Author",  align = "center"),
      menuItemOutput("lk_in"),
      menuItemOutput("blg")
    )),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tags$style("#closureBox {width:275px;}"),
    tabItems(
      tabItem(tabName = "general",
              fluidRow(box(selectInput("general_boro",h4("Select your Borough"),general_borough))),
              fluidRow(infoBoxOutput("totalBox"),
                       infoBoxOutput("criticalBox"),
                       infoBoxOutput("aBox")),
              fluidRow(box(
                width = 12, status = "success", solidHeader = TRUE,
                title = "Health Inspection Grades(2013-2016)",
                htmlOutput("grade_plot"))),
              br(),
              fluidRow(box(
                  width = 12, status ="success", solidHeader = TRUE,
                  title = "Density of Restaurants by Health Inspection Score",
                  plotOutput(outputId = "score_plot", height = 250)))),
      
      tabItem(tabName = "tile",
              fluidRow(box(
                selectInput("general_year",h4("Select your year"),general_year))),
              fluidRow(box(
                width = 12, status = "success", solidHeader = TRUE,
                title = "Inspection scores by Borough and Cuisine",
                plotlyOutput("cuisine_borough_plot")))),
      
      tabItem(tabName = "map",
              # Include custom CSS from Shiny RStudio
              tags$head(
                includeCSS("styles.css"),
                includeScript("gomap.js")
                ),
              leafletOutput("map", height = 600, width = "100%"),
              absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                            draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                            width = 330, height = "auto",
                            
                            h2("Restaurant Closures Explorer"),
                            checkboxGroupInput('close_year', 
                                               label = h3('Select Years'),
                                               choices = general_map_year, 
                                               selected = c(2012, 2013, 2014, 2015, 2016,2017)
                            ),
                            sliderInput("score_range", label = h3("Scores"), min = 0, 
                                        max = 117, value = c(0,117))
              )),
      tabItem(tabName = "data",
              DT::dataTableOutput('closure')),
      tabItem(tabName = "days_closed",
              fluidRow(box(width = 6, selectInput("closure_info_year",h4("Select a year"),closure_info_year)),
                       box(width=6, infoBoxOutput("closureBox"))),
              fluidRow(box(
                width = 12, status ="success", solidHeader = TRUE,
                title = "Number of days Restaurants stayed closed due to Health Violations",
                htmlOutput("days_close_hist"))),
              fluidRow(box(
                width = 12, status ="success", solidHeader = TRUE,
                title = "Distributions of Inspection Scores by Length of Closure",
                plotlyOutput("days_close_barplot")))),
      tabItem(tabName = "closure_prob",
              fluidRow(box(width = 6,height =150,
                           selectInput("closure_prob_year",h4("Select a year"), closure_info2_year)),
                       box(width = 6,height = 150,
                           sliderInput("closure_prob_n", label = h4("Choose number of values to display"), min = 1, 
                                                  max = 135, value = 10))),
              fluidRow(box(width = 12, status = "success",solidHeader = TRUE,
                           title = "Proportion of Closures by Borough",
                           htmlOutput("closure_prob_plot_borough"))),
              fluidRow(box(width = 12, status = "success",solidHeader = TRUE,
                           title = "Proportion of Closures by Borough and Cuisine",
                           htmlOutput("closure_prob_plot"))),
              fluidRow(tabsetPanel(
                tabPanel("Restaurant Closures By Borough", DT::dataTableOutput('closure_prob_data')),
                tabPanel("Restaurant Closures By Borough and Cuisine", DT::dataTableOutput('closure_prob_borough_data'))
              ))),
      
      tabItem(tabName = "app",
              box(width = 12, status = "success", solidHeader = TRUE, title = "About this App",
                  tags$p("This app explores NYC Health Department Restaurant inpspection data from 2012 to 2017. 
                         It attemps to answer the question of which restaurants or type cuisines and boroughs are safer
                         to eat at in NYC"),
                  tags$b("How restaurants are graded"),
                  tags$br(),
                  tags$p("According to the Health Department, Restaurants with a score between 0 and 13 points earn an A, 
                         those with 14 to 27 points receive a B and those with 28 or more a C."),
                  tags$p("A restaurant's score depends on how well it follows City and State food safety requirements. Inspectors 
                  check for food handling, food temperature, personal hygiene, facility and equipment maintenance and vermin control.
                  Each violation earns a certain number of points. If a violation is deemed a public health hazard (example:failing to keep food at 
                  right temperature), and such violaiton can't be corrected by the end of the inspection, the Health Department
                         may close the restaurant until the problem is fixed"),
                  tags$b("General Overview of restaurants"),
                  tags$br(),
                  tags$p("This section takes a closer look at the distribution of Scores and Grades by Borough and Cuisine 
                         of all restaurants in NYC."),
                  tags$b("Restaurant Closures"),
                  tags$p("This section focuses on restaurants which have been closed by NYC Health Department for commiting infractions
                         considered to be a public health hazard. It takes a closer look at the relationship between the number of days a
                         restaurant stays closed and the Sanitation Score. It also explores whether there are Boroughs or Boroughs and
                         Cuisine types which are more likely to have restaurants closed by the Health Department"),
                  tags$b("Data Scouces"),
                  tags$br(),
                  tags$a(href="https://data.cityofnewyork.us/Health/DOHMH-New-York-City-Restaurant-Inspection-Results/xx67-kt59", 
                         "DOHMH New York City Restaurant Inspection Results"),
                  tags$br(),
                  tags$a(href="http://www1.nyc.gov/assets/doh/downloads/pdf/rii/how-we-score-grade.pdf", 
                         "How Health Department Scores Restaurants (Jan,18 2017 version)")
              
                  ))
  )
))
