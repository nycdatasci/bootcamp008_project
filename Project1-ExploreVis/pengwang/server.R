library(PerformanceAnalytics)
library(quantmod)
library(dygraphs)
library(shinydashboard)

source('./helpers.R')

shinyServer(function(input, output){
  fetched_data = reactive({
    data_list = list()
    name_list = list(input$stock1, input$stock2, input$stock3, input$stock4)
    for (i in 1:4){
      data_list[[i]] = fetch_data(name_list[[i]], input$start_date, input$frequency)
      colnames(data_list[[i]]$return) = name_list[[i]]
    }
    data_list
  })
  
  output$plotI = renderDygraph(
   if (input$return){
     dygraph(merge_data(fetched_data()[[1]],fetched_data()[[2]],
                fetched_data()[[3]],fetched_data()[[4]])$return,
             main = 'Individual Returns') %>%
       dyRangeSelector(dateWindow = c("2016-01-01", "2017-01-01"))
   } else {
     dygraph(merge_data(fetched_data()[[1]],fetched_data()[[2]],
                fetched_data()[[3]],fetched_data()[[4]])$price,
             main = 'Individual Price') %>%
       dyRangeSelector(dateWindow = c("2016-01-01", "2017-01-01"))
   }
  )
  
  output$plotP = renderDygraph({
    merged = merge_data(fetched_data()[[1]],fetched_data()[[2]],
               fetched_data()[[3]],fetched_data()[[4]])
    weights = c(input$w1, input$w2, input$w3, input$w4)
    if (input$return){
      return (dygraph(Return.portfolio(merged$return, weights = weights),
                      main = 'Portfolio Returns') %>%
                dyRangeSelector(dateWindow = c("2016-01-01", "2017-01-01")))
    } else {
      return (dygraph(0.25 * (merged$price[,1,drop = F]*weights[1] + merged$price[,2,drop = F]*weights[2]
                      +merged$price[,3,drop = F]*weights[3] + merged$price[,4,drop = F]*weights[4]),
                      main = 'Portfolio Price') %>%
                dyRangeSelector(dateWindow = c("2016-01-01", "2017-01-01")))
    }
  })
  
  output$plotG = renderDygraph({
    merged = merge_data(fetched_data()[[1]],fetched_data()[[2]],
                        fetched_data()[[3]],fetched_data()[[4]])
    weights = c(input$w1, input$w2, input$w3, input$w4)
    return (dygraph(Return.portfolio(merged$return, weights = weights, wealth.index = T),
                    main = 'Portfolio Growth') %>%
                dyRangeSelector(dateWindow = c("2016-01-01", "2017-01-01")))
  })
  
  output$box1 = renderInfoBox({
    infoBox('Please Like!', subtitle = 'Click Here for Our Page!', icon = icon('handshake-o'),
            href = 'https://www.facebook.com/VeryDoge/')
    
  })
  
  output$box2 = renderInfoBox({
    infoBox('Please Let Us Know!', subtitle = 'Contact Us at fakeemail@gmail.com', 
            icon = icon('glyphicon glyphicon-envelope'))
  })
})

