library(shinydashboard)

shinyUI(dashboardPage(
  #header
  dashboardHeader(title = "Hospital Charging"),
  #sidebar
  dashboardSidebar(
    sidebarUserPanel("Jessie Gong",
                     image = "hospital_img.png"),
    sidebarMenu(id="menu",
      menuItem("About", tabName = "About", icon = icon("info")),
      menuItem("State Overview",tabName = "Overview", icon = icon("map-o")),
      menuItem("Hospital Comparison", tabName = "Hospital_Comparison", icon = icon("medkit")),
      menuItem("DRG Comparison", tabName = "DRG_Comparison", icon = icon("stethoscope")),
      menuItem("Spending Exploration",tabName = "Explore", icon = icon("balance-scale"))
      ),
      conditionalPanel(condition = "input.menu == 'Hospital_Comparison'",
                       selectizeInput("select_year_2", label = h5("Select year:"),
                                      choice = year, selected = "2014"),

                       selectizeInput("select_DRG_2", label = h5("Select DRG:"),
                                      choice = DRG, selected = "470 - MAJOR JOINT REPLACEMENT OR REATTACHMENT OF LOWER EXTREMITY W/O MCC"),

                       selectizeInput("select_hospital", label = h5("Select hospital:"),
                                      choice = hospital, selected = "NEW YORK METHODIST HOSPITAL", 
                                      multiple = TRUE)
  ),
      conditionalPanel(condition = "input.menu == 'Overview'",
                       selectizeInput("select_year", label = h5("Select year:"), 
                                      choice = year, selected = "2014"),
                       selectizeInput("select_DRG", label = "Select Diagnosis Related Group:",
                                      choice = DRG, selected = "470 - MAJOR JOINT REPLACEMENT OR REATTACHMENT OF LOWER EXTREMITY W/O MCC")),
      conditionalPanel(condition = "input.menu == 'DRG_Comparison'",
                       selectizeInput("select_year_3", label = h5("Select year:"),
                                      choice = year, selected = "2014"),
                       selectizeInput("select_DRG_4", label = h5("Select DRG:"),
                                      choice = DRG, selected = "470 - MAJOR JOINT REPLACEMENT OR REATTACHMENT OF LOWER EXTREMITY W/O MCC",
                                      multiple = TRUE))
  ),
  #body
  dashboardBody(
    tabItems(
      ## tab About ##
      tabItem(tabName = "About",
              fluidRow(
                tabBox(
                  width = 12,
                  
                tabPanel(
                  "About the Dataset",
                  fluidRow(
                    column(
                      width = 8, 
                      tags$h4("The Centers for Medicare and Medicaid (CMS) released Inpatient Charge Data from FY 2011, The Inpatient data describes the following
                              data elements:"),
                      tags$h3("-DRG:"),tags$h4("A Diagnosis Related Group is a statistical system of classifying inpatient stays into groups for the purposes of payment. The CMS data provides average payments for providers organized by individual DRGs."),
                      tags$h3("-Provider:"),tags$h4("Individual providers are described by their id, name and address."),
                      tags$h3("-Total Discharges:"),tags$h4("This is simply the count of the number of discharges for that DRG and Provider."),
                      tags$h3("-Average Covered Charges:"),tags$h4("Hospital billing costs, which are used as negotiating points and not particularly meaningful in terms of the actual amounts paid by Medicare. These are the charges that would be billed to a patient without insurance."),
                      tags$h3("-Average Medicare Payments:"),tags$h4("The average amount that Medicare pays to the provider for Medicare's share of the MS-DRG."),
                      tags$h3("-Average Total Payments:"),tags$h4("Including the co-payments and deductibles that the patient is responsible for, as well as additional payments by third parties, in addition to Medicare payments."),
                      tags$a(href = 'https://questions.cms.gov/faq.php?id=5005&rtopic=2038&rsubtopic=7950',
                             "Learn more at CMS")),
                    column(
                      width = 4,align = "bottom right",
                    tags$img(src = "bill.jpg", width = "300px", height = "300px"))))

                    )
                  )),
                

      
  ## tab Inpatient- Overview ##      
      tabItem(tabName = "Overview",
              
            # fluidRow(
              tabsetPanel(
                tabPanel(
                  'Map',
                  fluidRow(
                    box(width = 6, title = "Average Charges by State",
                        htmlOutput("geo_plot")),
                    box(width = 6, title = "Average Medicare Payments by State",
                        htmlOutput("g_plot"))
                  #   box(width = 3,
                  #       selectizeInput("select_year", label = "Select year:", 
                  #                   choice = year, selected = "2014"),
                  #       selectizeInput("select_cost", label = "Select charges/payments:", 
                  #                   choice = cost, selected = "Charges"),
                  #       selectizeInput("select_DRG", label = "Select Diagnosis Related Group)",
                  #                   choice = DRG, selected = "470 - MAJOR JOINT REPLACEMENT OR REATTACHMENT OF LOWER EXTREMITY W/O MCC")))
                  ),
                  
                  fluidRow(
                    box(width = 6,
                        htmlOutput("hist_plot")),
                    box(width = 6,
                        htmlOutput("histogram_plot"))
                        
                    )
                  ),
                tabPanel(
                  'Explore by State',
                  fluidRow(
                    box(width = 6,
                        htmlOutput("col_plot")),
                    box(width = 6,
                        htmlOutput("con_plot"))
                    
                  )
                ),
          
                tabPanel(
                  'Table',
                  dataTableOutput("sum_table")

                  )
               

             )),
  ## tab Explore ##
      tabItem(tabName = "Explore",
              tabsetPanel(
                tabPanel(
                  'Top Spending',
                  fluidRow(
                    box(width = 8,
                        htmlOutput("bubble_plot"),
                        "The size of bubble represents total Medicare Spending for each DRG",br(),
                        "Total Medicare Spending = Total Discharges * Average Medicare Payments"),
                    box(width = 4,
                         sliderInput(
                           "select_top", 
                           label = h5("Select top most expensive (according to total Medicare Spending) DRG:"),
                           min=5, max=100,value=5,step=5))
                      )),

                tabPanel(
                  'Year Trending',
                  fluidRow(
                    box(width = 9,
                        htmlOutput("line_plot")),
                    box(width = 3,
                        
                        selectizeInput("select_DRG_3", label = h3("Select DRG:"),
                                       choice = DRG, selected = "470 - MAJOR JOINT REPLACEMENT OR REATTACHMENT OF LOWER EXTREMITY W/O MCC"),
                        selectizeInput("select_hospital_2", label = h3("Select hospital:"),
                                       choice = hospital, selected = c("SOUTHEAST ALABAMA MEDICAL CENTER"),
                                       multiple = T)
                        
                    )
                  )))),
    
              
  ## tab Hospital Comparison ##      
       tabItem(tabName = "Hospital_Comparison",
             tabsetPanel(
               tabPanel(
                 'Chart',
                 fluidRow(
                   box(width = 12,
                       htmlOutput("bar_plot"))
                   )
               ),
          
               
               tabPanel(
                 'Table',
                 fluidRow(
                   box(width = 12, htmlOutput("subtable1"))
                   ))
    )),
  tabItem(tabName = "DRG_Comparison",
          tabsetPanel(
            tabPanel(
              'Chart',
              fluidRow(
                box(width = 12,
                    plotOutput("real_box", height = 600))
                
              )
            ),
            tabPanel(
              'Table',
              fluidRow(
                box(width = 12, htmlOutput("subtable2"))
              ))
            )
          ),
  tabItem(tabName = "Final_Summary",
          box(width = 12
              ))
  )
          
          
          
  )))



