library(shiny)
library(leaflet)
require(global.R)
options(shiny.error = browser)

fluidPage(
  
  fluidRow(
    column(width = 10,
           offset = 1,
           br(),
           img(src='hs_logo.png', width=162, height=54),
           br()
          ),
  fluidRow(
    column(width = 10,
           offset = 1,
         helpText("Built on NYC 311 heating complaint data and Heat Seek temperature sensor data")),
    column(width = 10,
           offset = 1,
           tabsetPanel(
             tabPanel("Intro",
                      HTML(
                        "<br>",
                        "<p>Heat Seek is a team of New Yorkers who believes no New Yorker should have to spend the winter in a frigid apartment. The reality is, this happens to thousands of us every year, 
                        creating a public health hazard and some serious animosity between tenants and landlords.</p>",
                        "<p>We’re tapping the internet of things to empower tenants, landlords, community organizations, and the justice system to tackle New York's heating crisis. We:</p>",
                        "<li>Provide unbiased evidence to verify heating code abuse claims in housing court</li>",
                        "<li>Help landlords heat their buildings more effectively while reducing costs</li>",
                        "<li>Create transparency in heating data to educate the community and inform housing policy</li>",
                        "<br>",
                        "<p>Our affordable temperature sensors can be installed in any number of apartments per building. 
                        They talk to each other via mesh network to periodically collect and transmit ambient temperature data to Heat Seek’s servers. 
                        Our powerful web app integrates this data with public 311 heating complaint information to deliver a better picture of New York City’s heating crisis than ever before.</p>",
                        "<p>We are working closely with community organizations, landlords, and the HPD to make our technology available to thousands of New Yorkers in time for the cold.</p>",
                        "<br>"
                      ),
                      HTML("<iframe width='854' height='480' src='https://www.youtube.com/embed/15hh8EL13FM' frameborder='0' allowfullscreen></iframe>",
                           "<br><br>")),
             tabPanel("311 Complaint Data",
                      HTML("<br>"),
                      checkboxInput("exclude_unspecified", "Exclude 'Unspecified' Boroughs", TRUE),
                      checkboxInput("exclude_not_winters", "Exclude Non-Winter Months", TRUE),
                      plotOutput("bar_311_by_borough"),
                      HTML("<br>"),
                      plotOutput("bar_311_by_year"),
                      HTML("<br>"),
                      plotOutput("bar_311_by_winter")),
             tabPanel("Sensor Time Series",
                      HTML("<br>"),
                      # selectizeInput(
                      #   inputId = 'hs_sensor_select',
                      #   label = "Select Individual Sensor",
                      #   choices = unique(df_hs$sensor_short_code),
                      #   selected = unique(df_hs$sensor_short_code)[1]
                      # ),
                      selectizeInput(
                        inputId = 'hs_address_select',
                        label = "Select Specific Address",
                        choices = unique(df_hs$clean_address),
                        selected = c('196 ROCKAWAY PARKWAY')
                      ),
                      checkboxInput("group_by_violations", "Highlight Violations", TRUE),
                      checkboxInput("remove_outliers", "Remove Outliers", FALSE),
                      dateRangeInput(
                        inputId = 'hs_date_inp',
                        label = "Select Range for Sensor Data",
                        start = min(df_hs$created_at)
                      ),
                      plotOutput("line_hs")),
             tabPanel("Sensor Map",
                      leafletOutput('map_hs', width = '100%', height=600)),
             tabPanel("Sensor Data",
                      dataTableOutput("data"), width = "100%"),
             tabPanel("Next Steps",
                      HTML(
                        "<h4>Next Steps for Heat Seek</h4>",
                        "<p>Heating complaints are up 20% thus far in Winter 2016-17 compared to the same time last year. This problem is not getting better.</p>",
                        "<p>To combat this on going problem, we've partnered with Brooklyn Borough President Eric Adams to keep the heat on for all of New York City</p>",
                        "<div align='center'><img alt='Borough President Eric Adams' src='eric_adams.jpeg' height=370 width=500></img></div>",
                        "<div align='center'><i>Borough President Eric Adams speaking at a press conference</i></div>",
                        "<br>",
                        "<p>Borough President Adams has also outlined legislative action he will be working on with the City Council, in particular Council Member Ritchie Torres, 
                        that would allow for the installation of heat sensors in apartment buildings, as well as for their utilization as a means to combat heating-related abuse by bad-acting landlords. 
                        Additionally, we plan to work with Borough President Adams on a training partnership with the New York City Housing Court that will train housing court judges on how to interpret data collected by heat monitors.</p>",
                        "<br>"
                        ),
                      HTML(
                        "<h4>Additional Research Questions</h4>",
                        "<li>How are income and lack of heat related? (similar to below)</li>",
                        "<li>How are gentrification and lack of heat related?</li>",
                        "<li>How can we quantify the lack heat and health outcomes?</li>",
                        "<br>"
                      )
                      )
             
           )
           )
           
        )
  )
)