library(shiny)
library(ggplot2)
library(DT)
library(tibble)

shinyUI(fluidPage(
  img(src='planetary_logo.png', align = "right",height = 70, width = 120),
  titlePanel("BACKTESTING ANALYSIS", windowTitle = 'Planetary Ascension - Backtesting Analysis'),
  
  sidebarPanel( 

    conditionalPanel(
      "input.dataset  === 'RAW DATA'",
      fluidRow(br(), column(width= 10, h4('DATA SET DESCRIPTION'),p('Bloomberg and Python have been for this quantitative screening backtesting 
                                         analysis while utilizing R and Shiny web development tools for data analysis 
                                         purposes. The screened universe of companies is comprised of 215 stocks from 
                                         the US, UK and European developed markets for the period 2003-2015 using 
                                         six-month screening rebalancing periods.')
                            ))
    ),

    conditionalPanel(
      "input.dataset  === 'SEGMENTATION ANALYSIS'",
      fluidRow(br(), column(width= 10, h4('SCREENED UNIVERSE DESCRIPTION'), p('More than half of our screened companies below to sectors with significant
                                                                              business cyclicality bias whereas less than one quarter of the sample belongs
                                                                              to more defensive groups (Consumer Staples, Healthcare, etc). Hence, a first
                                                                              conclusion about this is that an investor narrowing his portfolio to a turnaround 
                                                                              strategy is to bear a huge cyclical bias.')))
    ),
        
    conditionalPanel(
      "input.dataset  === 'INVESTMENT HORIZON ANALYSIS'",
      fluidRow(br(),column(width= 10,
                           selectInput('st','SELECT STATISTIC TO CHART',
                                                         choices= c('mean', 'vol', 'median', 'min', 'max')),
                           br(),br(),
                           radioButtons('rv','SELECT RETURN SERIES TO CHART',
                                        choices=  c('Total Return', 'Alpha', 'Total Return CAGR', 'Alpha CAGR')
           )
           )
      )
      ),
    
    conditionalPanel(
      "input.dataset  === 'SECTOR ANALYSIS'",
      fluidRow(br(),column(width= 10,
                           selectInput('uih','SELECT INVESTMENT HORIZON TO CHART',
                                       choices= c('0.5y', '1y', '1.5y', '2y', '2.5y','3y')),
                           br(),br(),
                           radioButtons('urv','SELECT RETURN SERIES TO CHART',
                                        choices=  c('Total Return', 'Alpha', 'Total Return CAGR', 'Alpha CAGR')
                           )
      )
      )
    ),
    
    conditionalPanel(
      "input.dataset  === 'RISK-REWARD ANALYSIS'",
      fluidRow(br(),column(width= 10,
                           selectInput('rih','SELECT INVESTMENT HORIZON TO CHART',
                                       choices= c('0.5y', '1y', '1.5y', '2y', '2.5y','3y')),
                           br(),br(),
                           radioButtons('rrv','SELECT RETURN SERIES TO CHART',
                                        choices=  c('Total Return', 'Alpha', 'Total Return CAGR', 'Alpha CAGR')
                           ),
                           br(),br(),
                           radioButtons('rsec','SELECT SECTOR, INDUSTRY OR CYCLICALITY SCORE TO CHART',
                                        choices=  c('sector', 'industry', 'cyclicality_score')
                           )
                           
      )
      )
    ),
    
    conditionalPanel(
      "input.dataset  === 'PROBABILITY'",
      fluidRow(br(), column(width= 10, h4('BAYESIAN PROBABILITY'),p('A good way to test if it makes sense to exit an unsuccessful trade 
                                                                    is to analyse what happens with our turnaround strategy during the first 
                                                                    6 months and compare to future results. Bayesian probability theory is very 
                                                                    helpful here: Bayesian inference is a method of statistical inference 
                                                                    in which Bayes theorem is used to update the probability for a hypothesis 
                                                                    as more evidence or information becomes available'),br(),br(),
                            numericInput('sl','ENTER START RETURN TO TEST',value = 0)
                            
      ))
      )    
    
    
    ),
  mainPanel(
    tabsetPanel(
      id = 'dataset',
      
      tabPanel('RAW DATA',
               column(width= 12, DT::dataTableOutput('raw_data'))
      ),

      tabPanel('SEGMENTATION ANALYSIS',
               column(width= 6, br(), plotOutput('pie1')),
               column(width= 6, br(), plotOutput('pie3'),br()),
               column(width= 12, plotOutput('pie2'))
               ),
      
      tabPanel('INVESTMENT HORIZON ANALYSIS',
               column(width= 12, br(), plotOutput('bar1'),br()),
               column(width= 12, plotOutput('dens'))
      ),
      
      tabPanel('SECTOR ANALYSIS',
               column(width= 12, plotOutput('box'),br(),br()),
               column(width= 12, plotOutput('dot'))
      ),

      tabPanel('RISK-REWARD ANALYSIS',
               column(width= 12, br(),br(), plotOutput('rrw'))
      ),

      tabPanel('PROBABILITY',
               column(width= 12, br(),br(), DT::dataTableOutput('prob_ret'),br(),br()),
               column(width= 12, DT::dataTableOutput('prob_alpha'))
               )            
      
      
      )
    )
  ))