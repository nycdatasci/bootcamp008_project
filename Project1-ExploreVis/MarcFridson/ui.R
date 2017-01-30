
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(skin = "green",
  dashboardHeader(title = "NFL Draft Analysis"),
  dashboardSidebar(
    sidebarUserPanel("Marc Fridson"),
    sidebarMenu(
    menuItem("NFL Team Draft Success", tabName = "nfl_team", icon = icon("star")),
    menuItem("Pro Bowls by Round/Position", tabName = "probowl_rnd", icon = icon("bar-chart")),
    menuItem("Years in the NFL by Age", tabName = "age_years", icon = icon("bar-chart")),
    menuItem("NFL Success by School", tabName = "coll_success", icon = icon("university"))
  )),
  dashboardBody(
    tabItems(
      tabItem(tabName="nfl_team",fluidPage(
      h1("NFL Team Draft Performance"),
      hr(),
      fluidRow(box(splitLayout(checkboxGroupInput("check_pos","Positions to include:", c("QB","RB","FB","WR","TE","T","G","C","DE","DT","LB","DB","K","P"),selected = c("QB","RB","FB","WR","TE","T","G","C","DE","DT","LB","DB","K","P"),inline = TRUE,width = "50%"),sliderInput("year_slide","Draft Years Included:",1985,2015,c(1985,2015),sep = "",width = "98%")),width = "100%",height = "95px")),
      fluidRow(box(plotOutput("team_plot"),width = "100%")),
      fluidRow(box(strong("League Wide Summary Statistics for Selections"),tableOutput("Rnd_Summary"),width="100%",height = "200px"))
          )
        ),
    tabItem(tabName = "probowl_rnd",fluidPage(
      h1("Pro Bowl Appearances By Round and Position"),
      hr()),
    fluidRow(box(selectInput("team_sel","Select Teams to include:",levels(nfl$Tm),selected=NULL,multiple=TRUE,width = "99%"),width = "100%")),
    fluidRow(box(sliderInput("year_slide2","Draft Years to include:",1985,2015,c(1985,2015),sep = "",width = "99%"),width = "100%")),  
    fluidRow(box(plotOutput("pb_plot"),width = "100%"))),
    
    tabItem(tabName = "age_years",fluidPage(
      h1("Career Length by Draft Age and Position"),
      hr()),
      fluidRow(box(selectInput("team_sel2","Select Teams to include:",levels(nfl$Tm),selected=NULL,multiple=TRUE,width = "99%"),width = "100%")),
      fluidRow(box(sliderInput("year_slide3","Draft Years to include:",1985,2015,c(1985,2015),sep = "",width = "99%"),width = "100%")),  
      fluidRow(box(plotOutput("age_plot"),width = "100%"))),
    
    tabItem(tabName = "coll_success",fluidPage(
      h1("NFL Success by College Attended"),
      hr()),
    fluidPage(box(DT::dataTableOutput("sch_tbl"),width = "100%")))
)  
)
)
)