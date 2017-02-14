library(shiny)
library(shinydashboard)

shinyUI(
  dashboardPage(skin = "purple",
                dashboardHeader(title = "Oil and Gas Activity in Alberta", titleWidth = 300),
                dashboardSidebar(label = h3("Mini-Project at \nNYDSA"), 
                                 sidebarMenu(
                                   dateRangeInput("date", label = h3("Select Time Period"),start = "2016-01-01",
                                                  end = "2016-01-31",min = "2012-01-01",max = "2016-12-31"),
                                   menuItem("New Wells Drilled", icon = icon("thumb-tack"),
                                            menuItem("Map", tabName = "mapDrilling", icon = icon("map")),
                                            menuItem("Charts", tabName = "chartDrilling", icon = icon("bar-chart-o")),
                                            menuItem("Raw Data", tabName = "summaryDrilling", icon = icon("table"))
                                   ),
                                   
                                   menuItem("Well Licences Issued", icon = icon("newspaper-o"),
                                            menuItem("Map", tabName = "mapLicences", icon = icon("map")),
                                            menuItem("Charts", tabName = "chartLicences", icon = icon("bar-chart-o")),
                                            menuItem("Raw Data", tabName = "summaryLicences", icon = icon("table"))
                                   ),
                                   
                                   menuItem("New Pipeline Approvals", icon = icon("newspaper-o"),
                                            menuItem("Map", tabName = "mapPipelines", icon = icon("map")),
                                            menuItem("Charts", tabName = "chartPipelines", icon = icon("bar-chart-o")),
                                            menuItem("Raw Data", tabName = "summaryPipelines", icon = icon("table"))
                                   ),
                                   
                                   menuItem("Abandoned Wells", icon = icon("warning"),
                                            menuItem("Map", tabName = "mapAbandoned", icon = icon("map")),
                                            menuItem("Raw Data", tabName = "summaryAbandoned", icon = icon("table"))
                                   ),
                                   
                                   menuItem("Price and Production", icon = icon("bar-chart-o"),tabName = "chartPrices"
                                   )
                                 )
                ),
                dashboardBody(
                  tabItems(
                    # Drilling Activity map tab content
                    tabItem(tabName = "mapDrilling",
                            fluidRow(
                              valueBoxOutput("NewWellsDrilledDA"),
                              valueBoxOutput("ContractorsActiveDA"),
                              valueBoxOutput("LicenceesActiveDA")
                            ),
                            fluidRow(box(h4("Select time period from the menu on left. Map shows approximate locations of 
                                        wells drilled in Alberta during the period."),
                                         leafletOutput("mapDrillingdf",width = "100%",height = 700),
                                         width = 12, height = 755)
                            )
                    ),
                    
                    # Drilling Activity chart tab content
                    tabItem(tabName = "chartDrilling",
                            fluidRow(
                              valueBoxOutput("TopReasonDA"),
                              valueBoxOutput("TopDrillerDA"),
                              valueBoxOutput("TopLicenceeDA")
                            ),
                            fluidRow(
                              box(h4("These charts provide a brief overview of the drilling activity reported to 
                                          Alberta Energy Regulator(AER)."), hr(),
                                  radioButtons("radioDA", label = h3("Chart to plot: "),
                                               choices = list("Monthly Drilling Activity" = 1, 
                                                              "Number of Drilling Contractors Active During a Month" = 2, 
                                                              "Number of Drilling Permit Holders Active During a Month" = 3,
                                                              "Most Active Drilling Contractors" = 4,
                                                              "Most Active Permit Holders" = 5,
                                                              "Counties With Most Activity" = 6,
                                                              "Top Reasons For Drilling" = 7
                                               ), 
                                               selected = 1, width = '90%'),width = 3,height = 450),
                              box(
                                dygraphOutput("chartDrilling"),width = 9, height = 450)
                            ),
                            fluidRow(
                              
                            )
                            
                    ),
                    
                    # Drilling Activity summary tab content
                    tabItem(tabName = "summaryDrilling",
                            h2('Summary of Drilling Actvities'),
                            dataTableOutput('summaryDrillingdf')
                    ),
                    
                    # Well Licences map tab content
                    tabItem(tabName = "mapLicences",
                            fluidRow(
                              valueBoxOutput("NewLicencesIssued"),
                              valueBoxOutput("PercentHorizontalLicences"),
                              valueBoxOutput("AverageDepthLicences")
                            ),
                            fluidRow(box(h4("Select time period from the menu on left. Map will show approximate 
                                      locations of drilling permits issued in Alberta during the period."),
                                         leafletOutput("mapLicencesdf",width = "100%",height = 700),
                                         width = 12, height = 755)
                            )
                    ),
                    
                    # Well Licences chart tab content
                    tabItem(tabName = "chartLicences",
                            fluidRow(
                              valueBoxOutput("TopLicenceeLic"),
                              valueBoxOutput("TopSubstanceLic"),
                              valueBoxOutput("TopTypeLic")
                            ),
                            fluidRow(
                              box(h4("These charts provide a brief overview of the drilling permits issued by
                                          Alberta Energy Regulator(AER)."), hr(),
                                  radioButtons("radioLic", label = h3("Chart to plot: "),
                                               choices = list("Number of permits issued by month" = 1, 
                                                              "Number of companies that were issued permits" = 2, 
                                                              "Number of permits issued by product" = 3,
                                                              "Projected depths of wells by product" = 4,
                                                              "Projected depths of wells by substance" = 5,
                                                              "Projected depths of wells by type (top 5)" = 6,
                                                              "Projected depths of wells by company  (top 5)" = 7
                                               ), 
                                               selected = 1, width = '90%'),width = 3,height = 450),
                              box(dygraphOutput("chartLicences"),width = 9, height = 450)
                            ),
                            fluidRow(
                              
                            )
                    ),
                    
                    # Well Licences summary tab content
                    tabItem(tabName = "summaryLicences",
                            h2('Summary of Licences Issued'),
                            dataTableOutput('summaryLicencesdf')
                    ),
                    
                    # Pipelines map tab content
                    tabItem(tabName = "mapPipelines",
                            fluidRow(
                              valueBoxOutput("pmv1"),
                              valueBoxOutput("pmv2"),
                              valueBoxOutput("pmv3")
                            ),
                            fluidRow(
                              box(h4("Select time period from the menu on left side. Map will show approximate 
                                      locations of new pipeline construction during the period."),
                                  leafletOutput("mapPipelinesdf",width = "100%",height = 700),
                                  width = 12, height = 755)
                            )
                    ),
                    
                    # Pipelines chart tab content
                    tabItem(tabName = "chartPipelines",
                            fluidRow(
                              valueBoxOutput("pcv1"),
                              valueBoxOutput("pcv2"),
                              valueBoxOutput("pcv3")
                            ),
                            fluidRow(
                              box(h4("These charts provide a brief overview of pipeline construction start as reported to
                                          Alberta Energy Regulator(AER)."), hr(),
                                  radioButtons("radioPipe", label = h3("Chart to plot: "),
                                               choices = list("Number of pipeline starts by month" = 1, 
                                                              "Number of companies active" = 2, 
                                                              "Total projected length of pipelines commecing construction" = 3,
                                                              "Counties where pipeline's start (top 5)" = 4,
                                                              "Counties where pipeline's end (top 5)" = 5
                                               ), 
                                               selected = 1, width = '90%'),width = 3,height = 450),
                              box(
                                dygraphOutput("chartPipelines"),width = 9, height = 450)
                            ),
                            fluidRow(
                              
                            )
                    ),
                    
                    # Pipelines summary tab content
                    tabItem(tabName = "summaryPipelines",
                            h2('Summary of New Pipelines Approved'),
                            dataTableOutput('summaryPipelinesdf')
                    ),
                    
                    # Abandoned Wells map tab content
                    tabItem(tabName = "mapAbandoned",
                            fluidRow(
                              valueBoxOutput("TotalWells"),
                              valueBoxOutput("MostFrom"),
                              valueBoxOutput("Category")
                            ),
                            fluidRow(
                              box(h4("Use slider at the bottom to see locations of abandoned wells in Alberta."),
                                  leafletOutput("mapAbandoneddf",width = "100%",height = 700),
                                  width = 12, height = 755),
                              absolutePanel(top = 820, right = 950,
                                            sliderInput("markersAbnd", "Select % wells to plot", min(0), max(100),
                                                        value = 5, step = 0.01, width = 500
                                            )
                              )
                            )
                    ),
                    
                    # Abandoned Wells summary tab content
                    tabItem(tabName = "summaryAbandoned",
                            h2('Abandoned Wells in Alberta'),
                            dataTableOutput('summaryAbandoneddf')
                    ),
                    
                    # Prices chart tab content
                    tabItem(tabName = "chartPrices",
                            fluidRow(
                              valueBoxOutput("avPrice"),
                              valueBoxOutput("avConvVol"),
                              valueBoxOutput("avSandsVol")
                            ),
                            fluidRow(
                              box(h4("Check out these cool charts."), hr(),
                                  radioButtons("radioPP", label = h3("Chart to plot: "),
                                               choices = list("Price of WCS vs WTI" = 1, 
                                                              "Alberta Production Comparables" = 2
                                               ), 
                                               selected = 1, width = '90%'),width = 3,height = 450),
                              box(
                                dygraphOutput("priceProduction"),width = 9, height = 450
                              )
                            ),
                            fluidRow(
                              
                            )
                            
                    )
                  )
                )
  )
)