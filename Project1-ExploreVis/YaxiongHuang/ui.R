library(shiny)
library(shinydashboard)
library(dplyr)
library(dygraphs)
library(ggvis)

shinyUI(dashboardPage(
  dashboardHeader(title = "NYC Leading Cause of Death",titleWidth = 290),
 
  dashboardSidebar(width = 360,
                  
    
    sidebarMenu(
    menuItem('Introduction',tabName = "Introduction",icon = icon("gear")),
    menuItem('Trend',tabName = 'Trend',icon = icon("line-chart"),
    menuSubItem("Death Trend Overview", tabName = "Trendline", icon = icon("line-chart")),
    menuSubItem("Death Trend By Sex", tabName = "DeathTrendBySex", icon = icon("line-chart")),
    menuSubItem("Death By Leading Cause Barchart", tabName = "LeadingCauseBarChart", icon = icon("bar-chart")),
    menuSubItem("Trend By Leading Cause", tabName = "TrendByLeadingCause", icon = icon("line-chart")),
    menuSubItem("Death Trend by Race Ethnicity", tabName = "TrendLineByRaceEthnicity", icon = icon("line-chart")),
    menuSubItem("Death By Sex", tabName = "DeathBySex", icon = icon("bar-chart-o"))),
    
    
    
    menuItem("Death Distribution", tabName = "DeathByRaceAndSexDensity",icon = icon("area-chart")),
    
    menuItem("Death Ranking", tabName = "Death Ranking",icon = icon("bar-chart"),
    menuSubItem("Total Death By Race Ethnicity Ranking", tabName = "TotalDeathByRaceEthnicityBarchart", icon = icon("bar-chart")),
    menuSubItem("Top 5 Leading Causes", tabName = "Top5LeadingCauses", icon = icon("bar-chart"))),
    
    menuItem('Health Indicators',tabName = 'HealthIndicators',icon = icon("bar-chart"),
    menuSubItem("Heart Disease and Stroke Indicators",tabName = "HeartDiseaseandStrokeIndicators",icon = icon("bar-chart")),
    menuSubItem("Injury Related Indicators",tabName = "InjuryRelatedIndicators",icon = icon("bar-chart")),
    menuSubItem("Respiratory Disease Indicators",tabName = "RespiratoryMortalityIndicators",icon = icon("bar-chart")),
    menuSubItem("Substance Abuse/Mental Health-Related Indicators",tabName = "SubstanceAbuseMentalHealthIndicators",icon = icon("bar-chart")),
    menuSubItem("Diabetes Indicators",tabName = "DiabetesIndicators",icon = icon("bar-chart")),
    menuSubItem("Cancer Indicators",tabName = "CancerIndicators",icon = icon("bar-chart")),
    menuSubItem("Birth Related Indicators",tabName = "BirthRelatedIndicators",icon = icon("bar-chart"))),
    
    menuItem('Death By Race Ethnicity Comparison',tabName = 'DeathByRaceEthnicityComparison',icon = icon("bar-chart"),
    menuSubItem("Death By Race Ethnicity and Leading Cause", tabName = "BarChart2", icon = icon("bar-chart")),
    menuSubItem("Death By Race Ethnicity and Year/Leading Cause", tabName = "BarChart", icon = icon("bar-chart")),
    menuSubItem("Total Death By Race Ethnicity and Year/Leading Cause", tabName = "BarChart1", icon = icon("bar-chart"))),
    menuItem('Conclusion',tabName = "Conclusion",icon = icon("comments-o"))
  )),

  dashboardBody(
    tabItems(
      tabItem(tabName = 'Introduction',
              fluidRow(h1('Introduction'),
                       img(src = "c.png",height = 400, width = 450)),
                      br(),
              fluidRow(column(12,p("The death has changed dramatically and different types of leading causes have a significant impact on difference races (Asian and Pacific Island, Black Non-Hispanic, White Non-Hispanic, and Hispanic).  We would like to analyze the leading causes of death and health indicators.  The following questions could be answered: Which race has more deaths?  Does female have more deaths than males?  Which leading cause has a significant impact on the trend?  What is the distribution for the deaths by year, race and sex?")))),
      tabItem(tabName = "Trendline",
              fluidRow(column(12,dygraphOutput("Trendline")))),
      tabItem(tabName = "DeathTrendBySex",
              fluidRow(column(12,plotOutput("TrendlineBySex")))),
      
      tabItem(tabName = "TrendLineByRaceEthnicity",
              fluidRow(column(8,plotOutput("TrendLineByRaceEthnicity")),
                       column(4,checkboxGroupInput("Race_Ethnicity",label = h3("Select the race ethnicity"),
                            choices = c("Asian and Pacific Islander" = "Asian and Pacific Islander","Black Non-Hispanic" = "Black Non-Hispanic",
                                          "White Non-Hispanic" = "White Non-Hispanic","Hispanic" = "Hispanic"),selected = "Hispanic",width = 600)))),
      tabItem(tabName = "DeathBySex",
              fluidRow(htmlOutput("DeathBySex"),height=800,width = "100%",
                       selectInput(inputId = "Sex",label = "Choose sex",choices = c("Male" = "M","Female" = "F")))),
      
     
      tabItem(tabName = "DeathByRaceAndSexDensity",
              fluidRow(column(12,plotOutput("DeathByRaceAndSexDensity"),selectInput(inputId = "Sex1",label = "Choose sex",choices = c("All"="All","Male" = "M",
                                                                                                                                                       "Female" = "F"))))),
      tabItem(tabName = "TotalDeathByRaceEthnicityBarchart", 
              fluidRow(column(12,plotOutput("TotalDeathByRaceEthnicityBarchart")))),
      tabItem(tabName = "Top5LeadingCauses",
              fluidRow(column(12,plotOutput("Top5LeadingCauses")))),
      tabItem(tabName = "HeartDiseaseandStrokeIndicators",
              h3("Heart Disease and Stroke Mortality"),
              fluidRow(column(12,plotOutput("HeartDiseaseStrokeMortality"))),
              br(),
              h3("Heart Disease and Stroke Hospitalizations"),
              fluidRow(column(12,plotOutput("HeartDiseaseStrokeHospitalizations")))),
      tabItem(tabName = "InjuryRelatedIndicators",
              h3("Injury Related Mortality"),
              fluidRow(column(12,plotOutput("InjuryMortality"))),
              br(),
              h3("Injury Related Hospitalizations"),
              fluidRow(column(12,plotOutput("InjuryHospitalizations")))),
      tabItem(tabName = "RespiratoryMortalityIndicators",
              h3("Respiratory Mortality"),
              fluidRow(column(12,plotOutput("RespiratoryMortality"))),
              br(),
              h3("Respiratory Hospitalizations"),
              fluidRow(column(12,plotOutput("RespiratoryHospitalizations")))),
      tabItem(tabName = "SubstanceAbuseMentalHealthIndicators",
              h3("Substance Abuse Mental Health Mortality"),
              fluidRow(column(12,plotOutput("DrugSuicideMortality"))),
              br(),
              h3("Substance Abuse Mental Health Hospitalizations"),
              fluidRow(column(12,plotOutput("DrugRelatedHospitalizations")))),
      tabItem(tabName = "DiabetesIndicators",
              h3("Diabetes Mortality"),
              fluidRow(column(12,plotOutput("DiabetesMortality"))),
              br(),
              h3("Diabetes Hospitalizations"),
              fluidRow(column(12,plotOutput("DiabetesHospitalizations")))),
      tabItem(tabName = "CancerIndicators",
              h3("Cancer Incidence"),
              fluidRow(column(12,plotOutput("CancerIncidence"))),
              br(),
              h3("Cancer Mortality"),
              fluidRow(column(12,plotOutput("CancerMortality")))),
      tabItem(tabName = "BirthRelatedIndicators",
              h3("Birth Related Mortality"),
              fluidRow(column(12,plotOutput("InfantMortality")))),        
      tabItem(tabName = "Conclusion",
              fluidRow(column(12,h1(strong("Conclusion",align = "center",style = "font-family: 'times'; font-si19pt")),
                              p("Looking at the trend from 2007 to 2014, we see in the year of 2008 has the highest death number. What happened in the year of 2008? There is only a slight difference for the total death between 2007 and 2008. Where is the slight increasing coming from? Actually, the mahority of deaths are from male.  The major leading causes for the death increasing are Alzheimer's Disease, Chronic Liver Disease and Cirrhosis, Chronic Lower Respiratory Diseases, and Essential Hypertension and Renal Diseases.  The year of 2012 has the least deaths over the period. The decreasing deaths are coming from the male.  The major leading causes for the death drop down is Assault (Homicide), Cerebrovascular Disease (Stroke),  Chronic Lower Respiratory Diseases, Human Immunodeficiency Virus Disease (HIV), Influenza (Flu) and Pneumonia, and Mental and Behavioral Disorders due to Accidental Poisoning and Other Psychoactive Substance Use."),
                              br(),
                              p("The deaths for Asian and Pacific Islander are gradually increasing while Non-Hispanic has a downward trend.  Hispanic deaths are increasing dramatically except there is a drop in 2009. Both male and female deaths dropped about half of deaths comparing with the deaths in 2008.  Black Non-Hispanic deaths decreased dramatically till 2010 and had wiggling sign afterward.  Comparing the trend between race ethnicity, Asian and Pacific Islander has the least deaths and White Non-Hispanic has the highest deaths.  What are the leading causes make the deaths of White Non-Hispanic/Black Non-Hispanic so high?  Heart Diseases is the number one leading cause but there might be different types of heart diseases.  Also, all other causes are ranking number three.  What are all other causes? Perhaps, health indicators might tell the story behind it.  Coronary Heart Disease has high mortality for Black Non-Hispanic and White Non-Hispanic.  Black mortality are slightly higher than white for the heart disease/stroke.  White has a high risk on unintentional injury and elderlies have higher risk to fall.  Black has high risk at Asthma/Chronic Lower Respiratory Hospitalizations.  White has high suicide mortality and black has high drug related hospitalizations.  Black has higher risk in diabetes. Both black and white are at high risk in cancer.  Black has higher birth related mortality."),
                              br(),
                              p("Through the data exploratory data analysis, we conclude that the death trend of females has a significant impact on the overall trend.  The health of females got significant improvement in 2009. Females have more deaths than males and breast cancer is one of the major leading causes of death for females. Black and White have higher health issues/hospitalizations than other races.")
                       ))), 
              
      tabItem(tabName = "BarChart",
              fluidRow(column(8,plotOutput("BarChart")),
                       column(4,sliderInput("Year",label = h3("Choose the year"),min = 2007, max = 2014, value = 2007,sep=''),
                                      checkboxGroupInput("LeadingCauseType",label = h3("Select Leading Cause"),
                                                         choices = list("Accidents Except Drug Posioning"= "Accidents Except Drug Posioning (V01-X39, X43, X45-X59, Y85-Y86)",
                                                                        "All Other Causes" = "All Other Causes",
                                                                        "Alzheimer's Disease" = "Alzheimer's Disease (G30)",
                                                                        "Assault (Homicide)" = "Assault (Homicide: Y87.1, X85-Y09)",
                                                                        
                                                                        "Cerebrovascular Disease (Stroke)"= "Cerebrovascular Disease (Stroke: I60-I69)",
                                                                        "Certain Conditions originating in the Perinatal Period" = "Certain Conditions originating in the Perinatal Period (P00-P96)",
                                                                        "Chronic Liver Disease and Cirrhosis" = "Chronic Liver Disease and Cirrhosis (K70, K73)",
                                                                        "Chronic Lower Respiratory Diseases" = "Chronic Lower Respiratory Diseases (J40-J47)",
                                                                        "Congenital Malformations, Deformations, and Chromosomal Abnormalities" = "Congenital Malformations, Deformations, and Chromosomal Abnormalities (Q00-Q99)",
                                                                        "Diabetes Mellitus"="Diabetes Mellitus (E10-E14)",
                                                                        "Diseases of Heart" = "Diseases of Heart (I00-I09, I11, I13, I20-I51)",
                                                                        "Essential Hypertension and Renal Diseases" = "Essential Hypertension and Renal Diseases (I10, I12)",
                                                                        "Human Immunodeficiency Virus Disease (HIV)" = "Human Immunodeficiency Virus Disease (HIV: B20-B24)",
                                                                        "Influenza (Flu) and Pneumonia"= "Influenza (Flu) and Pneumonia (J09-J18)",
                                                                         
                                                                        "Intentional Self-Harm (Suicide)" = "Intentional Self-Harm (Suicide: X60-X84, Y87.0)",
                                                                        "Malignant Neoplasms (Cancer)"= "Malignant Neoplasms (Cancer: C00-C97)",
                                                                        "Mental and Behavioral Disorders due to Accidental Poisoning and Other Psychoactive Substance Use"="Mental and Behavioral Disorders due to Accidental Poisoning and Other Psychoactive Substance Use (F11-F16, F18-F19, X40-X42, X44)",
                                                                        
                                                                        "Nephritis, Nephrotic Syndrome and Nephrisis" = "Nephritis, Nephrotic Syndrome and Nephrisis (N00-N07, N17-N19, N25-N27)",
                                                                        "Septicemia"="Septicemia (A40-A41)"
                                                                        
                                                                        
                                                                        
                                                         ),selected = "All Other Causes"))
                             
          
                                      
                                      )),
      tabItem(tabName = "BarChart1",
              fluidRow(column(8,plotOutput("BarChart1")),
                       column(4,sliderInput("Year1",label = h3("Choose the year"),min = 2007, max = 2014, value = 2007,sep=''),
                           checkboxGroupInput("LeadingCauseType1",label = h3("Select Leading Cause"),
                                              choices = list("Accidents Except Drug Posioning"= "Accidents Except Drug Posioning (V01-X39, X43, X45-X59, Y85-Y86)",
                                                             "All Other Causes" = "All Other Causes",
                                                             "Alzheimer's Disease" = "Alzheimer's Disease (G30)",
                                                             "Assault (Homicide)" = "Assault (Homicide: Y87.1, X85-Y09)",
                                                             
                                                             "Cerebrovascular Disease (Stroke)"= "Cerebrovascular Disease (Stroke: I60-I69)",
                                                             "Certain Conditions originating in the Perinatal Period" = "Certain Conditions originating in the Perinatal Period (P00-P96)",
                                                             "Chronic Liver Disease and Cirrhosis" = "Chronic Liver Disease and Cirrhosis (K70, K73)",
                                                             "Chronic Lower Respiratory Diseases" = "Chronic Lower Respiratory Diseases (J40-J47)",
                                                             "Congenital Malformations, Deformations, and Chromosomal Abnormalities" = "Congenital Malformations, Deformations, and Chromosomal Abnormalities (Q00-Q99)",
                                                             "Diabetes Mellitus"="Diabetes Mellitus (E10-E14)",
                                                             "Diseases of Heart" = "Diseases of Heart (I00-I09, I11, I13, I20-I51)",
                                                             "Essential Hypertension and Renal Diseases" = "Essential Hypertension and Renal Diseases (I10, I12)",
                                                             "Human Immunodeficiency Virus Disease (HIV)" = "Human Immunodeficiency Virus Disease (HIV: B20-B24)",
                                                             "Influenza (Flu) and Pneumonia"= "Influenza (Flu) and Pneumonia (J09-J18)",
                                                              
                                                             "Intentional Self-Harm (Suicide)" = "Intentional Self-Harm (Suicide: X60-X84, Y87.0)",
                                                             "Malignant Neoplasms (Cancer)"= "Malignant Neoplasms (Cancer: C00-C97)",
                                                             "Mental and Behavioral Disorders due to Accidental Poisoning and Other Psychoactive Substance Use"="Mental and Behavioral Disorders due to Accidental Poisoning and Other Psychoactive Substance Use (F11-F16, F18-F19, X40-X42, X44)",
                                                              
                                                             "Nephritis, Nephrotic Syndrome and Nephrisis" = "Nephritis, Nephrotic Syndrome and Nephrisis (N00-N07, N17-N19, N25-N27)",
                                                             "Septicemia"="Septicemia (A40-A41)"
                                                             
                                                             
                                                             
                                              ),selected = "All Other Causes"))
      )),
      
      tabItem(tabName = "TrendByLeadingCause",
              fluidRow(column(8,plotOutput("TrendByLeadingCause")),
                       column(4,checkboxGroupInput("Leading.Cause",label = h3("Select Leading Cause"),
                                              choices = list("Accidents Except Drug Posioning"= "Accidents Except Drug Posioning (V01-X39, X43, X45-X59, Y85-Y86)",
                                                             "All Other Causes" = "All Other Causes",
                                                             "Alzheimer's Disease" = "Alzheimer's Disease (G30)",
                                                             "Assault (Homicide)" = "Assault (Homicide: Y87.1, X85-Y09)",
                                                             
                                                             "Cerebrovascular Disease (Stroke)"= "Cerebrovascular Disease (Stroke: I60-I69)",
                                                             "Certain Conditions originating in the Perinatal Period" = "Certain Conditions originating in the Perinatal Period (P00-P96)",
                                                             "Chronic Liver Disease and Cirrhosis" = "Chronic Liver Disease and Cirrhosis (K70, K73)",
                                                             "Chronic Lower Respiratory Diseases" = "Chronic Lower Respiratory Diseases (J40-J47)",
                                                             "Congenital Malformations, Deformations, and Chromosomal Abnormalities" = "Congenital Malformations, Deformations, and Chromosomal Abnormalities (Q00-Q99)",
                                                             "Diabetes Mellitus"="Diabetes Mellitus (E10-E14)",
                                                             "Diseases of Heart" = "Diseases of Heart (I00-I09, I11, I13, I20-I51)",
                                                             "Essential Hypertension and Renal Diseases" = "Essential Hypertension and Renal Diseases (I10, I12)",
                                                             "Human Immunodeficiency Virus Disease (HIV)" = "Human Immunodeficiency Virus Disease (HIV: B20-B24)",
                                                             "Influenza (Flu) and Pneumonia"= "Influenza (Flu) and Pneumonia (J09-J18)",
                                                             
                                                             "Intentional Self-Harm (Suicide)" = "Intentional Self-Harm (Suicide: X60-X84, Y87.0)",
                                                             "Malignant Neoplasms (Cancer)"= "Malignant Neoplasms (Cancer: C00-C97)",
                                                             "Mental and Behavioral Disorders due to Accidental Poisoning and Other Psychoactive Substance Use"="Mental and Behavioral Disorders due to Accidental Poisoning and Other Psychoactive Substance Use (F11-F16, F18-F19, X40-X42, X44)",
                                                             
                                                             "Nephritis, Nephrotic Syndrome and Nephrisis" = "Nephritis, Nephrotic Syndrome and Nephrisis (N00-N07, N17-N19, N25-N27)",
                                                             "Septicemia"="Septicemia (A40-A41)"
                                                             
                                                             
                                                             
                                              ),selected = "All Other Causes")))),
      tabItem(tabName = "LeadingCauseBarChart",
              fluidRow(column(8,plotOutput("DeathBySexLeadingCause")),
                      column(4,selectInput(inputId = "Sex5",label = "Choose sex",choices = c("All" = "All","Male" = "M","Female" = "F")),checkboxGroupInput("Leading.Cause1",label = h3("Select Leading Cause"),
                                              choices = list("Accidents Except Drug Posioning"= "Accidents Except Drug Posioning (V01-X39, X43, X45-X59, Y85-Y86)",
                                                             "All Other Causes" = "All Other Causes",
                                                             "Alzheimer's Disease" = "Alzheimer's Disease (G30)",
                                                             "Assault (Homicide)" = "Assault (Homicide: Y87.1, X85-Y09)",
                                                             
                                                             "Cerebrovascular Disease (Stroke)"= "Cerebrovascular Disease (Stroke: I60-I69)",
                                                             "Certain Conditions originating in the Perinatal Period" = "Certain Conditions originating in the Perinatal Period (P00-P96)",
                                                             "Chronic Liver Disease and Cirrhosis" = "Chronic Liver Disease and Cirrhosis (K70, K73)",
                                                             "Chronic Lower Respiratory Diseases" = "Chronic Lower Respiratory Diseases (J40-J47)",
                                                             "Congenital Malformations, Deformations, and Chromosomal Abnormalities" = "Congenital Malformations, Deformations, and Chromosomal Abnormalities (Q00-Q99)",
                                                             "Diabetes Mellitus"="Diabetes Mellitus (E10-E14)",
                                                             "Diseases of Heart" = "Diseases of Heart (I00-I09, I11, I13, I20-I51)",
                                                             "Essential Hypertension and Renal Diseases" = "Essential Hypertension and Renal Diseases (I10, I12)",
                                                             "Human Immunodeficiency Virus Disease (HIV)" = "Human Immunodeficiency Virus Disease (HIV: B20-B24)",
                                                             "Influenza (Flu) and Pneumonia"= "Influenza (Flu) and Pneumonia (J09-J18)",
                                                             
                                                             "Intentional Self-Harm (Suicide)" = "Intentional Self-Harm (Suicide: X60-X84, Y87.0)",
                                                             "Malignant Neoplasms (Cancer)"= "Malignant Neoplasms (Cancer: C00-C97)",
                                                             "Mental and Behavioral Disorders due to Accidental Poisoning and Other Psychoactive Substance Use"="Mental and Behavioral Disorders due to Accidental Poisoning and Other Psychoactive Substance Use (F11-F16, F18-F19, X40-X42, X44)",
                                                             
                                                             "Nephritis, Nephrotic Syndrome and Nephrisis" = "Nephritis, Nephrotic Syndrome and Nephrisis (N00-N07, N17-N19, N25-N27)",
                                                             "Septicemia"="Septicemia (A40-A41)"
                                                             
                                                             
                                                             
                                              ),selected = "All Other Causes"))
              )),
                
              
      
      tabItem(tabName = "BarChart2",
              fluidRow(column(8,plotOutput("BarChart2")),
                       column(4,checkboxGroupInput("LeadingCauseType2",label = h3("Select Leading Cause"),
                                              choices = list("Accidents Except Drug Posioning"= "Accidents Except Drug Posioning (V01-X39, X43, X45-X59, Y85-Y86)",
                                                             "All Other Causes" = "All Other Causes",
                                                             "Alzheimer's Disease" = "Alzheimer's Disease (G30)",
                                                             "Assault (Homicide)" = "Assault (Homicide: Y87.1, X85-Y09)",
                                                             
                                                             "Cerebrovascular Disease (Stroke)"= "Cerebrovascular Disease (Stroke: I60-I69)",
                                                             "Certain Conditions originating in the Perinatal Period" = "Certain Conditions originating in the Perinatal Period (P00-P96)",
                                                             "Chronic Liver Disease and Cirrhosis" = "Chronic Liver Disease and Cirrhosis (K70, K73)",
                                                             "Chronic Lower Respiratory Diseases" = "Chronic Lower Respiratory Diseases (J40-J47)",
                                                             "Congenital Malformations, Deformations, and Chromosomal Abnormalities" = "Congenital Malformations, Deformations, and Chromosomal Abnormalities (Q00-Q99)",
                                                             "Diabetes Mellitus"="Diabetes Mellitus (E10-E14)",
                                                             "Diseases of Heart" = "Diseases of Heart (I00-I09, I11, I13, I20-I51)",
                                                             "Essential Hypertension and Renal Diseases" = "Essential Hypertension and Renal Diseases (I10, I12)",
                                                             "Human Immunodeficiency Virus Disease (HIV)" = "Human Immunodeficiency Virus Disease (HIV: B20-B24)",
                                                             "Influenza (Flu) and Pneumonia"= "Influenza (Flu) and Pneumonia (J09-J18)",
                                                             
                                                             "Intentional Self-Harm (Suicide)" = "Intentional Self-Harm (Suicide: X60-X84, Y87.0)",
                                                             "Malignant Neoplasms (Cancer)"= "Malignant Neoplasms (Cancer: C00-C97)",
                                                             "Mental and Behavioral Disorders due to Accidental Poisoning and Other Psychoactive Substance Use"="Mental and Behavioral Disorders due to Accidental Poisoning and Other Psychoactive Substance Use (F11-F16, F18-F19, X40-X42, X44)",
                                                              
                                                             "Nephritis, Nephrotic Syndrome and Nephrisis" = "Nephritis, Nephrotic Syndrome and Nephrisis (N00-N07, N17-N19, N25-N27)",
                                                             "Septicemia"="Septicemia (A40-A41)"
                                                             
                                                             
                                                             
                                              ),selected = "All Other Causes"))
        
      )
)))))
