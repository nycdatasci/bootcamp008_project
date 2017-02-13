library(tidyverse)
library(shiny)
library(shinydashboard)
library(ggthemes)
library(openxlsx)
# setwd("/Users/ethanweber/Desktop/Shiny_Project/Script")
#df <- read_rds("/Users/ethanweber/Desktop/Shiny_Project/shinydata")

ages <- list("15_16-24", "25-34",    "35-44",    "45-54",    "55-64",   "65+", "TotalPop")

header <- dashboardHeader(title = "Suicide and Unemployment")
?dashboardHeader
sidebar <- dashboardSidebar(
    sidebarMenu(
    menuItem("Unemployment & Suicide", tabName = "Intro", icon = icon("th")),
    menuItem("Total Population", tabName = "Total_Population", icon = icon("th")),
    menuItem("Prime Age Suicide Rate", tabName = 'Prime_Age_Suicide_Rate', icon = icon('th')),
    menuItem("Prime Age Labor Force Participation Rate", tabName = "Prime_Age_Labor_Force_Participation", icon = icon("th")),
    menuItem("Prime Age Unemployment Rate", tabName = "Prime_Age_Unemployment_Rate", icon = icon("th")),
    menuItem("Suicide by Age", tabName = "Data_by_age", icon = icon("th")),
    menuItem("Labor Force Paricipation by Age", tabName = 'lfpba', icon = icon("th")),
    menuItem("Mechanism", tabName = 'Mechanism', icon = icon("th")),
    menuItem("Occupation", tabName = 'Occupation', icon = icon("th")),
    menuItem("Age Group Nonparticipation", tabName = 'nonpage', icon = icon("th")),
    menuItem("Conclusion", tabName = 'conclusion', icon = icon("th"))
    )
    )


body <- dashboardBody(
    
    tabItems(
      tabItem(tabName = "Intro",
              h1("America's suicide rate has risen 24% from 1999 to 2014"),
              h3("Social scientists have proposed many reasons for this including: \n
                  an increase in unemployment and workforce nonparticipation \n
                 fewer opportunities for low skilled workers due to globalization \n
                  decreasing social connectedness due to lower marriage rates \n
                 higher divorce rates, and reduced social interactions."),
              h2("My project seeks to visualize economic and sociological forces and their effect on suicide rates.")
              ),
      tabItem(tabName = "Total_Population",
              h2("Total Population Suicide Rate"),
              plotOutput('usaMap')
                ,
                box(
                  sliderInput('yearusa', 'year', 1999, 2014, 1999)
                )
              ),
      
        tabItem(tabName = "Prime_Age_Suicide_Rate",
            h2("Suicide rate per 100,000 individuals age 25-65"),
            plotOutput('pasr'),
            box(
              sliderInput('yearpasr', 'year', 1999, 2014, 1999)
              )
            ),
      
        tabItem(tabName = "Prime_Age_Labor_Force_Participation",
              h2("Percentage of nonworking individuals age 25-65"),
              plotOutput('palfp'),
              box(
                sliderInput('yearpalf', 'year', 1999, 2014, 1999)
                )
        ),
      
      tabItem(tabName = "Prime_Age_Unemployment_Rate",
              h2("Unemployment rate among individuals age 25-65"),
              plotOutput('paur'),
              box(
                sliderInput('yearpaur', 'year', 1999, 2014, 1999)
              )
      ),
      
        tabItem(tabName = "Data_by_age",
                plotOutput('dba'),
                h2("Suicide rate by age group."),
                box(
                  selectInput('dbaages', 'Age Group', list("15_16-24", "25-34",    "35-44",    "45-54",    "55-64",   "65+"), '35-44' )
                ),
                box(
                  sliderInput('yeardba', 'year', 1999, 2014, 1999))
            ),
      
      tabItem(tabName = "lfpba",
              plotOutput('lfpba'),
              h2("Labor force non participation rate by age group."),
              box(
                selectInput('lfpages', 'Age Group', list("15_16-24", "25-34",    "35-44",    "45-54",    "55-64",   "65+"), '35-44' )
              ),
              box(
                sliderInput('lfpyear', 'year', 1999, 2014, 1999))
      ),
      
      tabItem(tabName = "Occupation",
              h1('Certain Occupations have suicide rates multiple times those of others.'),
              h5('Data was collected and analyzed by the bls in 2015.'),
              plotOutput('occu')
              ),
      tabItem(tabName = "Mechanism",
              h1("Firearms Impact Suicide Rate"),
              h4('"Using a variety of techniques and data we estimate that a 1 percentage point increase in the household gun ownership rate leads to a .5 to .9% increase in suicides." - Alex Tabarrok'),
              h4("Researchers at Harvard's School of Public Health estimate that just 1 in 45 suicides are successful.  The number is far higher with guns."),
              plotOutput('mechgraph'),
              box(
                sliderInput('mechyear', 'year', 1999, 2014, 1999)
              )
                ),
      tabItem(tabName = "nonpage",
              h1('Laboforce nonparticipation rates have not recovered since 2009.'),
              plotOutput('nonpage'),
              h3("Erik Hurst on nonemployed men 25-34:"),
              h3("'Are they married? Are they having kids? And the answer is, 'No.' This is not a group--if you are not working as a man in your 20s with less than a Bachelor's Degree, you are pretty much single and childless. Not all. But 90-some percent of them aren't married.'")
      ),
      tabItem(tabName = "conclusion",
              h1("Suicide as a Systemic Phenomenon:"),
              h3("Suicide rates vary by several hundred percentage points among various economic, social, and demographic groups."),
              h3("Data science can open the door to analyses that were not possible in the past."),
              h3("Educational, social, economic, and demographic information can help predict suicide rates in populations."),
              h3("Emile Durkheim, a French sociologist, published a book analyzing social causes of suicide and concluded the following:"),
              h4("Men commit suicide more frequently, single people are more likely to commit suicide, those without children are more likely to commit suicide,
                 among several other observations"),
              h3("More effective forecasting may offer less intrusive, more effective frameworks for decreasing suicide")
              
              )
      )
      )


dashboardPage(
  header,
  sidebar,
  body
)
