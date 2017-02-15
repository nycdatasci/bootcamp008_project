imgURL <- "http://www.healthworks.my/wp-content/uploads/2014/10/drinking-man.jpg"


shinyUI(dashboardPage(
  dashboardHeader(title = "Alcohol Consumption in School"),
  dashboardSidebar(
    sidebarUserPanel("Grant Webb", image = imgURL),
    sidebarMenu(
      menuItem("Info", tabName = "Info", icon = icon("info")),
      menuItem("Distributions", tabName = "Distributions", icon = icon("bar-chart")),
      menuItem("BoxPlots", tabName = "BoxPlots", icon = icon("square")),
      menuItem("Data", tabName = "data", icon = icon("database")))
  ) ,
   dashboardBody(
      tabItems(
         tabItem(tabName =  "Distributions",
                 fluidRow(
                   selectInput("selected",
                               "Select Item to Display",
                               choice),
                   plotOutput("DailyAlcohol"),
                   plotOutput("WeekendAlcohol")
                   )
                 ),
         tabItem(tabName = "BoxPlots",
                 fluidRow(
                   selectInput("grades",
                               "Select Class Times",
                               class_time_grades),
                   plotOutput("BoxDailyAlcohol"),
                   plotOutput("BoxWeekendAlcohol")
                   )
                 ),
         tabItem(tabName = "data",
                           fluidRow(box(DT::dataTableOutput("table"), width = 20))
                           ),
         tabItem(tabName = "Info",
                 box(width = 12, status = "info", solidHeader = TRUE, title = "Information",
                     tags$p("The puprose of this app is to explore and visualize the 
                            amount of alcohol consummed by student between 15-22 years of age. Are there 
                            any trends in the lives of students which can lead to a higher chance for drinking? The data were obtained in
                            a survey of students math and portuguese language courses in secondary school. It contains a lot of interesting 
                            social, gender and study information about students."),
        
                     tags$b("Data Scouces"),
                     tags$br(),
                     tags$a(href="https://www.kaggle.com/uciml/student-alcohol-consumption", "Student Alcohol Consumptions Kaggel")
                     
                     ))
       )
 
   )
))