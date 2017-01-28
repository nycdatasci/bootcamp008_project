# ui.R

dbHeader = dashboardHeader(
  tags$li(class = "dropdown",
          tags$style(".main-header {max-height: 85px}"),
          tags$style(".main-header .logo {height: 85px}"),
          tags$style(".sidebar-toggle {height: 85px}")
  )
)

dbHeader$children[[2]]$children =
    tags$a(
      href='http://www.bayareabikeshare.com/',
      tags$img(src='babs-logo.png',height=75,style='padding-top:12px')
    )

shinyUI(dashboardPage(
  skin = 'blue',
  dbHeader,

  dashboardSidebar(
    tags$style(".left-side, .main-sidebar {padding-top: 85px}"),

    sidebarMenu(
      menuItem(
        'Start',
        tabName = 'start',
        icon = icon('comment-o')
      ),

      menuItem(
        'Stations',
        tabName = 'stations',
        icon = icon('home')
      ),

      menuItem(
        'Trips',
        tabName = 'trips',
        icon = icon('exchange')
      ),

      menuItem(
        'Bikes',
        tabName = 'bikes',
        icon = icon('bicycle')
      ),

      menuItem(
        'Customers',
        tabName = 'customers',
        icon = icon('users')
      ),

      menuItem(
        'Weather',
        tabName = 'weather',
        icon = icon('cloud')
      ),

      menuItem(
        'About',
        tabName = 'about',
        icon = icon('question')
      )
    )
  ),

   dashboardBody(
    tabItems(
      tabItem(
        tabName = 'start',
        h2('Bay Area Bike Share Management Dashboard'),

        fluidRow(
          box(
            p('Welcome to the Bay Area Bike Share Management Dashboard!'),
            width=12
          )
        ),

        fluidRow(
          infoBoxOutput('datesLoaded', width=12)
        ),

        fluidRow(
          box(
            img(src='foto-01.jpg', width='100%'),
            width=6,
            align='center'
          ),

          box(
            img(src='foto-02.jpg', width='100%'),
            width=6,
            align='center'
          )
        )
      ),

      tabItem(
        tabName = 'stations',
        h2('Stations'),

        fluidRow(
          infoBoxOutput('staCount',width=4),
          infoBoxOutput('cityCount',width=4),
          infoBoxOutput('dockCount',width=4)
        ),

        tabsetPanel(
          tabPanel(
            'Map',

            fluidRow(
              box(
                leafletOutput(
                  'stationsMap',
                  width='100%',
                  height=600
                ),
                width=12
              )
            )
          ),
          tabPanel(
            'Overview',

            fluidRow(
              box(
                htmlOutput('staPerCity'),
                width=12
              )
            )
          ),

          tabPanel(
            'Detail per Station',

            fluidRow(
              box(
                selectInput(
                  'stationDetail',
                  label=h4('Select station'),
                  choices = setNames(arrange(stations, name)$station_id, arrange(stations, name)$name),
                  selected = NULL
                ),
                width=12,
                height=110
              )
            ),

            tabsetPanel(
              tabPanel (
                'Date',
                fluidRow(
                  box(
                    htmlOutput('staCalendar'),
                    width=12,
                    height=200
                  )
                )
              ),

              tabPanel(
                'Time',
                fluidRow(
                  box(
                    plotOutput(
                      'staStartByHour',
                      width='100%',
                      height=600
                    ),
                    width=6
                  ),

                  box(
                    plotOutput(
                      'staEndByHour',
                      width='100%',
                      height=600
                    ),
                    width=6
                  )
                )
              )
            )
          ),

          tabPanel(
            'Station comparison',

            fluidRow(
              box(
                selectInput(
                  'staComp1',
                  label=h4('Select station'),
                  choices = setNames(arrange(stations, name)$station_id, arrange(stations, name)$name),
                  selected = NULL
                ),
                width=6,
                height=110
              ),

              box(
                selectInput(
                  'staComp2',
                  label=h4('Select station'),
                  choices = setNames(arrange(stations, name)$station_id, arrange(stations, name)$name),
                  selected = NULL
                ),
                width=6,
                height=110
              )
            ),

            tabsetPanel(
              tabPanel(
                'Trip date',

                fluidRow(
                  box(
                    htmlOutput('staCalendarComp1'),
                    width=12,
                    height=200
                  )
                ),

                fluidRow(
                  box(
                    htmlOutput('staCalendarComp2'),
                    width=12,
                    height=200
                  )
                )
              ),

              tabPanel(
                'Trip start time',

                fluidRow(
                  box(
                    plotOutput(
                      'staStartByHourComp1',
                      width='100%',
                      height=600
                    ),
                    width=6
                  ),

                  box(
                    plotOutput(
                      'staStartByHourComp2',
                      width='100%',
                      height=600
                    ),
                    width=6
                  )
                )
              ),

              tabPanel(
                'Trip end time',

                fluidRow(
                  box(
                    plotOutput(
                      'staEndByHourComp1',
                      width='100%',
                      height=600
                    ),
                    width=6
                  ),

                  box(
                    plotOutput(
                      'staEndByHourComp2',
                      width='100%',
                      height=600
                    ),
                    width=6
                  )
                )
              )
            )
          )
        )
      ),

      tabItem(
        tabName = 'trips',
        h2('Trips'),

        fluidRow(
          infoBoxOutput('tripCount', width=4),
          infoBoxOutput('maxTripABne', width=4),
          infoBoxOutput('maxTripABe', width=4)
        ),

        fluidRow(
          box(
            selectInput(
              'tripsWhich',
              label=h4('Routes to display'),
              choices=list(
                'None' = 0,
                'A:B != B:A' = 'routesABne',
                'A:B == B:A' = 'routesABe'
              ),
              selected=0
            ),
            width=2,
            height=110
          ),

          box(
            numericInput(
              'tripsCutoff',
              label=h4('Display only routes having more than x trips'),
              value=1000
            ),
            width=5,
            height=110
          )
        ),

        tabsetPanel(
          tabPanel(
            'Map',

            fluidRow(
              box(
                leafletOutput(
                  'tripsMap',
                  width='100%',
                  height=600
                ),
                width=12
              )
            )
          ),

          tabPanel(
            'Sankey',

            fluidRow(
              box(
                htmlOutput('tripsSankey'),
                width=12
              )
            )
          ),

          tabPanel(
            'Table',

            fluidRow(
              box(
                htmlOutput('tripsTable'),
                width=12
              )
            )
          )
        )
      ),

      tabItem(
        tabName = 'bikes',
        h2('Bikes'),

        fluidRow(
          infoBoxOutput('bikeCount', width=4),
          infoBoxOutput('maxBike', width=4),
          infoBoxOutput('minBike', width=4)
        ),

        tabsetPanel(
          tabPanel(
            'Overview',

            fluidRow(
              box(
                selectInput(
                  'bikesMetric',
                  label = h4('Metric to display'),
                  choices = list(
                    'Count' = 'n',
                    'Total Duration' = 'dur',
                    'Median Duration' = 'medDur'
                  )
                ),
                width=4,
                height=110
              )
            ),

            fluidRow(
              box(
                htmlOutput(
                  'bikesPlot',
                  width='100%',
                  height=600
                ),
                width=12
              )
            )
          ),

          tabPanel(
            'Bikes in operation',

            fluidRow(
              box(
                sliderInput(
                  'bikeOpsDays',
                  label=h4('Select days in operation'),
                  min=min(bikes$daysInUse),
                  max=max(bikes$daysInUse),
                  value=c(min(bikes$daysInUse), max(bikes$daysInUse))
                ),
                width=12
              )
            ),

            fluidRow(
              box(
                htmlOutput('bikesOps'),
                width=12
              )
            )
          )
        )
      ),

      tabItem(
        tabName = 'customers',
        h2('Customers'),

        fluidRow(
          valueBoxOutput('custSubscr'),
          valueBoxOutput('custCust'),
          valueBoxOutput('custSubscrVsCust')
        ),

        fluidRow(
          valueBoxOutput('custSubscrDur'),
          valueBoxOutput('custCustDur'),
          valueBoxOutput('custSubscrVsCustDur')
        ),

        fluidRow(
          valueBoxOutput('custSubscrMedDur'),
          valueBoxOutput('custCustMedDur'),
          valueBoxOutput('custSubscrVsCustMedDur')
        )
      ),

      tabItem(
        tabName = 'weather',
        h2('Weather'),

        fluidRow(
          box(
            selectInput(
              'weatherCity',
              label=h4('Select city'),
              choices = setNames(arrange(zip2City, city)$ZIP, arrange(zip2City, city)$city)
            ),
            width=4,
            height=110
          ),

          box(
            dateRangeInput(
              'weatherDate',
              label=h4('Select date range'),
              start=min(weatherTrips$Date),
              end=max(weatherTrips$Date),
              min=min(weatherTrips$Date),
              max=max(weatherTrips$Date)
            ),
            width=4,
            height=110
          ),

          box(
            selectInput(
              'weatherMetric',
              label=h4('Select metric to measure against'),
              choices = list(
                'Temp. F' = 'F',
                'Temp. C' = 'C',
                'Cloud Cover' = 'Cloud'
              )
            ),
            width=4,
            height=110
          )
        ),

        fluidRow(
          box(
            htmlOutput('weatherTrips'),
            width=12
          )
        )
      ),

      tabItem(
        tabName = 'about',
        h2('About'),
        fluidRow(
          box(
            'Code: ', a(href='mailto:sh@steeefan.de', 'Stefan Heinz'), br(),
            'Data: ', a(href='http://www.bayareabikeshare.com/open-data', 'Bay Area Bike Share'), br(),
            br(),
            'This project has no affiliation with Bay Area Bike Share or Motivate International, Inc.',
            'It\'s build on top of their freely',
            a(href='http://www.bayareabikeshare.com/open-data', 'available data'),
            'as part of the', a(href='nycdatascience.com/data-science-bootcamp/', 'NYC Data Science Academy Data Science Bootcamp.')
          )
        )
      )
    )
   )
))
