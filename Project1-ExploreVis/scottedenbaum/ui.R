library(shinydashboard)
sel_group_by = c('Individual' = 'Client.Uid',
                 'Corp Location' = 'EE.Provider',
                 'Household Formation' = 'Household.Type',
                 'Race/Ethnicity' = 'Client.Primary.Race',
                 'Gender' = 'Gender')

sel_group_by2 = c('Gender' = 'Gender',
                  'Household Formation' = 'Household.Type',
                  'Primary.Race' = 'Client.Primary.Race')

ckbox_filter = levels(df1$Goal.Classification)[2:12]


IMG <- "RedShield.jpg"
shinyUI(dashboardPage(skin="red",
  dashboardHeader(title = "Pathway of Hope"),
  dashboardSidebar(width = 300,
      sidebarUserPanel("Salvation Army", image = IMG),
      sidebarMenu(
        menuItem("Controls", tabName = "Goal", icon = icon("th"),
                 checkboxGroupInput("filterbox", "Filter by Goal Categories:",
                                    choices = ckbox_filter, selected = ckbox_filter, inline = TRUE),
          menuSubItem( selectInput("selected",
                                            "Select Grouping",
                                            choices=sel_group_by)
                      )
          ),

        menuSubItem("Goal Analysis By Geography", tabName = "Goal-Geog", icon=icon("bar-chart")),
        menuItem("About POH", tabName = "POH", icon = icon("raod"))
        ) 
  ),
  dashboardBody(
        tabItems(
          
          tabItem(tabName="Goal-Geog",
              fluidRow(
                      column(12,
                          box(htmlOutput("hist", width = "300%", height = "600px"))
                        )
              ),
                    fluidRow(column(12, 
                                box(title = "Analysis by grouping"), 
                                htmlOutput("col", width = "300%", height = "600px")
                                )
                    )
              ),#tabitem1
          
          tabItem(tabName="POH",
                  fluidRow(column(12,
                                  #box(imageOutput("image2", width=300, height=300)),
                                  #box(title = "Pathway of Hope",imageOutput("POHLogo", width = 300, height = 300), imageOutput("POHLo"))
                                 imageOutput("imageClient")
                                  #box(imageOutput("imageRedShield", width = 300, height = 300))
                  ),
                  fluidRow(column(10,
                                  wellPanel(
                                    box(title = "The Pathway of Hope Initiative - Helping Families Break the Cycyle of Poverty since 2015",
                                        h4("Pathway of Hope is an expert solution to families in crisis through The
                                            Salvation Army. It is targeted and intensive case management to assist
                                            families striving to break free from intergenerational poverty. The
                                            Salvation Army forms a crucial partnership with families in need. Families
                                            a part of the program possess the desire to change their situation, and are
                                            willing to share accountability with The Salvation Army for planned
                                            actions. By achieving increased stability, these families find a newfound
                                            hope, propelling them forward on their journey to sufficiency.",
                                           br(),
                                          "This analysis takes a deeper look at the initiative, running in
                                          over 25 local communities within The Salvation Army’s Eastern Territory.
                                          The in-take process individually evaluates a family in crisis, and
                                          identifies custom and critical goals ranging from securing employment to
                                          finding affordable childcare")
                                    )
                                  )
                                )
                          )                 
                  )#tabitem2
          
              )#tabitems
    )#dashboardbody
  
  
  )))