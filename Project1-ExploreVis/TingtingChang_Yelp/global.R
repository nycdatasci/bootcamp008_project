library(dplyr)
library(DT)
library(shinydashboard)
library(shiny)
library(leaflet)
library(googleVis)
library(ggplot2)

phx <- read.csv('phx.csv', check.names = FALSE)
restaurant <- read.csv('phx_resaturant.csv', check.names = FALSE)
dataset <- phx
iconSet <- iconList(red = makeIcon("hipster.svg", iconWidth = 30, iconHeight = 32), 
                    green = makeIcon("dollar-symbol.svg", iconWidth = 30, iconHeight = 32))

attri_col <- list('Hipster Ambience' = 'attributes.Ambience.hipster',
                  'Outdoor Seating' = 'attributes.Outdoor.Seating',
                  'Good for Group' = 'attributes.Good.For.Groups',
                  'Credit Cards' = 'attributes.Accepts.Credit.Cards',
                  'Divey' = 'attributes.Ambience.divey',
                  'TV' = 'attributes.Has.TV',
                  'Take Out' = 'attributes.Take.out',
                  'Review Count' = 'review_count')

hp_col <- list('Hipster VS. Noise Level' = 'attributes.Noise.Level',
               'Hipster VS. Group Food' = 'attributes.Good.For.Groups',
               'Hipster VS. Outdoor Seating' = 'attributes.Outdoor.Seating',
               'Hipster VS. Credit Cards' = 'attributes.Accepts.Credit.Cards',
               'Hipster VS. Divey' = 'attributes.Ambience.divey',
               'Hipster VS. TV' = 'attributes.Has.TV',
               'Hipster VS. Price' = 'attributes.Price.Range',
               'Hipster VS. Take Out' = 'attributes.Take.out',
               'Hipster VS. Reviews' = 'review_count')


mp_col <- list('Locate' = 'leaflet',
               'Density' = 'density')


hipster <- dataset %>%
  filter(attributes.Ambience.hipster == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(attributes.Ambience.hipster), stars = mean(stars)) %>%
  arrange(desc(total))



outseat <- dataset %>%
  filter(attributes.Outdoor.Seating == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(attributes.Outdoor.Seating), stars = mean(stars)) %>%
  arrange(desc(total))

group <- dataset %>%
  filter(attributes.Good.For.Groups == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(attributes.Good.For.Groups), stars = mean(stars)) %>%
  arrange(desc(total))

credit <- dataset %>%
  filter(attributes.Accepts.Credit.Cards == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(attributes.Accepts.Credit.Cards), stars = mean(stars)) %>%
  arrange(desc(total))

divey <- dataset %>%
  filter(attributes.Ambience.divey == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(attributes.Ambience.divey), stars = mean(stars)) %>%
  arrange(desc(total))

tv <- dataset %>%
  filter(attributes.Has.TV == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(attributes.Has.TV), stars = mean(stars)) %>%
  arrange(desc(total))
  

takeout <- dataset %>%
  filter(attributes.Take.out == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(attributes.Take.out), stars = mean(stars)) %>%
  arrange(desc(total))
  
price <- dataset %>%
  filter(attributes.Price.Range == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(attributes.Price.Range), stars = mean(stars)) %>%
  arrange(desc(total))
  
  
reviews <- dataset %>%
  filter(review_count == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(review_count), stars = mean(stars)) %>%
  arrange(desc(total))
  
  
data.list <- list(hipster, outseat, group, credit, divey, tv, price, takeout, reviews)


hipster.noise <- dataset %>%
  filter(attributes.Ambience.hipster == TRUE) %>%
  group_by(categories, attributes.Noise.Level) %>%
  summarise(total = sum(attributes.Ambience.hipster)) %>%
  arrange(desc(total))


hipster.group <- dataset %>%
  filter(attributes.Ambience.hipster == TRUE) %>%
  group_by(categories, attributes.Good.For.Groups) %>%
  summarise(total = sum(attributes.Ambience.hipster)) %>%
  arrange(desc(total))


hipster.seat <- dataset %>%
  filter(attributes.Ambience.hipster == TRUE) %>%
  group_by(categories, attributes.Outdoor.Seating) %>%
  summarise(total = sum(attributes.Ambience.hipster)) %>%
  arrange(desc(total))

hipster.credit <- dataset %>%
  filter(attributes.Ambience.hipster == TRUE) %>%
  group_by(categories, attributes.Accepts.Credit.Cards) %>%
  summarise(total = sum(attributes.Ambience.hipster)) %>%
  arrange(desc(total))

hipster.divey <- dataset %>%
  filter(attributes.Ambience.hipster == TRUE) %>%
  group_by(categories, attributes.Ambience.divey) %>%
  summarise(total = sum(attributes.Ambience.hipster)) %>%
  arrange(desc(total))

hipster.tv <- dataset %>%
  filter(attributes.Ambience.hipster == TRUE) %>%
  group_by(categories, attributes.Has.TV) %>%
  summarise(total = sum(attributes.Ambience.hipster)) %>%
  arrange(desc(total))

hipster.price <- dataset %>%
  filter(attributes.Ambience.hipster == TRUE) %>%
  group_by(categories, attributes.Price.Range) %>%
  summarise(total = sum(attributes.Ambience.hipster)) %>%
  arrange(desc(total))

hipster.takeout <- dataset %>%
  filter(attributes.Ambience.hipster == TRUE) %>%
  group_by(categories, attributes.Take.out) %>%
  summarise(total = sum(attributes.Ambience.hipster)) %>%
  arrange(desc(total))

hipster.reviews <- dataset %>%
  filter(attributes.Ambience.hipster == TRUE) %>%
  group_by(categories, review_count) %>%
  summarise(total = sum(attributes.Ambience.hipster)) %>%
  arrange(desc(total))

hp.list <- list(hipster.noise,hipster.group, hipster.seat, hipster.credit,
                hipster.divey, hipster.tv, hipster.price, hipster.takeout,
                hipster.reviews)

summ = function(x) sum(x, na.rm=T)
price = function(x) mean(x, na.rm = T)

summ <- dataset %>%
  group_by(categories) %>%
  summarise(reviews = sum(review_count),
            stars = format(mean(stars), digits=2, nsmall=2),
            hipster = summ(attributes.Ambience.hipster),
            divey = summ(attributes.Ambience.divey),
            credit= summ(attributes.Accepts.Credit.Cards),
            divey = summ(attributes.Ambience.divey),
            tv = summ(attributes.Has.TV),
            price = round(price(attributes.Price.Range)),
            takeout = summ(attributes.Take.out)
  ) %>%
  arrange(desc(reviews))






