## ui.R ##

  home <- tags$html(
    tags$head(
      tags$title('The Energy Benchmarking Dashboard')
    ),
    tags$body(
      leafletOutput("map", width = "100%", height = "750"),
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                    draggable = TRUE, top = 100, right = 25, bottom = "auto", left = "auto",
                    width = 250, height = "auto",
                    h3(strong('The Building Energy Dashboard')),
                    p('In the United States, a group of progressive cities have begun collecting and publicly reporting energy consumption of large buildings.'),
                    p('This map shows average building energy consumption within each zip code.'),
                    p('Use the map to explore which neighborhoods are using the most energy, and change years to see how energy use is changing over time!'),
                    p('To explore further, click a tab on the panel to the left. Explore maps, graphs, or the data itself.'),
                    selectizeInput("mapcity", "Select City to Display", 
                                   mapcities, selected = "NYC"),
                    selectizeInput("mapyear", "Pick Year to Display",
                                   2011:2015, selected = 2014)
                    )
      )
      )
  sidebar <- dashboardSidebar(
    
      sidebarUserPanel("", image = "http://www.pd4pic.com/images/building-flat-cartoon-trees-windows-doors-tall.png"),
      sidebarMenu(
        menuItem("Home", tabName = "home", icon = icon("home")),
        menuItem("Data Explorer", tabName = "graph", icon = icon("flag")),
        menuItem("City Explorer", tabName = "city", icon = icon("building")),
        menuItem("View Data", tabName = "data", icon = icon("database"))
        )
    )
  
  body <- dashboardBody(
      tabItems(
        tabItem(tabName = "home",
                fluidRow(box(width = 15, 
                             home))),
        tabItem(tabName = "data",
                fluidRow(
                    column(width = 2,
                           tabBox(width = NULL,
                                  tabPanel(h5("Filter"),
                                   checkboxGroupInput('data_years', 'Years to Display:',
                                                      c(2011, 2012, 2013, 2014, 2015), selected = 2013),
                                   checkboxGroupInput('data_cities', 'Cities to Display:',
                                                      cities, selected = "New York City")
                          ))),
                    column(width = 10,
                      wellPanel(dataTableOutput("table"))))),
        
        tabItem(tabName = "graph",
                fluidRow(
                  column(width = 3,
                     h4("Customize Plot"),
                     checkboxGroupInput('show_years', 'Years to Display:',
                                            c(2011, 2012, 2013, 2014, 2015), selected = 2013),
                     checkboxGroupInput('show_cities', 'Cities to Display:',
                                  cities, selected = "New York City"),
                     sliderInput("xrange", "Set x-axis range", min = 0, max = 1000, value = c(0, 1000)),
                     sliderInput("yrange", "Set y-axis range", min = 0, max = 1000000, value = c(0, 10000000)),
                     selectInput("xvar", "X-axis variable", plotxvalues, selected = "NormSourceEUI"),
                     selectInput("yvar", "Y-axis variable", plotyvalues, selected = "ReportedGFA")
                  ),
                  column(width = 9,
                          fluidRow(wellPanel(plotOutput("graph1")))))),
        
        tabItem(tabName = "city",
                fluidRow(box(width = 9,
                        radioButtons("radio", label = h4(strong("Select City to Display")),
                                choices = list("New York City" = "New York City",
                                               "Washington, DC" = "DC", "San Francisco" = "San Francisco"), 
                                          selected = "New York City")),
                        #Stats feature to be added!
                            # wellPanel(width = 5,
                            #     h4(textOutput("willitwork")),
                            #     textOutput("citystats1"),
                            #     textOutput("citystats2")
                            #     ),
                            box(width = 3,
                                h5("Advanced Options:"),
                                checkboxInput("log", "Log Transform Plots", FALSE))),
                fluidRow(box(width = 6, 
                                   plotOutput("city1")),
                         box(width = 6,
                            plotOutput("city2"))),
                fluidRow(box(width = 6,
                             plotOutput("city3")),
                         box(width = 6,
                             plotOutput("city4")))
                )
        ))
  
  shinyUI(
    dashboardPage(
      dashboardHeader(title = "Benchmarking Energy Dashboard"),
      sidebar,
      body
    ))