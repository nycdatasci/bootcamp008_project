library(dplyr)
library(DT)
library(shinydashboard)
library(shiny)
library(leaflet)
library(googleVis)
library(ggplot2)
library(dplyr)
library(tidyr)
library(ggmap)

phx <- read.csv('phx.csv', check.names = FALSE)
restaurant <- read.csv('phx_resaturant.csv', check.names = FALSE)
dataset <- phx
iconSet <- iconList(red = makeIcon("hipster.svg", iconWidth = 30, iconHeight = 32), 
                    green = makeIcon("dollar-symbol.svg", iconWidth = 30, iconHeight = 32))

attri_col <- list('Hipster Ambience' = 'attributes.Ambience.hipster',
                  'Outdoor Seating' = 'attributes.Outdoor.Seating',
                  'Good for Group' = 'attributes.Good.For.Groups',
                  'Good for Kids' = 'attributes.Good.for.Kids',
                  'Credit Cards' = 'attributes.Accepts.Credit.Cards',
                  'Parking Garage' = 'attributes.Parking.garage',
                  'Price Range' = 'attributes.Price.Range',
                  'Divey' = 'attributes.Ambience.divey',
                  'Noise Level' = 'attributes.Noise.Level',
                  'TV' = 'attributes.Has.TV',
                  'Take Out' = 'attributes.Take.out',
                  'Review Count' = 'review_count')



hp_col <- list('Hipster VS. Noise Level' = 'attributes.Noise.Level',
               'Hipster VS. Group Food' = 'attributes.Good.For.Groups',
               'Hipster VS. Kids' = 'attributes.Good.for.Kids',
               'Hipster VS. Outdoor Seating' = 'attributes.Outdoor.Seating',
               'Hipster VS. Credit Cards' = 'attributes.Accepts.Credit.Cards',
               'Hipster VS. Divey' = 'attributes.Ambience.divey',
               'Hipster VS. Garage Parking' = 'attributes.Parking.garage',
               'Hipster VS. TV' = 'attributes.Has.TV')


mp_col <- list('Locate' = 'leaflet',
               'Density' = 'density')


hipster <- dataset %>%
  filter(attributes.Ambience.hipster == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(attributes.Ambience.hipster), stars = mean(stars)) %>%
  arrange(desc(total))


noise <- dataset %>%
  mutate(noisy = ifelse(attributes.Noise.Level =='loud' |
                          attributes.Noise.Level== 'very_loud', T, F)) %>% 
  filter(noisy == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(noisy), stars = mean(stars)) %>%
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

kids <- dataset %>%
  filter(attributes.Good.for.Kids == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(attributes.Good.for.Kids), stars = mean(stars)) %>%
  arrange(desc(total))

credit <- dataset %>%
  filter(attributes.Accepts.Credit.Cards == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(attributes.Accepts.Credit.Cards), stars = mean(stars)) %>%
  arrange(desc(total))


park.garage <- dataset %>%
  filter(attributes.Parking.garage == TRUE) %>%
  group_by(categories) %>%
  summarise(total = sum(attributes.Parking.garage), stars = mean(stars)) %>%
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
  group_by(categories) %>%
  summarise(total = sum(review_count), stars = mean(stars)) %>%
  arrange(desc(total))
  
  
data.list <- list( hipster, outseat, group, kids, 
                  credit, park.garage, price, divey, noise, 
                  tv,  takeout, reviews)


#==================================================================
# hipster VS. other attributes

summ = function(x) sum(x, na.rm=T)


# Hipster VS. noise
hipster.noise <- select(dataset, categories, 
                        attributes.Noise.Level, attributes.Ambience.hipster) %>% 
  mutate(noisy = ifelse(attributes.Noise.Level =='loud' |
                          attributes.Noise.Level== 'very_loud', T, F)) %>% 
  group_by(categories, attributes.Ambience.hipster) %>% 
  summarise(ratio = summ(noisy)/n()) %>%   
  arrange(desc(ratio))


hipster.noise <- hipster.noise[complete.cases(hipster.noise),] %>% 
  spread(key=attributes.Ambience.hipster,
         value=ratio) 


hipster.noise <- hipster.noise[complete.cases(hipster.noise),] %>% 
  gather(key= 'hipster', value='ratio', -categories) 


# Hipster VS. group

hipster.group <- select(dataset, categories, 
                        attributes.Good.For.Groups, attributes.Ambience.hipster) %>% 
  group_by(categories, attributes.Ambience.hipster) %>% 
  summarise(ratio = summ(attributes.Good.For.Groups)/n()) %>%   
  arrange(desc(ratio))


hipster.group <- hipster.group[complete.cases(hipster.group),] %>% 
  spread(key=attributes.Ambience.hipster,
         value=ratio) 


hipster.group <- hipster.group[complete.cases(hipster.group),] %>% 
  gather(key= 'hipster', value='ratio', -categories) 




# Hipster VS. seat
hipster.seat <- select(dataset, categories, 
                        attributes.Outdoor.Seating, attributes.Ambience.hipster) %>% 
  group_by(categories, attributes.Ambience.hipster) %>% 
  summarise(ratio = summ(attributes.Outdoor.Seating)/n()) %>%   
  arrange(desc(ratio))


hipster.seat <- hipster.seat[complete.cases(hipster.seat),] %>% 
  spread(key=attributes.Ambience.hipster,
         value=ratio) 


hipster.seat <- hipster.seat[complete.cases(hipster.seat),] %>% 
  gather(key= 'hipster', value='ratio', -categories) 


# Hipster VS. Garage Parking
hipster.gpark <- select(dataset, categories, 
                       attributes.Parking.garage, attributes.Ambience.hipster) %>% 
  group_by(categories, attributes.Ambience.hipster) %>% 
  summarise(ratio = summ(attributes.Parking.garage)/n()) %>%   
  arrange(desc(ratio))


hipster.gpark <- hipster.gpark[complete.cases(hipster.gpark),] %>% 
  spread(key=attributes.Ambience.hipster,
         value=ratio) 


hipster.gpark <- hipster.gpark[complete.cases(hipster.gpark),] %>% 
  gather(key= 'hipster', value='ratio', -categories) 


# Hipster VS. Kids
hipster.kids <- select(dataset, categories, 
                        attributes.Good.for.Kids, attributes.Ambience.hipster) %>% 
  group_by(categories, attributes.Ambience.hipster) %>% 
  summarise(ratio = summ(attributes.Good.for.Kids)/n()) %>%   
  arrange(desc(ratio))


hipster.kids <- hipster.kids[complete.cases(hipster.kids),] %>% 
  spread(key=attributes.Ambience.hipster,
         value=ratio) 


hipster.kids <- hipster.kids[complete.cases(hipster.kids),] %>% 
  gather(key= 'hipster', value='ratio', -categories) 

# Hipster VS. credit
hipster.credit <- select(dataset, categories, 
                         attributes.Accepts.Credit.Cards, attributes.Ambience.hipster) %>% 
  group_by(categories, attributes.Ambience.hipster) %>% 
  summarise(ratio = summ(attributes.Accepts.Credit.Cards)/n()) %>%   
  arrange(desc(ratio))


hipster.credit <- hipster.credit[complete.cases(hipster.credit),] %>% 
  spread(key=attributes.Ambience.hipster,
         value=ratio) 


hipster.credit <- hipster.credit[complete.cases(hipster.credit),] %>% 
  gather(key= 'hipster', value='ratio', -categories) 


# Hipster VS. Divey
hipster.divey <- select(dataset, categories, 
                        attributes.Ambience.divey, attributes.Ambience.hipster) %>% 
  group_by(categories, attributes.Ambience.hipster) %>% 
  summarise(ratio = summ(attributes.Ambience.divey)/n()) %>%   
  arrange(desc(ratio))


hipster.divey <- hipster.divey[complete.cases(hipster.divey),] %>% 
  spread(key=attributes.Ambience.hipster,
         value=ratio) 


hipster.divey <- hipster.divey[complete.cases(hipster.divey),] %>% 
  gather(key= 'hipster', value='ratio', -categories) 



# Hipster VS. TV


hipster.tv <- select(dataset, categories, 
                     attributes.Has.TV, attributes.Ambience.hipster) %>% 
  group_by(categories, attributes.Ambience.hipster) %>% 
  summarise(ratio = summ(attributes.Has.TV)/n()) %>%   
  arrange(desc(ratio))

hipster.tv <- hipster.tv[complete.cases(hipster.tv),] %>% 
  spread(key=attributes.Ambience.hipster,
         value=ratio) 


hipster.tv <- hipster.tv[complete.cases(hipster.tv),] %>% 
  gather(key= 'hipster', value='ratio', -categories) 



# Hipster VS. Price
hipster.price <- select(dataset, categories, 
                        attributes.Price.Range, attributes.Ambience.hipster) %>% 
  group_by(categories, attributes.Ambience.hipster) %>% 
  summarise(ratio = summ(attributes.Price.Range)/n()) %>%   
  arrange(desc(ratio))

hipster.price <- hipster.price[complete.cases(hipster.price),] %>% 
  spread(key=attributes.Ambience.hipster,
         value=ratio) 


hipster.price <- hipster.price[complete.cases(hipster.price),] %>% 
  gather(key= 'hipster', value='ratio', -categories) 


# Hipster VS. Take Out
hipster.takeout <- select(dataset, categories, 
                          attributes.Take.out, attributes.Ambience.hipster) %>% 
  group_by(categories, attributes.Ambience.hipster) %>% 
  summarise(ratio = summ(attributes.Take.out)/n()) %>%   
  arrange(desc(ratio))

hipster.takeout <- hipster.takeout[complete.cases(hipster.takeout),] %>% 
  spread(key=attributes.Ambience.hipster,
         value=ratio) 


hipster.takeout <- hipster.takeout[complete.cases(hipster.takeout),] %>% 
  gather(key= 'hipster', value='ratio', -categories) 




hp.list <- list(hipster.noise,hipster.group, hipster.seat, hipster.credit,
                hipster.divey, hipster.tv, hipster.price, hipster.takeout)


## summary table
summ = function(x) sum(x, na.rm=T)
price = function(x) mean(x, na.rm = T)

summ <- dataset %>%
  group_by(categories) %>%
  summarise(reviews = sum(review_count),
            stars = format(mean(stars), digits=2, nsmall=2),
            hipster = summ(attributes.Ambience.hipster),
            divey = summ(attributes.Ambience.divey),
            credit= summ(attributes.Accepts.Credit.Cards),
            seat = summ(attributes.Outdoor.Seating),
            tv = summ(attributes.Has.TV),
            price = round(price(attributes.Price.Range)),
            takeout = summ(attributes.Take.out),
            parking.garage = summ(attributes.Parking.garage),
            kids = summ(attributes.Good.for.Kids),
            group = summ(attributes.Good.For.Groups)
  ) %>%
  arrange(desc(reviews))


## data overview table
overview <- head(dataset, 30) %>% select(review_count,
                                         stars,
                                         'credit' = attributes.Accepts.Credit.Cards,
                                         'divey' = attributes.Ambience.divey,
                                         'hipster' = attributes.Ambience.hipster,
                                         'groups' = attributes.Good.For.Groups,
                                         'kids' = attributes.Good.for.Kids,
                                         'TV' = attributes.Has.TV,
                                         'noise' = attributes.Noise.Level,
                                         'seating' = attributes.Outdoor.Seating,
                                         'parking' = attributes.Parking.lot,
                                         'price' = attributes.Price.Range,
                                         'takeout' = attributes.Take.out
) 