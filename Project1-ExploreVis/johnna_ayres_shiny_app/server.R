library(shiny)
library(googleVis)
library(dplyr)


states_party <- (read.csv("data/states_party_strength2.csv"))

states_party_temp <- states_party %>% 
  group_by(year) %>% 
  summarise(h.D.sum = sum(h.D.num), 
            h.R.sum = sum(H.R.num), 
            senate.D.sum = sum(senate.D.num), 
            senate.R.sum = sum(senate.R.num)) 

states_party_smy <- states_party_temp %>%
  mutate(prev = year - 2) %>%
  select(year, prev, h.D.sum, h.R.sum, senate.D.sum, senate.R.sum) %>%
  inner_join(states_party_temp %>% 
               select(year, h.D.sum, h.R.sum, senate.D.sum, senate.R.sum) %>%
               rename(prev = year,
                      prev.h.D = h.D.sum, 
                      prev.h.R = h.R.sum, 
                      prev.s.D = senate.D.sum, 
                      prev.s.R = senate.R.sum )) %>%
  mutate(h.D.diff = h.D.sum - prev.h.D,
         h.R.diff = h.R.sum - prev.h.R,
         sen.D.diff = senate.D.sum - prev.s.D,
         sen.R.diff = senate.R.sum - prev.s.R) %>%
  mutate(year = as.character(year))

states_party <- states_party %>% 
  mutate(H.to.D = h.D.num / (h.D.num + H.R.num),
         H.to.R = H.R.num / (h.D.num + H.R.num)) %>%
  
  mutate(S.to.D = senate.D.num / (senate.D.num + senate.R.num),
         S.to.R = senate.R.num / (senate.D.num + senate.R.num))


shinyServer(function(input, output) {
  
  state_party <- reactive({
    year <- as.integer(input$president) + 2*input$mid_term
    year <- ifelse(year > 2016, 2016, year)
    states_party<- states_party %>%
      filter(year ==  year)
  })
  
    output$map1 <- renderGvis({
      s.map <- gvisGeoChart(state_party(),
                       locationvar = "state",
                       colorvar = "S.to.D",
                       options=list(region="US", displayMode="regions",
                                    title = "Republican to Democrat",
                                    resolution="provinces",
                                    colorAxis="{colors:['#E74C3C','#FFFFFF','#2E86C1']}",
                                    defaultColor="#ECF0F1",
                                    width=500, height=300))
      s.chart <- gvisBarChart(states_party_smy %>% 
                                filter(year == as.character(as.integer(input$president) + 2)), xvar = "year", 
                              yvar = c("sen.D.diff", "sen.R.diff"),
                              options = list(title = "Party Strength: Change in Senate seats at Mid-Terms",
                                             width=500,
                                             legend="top"))
      gvisMerge(s.map, s.chart, horizontal = TRUE )
    })
    
    output$map2 <- renderGvis({
        h.map <- gvisGeoChart(state_party(),
                             locationvar = "state",
                             colorvar = "H.to.D",
                             options=list(region="US", displayMode="regions",
                                          title = "Republican to Democrat",
                                          resolution="provinces",
                                          colorAxis="{colors:['#E74C3C','#FFFFFF','#2E86C1']}",
                                          defaultColor="#ECF0F1",
                                          width=500, height=300))
        h.chart <- gvisBarChart(states_party_smy %>% 
                                  filter(year == as.character(as.integer(input$president) +2)), xvar = "year", 
                                yvar = c("h.D.diff", "h.R.diff"),
                                options = list(title = "Party Strength: Change in House seats at Mid-Terms",
                                               width=500,
                                               legend="top"))
        gvisMerge(h.map, h.chart, horizontal = TRUE )
    })

   # output$bar3 <- renderGvis({
   #   
   #   h.chart <- gvisBarChart(states_party_smy %>% filter(year == "1982"), xvar = "year", 
   #                           yvar = c("h.D.diff", "h.R.diff"),
   #                           options = list(width=300))
   #   gvisMerge(h.chart, s.chart, horizontal = FALSE )
   # })
    
})
  
  

