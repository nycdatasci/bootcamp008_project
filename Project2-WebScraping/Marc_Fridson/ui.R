
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinydashboard)
library(dplyr)

shinyUI(dashboardPage(skin = "green",
                      dashboardHeader(title = "NFL Draft Analysis"),
                      dashboardSidebar(
                        sidebarUserPanel("Marc Fridson"),
                        sidebarMenu(
                          menuItem("NFL Team Draft Success", tabName = "nfl_team", icon = icon("star")),
                          menuItem("Pro Bowls by Round/Position", tabName = "probowl_rnd", icon = icon("bar-chart")),
                          menuItem("Years in the NFL by Age", tabName = "age_years", icon = icon("bar-chart")),
                          menuItem("NFL Success by School", tabName = "coll_success", icon = icon("university")),
                          menuItem("CFB QB to NFL Success", tabName = "qb_coll", icon = icon("star")),
                          menuItem("CFB RB/FB to NFL Success", tabName = "rbfb_coll", icon = icon("star")),
                          menuItem("CFB WR/TE to NFL Success", tabName = "wrte_coll", icon = icon("star")),
                          menuItem("CFB Kicker to NFL Success", tabName = "k_coll", icon = icon("star")),
                          menuItem("CFB Punter to NFL Success", tabName = "p_coll", icon = icon("star"))
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
                            fluidPage(box(DT::dataTableOutput("sch_tbl"),width = "100%"))),
                          
                          tabItem(tabName = "qb_coll",fluidPage(
                            h1("QB College Stats vs NFL Success"),
                            hr()),
                            fluidRow(box(splitLayout(radioButtons("xlab1","Choose X Axis Variable:", c("games","completions","passing_attempts","pass_yards","yards_per_attempt","passing_tds","interceptions","rating","rush_attempts","rush_yards","avg_rush_yards"),selected = 'games',inline=TRUE,width = "35%"),radioButtons("ylab1","Choose Y Axis Variable:", c("pb","pro_years"),selected = 'pb'),sliderInput("year_slide4","Draft Years Included:",1985,2015,c(1985,2015),sep = "")),height="150px",width = "99%"),width="100%"),
                            fluidRow(box(plotOutput("qb_plot"),width = "100%"))),
                          
                          tabItem(tabName = "rbfb_coll",fluidPage(
                            h1("RB/FB College Stats vs NFL Success"),
                            hr()),
                            fluidRow(box(splitLayout(radioButtons("xlab2","Choose X Axis Variable:", c("games","rush_attempts","rush_yards","avg_rush_yards","rushing_tds","receptions","receiving_yards","avg_receiving_yards","avg_receiving_yards","receiving_tds","scrim_plays","scrim_yards","avg_scrim_yards","scrim_tds"),selected = 'games',inline=TRUE,width = "35%"),radioButtons("ylab2","Choose Y Axis Variable:", c("pb","pro_years"),selected = 'pb'),sliderInput("year_slide5","Draft Years Included:",1985,2015,c(1985,2015),sep = "")),height="150px",width = "99%"),width="100%"),   
                            fluidRow(box(plotOutput("rbfb_plot"),width = "100%"))),
                          
                          tabItem(tabName = "wrte_coll",fluidPage(
                            h1("WR/TE College Stats vs NFL Success"),
                            hr()),
                            fluidRow(box(splitLayout(radioButtons("xlab3","Choose X Axis Variable:", c("games","rush_attempts","rush_yards","avg_rush_yards","rushing_tds","receptions","receiving_yards","avg_receiving_yards","avg_receiving_yards","receiving_tds","scrim_plays","scrim_yards","avg_scrim_yards","scrim_tds"),selected = 'games',inline=TRUE,width = "35%"),radioButtons("ylab3","Choose Y Axis Variable:", c("pb","pro_years"),selected = 'pb'),sliderInput("year_slide6","Draft Years Included:",1985,2015,c(1985,2015),sep = "")),height="150px",width = "99%"),width="100%"),   
                            fluidRow(box(plotOutput("wrte_plot"),width = "100%"))),
                          
                          tabItem(tabName = "k_coll",fluidPage(
                            h1("Kicker College Stats vs NFL Success"),
                            hr()),
                            fluidRow(box(splitLayout(radioButtons("xlab4","Choose X Axis Variable:", c("games","xpm","xpa","xp_per","fgm","fga","fg_per","points"),selected = 'games',inline=TRUE,width = "35%"),radioButtons("ylab4","Choose Y Axis Variable:", c("pb","pro_years"),selected = 'pb'),sliderInput("year_slide7","Draft Years Included:",2003,2015,c(2003,2015),sep = "")),height="150px",width = "99%"),width="100%"),   
                            fluidRow(box(plotOutput("k_plot"),width = "100%"))),
                          
                          tabItem(tabName = "p_coll",fluidPage(
                            h1("Punter College Stats vs NFL Success"),
                            hr()),
                            fluidRow(box(splitLayout(radioButtons("xlab5","Choose X Axis Variable:", c("games","punts","punt_yards","avg_punt"),selected = 'games',inline=TRUE,width = "35%"),radioButtons("ylab5","Choose Y Axis Variable:", c("pb","pro_years"),selected = 'pb'),sliderInput("year_slide8","Draft Years Included:",2003,2015,c(1985,2015),sep = "")),height="150px",width = "99%"),width="100%"),
                            fluidRow(box(plotOutput("p_plot"),width = "100%")))
                        )  
                      )
)
)