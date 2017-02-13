##############################################
###  Data Science Bootcamp 8               ###
###  Project 2 - Web Scrapping             ###
###  Yvonne Lau  / February 9, 2017        ###
###         Skincare Products              ###
###         Recommender System             ###
##############################################


library(shiny)
library(shinydashboard)


categories_list <- unique(data_review_only$Category)
#--------UI Design
dashboardPage(skin = "purple",
              dashboardHeader(title = "Skincare Reviews"),
              dashboardSidebar(
                sidebarMenu(
                  menuItem("Get a recommendation", tabName = "recommender", icon = icon("thumbs-o-up")),
                  menuItem("Methodology", tabName = "app",icon=icon("info")),
                  menuItem("General information",tabName = "overview",icon = icon("arrows-alt")),
                  helpText("About Author",  align = "center"),
                  menuItemOutput("lk_in"),
                  menuItemOutput("blg")
                )),
              dashboardBody(
                tabItems(
                  tabItem(tabName = "recommender", 
                          fluidRow(
                            box(width = 12, 
                                column(4, 
                                       selectizeInput("category",
                                       h5("1.Select a Category of skincare product"),
                                       choice = categories_list)),
                                column(4, 
                                       selectizeInput("tags",
                                                      h5("2. Select what you would like in your product"),
                                                      choice = c("a","b"), 
                                                      multiple = T)), 
                                column(4, align = "bottom",
                                       fluidRow(
                                         helpText(h5("3. Get a recommendation")),
                                         actionButton("recommend", h4("***Recommend me a product***"))
                                       ))
                          )),
                          fluidRow(
                            DT::dataTableOutput("rec")
                          )),
                  tabItem(tabName = "overview",
                          # Top Row with general information on dataset
                          fluidRow(infoBox("Reviews",51788,color='yellow'),
                                   infoBox("Skincare Products",6262,color = 'yellow'),
                                   infoBox("% Reviews ratings > 9", "59.53%", color='yellow')),
                          # Tabs with products segmented by brand and 
                          fluidRow(
                            tabBox(id = "tabset1", width = 12,
                                   tabPanel("Wordcloud",
                                            wordcloud2Output('wordcloud2')),
                                   tabPanel("Distribution of User Ratings", plotOutput("ratings")),
                                   tabPanel("Reviews By Brand",
                                              htmlOutput("top_brands")),
                                   tabPanel("Reviews By Product",
                                            htmlOutput("top_products"))
                                   ))),
                  tabItem(tabName = "app",
                          box(width = 12, status = "warning", solidHeader = TRUE, title = "About this App",
                              tags$b("Motivation"),
                              tags$p("I love trying new skincare products. However, sometimes it takes a bit of time to sift through reviews to find a good match"),
                              tags$p("This app is designed for skincare products lovers like me to discover new products closely related to their preferences"),
                              tags$br(),
                              tags$b("General Overview of Data"),
                              tags$p("Dataset of over 50,000 reviews was collected from totalBeauty.com")
                          ))
                )
              ))