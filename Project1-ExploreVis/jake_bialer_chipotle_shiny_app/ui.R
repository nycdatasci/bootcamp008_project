library(shiny)
library(shinydashboard)
library(leaflet)

dashboardPage(
    dashboardHeader(
      title = "Chipotle Analysis",
      titleWidth = 350
    ),
    dashboardSidebar(
      width = 350,
      sidebarMenu(
        menuItem("Introduction", tabName = "Introduction"),
        menuItem("How Do Chipotle Prices Vary?", tabName = "Prices"),
        menuItem("Where Does Chipotle Have Food Shortages?", tabName = "Shortages"),
        menuItem("Where Is The Best Chipotle For Me?", tabName = "Locations"),
        menuItem("What Explains The Chipotle Price Variance?", tabName = "PriceVariance")
      )
    ),
    dashboardBody(
      tabItems(
        tabItem(
          tabName="Introduction",
          fluidRow(
            tabBox(
              width = 12,
              tags$div(
                includeHTML("intro.html")
              )
          )
          )
          
        ),
        
        tabItem(
          tabName = "Prices",
          
          fluidRow(box(
            width = 12,
            h3("How Do Chipotle Prices Vary?"),
            p("Like many national chains, the price of Chipotle varies based on geographic region. 
              This is not suprising given cost, demand, and numerous other factors differ based on geographic regions"),
            p("However, if you eat at Chipotle for",
              a(href = 'http://people.com/food/this-guy-has-eaten-chipotle-for-318-days-straight-and-still-looks-like-this/', '318 days straight'), 
              ", Chipotle can represent a significant cost-of-living expense  and the price of a burrito is a serious consideration."),
            p(" Chipotle pricing information is also of interest to people determining pricing strategy for national businesses. 
              Chipotle's prices could serve as a useful basis of comparision."),
            selectizeInput(
              inputId = "menu_item",
              label = "Select Menu Item",
              choices = menu_items
            )
          
          )),
          
          fluidRow(
            tabBox( width = 12,
                   tabPanel("Map",
                            plotOutput(outputId = "plot")
                          ),
                   tabPanel("Data",
                            dataTableOutput('mytable')
                            
                   ),
                   tabPanel("Graph",
                            plotOutput(outputId = "plot3")
                            )
            )
          )
        )
        ,
        tabItem(
          tabName = "Shortages",
          fluidRow(box(
            width = 12,
            h3("Chipotle Food Shortages"),
            p("Chipotle has specific farming requirements for the food they serve. 
              When Chipotle's food doesn't meet their requirements, they display a message on their site. They currently are displaying message to inform users about pork shortages on their site in U.S and chicken shorages in Canada.")
          ),
          fluidRow(box(
            width = 12,
            h4("Carnitas Shoratges"),
            p("Some Chipotle locations serve pork from the UK that doesn't meet all of their food standards. This message is diplayed when a user visits the page:",
            tags$blockquote("FYI This restaurant is currently serving carnitas made with pork that meets or exceeds all of our animal welfare standards, 
                            but not all facets of our antibiotic protocol. For details visit:", a(href = 'chipotle.com/carnitas', 'chipotle.com/carnitas')
            )),
            plotOutput(outputId = "plot2"),
            h4("Chicken Shoratges"),
            p('Fourteen of seventeen (82%) locations in Canada have a chicken shortage. These locations display the message, "FYI This restaurant is currently serving conventionally raised chicken. We\'ll be back to our unconventional ways ASAP.')
          ))
          
        )),
        tabItem(
          tabName = "Locations",
          fluidRow(
            width = 12,
            h3("Find The Best Chipotle For You"),
            box(width=12,
            p("Using Chipotle, Yelp, and sales tax data, you can find the best Chipotle for your needs! ")
            )
        
          
          
        ),
          fluidRow(
            column(
            width = 12,
            box(
            checkboxInput("tax", "Include Sales Tax", FALSE)
            ),
            box(
            numericInput("yelp_min", "Min Num of Yelp Reviews", value = 0, min=0,max=100)
            ),
            box(
            sliderInput("yelp", "Yelp Rating:",
                        min = 0, step=.5,max = 5, value = c(0,5)
            )),
            box(
              selectizeInput(
                inputId = "menu_item1",
                label = "Select Menu Item",
                choices = menu_items
              )),
            box(
              checkboxInput("shortage", "Exclude Locations With Carnitas Shortages", FALSE)
              
            )
            
            )
        ),
        fluidRow(
          width = 12,
          leafletOutput("mymap")
          
        )

      ),
      tabItem(
        tabName = "PriceVariance",
        h3("What explains the variation in price?"),
        fluidRow(
          width = 12,
          h4("Prices By Region"),
          p("For simplicity, when focusing on different prices, we will just look at steak burritos. Menu items prices change together, so a model for steak burritos
            should match other burrito prices."),
          p("Based on observing the maps, there are clear regional differences in price, especially in New York"),
          plotOutput('region_table')),
        fluidRow(
          width = 12,
          h4("Comparing Variables"),
          
          p("Prices also vary by housing price, population, and other factors"),
          p("Use the scatterplots below to compare prices"),
          selectizeInput(
            inputId = "the_col_name",
            label = "Select Regression Item",
            choices = global_items
          ),
          plotOutput('scatterplot'),
          h4("Regression"),
          p("Based on these observations, we can perform a regression..."),
          verbatimTextOutput("regression")
          
          
        )
        
        
      )
      )
    )
)
  
