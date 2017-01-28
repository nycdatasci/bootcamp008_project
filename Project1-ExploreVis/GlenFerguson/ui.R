shinyUI(dashboardPage(skin ='blue',
  dashboardHeader(title = "The Wine Trade"),
  dashboardSidebar(
    sidebarUserPanel('',image = '1024px-Cabernet_wine_barrels.jpg'),
    sidebarMenu(id = "sideBarMenu",
      menuItem("Info", tabName = "Info", icon = icon("info")),
      menuItem("MarketMap", tabName = "map", icon = icon("map")),
      menuItem("Market Variables 1961-2009", tabName = "Growth", icon = icon("balance-scale")),
      menuItem("Bilateral Trade 1990-2009", tabName =  "Bilateral", icon = icon("bar-chart-o")),
      menuItem("Trade Intensity", tabName =  "Intensity", icon = icon("arrows-h")),
      conditionalPanel("input.sideBarMenu == 'Growth'",
          selectizeInput(inputId = "y",
                         label = "Select y-variable",
                         choices = col_names),
          selectizeInput(inputId = "x",
                         label = "Select x-variable",
                         choices = rev(col_names)),
          selectizeInput(inputId = "regions",
                         label = "Select Regions",
                         choices = regions,
                         multiple = TRUE,
                         options = list(maxItems = 8),
                         selected = 'WEX'),
          sliderInput("years",label = "Five Year Range",
                       min = 1960, max = 2005, step = 5, value = 1960, ticks = FALSE),
                       tags$script(HTML("
                       $(document).ready(function() {setTimeout(function() {
                       supElement = document.getElementById('years').parentElement;
                       $(supElement).find('span.irs-max, span.irs-min, span.irs-single, span.irs-from, span.irs-to').remove();
                       }, 50);})")),
                        
    h3(textOutput("range"))
    ),
    conditionalPanel("input.sideBarMenu == 'Bilateral'",
                     selectizeInput(inputId = "variable",
                                    label = "Select Variable",
                                    choices = bt_col_names),
                     selectizeInput(inputId = "Country",
                                    label = "Select Country",
                                    choices = country_list,
                                    multiple = FALSE,
                                    selected = 'France')
                     ),
  conditionalPanel("input.sideBarMenu == 'Intensity'",
                   selectizeInput(inputId = "country",
                                  label = "Select Country",
                                  choices = country_list,
                                  multiple = TRUE,
                                  options = list(maxItems = 8),
                                  selected = 'France'),
                   sliderInput("var_year",label = "Year",
                               min = 1990, max = 2005, step = 1, value = 1990, ticks = FALSE),
                               tags$script(HTML("
                               $(document).ready(function() {setTimeout(function() {
                               supElement = document.getElementById('var_year').parentElement;
                               $(supElement).find('span.irs-max, span.irs-min, span.irs-single, span.irs-from, span.irs-to').remove();
                               }, 50);})")),
                    h3(textOutput("year"))
  ))),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "app.css")
    ),
         tabItems(
           tabItem(tabName = "Info",
                   fluidRow(
                     h1("Visualizing the Global Wine Trade")
                   ),
                   fluidRow(
                     box(width=12,
                         HTML("<h3>Purpose</h3>"),
                         HTML("<p>Wine is a luxury good produced from the fermentation of fresh grapes. 
                              Most wine is made from European grape vines that require hot summers, 
                              sufficient but not excessive rain, and an absence of extended periods 
                              with temperatures below 5˚ F. These conditions limit the number and size 
                              of production areas to regions that typically fall between the latitudes 
                              of 30 and 50˚. The markets for wine are global requiring an extensive 
                              global network of trade. Also, due to product differences based on 
                              regional growing conditions, wine is often branded regionally as well 
                              as by the grape type. These conditions have created a complex marketplace 
                              with different levels of branding and remote sales markets. Unlike many 
                              goods, wine production is tied to a particular agricultural cycle, with 
                              harvest quantity and quality changing based on factors beyond the control 
                              of wine producers. Demand from the market can, however, change rapidly. 
                              Thus wine producers must be very forward thinking and have a keen 
                              understanding of the current wine market. This site is to help the different
                              stakeholders in the industry understand how the industry has changed and 
                              clearly understand current market conditions to inform future decisions.</p>"
                              ),
                         HTML("<h3>Pages</h3>"),
                         HTML("<h4>Changes in the Global Wine Trade 1960-2009</h4>"),
                         HTML("<h5> An interactive chart to expore how elements of the global wine
                                   industry have changed from 1960-2009.</h5>
                               <p>The units for the elements are as follows.</p>
                               <ul>
                                 <li>Total grapevine area in thousands of hectares (000 ha)</li>
                                 <li>Volume of wine exports in millions of liters (ML)</li>
                                 <li>Volume of wine production in millions of liters (ML)</li>
                                 <li>Volume of wine consumption in millions of liters (ML)</li>
                                 <li>Volume of wine consumption per capita in litres</li>
                                 <li>Volume of wine imports in millions of liters (ML)</li>
                                 <li>Volume of net wine imports in millions of liters (ML)</li> 
                                 <li>Value of wine exports US$ million</li>
                                 <li>Value of wine imports US$ million</li>
                                 <li>Total alcohol consumption per capita in litres of alcohol</li>
                                 <li>Adult population in millions</li>
                                 <li>GDP per capita in US$ current</li>
                                 <li>GDP, in US$ current</li>
                               </ul>"),
                         HTML("<h4>Bilateral Trade from 1990 to 2009</h4>"),
                         HTML("<p>An interactive bar charts of Bilateral Trade 1990-2009
                               <ul>
                                 <li>Volume is in thousands of liters ('000 litres)</li>
                                 <li>Value is in thousands of UD dollars (US$ '000)</li>
                               </ul>
                               </p>"),
                         HTML("<h4>Trade Intensity from Country to Region 1990-2009</h4>"),
                         HTML("<p>Trade Intensity is calculated in volume or value terms 
                                  as the share of country i's wine exports going to region j [x<sub>ij</sub>/x<sub>i</sub>] 
                                  divided by the share of country j’s imports (m<sub>j</sub>) in world wine 
                                  imports (m<sub>w</sub>) net of country i’s imports (m<sub>i</sub>). That is, [x<sub>ij</sub>/x<sub>i</sub>]/[m<sub>j</sub>/(m<sub>w</sub> - m<sub>i</sub>)])
                              </p>"),
                         HTML("<h4>Sources</h4>"),
                         HTML("<p>The sources for this data were from the Wine Economics Research Center
                                  at the University of Adelaide with GDP data added from The World Bank.
                              </p>"),
                         HTML("<a href='http://www.adelaide.edu.au/wine-econ/databases/GWM/'>Global Wine Markets, 1961 to 2009: A Statistical Compendium</a></br>"),
                         HTML("<a href='http://data.worldbank.org/indicator/NY.GDP.PCAP.CD'>GDP Data</a>")
                     )
                   )
           ),
           tabItem(tabName = "map",
                   fluidRow(
                     h1("Wine Market Regions")
                   ),
                   fluidRow(
                      HTML("<img src='WorldMap_Key.png' alt='Region Key'>")
                   ),
                   fluidRow(
                      HTML("<p>
                            <ul>
                              <li>WEX: France, Italy, Portugal, Spain</li>
                              <li>WEM: Austria, Belgium-Luxembourg, Denmark, Finland, Germany, Greece, Ireland,
                                  Netherlands, Sweden, Switzerland, United Kingdom</li>
                              <li>ECA: Bulgaria, Croatia, Georgia, Hungary, Moldova, Romania, Russia, Ukraine</li>
                              <li>ANZ: Australia, New Zealand</li>
                              <li>USC: Canada, United States</li>
                              <li>LAC: Argentina, Brazil, Chile, Mexico, Uruguay</li>
                              <li>AME: South Africa, Turkey</li>
                              <li>APA: China, Hong Kong, India, Japan, (Republic of) Korea, Malaysia, Philippines,
                                  Singapore, Thailand</li>
                            </ul>
                            </p>")
                   )
           ),
           tabItem(tabName = "Growth",
                   fluidRow(
                     h1("Changes in the Global Wine Trade 1960-2009")
                   ),
                   fluidRow(
                     checkboxInput('checkbox1', label = 'Show Country Names', value = FALSE),
                     box(plotOutput("plot1"), width = 12, hieght =500)
                   )
                  ),
           tabItem(tabName = "Bilateral",
                   fluidRow(
                     h1("Bilateral Trade 1990-2009")
                   ),
                   fluidRow(
                     h2(textOutput("ex_country")),
                     box(plotOutput("plot2"), width = 12, hieght = 300)
                   )
           ),
           tabItem(tabName = "Intensity",
                   fluidRow(
                     h1("Trade Intensity from Country to Region 1990-2009")
                   ),
                   fluidRow(
                     h1(textOutput("SankeyTitle")),
                     box(htmlOutput("sankey"),width=12,height=550),
                     radioButtons("radio", label = 'Intensity Type',
                                  choices = list("Value" = 1, "Volume" = 2), 
                                  selected = 1)
                   )
           )
         )
  )
))