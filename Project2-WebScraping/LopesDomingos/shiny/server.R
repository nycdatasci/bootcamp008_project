library(shiny)
library(leaflet)
library(leaflet.extras)
library(dplyr)

companies_locations <- read.csv('data/company_job_locations.csv')
companies_locations <- companies_locations %>%
  select(company, latitude, longitude) %>%
  group_by(company, latitude, longitude) %>%
  summarize(quantity = n())

aggregator_locations <- read.csv('data/aggregator_job_locations.csv')
aggregator_locations$date_posted <- as.Date(aggregator_locations$date_posted)
max_date <- max(aggregator_locations$date_posted)
aggregator_locations['week'] = trunc((max_date - aggregator_locations$date_posted) / 7)
aggregator_locations <- aggregator_locations %>%
  group_by(week, latitude, longitude) %>%
  summarize(quantity = n()) %>% ungroup()

col_names = c('A', 'B', 'C', 'D', 'E', 'F')
locations_index <- unique(aggregator_locations[c('latitude', 'longitude')])
locations_index[3] = 0
colnames(locations_index)[3] = col_names[1]
for(i in 1:5) {
  locations_index <- locations_index %>%
    left_join(aggregator_locations %>% filter(week == i - 1) %>%
                select(longitude, latitude, quantity),
              by = c('longitude', 'latitude'))
  col = col_names[i+1]
  colnames(locations_index)[3+i] = col
  locations_index[col] <- replace(locations_index[col],
                                    which(is.na(locations_index[col]),
                                          arr.ind = T), 0)
  locations_index[col] <- locations_index[col] + locations_index[col_names[i]]
}

shinyServer(function(input, output, session) {
  
  
  
  output$companiesMap = renderLeaflet({
    leaflet(companies_locations) %>% addTiles() %>% setView(-95, 37, 4)# %>%
  })
  
  observeEvent(input$companies_refresh, {
    locations <- companies_locations %>% filter(company %in% input$companiesGroup) %>%
      group_by(latitude, longitude) %>% summarize(quantity = sum(quantity))
    leafletProxy('companiesMap', session, data = locations) %>%
      clearHeatmap() %>%
      addWebGLHeatmap(lng = ~longitude, lat = ~latitude, intensity = ~quantity,
                      size = 40000, opacity = 0.8, layerId = 'heat',
                      alphaRange = 0.1)})
  
  output$aggregatorsMap = renderLeaflet({
    leaflet() %>% addTiles() %>% setView(-95, 37, 4)
  })
  
  observeEvent(input$date_slider, {observeEvent(input$size_slider, {
    locations <- locations_index %>%
      select(longitude, latitude)
    locations['quantity'] = locations_index[col_names[input$date_slider[2]+1]] -
      locations_index[col_names[input$date_slider[1]+1]]
    leafletProxy('aggregatorsMap', session, data = locations) %>%
      clearHeatmap() %>%
      addWebGLHeatmap(lng = ~longitude, lat = ~latitude, intensity = ~quantity,
                      size = input$size_slider, opacity = 0.8, layerId = 'heat',
                      alphaRange = 0.1)})})
})