library(googleVis)

rm(list = ls())
setwd("~/johnnaayres.github.io/Project 1/shiny_app/")

states_party <- read.csv("data/states_party_strength2.csv")

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



h.chart <- gvisBarChart(states_party_smy %>% filter(year == "1982"), xvar = "year", 
                           yvar = c("h.D.diff", "h.R.diff"),
                           options = list(width="auto", height=300))
s.chart <- gvisBarChart(states_party_smy %>% filter(year == "1982"), xvar = "year", 
                           yvar = c("sen.D.diff", "sen.R.diff"),
                           options = list(width="auto", height=300))

m.chart <- gvisMerge(h.chart, s.chart, horizontal = FALSE )
plot(m.chart)

