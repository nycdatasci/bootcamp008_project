datatable(df)

imgURL = "click.jpg"
#function to control UI        
ui <- fluidPage(
  
  dashboardPage(
    
  dashboardHeader(title = "Next 911 Call"),
  
  dashboardSidebar(
    
    sidebarUserPanel("Arjun Singh Yadav",
                     image = imgURL),
    
    
    sidebarMenu(
      
      menuItem("Map", tabName = "map", icon = icon("map")),
      
      menuItem("Crime Density", tabName = "Cluster", icon = icon("pushpin", lib = "glyphicon")),
      
      menuItem("Data", tabName = "data", icon = icon("database")),
      
      menuItem("Summary", tabName = "summary", icon = icon("analysis"))),
    
    
    dateRangeInput(inputId="date_range",
              label=" Date Range:",
              min = as.Date("2012-03-01"), max = Sys.Date(), end = NULL,
              format = "yyyy-mm-dd",
              startview = "2012-03-01",
              weekstart = 0,
              language = "en", width = NULL),
    
    br(),
   
    selectInput("yaxis", "Choose Type Of Crime",
                choices =  c("Accident Priority" = "ACCIDENT.P",
                           "Accident" = "ACCIDENT",
                         "Disturbance Call Priority" = "DIST.P",
                         "Disturbance Call" = "DIST",
                         "Assult Call" = "ASSULT",
                         "Assult Call Priority" = "ASSULT.P",
                         "Assistance Required" = "ASSIST",
                         "Assistance Required Priority" = "ASSIST.P",
                         "Bombing Material Found" = "BOMB",
                         "Burglary" = "BURG",
                         "Burglary High Priority" = "BURG.H",
                         "Burglary Priority" = "BURG.P",
                         "Chemical Discharge Reported" = "CHEM",
                         "Disturbance In School" = "SC_DIST",
                         "School Disturbance Priority" = "SC_DIST.P",
                         "Shot Fired" = "SHOT",
                         "Shooting Priority" = "SHOT.P",
                         "Stabbing Cold" = "STAB"
                         ),selected = "STAB"
                       )
    ),
  
  dashboardBody(
    
    tabItems(
      tabItem(tabName ="map",
              leafletOutput("mymap",width="100%",height="1000px")
              # absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
              #               draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
              #               width = 330, height = "auto")
              ),
      
      
      tabItem(tabName ="Cluster",
              plotOutput("clus", width = "100%", height = "800px", click = NULL,
                         dblclick = NULL, hover = NULL, hoverDelay = NULL,
                         hoverDelayType = NULL, brush = NULL, clickId = NULL, hoverId = NULL,
                         inline = FALSE)),
      
      tabItem(tabName = "data",
              fluidPage(theme = shinytheme("spacelab"),
                        fluidRow(
                          column("NATIONAL INSTITUTE OF JUSTICE DATABASE",dataTableOutput(outputId = "table"),width=12),
                          column(10,p(textOutput("para")))))),
      tabItem(tabName ="summary",
              fluidPage(
                
                mainPanel(
                  plotOutput('plot1'))))
    )
  )
)
)




