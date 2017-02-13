shinyUI(dashboardPage(
  dashboardHeader(title = "Eating and Health"),
  dashboardSidebar(
    
    sidebarUserPanel("E & H"),
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("home")), #intro page
      menuItem("Graphs", tabName = "graph", icon = icon("bar-chart"), #important graphs
               menuSubItem("Health", tabName = "health", icon = icon("heartbeat")),
               menuSubItem("Time Spent Eating", tabName = "timeeat", icon = icon("clock-o")),
               menuSubItem("Food Type", tabName = "foodtype", icon = icon("coffee")),
               menuSubItem("Meal Preparation", tabName = "mealprep", icon = icon("shopping-cart")),
               menuSubItem("Exercise", tabName = "exercise", icon = icon("soccer-ball-o")),
               menuSubItem("Financial Situation", tabName = "finance", icon = icon("usd"))
               ),
      menuItem("Interactive", tabName = "interactive", icon = icon("hand-pointer-o")), #interactive
      menuItem("Dictionary", tabName =  "dictionary", icon = icon("book"))
    )
    
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tabItems(
      tabItem(tabName = "home",
              fluidRow(column( 12, h3("Eating and Health Module"),
                       p("The American Time Use Survey, collected by the US Department of Labor, provides estimates of
                         how Americans spend their time. This application was built to specifically view the Eating and
                         Health module of the survey. The data is used to examine eating and drinking patterns and how it
                         relates to one's health."),
                       a("For more information, please visit their website", href = "https://www.bls.gov/tus/ehdatafiles.htm"),
                       h4("Graphs"), p("The related variables have been grouped together and can individually 
                        be plotted against important health related variables."),
                       h4("Interactive"), p("Variables can be plotted against each other to view their relationships."),
                       h4("Dictionary"), p("Short summary of the questions related to each variable.")
                    
                       ))
              ),
      tabItem(tabName = "health",
              fluidRow(column(3, selectizeInput(inputId = "h1", label = "Variable 1", 
                                                choices = importantvars)),
                       column(3, uiOutput("h2")),
                       column(3, uiOutput("h3")),
                       column(3, uiOutput("h4"))
                       ),
              fluidRow(plotOutput(outputId = "hplot")
                       ),
              fluidRow( column(12, h4("Variables"),
                        verbatimTextOutput("hv1"),
                        verbatimTextOutput("hv2"),
                        verbatimTextOutput("hv3")
                       )),
              fluidRow(column(4, verbatimTextOutput("hv4")),
                       column(4, verbatimTextOutput("hv5")),
                       column(4, verbatimTextOutput("hv6"))
                       )
              ),
      tabItem(tabName = "finance",
               fluidRow(column(3, selectizeInput(inputId = "f1", label = "Variable 1",
                                                 choices = financialvars)),
                        column(3, uiOutput("f2")),
                        column(3, uiOutput("f3")),
                        column(3, uiOutput("f4"))
                        ),
              fluidRow(plotOutput(outputId = "fplot")
                       ),
              fluidRow( column(12, h4("Variables"),
                               verbatimTextOutput("fv1"),
                               verbatimTextOutput("fv2"),
                               verbatimTextOutput("fv3")
              )),
              fluidRow(column(4, verbatimTextOutput("fv4")),
                       column(4, verbatimTextOutput("fv5")),
                       column(4, verbatimTextOutput("fv6"))
              )
              ),
      tabItem(tabName = "exercise",
              fluidRow(column(3, selectizeInput(inputId = "e1", label = "Variable 1", 
                                                choices = exercisevars)),
                       column(3, uiOutput("e2")),
                       column(3, uiOutput("e3")),
                       column(3, uiOutput("e4"))
                       ),
              fluidRow(plotOutput(outputId = "eplot")
                       ),
              fluidRow( column(12, h4("Variables"),
                               verbatimTextOutput("ev1"),
                               verbatimTextOutput("ev2"),
                               verbatimTextOutput("ev3")
              )),
              fluidRow(column(4, verbatimTextOutput("ev4")),
                       column(4, verbatimTextOutput("ev5")),
                       column(4, verbatimTextOutput("ev6"))
              )
              ),
      tabItem(tabName = "mealprep",
              fluidRow(column(3, selectizeInput(inputId = "m1", label = "Variable 1", 
                                                choices = mealprepvars)),
                       column(3, uiOutput("m2")),
                       column(3, uiOutput("m3")),
                       column(3, uiOutput("m4"))
                       ),
              fluidRow(plotOutput(outputId = "mplot")
                       ),
              fluidRow( column(12, h4("Variables"),
                               verbatimTextOutput("mv1"),
                               verbatimTextOutput("mv2"),
                               verbatimTextOutput("mv3")
              )),
              fluidRow(column(4, verbatimTextOutput("mv4")),
                       column(4, verbatimTextOutput("mv5")),
                       column(4, verbatimTextOutput("mv6"))
              )
              ),
      tabItem(tabName = "foodtype",
              fluidRow(column(3, selectizeInput(inputId = "fo1", label = "Variable 1", 
                                                choices = eattypevars)),
                       column(3, uiOutput("fo2")),
                       column(3, uiOutput("fo3")),
                       column(3, uiOutput("fo4"))
                       ),
              fluidRow(plotOutput(outputId = "foplot")
                       ),
              fluidRow( column(12, h4("Variables"),
                               verbatimTextOutput("fov1"),
                               verbatimTextOutput("fov2"),
                               verbatimTextOutput("fov3")
              )),
              fluidRow(column(4, verbatimTextOutput("fov4")),
                       column(4, verbatimTextOutput("fov5")),
                       column(4, verbatimTextOutput("fov6"))
              )
              ),
      tabItem(tabName = "timeeat",
              fluidRow(column(3, selectizeInput(inputId = "t1", label = "Variable 1", 
                                                choices = timeeatvars)),
                       column(3, uiOutput("t2")),
                       column(3, uiOutput("t3")),
                       column(3, uiOutput("t4"))
                       ),
              fluidRow(plotOutput(outputId = "tplot")
                       ),
              fluidRow( column(12, h4("Variables"),
                               verbatimTextOutput("tv1"),
                               verbatimTextOutput("tv2"),
                               verbatimTextOutput("tv3")
              )),
              fluidRow(column(4, verbatimTextOutput("tv4")),
                       column(4, verbatimTextOutput("tv5")),
                       column(4, verbatimTextOutput("tv6"))
              )
              ),
      tabItem(tabName = "interactive",
              fluidRow(column(3, selectizeInput(inputId = "i1", label = "Variable 1", selected = "hgt", 
                                                choices = col_names)),
                       column(3, uiOutput("i2")),
                       column(3, uiOutput("i3")),
                       column(3, uiOutput("i4"))
                       ),
              fluidRow(plotOutput(outputId = "iplot")
                       ),
              fluidRow( column(12, h4("Variables"),
                               verbatimTextOutput("iv1"),
                               verbatimTextOutput("iv2"),
                               verbatimTextOutput("iv3")
              )),
              fluidRow(column(4, verbatimTextOutput("iv4")),
                       column(4, verbatimTextOutput("iv5")),
                       column(4, verbatimTextOutput("iv6"))
              )
              ),
      tabItem(tabName = "dictionary",
              fluidRow(dataTableOutput("dict")),
              fluidRow()
              )
      
    )
  )
))
