# US Map w population stats.

shinyUI(
    dashboardPage(
        dashboardHeader(title = "Lending Club"),
        dashboardSidebar(
          
            sidebarUserPanel("NYC DSA",
                             image = "https://yt3.ggpht.com/-04uuTMHfDz4/AAAAAAAAAAI/AAAAAAAAAAA/Kjeupp-eNNg/s100-c-k-no-rj-c0xffffff/photo.jpg"),
            sidebarMenu(
              menuItem("Map", tabName = "map", icon = icon("map")),
              menuItem("Grades", tabName = "grades", icon = icon("bar-chart")),
              menuItem("Rates", tabName = "rates", icon = icon("bar-chart")),              
              menuItem("Correls", tabName = 'correls', icon = icon("random")),
              menuItem("Data", tabName = "data", icon = icon("database"))
              )
            # ,
            # selectizeInput("selected",
            #                "Select Item to Display",
            #                c("stavg", "grade")
            #                 )
        ),    # dbSidebar
        dashboardBody(
            tags$head(
              tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
            ),
            tabItems(

              tabItem(tabName = "map",
                      fluidRow(box(width=12,plotOutput("map")))
                      ),
                               # box(htmlOutput("hist"), height = 300))),
              tabItem(tabName = "grades",
                      fluidRow(box(width=12,plotOutput("grades")))
                      ),
              
              tabItem(tabName = "rates",
                      fluidRow(box(width=12,plotOutput("rates"),
                                   sliderInput("slider1", label = h3("Year"), min = 2008, 
                                                max = 2011, step = 1, value = 2008, sep = FALSE,
                                               ticks = TRUE, animate = TRUE)
                                  )
                          )    # fluidRow
                  ),    # tabItem

              tabItem(tabName = "correls",
                      fluidRow(box(width=12,plotOutput("correls"), height = 500))
                  ),
              
              tabItem(tabName = "data",
                      fluidRow(box(DT::dataTableOutput("table"), width = 12))
                      )
                    
              )    # tabItems
        )    # dbBody
    )    # dbPage
)    # shinyUI