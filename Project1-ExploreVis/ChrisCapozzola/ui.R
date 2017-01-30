library(shiny)

fluidPage(
  titlePanel("Zika Virus Infections"),
  sidebarLayout(
    sidebarPanel(
      selectizeInput(
        inputId = "country_input",
        label = "Select a Country",
        choices = countries_lst,
        selected = "Colombia"
      ),
      selectizeInput(
        inputId = "case_input",
        label = "Select Confirmed or Probable Cases",
        choices = C_P_select,
        selected = "Confirmed"
      ),
      sliderInput(
        inputId = "dts",
        label = "Date",
        min = 1, max = length(unique(colombia_data$report_date)), value = 1, step = 1
      ),
      verbatimTextOutput("summary"),
      uiOutput("Date")
    ),
  mainPanel(
    plotOutput("plot")
  )
))