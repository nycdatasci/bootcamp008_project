library(ggplot2)
library(dplyr)

#UNUSED IN SCRIPTS
#  cou <- c('ECA', 'AME')
#  selected_regions = unlist(sapply(cou, get))
#  len_vec <- sapply(cou, function(x){length(get(x))})
#  Temp_regions <- c()
#  for(i in cou){
#      Temp_regions <- c(Temp_regions,rep(i, each=length(get(i))))
#  }
#  Temp_countries <-  unlist(sapply(cou, get))
#  Temp_regions <- data.frame(Temp_regions,Temp_countries)
#  names(Temp_regions) <- c('Import_Region','names')
#  
#  to_map <- map("world", fill = TRUE, plot = FALSE, region = selected_regions)
#  map_value <- filter(bilateral_trade, Export_Country == 'FRA', Year == 2009) %>%
#               select(Import_Region, Vol_wine_exports_region) %>%
#               inner_join(Temp_regions) %>%
#               select(Vol_wine_exports_region, names)

#  output$mymap <- renderLeaflet({
#    pal <- colorNumeric(palette = 'YlOrRd', domain=map_value$Vol_wine_exports_region)
#    binpal <- colorBin("Blues", map_value$Vol_wine_exports_region, 2, pretty = FALSE)
#    factpal <- colorFactor(topo.colors(2), map_value$Vol_wine_exports_region)
#    leaflet() %>%
#      addProviderTiles("OpenStreetMap.HOT") %>%
#      setView(lat = 32.920611, lng = -40.590431, zoom = 1) %>%
#      addPolygons(data=to_map, stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5
#                  color= ~factpal(map_value$Vol_wine_exports_region)
#                  color= ~pal(map_value$Vol_wine_exports_region)
#                  color= ~binpal(map_value$Vol_wine_exports_region)
#                  )
#  })


#col_names = c(`Total grapevine area, 000 ha`, 
#              `Volume of wine exports, ML`, 
#              `Volume of wine production, ML`, 
#              `Volume of wine consumption, ML`, 
#              `Volume of wine consumption per capita, litres`, 
#              `Volume of wine imports, ML`, 
#              `Volume of wine net imports, ML`, 
#              `Value of wine exports, US$ million`,
#              `Value of wine imports, US$ million`, 
#              `Total alcohol consumption per capita (litres of alcohol)`,
#              `Adult population (millions)`, 
#              `GDP per capita, US$ current`, 
#              `GDP, US$ current`)

setwd("~/Desktop/Wine_trade_datasets/Final_Data")
growth_data <- readRDS('1960-2009_data.rds')
inputyears = 1960 
growth_data <- filter(growth_data, FiveYearRange == (paste0(inputyears,'-',inputyears+4)))

bilat <- bilateral_trade %>%
         filter(Export_Country == 'USA')

g <- ggplot(data=bilat, aes_string(y = 'Value_wine_exports_region', x = 'Year')) + 
     geom_bar(stat = "identity", aes(fill = Import_Region))
g

# %>%
#  filter(`5_Year_Range` == '1960-1964') %>%
#  filter(Country == 'France'|Country == 'Italy'|Country =='Spain')
#  filter(Region == 'WEM'| Region == 'APA')
  group_by(Region) %>%
  summarize(`Total grapevine area, 000 ha` = sum(`Total grapevine area, 000 ha`), 
              `Volume of wine exports, ML` = sum(`Volume of wine exports, ML`))

g <- ggplot(data = growth_data, aes(x =`Total grapevine area, 000 ha` , y = `Volume of wine exports, ML`)) +
     geom_point(aes(color = Country)) + 
     geom_text(aes(label=Region),hjust=0.5, vjust=1.5, size = 2.5)
g

group_by(Region) %>%
  summarize(`Total grapevine area, 000 ha` = sum(`Total grapevine area, 000 ha`), 
            `Volume of wine exports, ML` = sum(`Volume of wine exports, ML`))

g <- ggplot(data = bilateral_trade, aes(x =`Total grapevine area, 000 ha` , y = `Volume of wine exports, ML`)) +
  geom_bar(aes(color = Country)) + 
  geom_text(aes(label=Region),hjust=0.5, vjust=1.5, size = 2.5)
g


