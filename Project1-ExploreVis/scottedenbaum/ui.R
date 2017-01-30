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


IMG <- "POHLogo1.jpg"
shinyUI(dashboardPage(skin="red",
  dashboardHeader(title = "Pathway of Hope"),
  dashboardSidebar(width = 500,
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
                    ),
                    fluidRow(column(12,
                                    imageOutput("image2"))
                             )
              ),#tabitem1
          
          tabItem(tabName="POH",
                  fluidRow(column(12,
                                  wellPanel(
                                    box(title = "The Pathway of Hope Initiative - Helping Families Break the Cycyle of Poverty since 2015",
                                        h2("The Salvation Army initiated the Pathway of Hope Program in 2015")
                                    )
                                  )
                                )
                          )                 
                  )#tabitem2
          
              )#tabitems
    )#dashboardbody
  
  
  ))


