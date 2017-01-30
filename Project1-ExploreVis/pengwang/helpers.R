library(PerformanceAnalytics)
library(quantmod)
library(dygraphs)


fetch_data = function(stock_name, start_date, period = 'monthly'){
  raw_data = getSymbols(stock_name, src = 'yahoo', from = start_date, 
                        auto.assign = FALSE, warnings = FALSE) 
  return_data = periodReturn(raw_data, period = period, type = 'log')
  close_price_data = raw_data[,4, drop = F]
  return (list('return' = return_data, 'price' = close_price_data))
}


merge_data = function(fetched_1, fetched_2 ,fetched_3 ,fetched_4){
  merged_price_data = merge.xts(fetched_1$price, fetched_2$price ,
                                fetched_3$price, fetched_4$price)
  merged_return_data = merge.xts(fetched_1$return, fetched_2$return ,
                                 fetched_3$return, fetched_4$return)
  merged_data = list(price = merged_price_data, return = merged_return_data)
  return (merged_data)
}


